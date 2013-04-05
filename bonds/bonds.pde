import toxi.processing.*;
import processing.opengl.*;
import toxi.math.conversion.*;
import toxi.geom.*;
import toxi.math.*;
import toxi.geom.mesh2d.*;
import toxi.util.datatypes.*;
import toxi.util.events.*;
import toxi.geom.mesh.subdiv.*;
import toxi.geom.mesh.*;
import toxi.math.waves.*;
import toxi.util.*;
import toxi.math.noise.*;
import toxi.physics.*;
import toxi.physics.behaviors.*;
import toxi.physics.constraints.*;
import peasy.*;
import controlP5.*;
import java.nio.FloatBuffer;
import java.util.Collections;
import java.util.List; 
import processing.pdf.*;

PeasyCam cam;
ToxiclibsSupport gfx;
SensibleMesh smesh;
ArrayList <Nodo> nodos;
ArrayList <Nodo> nodosParaDestruir;
ListaRelaciones relaciones;

// Variables simulación
VerletPhysics fisica;
ControlP5 ui;
Face faceOver = null;
int RCENTRO = 30;
int RNODO = 3;
boolean meshFill = false;
boolean particulas = true;
boolean edit = false;
float drag = 0.75;
float reboteEntreNodos = 1;
float rugosidad = 1.25;
float amin = 10000;
int estado;
boolean doSave;

int numMax = 10;
int cuentaNodos = 0;



/***************************
* MAIN :: setup()
*
*******/

void setup() {
  size(1000, 600, OPENGL);

  //// 
  // Inicializamos UI
  //
  
  gfx = new ToxiclibsSupport(this);  
  ui = new ControlP5(this);
  
  ui.addButton("initSimulation").setPosition(10, 10);
  ui.addButton("compacta").setPosition(10, 70);  
  ui.addToggle("particulas").setPosition(10, 110);
  ui.addToggle("edit").setPosition(10, 170);
  ui.addSlider("drag", 0, 1).setPosition(100, 10);
  ui.addSlider("rugosidad", 0, 2).setPosition(300, 10);
  ui.addSlider("reboteEntreNodos", 0, 1).setPosition(410, 10);  
  ui.addSlider("numMax", 0, 600).setPosition(570, 10);
  ui.addSlider("RNODO", 0, 40).setPosition(730, 10);
 
  //// 
  // Inicializamos mesh a partir de un archivo STL
  //
  
  WETriangleMesh meshIni = (WETriangleMesh) new STLReader().loadBinary(dataPath("bunnyrhino2.stl"), STLReader.WEMESH);
  meshIni.scale(2);  
  WETriangleMesh mesh = new WETriangleMesh();
  
  //// Calculamos el área mínima
  for (Face f : meshIni.faces) {
    float asq = areaSq(f.a, f.b, f.c);
    if (asq < amin && asq > 1000) {
      amin = asq;
    }
  }
  println("--- Area mínima: " + amin);
  
  //// Subdividimos aquellas caras cuya área sea mayor que el doble de amin
  for (Face f : meshIni.faces) {
    float asq = areaSq(f.a, f.b, f.c);
    int n = floor(asq/amin);
    if (n > 1) {
      subdivide(f.a, f.b, f.c, n, mesh);
    }
    else {
      mesh.addFace(f.a, f.b, f.c);
    }
  }
  
  //// Transformaciones adicionales
  //for (int n = 0; n < 1; n++) mesh.subdivide();
  //LaplacianSmooth lps = new LaplacianSmooth();
  //lps.filter(mesh, 1);
  mesh.center(new Vec3D());  
  
  //// Inicializamos el objeto smesh con VBO
  smesh = new SensibleMesh(mesh);
  smesh.computeFaceNormals();
  smesh.faceOutwards();  
  smesh.computeVertexNormals();
    
  //// 
  // Inicializamos la simulación
  //
  
  initSimulation(0);

  //// 
  // Inicializamos la cámara
  //
  
  cam = new PeasyCam(this, 1000);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(1500);  
  cam.setResetOnDoubleClick(false);
}





/***************************
* MAIN :: initSimulation()
* Subdivide una cara si su área es mayor que un valor,
* y añade la cara a la mesh
*******/

void initSimulation(int value) {
  fisica = new VerletPhysics();
  fisica.setWorldBounds(new AABB(new Vec3D(0, 0, 0), new Vec3D(width, height, width)));  
  fisica.setDrag(drag);
  nodos = new ArrayList();
  
  int cuenta = 0;
  ArrayList <WEFace> faces = new ArrayList();
    
  nodosParaDestruir = new ArrayList();
  relaciones = new ListaRelaciones();  
}




/***************************
* MAIN :: initSimulation()
* Subdivide una cara si su área es mayor que un valor,
* y añade la cara a la mesh
*******/

void compacta(int value) {
//  estado = 1;
  for (Nodo n : nodos) {
    n.estado = 1;
  }
}



/***************************
* MAIN :: draw()
*
*******/

void draw() {
  
  ////
  // Añadimos partículas a la simulación en caso de que
  // estemos por debajo de numMax
  //
  
  if (nodos.size() < numMax && frameCount%1 == 0 && estado == 0) {
    WEVertex we = null;
    int r = floor(random(smesh.vertices.size()));
    we = smesh.getVertexForID(r);
     
    Nodo nodo = new Nodo(cuentaNodos, this, we);
    cuentaNodos++;
    
    nodos.add(nodo);
  }
  
  ////
  // Destruimos las partículas señaladas con weight = 10
  //
  
  nodosParaDestruir.clear();
  for (Nodo n : nodos) {
    if (n.getWeight() == 10) {
      nodosParaDestruir.add(n);
    }
  }
  for (Nodo n : nodosParaDestruir) {
    for (Nodo m : nodos) {
      VerletSpring spr = fisica.getSpring(n, m);
      fisica.removeSpring(spr);
    }
    fisica.removeParticle(n);
    nodos.remove(n);
  }
  
  ////
  // Fondo y luces espacio 3D
  //  
  
  background(255);
  ambientLight(200, 200, 200);
  directionalLight(128, 128, 128, 0, 0, -1);
  lightFalloff(1, 0, 0); 
  lightSpecular(0, 0, 0);

  ////
  // Actualizamos simulación
  //  
  
  fisica.update();
  
  // detección de colisiones y dibujo de nodos
  for (Nodo n : nodos) {
    n.colisiones();
    n.draw();
    n.colision = false;    
  }
  
  // cálculo de estructura
  for (Relacion r : relaciones.relaciones) {
    r.update();
    r.draw();
  }  
  

  ////
  // Mostramos la superficie interactiva
  //  
  
  if (smesh != null) {
    smesh.draw();
  }

  // Edit mode
  if (edit) {
    for (Face f : smesh.faces) {
      Triangle2D t = new Triangle2D(new Vec2D(screenX(f.a.x, f.a.y, f.a.z), screenY(f.a.x, f.a.y, f.a.z)), 
      new Vec2D(screenX(f.b.x, f.b.y, f.b.z), screenY(f.b.x, f.b.y, f.b.z)),
      new Vec2D(screenX(f.c.x, f.c.y, f.c.z), screenY(f.c.x, f.c.y, f.c.z)));
      if (t.containsPoint(new Vec2D(mouseX, mouseY))) {
        fill(255,0,0);
        gfx.triangle(f.toTriangle());
        faceOver = f;
      }
    }
  } 


  ////
  // Controles UI
  // 
  
  cam.beginHUD();
  lights();
  textAlign(RIGHT);
  fill(50);
  text(frameRate, width-10, height-10);
  ui.draw();
  cam.endHUD();
   
  
  if (doSave) saveFrame("masta-single-####");
  doSave = false;
}


/***************************
* EVENTS :: mouseReleased()
* Only in edit mode
*******/

void mouseReleased() {
  if (edit) {
    if (faceOver != null) nodos.add(new Nodo(cuentaNodos, this, faceOver.getCentroid()));
  }
}


/***************************
* EVENTS :: keyReleased()
*
*******/

void keyReleased() {
  if (key == 'n') {
    numMax += 10;
  }
  else if (key == 'e') {
    relaciones.export();   
  }
  else if (key == 'm') {
   // mesh = relaciones.exportToMesh();
  }
  else if (key == 'p') {
    doSave = true;
  }
}

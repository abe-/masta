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
import java.awt.event.*;
//import codeanticode.gsvideo.*;

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
float zoom = 1;

// MovieMaker
// GSMovieMaker mm;
// int fps = 25;

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
  ui.setAutoDraw(false);
  
  ui.addButton("openFile").setPosition(10, 10);
  
  ui.addButton("initSimulation").setPosition(110, 10);
  ui.addButton("compacta").setPosition(110, 35);  
  
  ui.addSlider("numMax", 0, 600).setPosition(200, 10).setColorLabel(50);
  ui.addSlider("RNODO", 0, 40).setPosition(200, 30).setColorLabel(50);
  ui.addSlider("reboteEntreNodos", 0, 1).setPosition(200, 50).setColorLabel(50);  
  ui.addSlider("drag", 0, 1).setPosition(200, 70).setColorLabel(50);
  ui.addSlider("rugosidad", 0, 2).setPosition(200, 90).setColorLabel(50);  
  
  ui.addToggle("particulas").setPosition(410, 10).setWidth(20).setColorLabel(50);
  ui.addToggle("edit").setPosition(510, 10).setWidth(20).setColorLabel(50);
 

  //// 
  // Inicializamos la superficie con el mesh por defecto
  //
  initMesh(dataPath("bunnyrhino.stl"));

  //// 
  // Inicializamos la cámara
  //
  
  cam = new PeasyCam(this, 1000);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(1500);  
  cam.setResetOnDoubleClick(false);
  
  // PeasyCam has problems with 2.0b8:
  addMouseWheelListener(new MouseWheelListener() { 
    public void mouseWheelMoved(MouseWheelEvent mwe) { 
      mouseWheel(mwe.getWheelRotation());
  }});  
  
  // MovieMaker
  // mm = new GSMovieMaker(this, width, height, "bunnyrhino-with-masta.ogg", GSMovieMaker.THEORA, GSMovieMaker.HIGH, fps);
  // mm.setQueueSize(50, 10);
  // mm.start();
}


/***************************
* MAIN :: initMesh(fileName)
* 
*******/
void initMesh(String fileName) {
  //// 
  // Inicializamos mesh a partir de un archivo STL
  //
  
  WETriangleMesh meshIni = (WETriangleMesh) new STLReader().loadBinary(fileName, STLReader.WEMESH);
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
* MAIN :: compacta()
* 
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
  
  if (nodos != null && nodos.size() < numMax && frameCount%1 == 0 && estado == 0) {
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
  
  if (nodos != null) {
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
  }
  
  ////
  // Fondo, zoom y luces espacio 3D
  //  
  
  background(255);
  ambientLight(200, 200, 200);
  directionalLight(128, 128, 128, 0, 0, -1);
  lightFalloff(1, 0, 0); 
  lightSpecular(0, 0, 0);
  pushMatrix();
  scale(zoom, zoom, zoom);

  ////
  // Actualizamos simulación
  //  
  
  if (fisica != null) fisica.update();
  
  
  // detección de colisiones y dibujo de nodos
  if (nodos != null) {
    for (Nodo n : nodos) {
      n.colisiones();
      n.draw();
      n.colision = false;    
    }
  }
  
  // cálculo de estructura
  if (relaciones != null) {
    for (Relacion r : relaciones.relaciones) {
      r.update();
      r.draw();
    }
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

  popMatrix();

  ////
  // Controles UI
  // 
  
  cam.beginHUD();
  noLights();
  ui.draw();
  textAlign(RIGHT);
  fill(50);
  text(frameRate, width-10, 15);  
  cam.endHUD();
   
  
  if (doSave) saveFrame("masta-single-####");
  doSave = false;
  
  // MovieMaker - Add window's pixels to movie
  // loadPixels();
  // mm.addFrame(pixels);  
}


/***************************
* UTILS :: openFile()
*******/

void openFile() {
  selectInput("Select a STL file to process:", "processFile");
}

void processFile(File selection) {
  if (selection != null) {
    println(selection.getAbsolutePath());
    initMesh(selection.getAbsolutePath());
  }
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
* EVENTS :: mouseWheel(delta)
* Only in edit mode
*******/
void mouseWheel(int delta) {
  zoom -= delta * 0.1;
  zoom = constrain(zoom, 0.1, 10); 
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


/***************************
* STOP
*
*******/
void stop() {
  // MovieMaker
  // mm.finish();
  super.stop();
}

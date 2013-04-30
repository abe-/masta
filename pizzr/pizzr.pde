import processing.opengl.*;
import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.math.noise.*;
import toxi.volume.*;
import toxi.util.*;
import toxi.processing.*;
import java.awt.event.*;
import org.json.*;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import peasy.*;
import controlP5.*;


//
// Mesh drawing & space
//
PeasyCam cam;
ToxiclibsSupport gfx;
PMatrix3D currCameraMatrix;
PGraphicsOpenGL g3; 

//
// Mesh data
//
WETriangleMesh meshBase, meshBaseScaled;
WETriangleMesh meshSelected, meshCopia;
WETriangleMesh meshScaled;

//
// Pieces data
//
ArrayList <Pieza> piezas;
float angXBase, angYBase, angXPieza, angYPieza;
float zoomBase = 0, zoomPieza = 5;
HashMap <WEFace, Pieza> carasPiezas;

//
// UI variables
//
boolean meshCargada;
boolean controlIzquierda;
boolean doSave;
boolean openingFile;
int sel = 0;
int nSel = 0;
String modelScale = "100"; // as string for textfield input
String lastFile = "gato3.stl";

//
// MASTA server, data & UI
//
ControlP5 cp5;
MultiListButton formList;
String url = "http://masta-project.com/server/";
HashMap <String, String> forms;
PFont mastaFont;
String formName;
int formId;

//
// Log & debug
//
PrintWriter output;

///////////////////////////////////////////////////////
// INIT - setup()
// 
///////////////////////

public void setup() {
  size(displayWidth, displayHeight, OPENGL);

  // Init UI for MASTA bond

  cp5 = new ControlP5(this);
  cp5.addButton("openFile").setPosition(10, 10);
  cp5.addButton("updateFile").setPosition(110, 10);  
  cp5.addTextfield("modelScale").setPosition(110, 35).setSize(70, 20).setAutoClear(false).setValue(modelScale);
  /* 
  // Still TODO: update JSON lib version to retrieve forms  
  // from the MASTA server
  
  cp5.addButton("RetrieveForms")
     .setPosition(20, 60)
     .setValue(0)
     .updateSize()
     .setColorBackground(50);
  cp5.addButton("PostForms")
     .setPosition(20, 90)
     .updateSize()
     .setColorBackground(30);
  MultiList selector = cp5.addMultiList("Forms",20,20,70,12);
  formList = selector.add("MASTA Forms", 0);
  formList.setColorBackground(color(100,0,0))
          .setHeight(30);    
  */
  forms = new HashMap();
  
  mastaFont = createFont("Intro.ttf", 30, true);

  // Init mesh space & drawing utils

  initMouseNav();
  gfx = new ToxiclibsSupport(this);
  g3 = (PGraphicsOpenGL)g;

  // init with default mesh
  initMesh("gato3.stl");
  
  // Init camera
  
  cam = new PeasyCam(this, 1000);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(15000);    
  
  // Log & debug
  output = createWriter("MASTA-log.txt");
}



///////////////////////////////////////////////////////
// MAIN - draw()
// 
///////////////////////

public void draw() {
  background(130, 140, 140);  

  // Modelos 3D
  hint(ENABLE_DEPTH_TEST);
  lights();
  
  if (doSave) {
    saveMesh();
  }

  // Muestra el objeto base con la pieza seleccionada
  pushMatrix();

  stroke(200);
  fill(255);
//  gfx.mesh(meshScaled);
  
  if (!openingFile) {
    for (Pieza pieza : piezas) {
      WETriangleMesh pmesh = pieza.mesh;
      Vec3D centroBase = pieza.base.getCentroid();
      Vec3D centroPieza = pmesh.computeCentroid();
      Vec3D desplazamiento = new Vec3D(centroPieza).scale(1.2-1);
      pushMatrix();
      translate(desplazamiento.x, desplazamiento.y, desplazamiento.z);
      gfx.mesh(pmesh);
      popMatrix();
    }
  }
  
  popMatrix();
  
  // GUI
  currCameraMatrix = new PMatrix3D(g3.camera);
  camera();
  noLights();
  cp5.draw();
  g3.camera = currCameraMatrix;  
}



///////////////////////////////////////////////////////
// SAVEMESH()
// exporta la pieza seleccionada a un archivo STL
///////////////////////

void saveMesh() {
  // save mesh as STL or OBJ file
  meshSelected.pointTowards(new Vec3D(0, 0, -1), meshSelected.faces.get(0).normal);
  
  meshSelected.saveAsSTL(sketchPath("cara"+sel+".stl"));
  doSave=false;
}





///////////////////////////////////////////////////////
// CONTROL DEL TECLADO
///////////////////////

public void keyReleased() {
  if (key == 's') {
    doSave=true;   
    return;
  } 
  if (key == 'n') {
    sel++;
    if (sel > piezas.size()-1) sel = 0;
  }
  if (key == 'm') {
    sel--;
    if (sel < 0) sel = piezas.size()-1;
  }
  if (meshSelected != null) {
    if (key == 'k') {
      nSel++;
      nSel = constrain(nSel, 0, 10);
    }
    if (key == 'j') {
      nSel--;
      nSel = constrain(nSel, 0, 10);
    }
  }
  if (key == 'c') {
    save("captura####.jpg");
  }
    
}


///////////////////////////////////////////////////////
// CONTROL DEL RATON
///////////////////////

public void mouseDragged() {
  if (controlIzquierda) {
    angYBase -= .01f*(mouseY-pmouseY);
    angXBase += .01f*(mouseX-pmouseX);
  }
  else {
    angYPieza -= .01f*(mouseY-pmouseY);
    angXPieza += .01f*(mouseX-pmouseX);    
  }
}

void mouseMoved() {
  controlIzquierda = (mouseX < width*.5);
}

// Rueda del ratón

void mouseWheel(int delta) {
  if (controlIzquierda) {
    zoomBase += .3*delta;
    zoomBase = constrain(zoomBase, .1, 20);
  }
  else {
    zoomPieza += .3*delta;
    zoomPieza = constrain(zoomPieza, .1, 20);
  }
}

void initMouseNav() {
  // Mouse Wheel
  addMouseWheelListener(new MouseWheelListener() { 
    public void mouseWheelMoved(MouseWheelEvent mwe) { 
      mouseWheel(mwe.getWheelRotation());
    }
  }
  );
}

///////////////////////////////////////////////////////
// UTILS - exit()
// Close the log file before quit.
///////////////////////

void exit() {
  output.flush();  
  output.close();
  super.exit();
}

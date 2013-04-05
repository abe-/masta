float SMALL_NUM = 0.00001;

WETriangleMesh simpleSolidify (WETriangleMesh mesh_, Vec3D[] normals_, float grosor) {
  // Creo la capa interior a partir de las normales 
  // de las caras de la exterior
  WETriangleMesh mesh = new WETriangleMesh();
  mesh.addMesh(mesh_);
  
  Vec3D[] normals = new Vec3D[normals_.length];
  arrayCopy(normals_, normals);
  for (int n = 0; n < normals.length; n++) {
    normals[n].invert();
  }
  
  
  mesh.faceOutwards();  
  mesh.computeFaceNormals();
  mesh.computeVertexNormals();
  
  WETriangleMesh interior = new WETriangleMesh();

  ArrayList <Vec3D> [] vertFaces = new ArrayList[mesh.vertices.size()];

  for (int n = 0; n < mesh.vertices.size(); n++) {
    WEVertex vx = mesh.getVertexForID(n);
    vertFaces[n] = new ArrayList();
  }
  
  for (Face f : mesh.faces) {
    Vec3D no = f.normal;
    Vertex[] v = new Vertex[3];
    v = f.getVertices(v);
    for (int n = 0; n < 3; n++) {
      vertFaces[v[n].id].add(no);
    }
  }
  
  for (int n = 0; n < mesh.vertices.size(); n++) {
    float escala = 0;
    for (Vec3D fn : vertFaces[n]) {
      float angle = 0;
      if (fn.cross(normals[n]).magnitude() != 0) {
        angle = fn.angleBetween(normals[n]);
      }
      if (angle >= HALF_PI) {
        escala += 1;
      }
      else if (angle < SMALL_NUM) {
        escala += 1;
      }
      else {
        escala += lengthFromAngle(angle);
      }
    }
   
    escala /= vertFaces[n].size();
    
    normals[n].scaleSelf((escala)*grosor);
//    if (normals[n].magnitude() > grosor) {
//      normals[n].scaleSelf(1./(normals[n].magnitude()*grosor));
//    }
  }
  
  int[] vert_mapping = new int[mesh.vertices.size()];
  for (int n = 0; n < vert_mapping.length; n++) {
    vert_mapping[n] = -1;
  }

  int len_verts = mesh.vertices.size();
  Vec3D[] verts = new Vec3D[mesh.vertices.size()];
  
  for (Face f : mesh.faces) {    
    Vertex[] v = new Vertex[3];
    v = f.getVertices(v);
    for (int n = 0; n < 3; n++) {
      int i = v[n].id;
      if (vert_mapping[i] == -1) {
        vert_mapping[i] = len_verts + verts.length;
        verts[i] = v[n].add(normals[i]); 
      }
    } 
  }   

  for (Face f : mesh.faces) {
    Vec3D[] nverts = new Vec3D[3];    
    Vertex[] v = new Vertex[3];
    v = f.getVertices(v);
    for (int n = 0; n < 3; n++) {
      int i = v[n].id;
      nverts[n] = verts[i];
    }
  
    if (nverts[0] != null && nverts[1] != null && nverts[2] != null) {
      WEFace fs = new WEFace(new WEVertex(nverts[0], 0), new WEVertex(nverts[1], 1), new WEVertex(nverts[2], 2));
      // Añadimos la cara a la superficie interior
      interior.addFace(fs.a, fs.b, fs.c, fs.uvA, fs.uvB, fs.uvC);      
    }
    else {
      println("no");
    }          
    
  }
  

  return interior;
}


float lengthFromAngle(float angle) {
  if (angle < SMALL_NUM) {
    return 1.0;
  }
  return abs(1./cos(angle));
}

// No la uso para nada
float faceArea(Face f) {
  return (.5*f.a.sub(f.c).cross(f.b.sub(f.c)).magnitude());
}

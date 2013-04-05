class SensibleMesh extends WETriangleMesh {
 
  HashMap <VerletParticle, WEFace> configuration;
  PShape sh, shEdit;
  
  SensibleMesh() {
    this(new WETriangleMesh());
  }
  
  SensibleMesh(WETriangleMesh mesh) {
    super();
    this.addMesh(mesh);
    configuration = new HashMap();
    
    java.util.Collection vertices = mesh.getVertices();
    sh = createShape(POINTS);
    shEdit = createShape(POINTS);
    java.util.Iterator iter = vertices.iterator();
    while(iter.hasNext()) {
       Vertex vx = (Vertex) iter.next();
       sh.stroke(100);
       sh.strokeWeight(.3);
       sh.vertex(vx.x, vx.y, vx.z);
       
       shEdit.stroke(200, 0, 0);
       shEdit.strokeWeight(2);
       shEdit.vertex(vx.x, vx.y, vx.z);
    }
    sh.end();
    shEdit.end();
  } 
 
  
  void draw() { 
    if (edit) shape(shEdit);
    else shape(sh);
  }
}

/***************************
* UTILS :: float areaSq (a,b,c)
* Devuelve el área al cuadrado de un triángulo
*******/

float areaSq(Vec3D a, Vec3D b, Vec3D c) {
  return b.sub(a).cross(c.sub(a)).magSquared();
}

/***************************
* UTILS :: void branch (a, b, c, mesh)
* Subdivide una cara si su área es mayor que un valor,
* y añade la cara a la mesh
*******/

void branch(Vec3D a, Vec3D b, Vec3D c, WETriangleMesh mesh) {
    if (areaSq(a, b, c) > amin) {
      subdivide(a, b, c, floor(areaSq(a, b, c)/amin), mesh);
    }
    else mesh.addFace(a, b, c);    
  
}

/***************************
* UTILS :: void subidivide (a, b, c, int n, mesh)
* Subdivide recursivemente una cara a través de branch()
*******/

void subdivide(Vec3D a, Vec3D b,Vec3D c, int n, WETriangleMesh mesh) {
  if (n > 0) {
    Vec3D a1 = a.add(b.sub(a).scale(.5));
    Vec3D b1 = b.add(c.sub(b).scale(.5));
    Vec3D c1 = c.add(a.sub(c).scale(.5));
    branch(a, a1, c1, mesh);
    branch(b, b1, a1, mesh);
    branch(c, c1, b1, mesh);
    branch(a1, b1, c1, mesh);
  }
}

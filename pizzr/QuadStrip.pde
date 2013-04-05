class QuadStrip extends TriangleMesh {
  
  ArrayList <Vec3D> vectores;
  ArrayList <Vertex> vertices;
  
  QuadStrip() {
    super();
    vectores = new ArrayList();
    vertices = new ArrayList();
  }
  
  void beginShape() {
    vectores.clear();
  }
  
  void vertex(float x, float y, float z) {
    vectores.add(new Vec3D(x, y, z)); 
  }
  
  void vertex(Vec3D v) {
    vectores.add(v); 
  }  
  
  void vertex(Vertex vx) {
    vertices.add(vx);
  }
  
  void endShape() {
    if (vectores.size() > 0) {
      for (int n = 0; n < vectores.size()-2; n+=2) {        
        Vec3D v0 = vectores.get(n);
        Vec3D v1 = vectores.get(n+1);
        Vec3D v2 = vectores.get(n+2);
        Vec3D v3 = vectores.get(n+3);
        this.addFace(v0, v1, v2);
        this.addFace(v2, v1, v3);
      }
    }
    else if (vertices.size() > 0) {
      for (int n = 0; n < vertices.size()-2; n+=2) {
        Vertex v0 = vertices.get(n);
        Vertex v1 = vertices.get(n+1);
        Vertex v2 = vertices.get(n+2);
        Vertex v3 = vertices.get(n+3);
        if (floor(n/2) % 2 == 0) {
          Face f1 = new Face(v0, v1, v2);
          Face f2 = new Face(v2, v3, v1);
          this.faces.add(f1);
          this.faces.add(f2);
        }
        else {
          Face f1 = new Face(v0, v3, v1);
          Face f2 = new Face(v3, v2, v0);
          this.faces.add(f1);
          this.faces.add(f2);          
        } 
      }      
    }
  }
  
}

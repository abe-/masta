class WEQuadStrip extends WETriangleMesh {
  
  ArrayList <Vec3D> vectores;
  
  WEQuadStrip() {
    super();
    vectores = new ArrayList();
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
  
  void endShape() {
    for (int n = 0; n < vectores.size()-2; n+=2) {
      Vec3D v0 = vectores.get(n);
      Vec3D v1 = vectores.get(n+1);
      Vec3D v2 = vectores.get(n+2);
      Vec3D v3 = vectores.get(n+3);
      this.addFace(v0, v2, v1);
      this.addFace(v2, v3, v1);
    }
  }
  
}

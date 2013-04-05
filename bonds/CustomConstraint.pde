public class CustomConstraint implements ParticleConstraint {

  public CustomConstraint() {
  }

  public void apply(VerletParticle p) {
    
    if (!p.getVelocity().isZeroVector()) {
    
    WEVertex closest = smesh.getClosestVertexToPoint(p);
    
    if (closest != null) {
      boolean fin = false;
      Vec3D dir = null;
      for (WingedEdge we : closest.edges) {
        if (we.faces.size() == 1) {
          fin = true;
          dir = new Vec3D(we.a.sub(we.b)).normalize();
        }
      }
      
      Vec3D wenorm = closest.normal;
      if (p.sub(closest).magnitude() > rugosidad*RNODO) p.setWeight(10); 
      
      Vec3D previous = p.getPreviousPosition();
      Vec3D vel = p.getVelocity();
      vel.subSelf(wenorm.scale(vel.dot(wenorm)));
      if (fin) {
        Vec3D paral = dir.scale(vel.dot(dir));
        Vec3D perp = vel.sub(paral);
        vel = paral.add(perp.invert());
      }
      p.set(previous.add(vel));
    }
  }
  }
}


// La copio del src de toxiclibs porque por alguna razón
// la clase VerletMinDistanceSpring no me funciona

class CustomSpring extends VerletSpring {  
 
  float lenSq;
  
  CustomSpring(VerletParticle a, VerletParticle b, float len, float str) {
    super(a, b, len, str);
    lenSq = len*len;
  }

  float rawDistance(VerletParticle a, VerletParticle b) {
    return (abs(a.x-b.x) + abs(a.y-b.y) + abs(a.z-b.z));
  }

  void update(boolean applyConstraints) {
    
    if (rawDistance(a, b) < restLength*3) {
      if (b.distanceToSquared(a) < lenSq) {
        super.update(applyConstraints);
      }
    }
  }  
}

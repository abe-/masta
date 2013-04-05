class Relacion {
 
  Nodo n1, n2;
  int tiempoColisiones, tiempoSolidificacion;
  boolean solidificada;
  
  boolean ilegal;
  float desviacion = 1;
 
  Relacion(Nodo n1_, Nodo n2_) {
    n1 = n1_;
    n2 = n2_;
    n1.lock();
    n2.lock();
  } 
  
  void lista() {
    if (!relaciones.finales.contains(n1)) {
      n1.id = relaciones.finales.size();
      relaciones.finales.add(n1);
    }
    if (!relaciones.finales.contains(n2)) {
      n2.id = relaciones.finales.size();      
      relaciones.finales.add(n2);
    }    
  }
  
  void update() {
    if (tiempoColisiones > tiempoSolidificacion && !solidificada) {
      solidificada = true;
    }
    else if (tiempoColisiones > tiempoSolidificacion) {
      if (n1 != null && n2 != null) {
        float d = n1.distanceToSquared(n2);
        desviacion = abs(n1.distanceToSquared(n2) - 4*RNODO*RNODO)/(4*RNODO*RNODO);
        if (desviacion > 0.1) {
          ilegal= true;
        }
      }
    }
  }
  
  void draw() {
    if (n1 != null && n2 != null) {      
      stroke(0, 50, 0);
      strokeWeight(2);
      color c = lerpColor(color(0, 155, 155), color(255,150,50), desviacion*5);
      stroke(c);
      gfx.line(n1, n2);  
    }
  }
  
}

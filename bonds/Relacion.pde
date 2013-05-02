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
      if (objeto == null) {   
        strokeWeight(2);
        color c = lerpColor(color(0, 155, 155), color(255, 150, 50), desviacion*5);
        stroke(c);
        gfx.line(n1, n2);  
      }
      else {
        Vec3D rel = n2.sub(n1);
        Vec3D pp = rel.cross(n1).normalize();
         
        float ancho = 4;
        pp.scaleSelf(ancho*.5);
        textureMode(NORMAL);
        noStroke();
        beginShape();
        texture(objeto); 
        vertex(n1.x-pp.x, n1.y-pp.y, n1.z-pp.z, 0, 0);
        vertex(n1.x+pp.x, n1.y+pp.y, n1.z+pp.z, 1, 0);
        vertex(n1.x+rel.x+pp.x, n1.y+rel.y+pp.y, n1.z+rel.z+pp.z, 1, 1);
        vertex(n1.x+rel.x-pp.x, n1.y+rel.y-pp.y, n1.z+rel.z-pp.z, 0, 1);
        endShape();
      }   
    }
  }
}


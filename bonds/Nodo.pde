// Este es el agente que va a construir las redes
// que permitirán la aparición de estructuras con
// aristas de igual lado.

// Propiedades físicas como forma de inteligencia
// con la que adherirse a las formas.

class Nodo extends VerletParticle {
  
  PApplet parent;
  boolean colision;
  boolean fis;
  float radio;
  boolean fixed;
  int cuentaColision;
  ArrayList <Nodo> contactos;
  ArrayList <Nodo> enContacto;
  int tiempoSolidificacion = 6000;
  int id;
  int estado;
  int vida;
  
  Vec3D posini;
  
  Nodo(int id_, PApplet parent_, Vec3D posini) {
    this(id_, parent_, posini, true);
  }


  Nodo(int id_, PApplet parent_, Vec3D posini, boolean fis) {
    super(posini);
    this.posini = posini;
    vida = 0;
    
    // Place the particle in the center of the face
    this.clearVelocity();
    this.clearForce();
    
    parent = parent_;
    id = id_;
    radio = RNODO;
    contactos = new ArrayList();
    enContacto = new ArrayList();
    this.fis = fis; 
    if (fis) {
      fisica.addParticle(this);        
      this.addConstraint(new CustomConstraint());
     
      
      for (Nodo n : nodos) {
        if (n != this) {
          //this.addBehavior(new AttractionBehavior(n, 2*RNODO, -.01));
          CustomSpring spr = new CustomSpring(this, n, 1.99*RNODO, reboteEntreNodos);
          fisica.addSpring(spr);
        } 
      }
    }  
  }
    
  
  void colisiones() {
    if (estado == 1) {
      //if (this.behaviors != null) this.behaviors.clear();
      //this.addBehavior(new AttractionBehavior(this, 2*RNODO, 0.1, RNODO*(.01+frameCount*0.001)));
      estado = 2;
    }

    else if (estado == 2) {
      colision = false;
      enContacto.clear();
      for (Nodo n : nodos) {
        if (this != n && n.estado == 2 && this.getWeight() != 10 && n.getWeight() != 10 && this.isIntersecting(n)) {
          this.colision = true;
          //gfx.line(this, n);
          enContacto.add(n);
        }
      }
      if (enContacto.size() > 2) {
        for (Nodo n : enContacto) {
          Relacion r = relaciones.contieneRelacion(this, n);          
          if (n.enContacto.size() > 2 && r == null) {
            //if (r == null) {
              r = new Relacion(this, n);
              relaciones.add(r);
            //}
            r.tiempoColisiones = r.tiempoSolidificacion+1;
          }  
        }  
      }
      if (enContacto.size() == 0) vida++;
      if (vida > 600) this.setWeight(10);      
    }
  }
  
  
  void draw() {
    if (colision) {
      noFill();
      if (contactos.size() > 0) {
        for (Nodo n : contactos) {
          Vec3D rel = new Vec3D(n).sub(this).scaleSelf(.25);
          stroke(0, 255, 0);
          strokeWeight(5);
          line(x,y,z,x+rel.x,y+rel.y,z+rel.z);
        }
      }
    }
    if (particulas && !doSave) {
        stroke(0, 150, 150);
        strokeWeight(2*RNODO);
        if (this.isLocked()) stroke(150,0,0);
        point(x, y, z);
    }
  }
  
  
  boolean isIntersecting(Nodo n) {
    Vec3D delta = n.sub(this);
    float d = delta.magSquared();
    return (Math.abs(d-4*RNODO*RNODO)/(4*RNODO*RNODO) < .2);
  }
  
  
}

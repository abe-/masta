class Pieza {
 
  Face base, techo;
  Face baseInt;
  WETriangleMesh mesh;
  int numero;
  WEVertex[] hexa, hexaInt;
  int num;
  float grosor = 1;
  float interp = .15;
  float longitudConector = 5.5;  
  float anchoConector = 4;
 
  Pieza(int numero_, Face base_) {
    numero = numero_;
    base = base_;
    
    mesh = new WETriangleMesh();
    if (base != null) {
      mesh.addFace(base.a, base.b, base.c, base.uvA, base.uvB, base.uvC);
      
      // Creo la cara paralela interior
      Vec3D aInt = base.a.interpolateTo(base.getCentroid(), interp); 
      aInt.addSelf(base.normal.getInverted().scale(grosor));
      
      Vec3D bInt = base.b.interpolateTo(base.getCentroid(), interp); 
      bInt.addSelf(base.normal.getInverted().scale(grosor));
      
      Vec3D cInt = base.c.interpolateTo(base.getCentroid(), interp); 
      cInt.addSelf(base.normal.getInverted().scale(grosor));      
      
      mesh.addFace(aInt,cInt,bInt);
      baseInt = mesh.faces.get(mesh.faces.size()-1);
    }
    mesh.setName("cara-"+numero);
  } 
  
  void addHexa(WEVertex[] hexa_) {
    hexa = hexa_;
    Vec3D centro = new Vec3D();
    for (int n = 0; n < 6; n++) {
      centro.addSelf(hexa[n]);
    }
    centro.scaleSelf(1./6.);
    
    if (numero < 1000) {
      Display disp = new Display(numero, 7, 4, 1);
      disp.mesh.pointTowards(base.normal.getInverted());
      disp.mesh.center(centro);
      disp.mesh.translate(base.normal.getInverted().scale(disp.d*.5));
      mesh.addMesh(disp.mesh);
    }
    
    hexaInt = new WEVertex[6];
    for (int n = 0; n < 6; n++) {
      hexaInt[n] = new WEVertex(hexa[n], mesh.vertices.size()+n);
      hexaInt[n].interpolateToSelf(centro, interp);
      hexaInt[n].addSelf(base.normal.scale(grosor));
    }
    centro.addSelf(base.normal.scale(grosor));
    
    for (int i = 0; i < 6; i++) {
      int im1 = (i == 5) ? 0 : i+1;
      mesh.addFace(hexaInt[i], hexaInt[im1], centro);
    }    
  }
  
  void hembra(Vertex a1, Vertex b1, Vertex a2, Vertex b2, boolean invertir) {
    TriangleMesh h = hueco(a1, b1, a2, b2, anchoConector, longitudConector, invertir); 
    mesh.addMesh( h );
  }
  
  void macho(Vertex a1, Vertex b1, Vertex a2, Vertex b2, boolean invertir) {
    TriangleMesh h = hueco(a1, b1, a2, b2, anchoConector, -longitudConector, invertir);
    mesh.addMesh( h );
  }  
  
  void pared(Vec3D a1, Vec3D b1, Vec3D a2, Vec3D b2, boolean invertir) {
    mesh.addMesh( cara(a1, b1, a2, b2, invertir) );
  }
  
  void cierre(Vertex vx1, Vertex vx2, Vertex vx3, Vertex vx4, Vertex vx1Int, Vertex vx2Int, Vertex vx3Int, Vertex vx4Int, boolean invertir) {
    mesh.addMesh(alfeizar(vx1, vx2, vx3, vx4, vx1Int, vx2Int, vx3Int, vx4Int, anchoConector, longitudConector, invertir));
  }
  
}

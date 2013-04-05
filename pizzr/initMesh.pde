public void initMesh(String file) {
  piezas.clear();
  meshBase = (WETriangleMesh)new STLReader().loadBinary(sketchPath(file), STLReader.WEMESH);
//  meshBase = new WETriangleMesh();
//  meshBase.addMesh (new Sphere(new Vec3D(0, 0, 0), 30).toMesh(5));
  meshBase.computeCentroid();
  meshBase.center(new Vec3D(0, 0, 0));
  meshBase.scale(100); // gato3 - 100 ; tucan - 2000
  
  meshScaled = new WETriangleMesh().addMesh(meshBase).scale(1.5);

  float grosor = 12.;
  int cuenta = 0;
  WEVertex[] nuevos = new WEVertex[meshBase.edges.size()*2];
  ArrayList bases = new ArrayList();

  // Sólo podemos iterar en los edges de una wemesh.
  // Lo que estamos haciendo en realidad es iterar por las WEFaces
  for (WingedEdge e : meshBase.edges.values()) {
    for (WEFace f : e.getFaces()) {
      if (!bases.contains(f)) {    
        bases.add(f);
        
        // Vamos a crear un hexágono bajo cada cara,
        // a una distancia constante "grosor"
        WEVertex[] hexa = new WEVertex[6];
        Vec3D centroHexa = new Vec3D();
        int n = 0;
        
        // Para conseguir los ptos ordenados del hexágono
        // iteramos sobre los vértices de la cara
        WEVertex[] verts = new WEVertex[3];
        verts = f.getVertices(verts);
        boolean[] hembra = new boolean[3];
        
        for (int m = 0; m < 3; m++) {
          WEVertex vx = verts[m];
          WEVertex vx2 = (m == 2) ? verts[0] : verts[m+1];
          
          for (WingedEdge ev : vx.edges) {
            if (ev.getOtherEndFor(vx) == vx2) {
              
              // Calculamos la "edge-normal"
              // - si sólo hay una cara coincidirá con la normal de la cara
              // - si hay dos caras será la media de las normales
              Vec3D en = null;
              switch(ev.faces.size()) { 
                case 1:
                  en = ev.faces.get(0).normal.getInverted();
                  break;
                case 2:
                  en = ev.faces.get(1).normal.add(ev.faces.get(0).normal).scale(-0.5);
                  break;
              } 
    
              if (en != null) {
                float proyFaceNormal = en.dot(f.normal);                
                en.scaleSelf(-1*grosor/proyFaceNormal);
                
                hexa[n] = new WEVertex(vx.add(en), ev.id);
                hexa[n+1] = new WEVertex(vx2.add(en), ev.id+1);
                Vec3D centro = hexa[n].add(hexa[n+1]).scale(.5);
                
                hexa[n].interpolateToSelf(centro, .75);
                centroHexa.addSelf(hexa[n]);
                hexa[n+1].interpolateToSelf(centro, .75);
                centroHexa.addSelf(hexa[n+1]);
                
                n += 2;      
              }
            }
          }
        }
          
        centroHexa.scaleSelf(1./6.);
        
        // Creamos la pieza con la cara y con el hexágono inferior
        if(piezas.size() < 1000) {
          Pieza p = new Pieza(cuenta, f);
          for (int i = 0; i < 6; i++) {
            int im1 = (i == 5) ? 0 : i+1;
            p.mesh.addFace(hexa[i], centroHexa, hexa[im1]);
          }
          p.addHexa(hexa);        
          piezas.add(p);
          carasPiezas.put(f, p);
          cuenta++;
        }          
      }      
    }
  }
  
  // Volvemos a iterar en las aristas para averiguar el signo
  // de las conexiones (paredes)
  for (WingedEdge e : meshBase.edges.values()) {
    int n = 0;
    boolean[] subida = new boolean[2];
    boolean yaMacho = false;
    for (WEFace f : e.getFaces()) {
          
      Pieza p = carasPiezas.get(f);
      if (p != null) {
      
      // ¿Qué edge estoy cogiendo de la cara?
      int i0 = -1;
      if ( n == 0 ) {
      if (f.a == e.a) i0 = 0;
      else if (f.b == e.a) i0 = 1;
      else if (f.c == e.a) i0 = 2;
      }
      else {
        if (f.a == e.b) i0 = 0;
        else if (f.b == e.b) i0 = 1;
        else if (f.c == e.b) i0 = 2;        
      }
      
      // Paredes de la pieza     
      Vertex a = null, b = null;   
      Vertex a2 = p.hexa[2*i0], b2 = p.hexa[2*i0+1];     
      Vertex aInt = null, bInt = null;   
      Vertex aInt2 = p.hexaInt[2*i0], bInt2 = p.hexaInt[2*i0+1];       
      switch(i0) {
        case 0:
          a = f.a;
          b = f.b;    
          aInt = p.baseInt.a;
          bInt = p.baseInt.c; // Cuidado que en baseInt b <-> c
          break;
        case 1:
          a = f.b;
          b = f.c;
          aInt = p.baseInt.c;
          bInt = p.baseInt.b;
          break;
        case 2:
          a = f.c;
          b = f.a;
          aInt = p.baseInt.b;
          bInt = p.baseInt.a;          
          break;
      }         
      // Decidimos por el ángulo si la pared es macho o hembra
      Vec3D nCara = new Vec3D();
      nCara = b.sub(a).cross(a2);
      
      // TODO: corregir esta asignación      
      subida[n] = (f.normal.dot(nCara) > 0);
  
      }    
    } 
    

    // Poco elegante: repetimos la iteración para distribuir H o M
    int m = 0;
    for (WEFace f : e.getFaces()) {
          
      Pieza p = carasPiezas.get(f);
      if (p != null) {
      
      // ¿Qué edge estoy cogiendo de la cara?
      int i0 = -1;
      if ( m == 0 ) {
      if (f.a == e.a) i0 = 0;
      else if (f.b == e.a) i0 = 1;
      else if (f.c == e.a) i0 = 2;
      }
      else {
        if (f.a == e.b) i0 = 0;
        else if (f.b == e.b) i0 = 1;
        else if (f.c == e.b) i0 = 2;        
      }
      
      // Paredes de la pieza     
      Vertex a = null, b = null;   
      Vertex a2 = p.hexa[2*i0], b2 = p.hexa[2*i0+1];     
      Vertex aInt = null, bInt = null;   
      Vertex aInt2 = p.hexaInt[2*i0], bInt2 = p.hexaInt[2*i0+1];       
      switch(i0) {
        case 0:
          a = f.a;
          b = f.b;    
          aInt = p.baseInt.a;
          bInt = p.baseInt.c; // Cuidado que en baseInt b <-> c
          break;
        case 1:
          a = f.b;
          b = f.c;
          aInt = p.baseInt.c;
          bInt = p.baseInt.b;
          break;
        case 2:
          a = f.c;
          b = f.a;
          aInt = p.baseInt.b;
          bInt = p.baseInt.a;          
          break;
      }         
      
      
      if (m == 0 && (!subida[m] || (subida[0] && !subida[1])) || m == 1 && yaMacho) {
        p.hembra(a, b, b2, a2, false);
        p.hembra(aInt, bInt, bInt2, aInt2, true);
        p.cierre(a, b, b2, a2, aInt, bInt, bInt2, aInt2, false);
      }
      else {
        yaMacho = true;
        p.macho(a, b, b2, a2, false);
        p.pared(aInt, bInt, aInt2, bInt2, true);   
      }
      //p.pared(a, b, a2, b2);   
      p.num++;
 
      // Paredes restantes (no conectoras)
      WEVertex a3 = (i0 == 2) ? p.hexa[0] : p.hexa[(i0+1)*2];
      WEVertex aInt3 = (i0 == 2) ? p.hexaInt[0] : p.hexaInt[(i0+1)*2];
      
      p.mesh.addFace(b, b2, a3);
      p.mesh.addFace(bInt, aInt3, bInt2);
      
      m++;
      }
    }  
  }
}


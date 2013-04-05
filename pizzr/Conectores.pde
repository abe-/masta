TriangleMesh hueco(Vertex vx1, Vertex vx2, Vertex vx3, Vertex vx4, float radio, float profundidad, boolean invertir) {
  QuadStrip qs = new QuadStrip();
  
  float factor = (profundidad < 0) ? 0.9 : 1; 
  
  Vec3D[] v = new Vec3D[4];
  v[0] = new Vec3D(vx1);
  v[1] = new Vec3D(vx2);
  v[2] = new Vec3D(vx3);
  v[3] = new Vec3D(vx4);
  
  Vec3D centroid = v[0].add(v[1]).add(v[2]).add(v[3]).scaleSelf(.25);
  Vec3D eje1 = v[0].sub(v[1]);
  Vec3D eje2 = v[1].sub(v[2]);
  Vec3D _n = eje1.cross(eje2).normalize();
      
  Vec3D vc1 = eje1.normalize();
  Vec3D[] centro = new Vec3D[4];
  Vec3D[] ncentro = new Vec3D[4];
  for (int n = 0; n < 4; n++) {
    Vec3D _v = vc1.getRotatedAroundAxis(_n.normalize(), HALF_PI*(n+.5));
    centro[n] = new Vec3D(centroid.add(_v.scale(radio*factor)));
    ncentro[n] = new Vec3D(centro[n].add(_n.scale(-1*profundidad)));    
  }
  
  // Pared agujereada
  
  qs.beginShape();
  for (int n = 0; n < 4; n++) {
    qs.vertex(v[n]);
    qs.vertex(centro[n]);
  }
  qs.vertex(v[0]);
  qs.vertex(centro[0]);
  qs.endShape();
  
  // Paredes laterales del conector
  float aprox = .75;
  float saliente = 1.;
  if (profundidad < 0) { 
    Vec3D n03 = ncentro[0].sub(centro[0]).cross(centro[3].sub(centro[0])).normalize();
    Vec3D n12 = ncentro[1].sub(centro[1]).cross(centro[2].sub(centro[1])).normalize().invert();
    
    for (int n = 1; n < 4; n++) {
      qs.beginShape();
      qs.vertex(centro[1].interpolateTo(centro[0], aprox).interpolateTo(ncentro[1].interpolateTo(ncentro[0], aprox), (float)(n-1)/3.));
      qs.vertex(centro[1].interpolateTo(centro[0], aprox).interpolateTo(ncentro[1].interpolateTo(ncentro[0], aprox), (float)(n)/3.));
      if (n == 3) { // PARCHE. Aquí pasa algo extraño con la expresión general
        qs.vertex(centro[2].interpolateTo(centro[3], aprox).interpolateTo(ncentro[2].interpolateTo(ncentro[3], aprox), (float)(n-1)/3.));
        qs.vertex(ncentro[2].interpolateTo(ncentro[3], aprox));
      }
      else {
        qs.vertex(centro[2].interpolateTo(centro[3], aprox).interpolateTo(ncentro[2].interpolateTo(ncentro[3], aprox), (float)(n-1)/3.));
        qs.vertex(centro[2].interpolateTo(centro[3], aprox).interpolateTo(ncentro[2].interpolateTo(ncentro[3], aprox), (float)(n)/3.));
      }
      
      if (n == 3) qs.vertex(centro[3].interpolateTo(ncentro[3], (float)(n-1)/3.).add(n03.scale(saliente)));
      else qs.vertex(centro[3].interpolateTo(ncentro[3], (float)(n-1)/3.));
      if (n == 2) qs.vertex(centro[3].interpolateTo(ncentro[3], (float)n/3.).add(n03.scale(saliente)));
      else qs.vertex(centro[3].interpolateTo(ncentro[3], (float)(n)/3.));
      
      if (n == 3) qs.vertex(centro[0].interpolateTo(ncentro[0], (float)(n-1)/3.).add(n03.scale(saliente)));
      else qs.vertex(centro[0].interpolateTo(ncentro[0], (float)(n-1)/3.));
      if (n == 2) qs.vertex(centro[0].interpolateTo(ncentro[0], (float)n/3.).add(n03.scale(saliente)));
      else qs.vertex(centro[0].interpolateTo(ncentro[0], (float)(n)/3.));
      
      qs.vertex(centro[1].interpolateTo(centro[0], aprox).interpolateTo(ncentro[1].interpolateTo(ncentro[0], aprox), (float)(n-1)/3.));
      qs.vertex(centro[1].interpolateTo(centro[0], aprox).interpolateTo(ncentro[1].interpolateTo(ncentro[0], aprox), (float)(n)/3.));   
      qs.endShape();
    }
    
    qs.beginShape();
    qs.vertex(ncentro[1].interpolateTo(ncentro[0], aprox));
    qs.vertex(ncentro[0]);
    qs.vertex(ncentro[2].interpolateTo(ncentro[3], aprox));
    qs.vertex(ncentro[3]);
    qs.endShape();    
    
    for (int n = 1; n < 4; n++) {    
      qs.beginShape();
      if (n == 3) qs.vertex(centro[1].interpolateTo(ncentro[1], (float)(n-1)/3.).add(n12.scale(saliente)));
      else qs.vertex(centro[1].interpolateTo(ncentro[1], (float)(n-1)/3.));
      if (n == 2) qs.vertex(centro[1].interpolateTo(ncentro[1], (float)n/3.).add(n12.scale(saliente)));
      else qs.vertex(centro[1].interpolateTo(ncentro[1], (float)(n)/3.));
      
      if (n == 3) qs.vertex(centro[2].interpolateTo(ncentro[2], (float)(n-1)/3.).add(n12.scale(saliente)));
      else qs.vertex(centro[2].interpolateTo(ncentro[2], (float)(n-1)/3.));
      if (n == 2) qs.vertex(centro[2].interpolateTo(ncentro[2], (float)n/3.).add(n12.scale(saliente)));
      else qs.vertex(centro[2].interpolateTo(ncentro[2], (float)(n)/3.));

      if (n == 3) { // PARCHE. Aquí pasa algo extraño con la expresión general
        qs.vertex(centro[3].interpolateTo(centro[2], aprox).interpolateTo(ncentro[3].interpolateTo(ncentro[2], aprox), (float)(n-1)/3.));
        qs.vertex(ncentro[3].interpolateTo(ncentro[2], aprox));
      }
      else {      
        qs.vertex(centro[3].interpolateTo(centro[2], aprox).interpolateTo(ncentro[3].interpolateTo(ncentro[2], aprox), (float)(n-1)/3.));
        qs.vertex(centro[3].interpolateTo(centro[2], aprox).interpolateTo(ncentro[3].interpolateTo(ncentro[2], aprox), (float)(n)/3.));
      }
      qs.vertex(centro[0].interpolateTo(centro[1], aprox).interpolateTo(ncentro[0].interpolateTo(ncentro[1], aprox), (float)(n-1)/3.));
      qs.vertex(centro[0].interpolateTo(centro[1], aprox).interpolateTo(ncentro[0].interpolateTo(ncentro[1], aprox), (float)(n)/3.));    

      if (n == 3) qs.vertex(centro[1].interpolateTo(ncentro[1], (float)(n-1)/3.).add(n12.scale(saliente)));
      else qs.vertex(centro[1].interpolateTo(ncentro[1], (float)(n-1)/3.));
      if (n == 2) qs.vertex(centro[1].interpolateTo(ncentro[1], (float)n/3.).add(n12.scale(saliente)));
      else qs.vertex(centro[1].interpolateTo(ncentro[1], (float)(n)/3.));

      qs.endShape();
    }
    
    qs.beginShape();
    qs.vertex(ncentro[1]);
    qs.vertex(ncentro[0].interpolateTo(ncentro[1], aprox));
    qs.vertex(ncentro[2]);
    qs.vertex(ncentro[3].interpolateTo(ncentro[2], aprox));
    qs.endShape();   
  
    // Lámina que une los brazos en la base
    qs.beginShape();
    qs.vertex(centro[0].interpolateTo(centro[1], aprox));
    qs.vertex(centro[1].interpolateTo(centro[0], aprox));      
    qs.vertex(centro[3].interpolateTo(centro[2], aprox));
    qs.vertex(centro[2].interpolateTo(centro[3], aprox));  
    qs.endShape();    
  }

  if (invertir) qs.flipVertexOrder();
  return qs;
}

TriangleMesh alfeizar(Vertex vx1, Vertex vx2, Vertex vx3, Vertex vx4, Vertex vx1Int, Vertex vx2Int, Vertex vx3Int, Vertex vx4Int, float radio, float profundidad, boolean invertir) {
  QuadStrip qs = new QuadStrip();
  
  float factor = (profundidad < 0) ? 0.9 : 1; 
  
  Vec3D[] v = new Vec3D[8];
  v[0] = new Vec3D(vx1);
  v[1] = new Vec3D(vx2);
  v[2] = new Vec3D(vx3);
  v[3] = new Vec3D(vx4);
  v[4] = new Vec3D(vx1Int);
  v[5] = new Vec3D(vx2Int);
  v[6] = new Vec3D(vx3Int);
  v[7] = new Vec3D(vx4Int);
  
  Vec3D centroid = v[0].add(v[1]).add(v[2]).add(v[3]).scaleSelf(.25);
  Vec3D centroidInt = v[4].add(v[5]).add(v[6]).add(v[7]).scaleSelf(.25);
  Vec3D eje1 = v[0].sub(v[1]);
  Vec3D eje2 = v[1].sub(v[2]);
  Vec3D _n = eje1.cross(eje2).normalize();
  Vec3D eje1Int = v[4].sub(v[5]);
  Vec3D eje2Int = v[5].sub(v[6]);
  Vec3D _nInt = eje1Int.cross(eje2Int).normalize();
      
  Vec3D vc1 = eje1.normalize();
  Vec3D vc1Int = eje1Int.normalize();  
  Vec3D[] centro = new Vec3D[4];
  Vec3D[] centroInt = new Vec3D[4];
  for (int n = 0; n < 4; n++) {
    Vec3D _v = vc1.getRotatedAroundAxis(_n.normalize(), HALF_PI*(n+.5));
    Vec3D _vInt = vc1Int.getRotatedAroundAxis(_nInt.normalize(), HALF_PI*(n+.5)); 
    centro[n] = new Vec3D(centroid.add(_v.scale(radio*factor)));      
    centroInt[n] = new Vec3D(centroidInt.add(_vInt.scale(radio*factor)));    
  }

  qs.beginShape();
  for (int n = 0; n < 4; n++) {
    qs.vertex(centro[n]);
    qs.vertex(centroInt[n]);
  }
  qs.vertex(centro[0]);
  qs.vertex(centroInt[0]);
  qs.endShape();  
  
  if (invertir) qs.flipVertexOrder();
  return qs;
}



TriangleMesh cara(Vec3D a1, Vec3D b1, Vec3D a2, Vec3D b2, boolean invertir) {
  QuadStrip qs = new QuadStrip();
  
  Vec3D a1b1 = a1.interpolateTo(b1, .5);
  Vec3D a2b2 = a2.interpolateTo(b2, .5);
  
  qs.beginShape();
  qs.vertex(a1);
  qs.vertex(a2);
//  qs.vertex(a1b1);
//  qs.vertex(a2b2);  
  qs.vertex(b1);
  qs.vertex(b2);
  qs.endShape();
      
  if (invertir) qs.flipVertexOrder();
  return qs;
}


TriangleMesh faceConDisplay(Face f, Display d) {
  TriangleMesh mesh = new TriangleMesh();
  
  // Averigüamos la dirección más larga de la Face
  Vertex[] verts = new Vertex[3];
  verts = f.getVertices(verts);
  Vec3D direccionLarga = new Vec3D();
  float lmax = 0;
  for (int n = 0; n < 3; n++) {
    Vec3D v = (n == 0) ? verts[2] : verts[n-1];
    float l = v.distanceTo(verts[n]);
    if (l > lmax) {
      direccionLarga = verts[n].sub(v);
      lmax = l;
    }
  }
  
//  d.mesh.rotateAroundAxis(new Vec3D(0, 0, 1), -direccionLarga.headingXY()+HALF_PI);
  d.mesh.pointTowards(f.normal);
  d.mesh.center(f.getCentroid().add(f.normal.scale(d.d*.5)));  
  mesh.addMesh(d.mesh);
  
  return mesh;
}


/*
TriangleMesh hueco(Vertex vx1, Vertex vx2, Vertex vx3, Vertex vx4, float radio, float profundidad) {
  QuadStrip qs = new QuadStrip();
  
  int num = 8;
  int pasos = floor(num/4);
  Vec3D[] v = new Vec3D[num];
  for (int n = 0; n < num; n++) {
    Vec3D v1 = new Vec3D();
    Vec3D v2 = new Vec3D();
    switch(floor(n/pasos)) {
      case 0 : v1 = vx1; v2 = vx2; break;
      case 1 : v1 = vx2; v2 = vx3; break;
      case 2 : v1 = vx3; v2 = vx4; break;
      case 3 : v1 = vx4; v2 = vx1; break;
    }
    v[n] = v1.interpolateTo(v2, (float)(n%pasos)/(float)pasos);
  }
  
  Vec3D centroid = v[0].add(v[1]).add(v[2]).add(v[3]).scaleSelf(.25);
  Vec3D eje1 = v[0].sub(v[1]);
  Vec3D eje2 = v[1].sub(v[2]);
  Vec3D _n = eje1.cross(eje2).normalize();
      
  Vec3D vc1 = eje1.normalize();
  Vec3D[] centro = new Vec3D[num];
  Vec3D[] ncentro = new Vec3D[num];
  float ang = TWO_PI/num;
  for (int n = 0; n < num; n++) {
    Vec3D _v = vc1.getRotatedAroundAxis(_n.normalize(), ang*(n+1./(float)num));
    centro[n] = new Vec3D(centroid.add(_v.scale(radio)));
    ncentro[n] = new Vec3D(centro[n].add(_n.scale(profundidad)));    
  }
  
  qs.beginShape();
  for (int n = 0; n < num; n++) {
    qs.vertex(v[n]);
    qs.vertex(centro[n]);
  }
  qs.vertex(v[0]);
  qs.vertex(centro[0]);
  qs.endShape();
  
  qs.beginShape();
  for (int n = 0; n < num; n++) {
    qs.vertex(centro[n]);
    qs.vertex(ncentro[n]);
  }
  qs.vertex(centro[0]);
  qs.vertex(ncentro[0]);
  qs.endShape();  
   
    
  Vec3D ncentroid = new Vec3D(centroid.add(_n.scale(profundidad)));    
  qs.beginShape();
  for (int n = 0; n < num; n++) {
    qs.vertex(ncentro[n]);
    qs.vertex(ncentroid);
  }
  qs.vertex(ncentro[0]);
  qs.vertex(ncentroid);
  qs.endShape();
      
  return qs;
}

*/


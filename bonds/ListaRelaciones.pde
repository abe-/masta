class ListaRelaciones {
  
  ArrayList <Relacion> relaciones;
  ArrayList <Nodo> finales;
  
  ListaRelaciones() {
    relaciones = new ArrayList();
    finales = new ArrayList();
  }
  
  Relacion contieneRelacion(Nodo n1, Nodo n2) {
    Relacion encontrada = null;
    for (Relacion r : relaciones) {
      if (r.n1 == n1 && r.n2 == n2 || r.n1 == n2 && r.n2 == n1) encontrada = r; 
    }
    return encontrada;
  }
  
  void add(Relacion r) {
    relaciones.add(r);
  }
  
  void export() {
    for (Relacion r : relaciones) {
      r.lista();
    }
    
    int columnas = 4;
    
    PrintWriter output = createWriter("export"+frameCount+".scad");
    PrintWriter lista = createWriter("lista"+frameCount+".txt");
    PrintWriter mapa = createWriter("lista_conexiones"+frameCount+".txt");
    String[] scad = loadStrings("scad/baseSCAD-tambor-pequeno.scad");  
    
    
    // Setup del plano PDF de conexiones -------------------------------------------
    PFont fuente = createFont("Arial", 10, true);
    
    PGraphicsPDF pdf = (PGraphicsPDF) createGraphics(595,842, PDF, "esquema-"+frameCount+".pdf");  
    pdf.beginDraw();
    pdf.background(255);
    
    // 30px ~ 1cm aprox.
    int margenPDF =  60;
    float diamPDF = 60; // 2 cm aprox
    float spacingPDF = min(20, (pdf.width - 2*margenPDF - columnas*diamPDF)/(columnas-1));
       
    int cuenta = 0;
    for (Nodo f : finales) {
      int j = cuenta % columnas;
      int i = floor(cuenta/columnas)%columnas;
      int k = floor(cuenta/(columnas*columnas)); // colocamos los grupos imprimibles en modo parking
      
      for (Relacion r : relaciones) {
        if (r.n1 == f) {
          if (!f.contactos.contains(r.n2)) f.contactos.add(r.n2);
        }
        else if (r.n2 == f) {
          if (!f.contactos.contains(r.n1)) f.contactos.add(r.n1);
        }
      }
      
      float x_pdf = margenPDF + (j+.5)*diamPDF + j*spacingPDF;
      float y_pdf = margenPDF + (i+.5)*diamPDF + i*spacingPDF; 
      
      if (f.contactos.size() > 1) {
        HashMap <Float, Float> angulos = new HashMap();
        HashMap <Float, Integer> ids = new HashMap();
        HashMap <String, Float> lineasAngulos = new HashMap();
        String lineaMapa = "";

        pdf.noFill();
        pdf.stroke(0);
        pdf.ellipse(x_pdf, y_pdf, diamPDF, diamPDF);
        
        Vec3D sum = new Vec3D();
        for (Nodo nc : f.contactos) {
          Vec3D rel = new Vec3D(nc).sub(f);
          sum.addSelf(rel);
        }
        sum.normalize();
        
        Vec3D rel0 = new Vec3D(f.contactos.get(0)).sub(f);
        rel0.subSelf(sum.scale(rel0.dot(sum)));  
        rel0.normalize();      
        
        for (Nodo nc : f.contactos) {
          Vec3D rel = new Vec3D(nc).sub(f);
          // Calculamos la altitud a partir del ángulo entre la suma y el vector
          float al = degrees(sum.angleBetween(rel, true));
          // Calculamos el azimuth a partir de las proyecciones del vector
          rel.subSelf(sum.scale(rel.dot(sum))); // en el plano normal a sum
          rel.normalize();          
          float az = (rel0.cross(rel).dot(sum) > 0 ? 1:-1)*degrees(rel0.angleBetween(rel, false));
          if (Float.isNaN(az)) {
            if (abs(rel.dot(rel0) - 1) < .5) az = 0;
            else az = 180;
          }
          // Añadimos los datos a los arrays que pasaremos después a scad
          angulos.put(al, az);
          ids.put(az, nc.id);
          
          // Anotamos la conexión en el mapa de conexiones (cuidado con ángulos negativos)
          lineaMapa = f.id + "-" +  nc.id;
          float az_ = (az < -1) ? 360+az : az;
          lineasAngulos.put(lineaMapa, az_);
        }

        // Ordenamos la lista ángulos por azimuth para el mapa de conexiones
        java.util.List _list = new java.util.LinkedList(lineasAngulos.entrySet());
        java.util.Collections.sort(
          _list, 
          new java.util.Comparator() {
            public int compare(Object o1, Object o2) {
            return ((Comparable) ((java.util.Map.Entry) (o1)).getValue()).compareTo(((java.util.Map.Entry) (o2)).getValue());
          }
        });        
        
        // Componemos una cadena de texto con el listado de conexiones
        lineaMapa = "";
        for (int n = 0; n < lineasAngulos.size(); n++) {
          String linea = (String) ((java.util.Map.Entry)_list.get(n)).getKey();
          lineaMapa += linea + " ";
        }
        
        String azimuth = "[";
        String altitud = "[";
        String id = "[";
        int cuenta2 = 0;
        float angAzimuth0 = 0;        
        for (java.util.Map.Entry me : angulos.entrySet()) {
          altitud += me.getKey();
          azimuth += me.getValue();
          id += separa(ids.get(me.getValue()));          
          float angAzimuth = (Float) me.getValue();
          float _x = 0;
          float _y = 0;
          
          if (cuenta2 == 0) {
            angAzimuth0 = angAzimuth;
            _x = x_pdf + .6 * diamPDF * cos(radians(-90));
            _y = y_pdf + .6 * diamPDF * sin(radians(-90));
            pdf.textFont(fuente);
            pdf.fill(0);
            pdf.textAlign(CENTER, CENTER);
            pdf.text(f.id, _x, _y);            
          }          
          
          if (cuenta2 < angulos.size()-1) {
            azimuth += ",";
            altitud += ",";
            id += ",";
                        
            cuenta2++;
          }
          
          _x = x_pdf + .35 * diamPDF * cos(radians(angAzimuth-angAzimuth0-90))-1;
          _y = y_pdf + .35 * diamPDF * sin(radians(angAzimuth-angAzimuth0-90))-1;
          
          pdf.textFont(fuente);
          pdf.fill(0);
          pdf.textAlign(CENTER, CENTER);
          pdf.text(ids.get(me.getValue()), _x, _y);          
        }
        azimuth += "]";
        altitud += "]";
        id += "]";
        
        String posicion = "[" + i*250 + "," + j*250 + "," + k*100 + "]";
        println(f.id);
        String lin = "tambor(" + separa(f.id) + ", " + posicion + ", " + id +"," + azimuth + "," + altitud + ");";
        
        scad = append(scad, lin);
        cuenta++;     
        
        if (j == 0) lista.println();          
        lista.print(f.id+" ");     
        mapa.println(lineaMapa);   
        
        if (cuenta % (columnas*columnas) == 0) pdf.nextPage();
      }
    }
    
    lista.close();
    lista.flush();
    
    mapa.close();
    mapa.flush();
    
    pdf.dispose();
    pdf.endDraw();
    
    for (int n = 0; n < scad.length; n++) {
      output.println(scad[n]);
    }
    output.close();
    output.flush();
  }
  
  String separa(int num) {
    int n1 = floor(num/100);
    int n2 = floor((num-n1*100)/10);
    int n3 = floor(num-n1*100-n2*10);
    return "[" + n1 + "," + n2 + "," + n3 + "]";
  }
  
  
  TriangleMesh exportToMesh() {
    TriangleMesh mesh = new TriangleMesh();
    TriangleMesh meshNoEquilateros = new TriangleMesh();
    for (Nodo f : finales) {    
      if (f.contactos.size() > 2) {
        for (Nodo ff : f.contactos) {
          if (ff.contactos.size() > 2) {
            for (Nodo fff : ff.contactos) {
              if (fff.contactos.size() > 2) {
                boolean sinCerrar = true;
                for (Nodo ffff : fff.contactos) {
                  if (ffff == f) {
                    mesh.addFace(f, ff, fff);             
                    sinCerrar = false;
                  }
                }
                if (sinCerrar) {
                  for (Nodo ffff : fff.contactos) {
                    if (ffff.contactos.size() > 2) {                    
                      for (Nodo fffff : ffff.contactos) {
                        if (fffff == f && sinCerrar) {
                          java.util.Collection vertices = meshNoEquilateros.getVertices();
                          ArrayList <Vec3D> _vertices = new ArrayList();
                          java.util.Iterator iter = vertices.iterator();
                          while(iter.hasNext()) {
                            Vertex vx = (Vertex) iter.next();
                            _vertices.add(vx);
                          }
                          
                          if (!(_vertices.contains(f) && _vertices.contains(ff) && _vertices.contains(fff) && _vertices.contains(ffff))) {
//                            meshNoEquilateros.addFace(f, ff, ffff);                           
//                            meshNoEquilateros.addFace(ff, fff, ffff);       
                            sinCerrar = false;     
                          }

  //                        mesh.addFace(f, ff, ffff);                           
//                          mesh.addFace(ff, fff, ffff);                                                   
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    mesh.addMesh(meshNoEquilateros);
    return mesh;
  }
  
}

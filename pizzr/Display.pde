class Display {
  
  boolean[][] on;
  TriangleMesh mesh;
  float w, h, d;
  
  Display(int numero, float w_, float h_, float d_) {
    mesh = new TriangleMesh();
    on = new boolean[11][5];
    w = w_; h = h_; d = d_;
    
    int[][][] num = 
      {
       {{1,1,1},{1,0,1},{1,0,1},{1,0,1},{1,1,1}},
       {{0,0,1},{0,0,1},{0,0,1},{0,0,1},{0,0,1}},
       {{1,1,1},{0,0,1},{1,1,1},{1,0,0},{1,1,1}},
       {{1,1,1},{0,0,1},{1,1,1},{0,0,1},{1,1,1}},
       {{1,0,1},{1,0,1},{1,1,1},{0,0,1},{0,0,1}},
       {{1,1,1},{1,0,0},{1,1,1},{0,0,1},{1,1,1}},
       {{1,1,1},{0,0,1},{1,1,1},{1,0,1},{1,1,1}},
       {{1,1,1},{0,0,1},{0,1,1},{0,1,0},{0,1,0}},
       {{1,1,1},{1,0,1},{1,1,1},{1,0,1},{1,1,1}},
       {{1,1,1},{1,0,1},{1,1,1},{0,0,1},{1,1,1}},
      };
    
    int num1 = numero/100;
    int num2 = (numero-num1*100)/10;
    int num3 = numero-num1*100-num2*10;
    
    for (int i = 0; i < 11; i++) {
      for (int j = 0; j < 5; j++) {
        if (i == 3 || i == 7) {
          on[i][j] = false;
        }
        else if (10-i < 3) {
          on[i][j] = (num[num1][j][(10-i)%3] == 1);
        }
        else if (10-i < 7) {
          on[i][j] = (num[num2][j][((10-i)-1)%3] == 1);
        }
        else {
          on[i][j] = (num[num3][j][((10-i)-2)%3] == 1);
        }
      }
    }
    
    float gx = w/11., gy = h/5., gz = d;
    
    QuadStrip qs = new QuadStrip();
    for (int j = 0; j < 5; j++) {
      qs.beginShape();
      for (int i = 0; i < 11; i++) {
        if (on[i][j]) {
          qs.vertex(gx*i, gy*j, gz);
          qs.vertex(gx*i, gy*(j+1), gz);
          qs.vertex(gx*(i+1), gy*j, gz);
          qs.vertex(gx*(i+1), gy*(j+1), gz);          
        }
        else {
          qs.vertex(gx*i, gy*j, 0);
          qs.vertex(gx*i, gy*(j+1), 0);
          qs.vertex(gx*(i+1), gy*j, 0);
          qs.vertex(gx*(i+1), gy*(j+1), 0);          
        }
      }
      qs.endShape();
    }
    
    // Cerramos en las j
    
    for (int i = 0; i < 11; i++) {
      for (int j = 0; j < 5; j++) {
        if (j == 0 && on[i][j] || (j > 0 && !on[i][j-1] && on[i][j])) {
          qs.beginShape();
          qs.vertex(gx*(i+1), gy*(j), 0);
          qs.vertex(gx*i, gy*(j), 0);
          qs.vertex(gx*(i+1), gy*(j), gz);
          qs.vertex(gx*i, gy*(j), gz);
          qs.endShape();
        } 
        if (j == 4 && on[i][j] || (j < 4 && !on[i][j+1] && on[i][j])) {
          qs.beginShape();
          qs.vertex(gx*(i+1), gy*(j+1), gz);
          qs.vertex(gx*i, gy*(j+1), gz);
          qs.vertex(gx*(i+1), gy*(j+1), 0);            
          qs.vertex(gx*i, gy*(j+1), 0);
          qs.endShape();
        }
      }      
    }
    
    // Cerramos en las i

    for (int j = 0; j < 5; j++) {
      for (int i = 0; i < 11; i++) {
        if (on[i][j]) {
          if (i == 0) {
            qs.beginShape();            
            qs.vertex(gx*i, gy*j, 0);
            qs.vertex(gx*i, gy*(j+1), 0);        
            qs.vertex(gx*i, gy*j, gz);
            qs.vertex(gx*i, gy*(j+1), gz);
            qs.endShape();            
          }
          if (i == 10) {
            qs.beginShape();
            qs.vertex(gx*(i+1), gy*j, gz);
            qs.vertex(gx*(i+1), gy*(j+1), gz);            
            qs.vertex(gx*(i+1), gy*j, 0);
            qs.vertex(gx*(i+1), gy*(j+1), 0);
            qs.endShape();        
          }
        }
      }
    }    
    
    mesh.addMesh(qs);
  }
  
}

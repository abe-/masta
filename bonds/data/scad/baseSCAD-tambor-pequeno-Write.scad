use <write.scad>

module tambor(num, posicion, azim, alt) {

	grosor = 12; // calibre del agujero
	ancho = 1.5;
	hprof = grosor + ancho;
	f = .5;
	dimX = 120;
	dimY = 50;

	font_height = 13;
	font_size = 35;

	scale([0.1, 0.1, 0.1]) {
		translate(posicion)
 		difference() {
			difference() {
				union() {
					cylinder(r = dimX, h = dimY, center = true);

					// Muesca angulo inicial
					//rotate(a = [0, 0, 15])
					//translate([dimX-hprof,0,dimZ/2+dimY])
					//cube([dimY/2, dimY/2, dimY/4], center = true);
					writecylinder(num, posicion, dimX*1.17, dimY/2+font_height/2, face="top", east=90-30, font="knewave.dxf", h = font_size, t = font_height, space=0.8);

					for (n = [0:len(azim)-1]) {
						writecylinder("123", posicion, dimX*.94, dimY/2+font_height/2, face="top", east=90-azim[n], font="knewave.dxf", h = font_size, t = font_height, space=0.8);			
					}					
				}
				cylinder(r = dimX/2, h = dimY*2, center = true);
			}

			for (n = [0:len(azim)-1]) {
				rotate(a = [0, 0, azim[n]])
				translate([dimX-hprof,0,0])

				rotate(a = [0, alt[n], 0])
				cylinder(r = grosor, h = 1.5*dimX, center = true);
				// Muesca 1
			}

		}
	}
}

tambor("123", [0,0,0], [-52.155178,-0.027976453,91.84058,-175.06926],[66.87972,24.824778,50.93638,108.045334]);
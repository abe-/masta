module tambor(posicion, azim, alt) {

	grosor = 36; // calibre del agujero
	ancho = 10;
	hprof = grosor + ancho;
	f = .5;
	dimX = 200;
	dimY = 110;
	dimZ = 110;

	scale([0.1, 0.1, 0.1]) {
		translate(posicion)
 		difference() {
			difference() {
				union() {
					cylinder(r = dimX, h = dimY, center = true);

					// Muesca angulo inicial
					rotate(a = [0, 0, 15])
					translate([dimX-hprof,0,dimZ/2+dimY/16])
					#cube([dimY/2, ancho, dimY/8], center = true);
				}
				cylinder(r = dimX-2*hprof, h = dimY*2, center = true);
			}
			

			for (n = [0:len(azim)-1]) {
				rotate(a = [0, 0, azim[n]])
				translate([dimX-hprof,0,0])

				rotate(a = [0, alt[n], 0])
				cylinder(r = grosor, h = dimX, center = true);
				// Muesca 1
			}
		}
	}
}

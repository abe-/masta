module centro(posicion , angulo, ang21, ang22, agudo, ang31, ang32, agudo3) {

	grosor = 14;
	ancho = 1.5;
	hprof = grosor + ancho;
	f = .5;

	scale([0.1, 0.1, 0.1]) {
		translate(posicion)
 		difference() {
			union() {
				// Base
				cube([90, 50, 50], center = true);
				if (ang21 != 333 && ang22 != 333) {
					// Extension de la base
					translate([-45-25, 45-25, 0])
					cube([50, 90, 50], center = true);
				}
				if (ang31 != 333 && ang32 != 333) {
					// Extension de la base
					translate([90-25, 0, 45-25])
					cube([50, 50, 90], center = true);
				}
			}


			// Angulo 1
			translate([-grosor-ancho,0,0])
			cylinder(r = grosor, h = 100, center = true);
			// Muesca 1
			translate([-30,25,25])
			cube([10, 10, 10], center = true);

			// Angulo 2
			translate([grosor+ancho, 0, 0])
			rotate(a = [angulo, 0, 0])
			cylinder(r = grosor, h = 100, center = true);
			// Muesca2
			if (abs(agudo) < 90) {
				translate([45,0,25])
				cube([10, 10, 10], center = true);
			}
			else {
				translate([45,0,-25])
				cube([10, 10, 10], center = true);
			}
			
			// Angulo 3
			if (ang21 != 333 && ang22 != 333) {
				translate([-45-25, 45-25, 0])
				translate([0, grosor+ancho, 0])
				rotate(a = [0, 90, 0])
				rotate(a = [0, -ang21, ang22]) 
				cylinder(r = grosor, h = 300, center = true);

				// Muesca3
				if (agudo > 0) {
					translate([-45-25, 45-25, 0])
					translate([0,45,25])
					cube([10, 10, 10], center = true);
				}
				else {
					translate([-45-25, 45-25, 0])
					translate([0,45,-25])
					cube([10, 10, 10], center = true);
				}
			}

			// Angulo 4
			if (ang31 != 333 && ang32 != 333) {
				translate([90-25, 0, 45-25])
				translate([0, 0, grosor+ancho])
				rotate(a = [0, 90, 0])
				rotate(a = [0, -ang31, ang32])
				cylinder(r = grosor, h = 300, center = true);

				// Muesca3
				if (agudo3 > 0) {
					translate([90-25, 0, 45-25])
					translate([0,25,45])
					cube([10, 10, 10], center = true);
				}
				else {
					translate([90-25, 0, 45-25])
					translate([0,25,-45])
					cube([10, 10, 10], center = true);
				}
			}

		}
	}
}
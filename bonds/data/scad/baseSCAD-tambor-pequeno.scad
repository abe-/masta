//http://www.thingiverse.com/thing:5575
module digits(numChars  = 0,
              chars     = [0],
              size      = [1,1,1], 
              center    = false,
              trans     = [0,0,0],
              rot       = [0,0,0],
              spacing   = 1/3, //space between characters is this times character width
              lineWidth = 1/3) { //width of line used to draw is this times the character width
	assign(w = size[0]/(numChars+numChars*spacing-spacing))
	assign(g = w * spacing)
	assign(L = w * lineWidth)
	assign(t = size[2])
	assign(h = (size[1]+L)/2)
	assign(v = h-L)
	assign(x = (w-L)/2) 
	assign(y = (h-L)/2) {
		translate(trans) rotate(rot){
			for (i=[0:numChars-1]) assign(c=chars[i]) translate([(1/2-numChars/2+i)*(w+g),0,-t/2] + (center ? 0 : 1)*size/2) {
				if (c==".")                                                             translate([ 0,L/2-v,t/2]) cube([2*L,2*L,t], center=true); //dot
				if (c==1)                                                               translate([ 0,0,t/2])     cube([L,2*h-L,t], center=true); //1
				if (c==0||      c==2||c==3||      c==5||c==6||c==7||c==8||c==9)         translate([ 0, v,t/2])    cube([w,L,t], center=true); //top
				if (            c==2||c==3||c==4||c==5||c==6||      c==8||c==9||c=="-") translate([ 0, 0,t/2])    cube([w,L,t], center=true); //middle
				if (c==0||      c==2||c==3||      c==5||c==6||      c==8||c==9)         translate([ 0,-v,t/2])    cube([w,L,t], center=true); //bottom
				if (c==0||                  c==4||c==5||c==6||      c==8||c==9)         translate([-x, y,t/2])    cube([L,h,t], center=true); //upper left
				if (c==0||c==2||c==3||c==4||                  c==7||c==8||c==9)         translate([ x, y,t/2])    cube([L,h,t], center=true); //upper right
				if (c==0||c==2||                        c==6||      c==8)               translate([-x,-y,t/2])    cube([L,h,t], center=true); //lower left
				if (c==0||            c==3||c==4||c==5||c==6||c==7||c==8||c==9)         translate([ x,-y,t/2])    cube([L,h,t], center=true); //lower right
			}
		}
	}
}

module tambor(num, posicion, ids, azim, alt) {

	grosor = 12; // calibre del agujero
	ancho = 1.5;
	hprof = grosor + ancho;
	f = .5;
	dimX = 120;
	dimY = 60;

	font_d = 16;
	font_w = dimY*1.35;
	font_h = dimY*.8;

	scale([0.1, 0.1, 0.1]) {
		translate(posicion)
 		difference() {
			difference() {
				difference() {
					union() {
						cylinder(r = dimX, h = dimY, center = true);

						
//						for (n = [0:len(azim)-1]) {
//						  rotate(a = [0, 0, azim[n]-azim[0]+30])
//						  translate([dimX/1.4,0,dimY/2+font_d/2])				
//						  digits(3, ids[n],[font_w,font_h,font_d],true,[0,0,0],[0,0,115],1/9,1/3); 
//						}					

						//Muesca angulo inicial
							rotate(a = [0, 0, 45])
							translate([dimX/1.35,0,dimY/2+font_d/2]) 
							digits(3, num,[font_w*.9,font_h*.9,font_d],true,[0,0,0],[0,0,90],1/9,1/3); 

//  					  	rotate(a = [0, 0, 45]) {
//							translate([dimX*1.25,0,-dimY/2+4])
//							cube([font_w*1.2,font_h,8],center=true);
//							translate([dimX*1.3,0,-dimY/2+font_d/2+8]) 
//							digits(3, num,[font_w*.9,font_h*.9,font_d],true,[0,0,0],[0,0,0],1/9,1/3); 
//						}
					}
					cylinder(r = dimX/1.8, h = dimY*2, center = true);
				}
			}

			// Sustraemos cilindros orientados segun los angulos
			union() {
				for (n = [0:len(azim)-1]) {
					rotate(a = [0, 0, azim[n]-azim[0]+30]) {
						translate([dimX-hprof,0,0]) {
							rotate(a = [0, alt[n], 0]) {
								cylinder(r = grosor, h = 1.5*dimX, center = true);
							}
						}
					}
				}

			}
		}
	}
}
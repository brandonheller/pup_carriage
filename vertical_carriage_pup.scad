// Presumably, this carriage will ride on an extrusion.
// Measured width of OpenBeam, slightly less than actual 15mm.
extrusion_width = 14.90;
roller_dia = 15.57;  // Measured diameter of 3 different Grabercars double 623 w-wheels.
roller_r = roller_dia / 2;
// Using calipers, measure from the edge of the extrusion to side of the wheel.
// This dimension must be slightly less than the sum of the extrusion width + roller dia. 
wheel_extrusion_len = 29.60;
// extra_squeeze helps to ensure that the rollers makes contact with the beam
// before tightening the tensioning screw, even if any measurements are off,
// screw holes for the rollers are drilled at a skewed angle, or screw holes are
// slightly enlarged and enable the screws to splay out a bit under tension.
// The ~2mm of screw adjustment from the slot is not a lot, and it's better
// to have the beam w/the single roller stretch out than to not get enough
// tension.
extra_squeeze = 0.3;
roller_x_offset = wheel_extrusion_len - roller_r - (extrusion_width / 2) - extra_squeeze;
beam_width = 10.0;
main_cube_width = (roller_x_offset + beam_width / 2) * 2;
main_cube_length = 40;
main_height = 8;
height_offset = 0;
rod_fastener_height = 10 + main_height;
rod_fastener_width = 14;
rod_fastener_length = 8;

round_r = 3;
pad = 0.1;
smooth = 50;

rod_offset = 3;

bearing_inset = 1.5;

cutter_bag = 2;
minimal_cut = (main_cube_width/4)*0.3;
rest_cut = (main_cube_width/4)*0.7;

m3_nut_slop = 0.25;  // Account for inability for layer height to exactly match nut width.
m3_nut_dia = 5.18 + m3_nut_slop;
m3_nut_r = m3_nut_dia / 2;
m3_nut_thickness = 2.35;

delta = 0.01;  // Small value to avoid visual artifacts for coincident surfaces.

module oval(w,h, height, center = false) {
  scale([1, h/w, 1]) cylinder(h=height, r=w, $fn=150, center=center);
}

module main_part()
{
  cube([main_cube_width, main_cube_width, main_height+height_offset], center = true);
  translate([0, main_cube_width/2, 0]) {
    cylinder(r=main_cube_width/2, h=main_height+height_offset, $fn=150, center = true);
  }
}

module cutter()
{
  translate([main_cube_width/4+minimal_cut/2, cutter_bag/2, 0]) {
    cube([minimal_cut+cutter_bag, cutter_bag, main_height + height_offset + 2], center = true);
  }
  translate([main_cube_width/4+minimal_cut, -main_cube_length/8, height_offset/2]) {
    cube([cutter_bag, main_cube_length/4+cutter_bag, main_height + (height_offset*2) + 2], center = true);
    rotate([0, 90, 0]) {
      cylinder(r=1.5, h=100, $fn=100, center = true);
    }
  }
  translate([main_cube_width/4+rest_cut, -main_cube_length/4, 0]) {
    cube([rest_cut, cutter_bag, main_height + height_offset + 2], center = true);
  }
}

module rod_rounding()
{
  translate([0, -rod_fastener_length/2+round_r, rod_fastener_height/2-round_r+(height_offset/2)]) {
    difference() {
      translate([0,-round_r+pad,round_r+pad])
        cube([rod_fastener_width+2*pad, round_r*2+pad, round_r*2+pad], center = true);
      rotate(a=[0,90,0]) {
        cylinder(rod_fastener_width+4*pad,round_r,round_r,center=true,$fn=smooth);
      }
    }
  }
}

module rod_holder()
{
  translate([(main_cube_width/2) - (rod_fastener_width/2) + rod_offset, -main_cube_length/2, rod_fastener_height/2 - main_height/2]) {
    difference() {
      union() {
        cube([rod_fastener_width, rod_fastener_length, rod_fastener_height+height_offset], center = true);
        translate([rod_fastener_width/2-rod_offset, rod_fastener_length/2-rod_offset/2, -rod_fastener_height/2+main_height/2]) {
          cylinder(main_height + height_offset, rod_offset, rod_offset, center=true, $fn=smooth);
        }
      }

      translate([0, -rod_fastener_length/2, -rod_fastener_height/2]) {
        rotate([23, 0, 0]) {
          cube([rod_fastener_width+0.2, 7.5, 100], center = true);
        }
      }

      translate([rod_fastener_width/2, 0, rod_fastener_height/2]) {

        translate([0, 0, -(rod_fastener_height-main_height)/2]) {
          difference() {
            translate([0, 0, 4]) {
              rotate([0, 0, 0]) {
                cube([rod_fastener_width-0.2, rod_fastener_length*2 + 0.2, rod_fastener_height/2 + 0.2], center = true);
              }

              rotate([25, 0, 0]) {
                cube([rod_fastener_width-0.2, rod_fastener_length*2 + 0.2, rod_fastener_height/2 + 0.2], center = true);
              }

              rotate([-25, 0, 0]) {
                cube([rod_fastener_width-0.2, rod_fastener_length*2 + 0.2, rod_fastener_height/2 + 0.2], center = true);
              }
            }


            rotate([0, -90, 0]) {
              cylinder(h = rod_fastener_width/1, r1 = 2.5, r2 = 8, center = false, $fn=100);
            }
          }
        }
      }

      // Holes for rod end mounts
      translate([0, 0, (rod_fastener_height/3-2)+(height_offset)]) {
        rotate([0, 90, 0]) {
          cylinder(r=1.5, h=100, $fn=100, center = true);
        }
      }
      // Nut traps for rod end mounts
      translate([-rod_fastener_width/2 - delta, 0, (rod_fastener_height/3-2)+(height_offset)]) {
        rotate([30, 0, 0]) rotate([0, 90, 0]) {
          cylinder(r=m3_nut_r, h=m3_nut_thickness + delta, $fn=6);
        }
      }
      rod_rounding();
      mirror([ 0, 1, 0 ]) {
        rod_rounding();
      }
    }
  }
}

module main_carriage()
{
  translate([0, 0 , (main_height + height_offset)/2]) {
    difference() {
      main_part();
      translate([0, 0, (-main_height/2)]) {
        //cube([17, 100, height_offset+0.2], center = true);
      }
      if (height_offset > 0 ) {
        translate([0, 0, (-main_height/2)-height_offset-2]) {
          rotate([90, 0, 0]) {
            //cylinder(r=main_cube_width/4, h=100, $fn=150, center = true);
            //oval(main_cube_width/4, main_cube_width/6, 100, true);
            oval(17.8/2, main_cube_width/4.0, 100, true);
          }
        }
      }
      translate([0, main_cube_length/4, 0]) {
        cube([main_cube_width/2, main_cube_length/2, main_height + height_offset + 2], center = true);
      }
      translate([0, main_cube_length/2, 0]) {
        cylinder(r=main_cube_width/4, h=main_height + height_offset + 2, $fn=100, center = true);
        oval(main_cube_width/4, main_cube_length/3, main_height + height_offset + 2, $fn=100, center = true);
      }
      // Hole for roller closest to the corner
      translate([-roller_x_offset, -main_cube_length/4, 0]) {
        cylinder(r=1.5, h=100, $fn=100, center = true);
        if (height_offset > 0 ) {
          translate([0, 0, -main_height/2-height_offset+bearing_inset]) {
            difference() {
              cylinder(r=12/2, h=bearing_inset+0.2, $fn=150, center = true);
              cylinder(r=5/2, h=bearing_inset+0.2, $fn=150, center = true);
            }
          }
        }
      }

      // Holes for belt_holder
      translate([-roller_x_offset, main_cube_length/8, height_offset/2]) {
        translate([0, 3, 0]) {
          rotate([0, 0, 0]) {
            cylinder(r=1.5, h=20, $fn=100, center = true);
          }
        }
        translate([0, -3, 0]) {
          rotate([0, 0, 0]) {
            cylinder(r=1.5, h=20, $fn=100, center = true);
          }
        }
      }


      // Hole for roller farthest from rod holders, on side w/2 rollers
      translate([-roller_x_offset, main_cube_length/2, 0]) {
        cylinder(r=1.5, h=100, $fn=100, center = true);
        if (height_offset > 0 ) {
          translate([0, 0, -main_height/2-height_offset+bearing_inset]) {
            difference() {
              cylinder(r=12/2, h=bearing_inset+0.2, $fn=150, center = true);
              cylinder(r=5/2, h=bearing_inset+0.2, $fn=150, center = true);
            }
          }
        }
      }
      // Hole for roller on side w/1 roller
      translate([roller_x_offset, (main_cube_length/3)/2, 0]) {
        cylinder(r=1.5, h=100, $fn=100, center = true);
        if (height_offset > 0 ) {
          translate([0, 0, -main_height/2-height_offset+bearing_inset]) {
            difference() {
              cylinder(r=12/2, h=bearing_inset+0.2, $fn=150, center = true);
              cylinder(r=5/2, h=bearing_inset+0.2, $fn=150, center = true);
            }
          }
        }
      }


      cutter();

      // Cut for belt.
      translate([0, 0, (main_height+height_offset)/2]) {
        cube([13, 100, 1], center = true);
      }

      // Holes near the rod mounts, probably for screws to tie drive line.
      translate([9, -main_cube_length/4, 0]) {
        cylinder(r=1.5, h=main_height+height_offset+0.2, $fn=100, center = true);
      }
      translate([-9, -main_cube_length/4, 0]) {
        cylinder(r=1.5, h=main_height+height_offset+0.2, $fn=100, center = true);
      }
      // Nut trap for tensioning screw
      translate([-roller_x_offset - beam_width / 2 + m3_nut_thickness, -main_cube_length/8, 0]) {
        rotate([30, 0, 0]) rotate([0, 270, 0]) {
          cylinder(r=m3_nut_r, h=m3_nut_thickness + delta, $fn=6);
        }
      }
    }

    rod_holder();
    mirror([ 1, 0, 0 ]) {
      rod_holder();
    }

  }
}


module belt_holder()
{
  difference() {
    union() {
      cube([10, 12, 15], center = true);
      translate([0, 0, -15/2]) {
        difference() {
          union() {
            cube([10, 40, 3], center = true);
            cube([18, 10, 3], center = true);
            translate([-18/2, 0, 0]) {
              cylinder(3, r=10/2, r=10/2, center=true, $fn=150);
            }
            translate([18/2, 0, 0]) {
              cylinder(3, r=10/2, r=10/2, center=true, $fn=150);
            }
          }
          translate([18/2, 0, 0]) {
            cylinder(100, r=3/2, r=3/2, center=true, $fn=150);
          }
          translate([-18/2, 0, 0]) {
            cylinder(100, r=3/2, r=3/2, center=true, $fn=150);
          }
        }
      }
    }
    translate([0, 3, 3]) {
      rotate([0, 90, 0]) {
        cylinder(100, r=3/2, r=3/2, center=true, $fn=150);
      }
    }
    translate([0, -3, 3]) {
      rotate([0, 90, 0]) {
        cylinder(100, r=3/2, r=3/2, center=true, $fn=150);
      }
    }
  }
}


main_carriage();
translate([-main_cube_width, 0, 9]) {
  belt_holder();
}

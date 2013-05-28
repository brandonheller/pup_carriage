// Cerberus Pup-style carriage for Kossel, compatible with Kossel Mini/Pro linear rails

// Steve Graber made the original design.
// Daniel Akesson converted the original into OpenSCAD.
// Brandon Heller tweaked the OpenSCAD to:
// - be compatible with linear rails (thicker, w/20x20 m3 mounting grid)
// - decouple rod mounts from the carriage, and be compatible with the Kosssel effector.

// Kossel Pro and Mini ball rails equivalent to HIWIN Model MGN 12H:
// http://hiwin.com/html/extras/mgn-c_mgn-h.html
// Distance from ball rail attachment plane to outer face of slider, marked H.
ball_rail_H = 13;

// This is the key dimension to enable rail compatibility.
// With the Graber double-623 V-wheels, an m3 nut plus a washer gives ~1mm of clearance.
carriage_extrusion_dist = 1;
main_height = ball_rail_H - carriage_extrusion_dist;

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

pad = 0.1;
smooth = 50;
main_curve_smooth = 150;

// Cut params
cut_width = 2.0;  // Width of cut
minimal_cut = (main_cube_width/4)*0.47;  // Larger values move the main cut (in the y dir) outwards.
rest_cut = (main_cube_width/4)*0.75; // Distance to make the cut that exits the outside of the carriage.

// Roller holes
roller_y_offset = (main_cube_length/3)/2;
roller_y_offset_each = main_cube_length*(3/4)/2;

m3_nut_slop = 0.25;  // Account for inability for layer height to exactly match nut width.
m3_nut_dia = 6.18 + m3_nut_slop;
m3_nut_r = m3_nut_dia / 2;
m3_nut_thickness = 2.35;

m3_screw_slop = 0.1;
m3_screw_dia = 3.0 + m3_screw_slop;
m3_screw_r = m3_screw_dia / 2;
m3_screw_head_slop = 0.3;
m3_screw_head_r = 5.5/2 + m3_screw_head_slop;
m3_screw_head_len = 3.0;  // SHCS
m3_screw_head_gap = 0.5;

delta = 0.02;  // Small value to avoid visual artifacts for coincident surfaces.

module oval(w,h, height, center = false) {
  scale([1, h/w, 1]) cylinder(h=height, r=w, $fn=main_curve_smooth, center=center);
}

module main_part()
{
  cube([main_cube_width, main_cube_width, main_height], center = true);
  translate([0, main_cube_width/2, 0]) {
    cylinder(r=main_cube_width/2, h=main_height, $fn=main_curve_smooth, center = true);
  }
}

module cut()
{
  // Cut from center of part out, along x
  translate([main_cube_width/4+minimal_cut/2, cut_width/2, 0]) {
    cube([minimal_cut+cut_width, cut_width, main_height + 2], center = true);
  }
  // Cut along y and corresponding screw hole through body
  translate([main_cube_width/4+minimal_cut, -main_cube_length/8, 0]) {
    cube([cut_width, main_cube_length/4+cut_width, main_height + 2], center = true);
    rotate([0, 90, 0]) {
      cylinder(r=m3_screw_r, h=100, $fn=smooth, center = true);
    }
  }
  // Nut trap for tensioning screw
  translate([-main_cube_width/2+delta, -main_cube_length/8, 0]) {
    rotate([30, 0, 0]) rotate([0, 90, 0]) {
      cylinder(r=m3_nut_r, h=m3_nut_thickness+delta, $fn=6, center=true);
    }
  }
  // Cut to outer edge of part, along x
  translate([main_cube_width/4+rest_cut, -main_cube_length/4, 0]) {
    cube([rest_cut, cut_width, main_height + 2], center = true);
  }
}

module main_carriage()
{
  translate([0, 0, (main_height)/2]) {
    difference() {
      main_part();

      // Square cutout in center
      translate([0, main_cube_length/4, 0]) {
        cube([main_cube_width/2, main_cube_length/2, main_height + 2], center = true);
      }

      // Oval cutout at rounded end
      translate([0, main_cube_length/2, 0]) {
        oval(main_cube_width/4, main_cube_length/3, main_height + 2, $fn=smooth, center = true);
      }

      // Holes for rollers
      translate([0, roller_y_offset, 0]) {
        // On side w/2 rollers:
        for (i=[-1, 1]) {
          translate([-roller_x_offset, roller_y_offset_each * i, 0]) {
            cylinder(r=m3_screw_r, h=100, $fn=smooth, center = true);
            translate([0, 0, main_height/2-m3_screw_head_len-m3_screw_head_gap])
              cylinder(r=m3_screw_head_r, h=100, $fn=smooth);
          }
        }
        // On side w/1 roller
        translate([roller_x_offset, 0, 0]) {
          cylinder(r=m3_screw_r, h=100, $fn=smooth, center = true);
          translate([0, 0, main_height/2-m3_screw_head_len-m3_screw_head_gap])
            cylinder(r=m3_screw_head_r, h=100, $fn=smooth);
        }
      }

      // Cut, plus corresponding screw and nut trap.
      cut();

      // 20x20 m3 grid to match HIWIN rails.
      translate([0, 1.5, 0]) {
        translate([10, -10, 0]) cylinder(r=m3_screw_r, h=100, $fn=50, center=true);
        translate([10, -10, -main_height/2-delta]) cylinder(r=m3_nut_r, h=m3_nut_thickness+delta, $fn=6);
        for (i=[-1, 1]) {
          translate([-10, i*10, 0]) cylinder(r=m3_screw_r, h=100, $fn=50, center=true);
          translate([-10, i*10, -main_height/2-delta]) cylinder(r=m3_nut_r, h=m3_nut_thickness+delta, $fn=6);
        }
      }

    }
  }
}

main_carriage();

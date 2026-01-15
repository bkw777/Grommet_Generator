// Toyota glove box latch grommet
// Default values are for 2025 4runner.

// For other years/models, use the customizer panel to change these values
// and save the config with a name with the model & year:
//   NOTES
//   glove_box_hole_vertical
//   glove_box_hole_horizontal
//   pawl_hole_horizontal_offset

// all values in mm
// the "// 0.1" comments tell the customizer panel to let you enter n.n values even if the normal default value happens to be a whole number

/* [Vehicle Site Reference Dimensions] */
NOTES = "Install with the thick wall towards the rear of the vehicle.";
glove_box_wall_thickness = 2;      // 0.1
glove_box_hole_vertical = 13;      // 0.1
glove_box_hole_horizontal = 13;    // 0.1
pawl_horizontal = 8;               // 0.1
pawl_vertical = 8;                 // 0.1

/* [Parameters] */
fitment_clearance = 0.1;           // 0.1
corner_radius = 1.5;               // 0.1

retainer_thickness = 2;            // 0.1
retainer_oversize = 0.2;           // 0.1
tip_undersize = 0.1;               // 0.1

flange_thickness = 1.5;            // 0.1
flange_overhang = 1;               // 0.1

pawl_clearance = 0.5;              // 0.1
pawl_hole_horizontal_offset = 0.8; // 0.1
pawl_hole_vertical_min_wall = 1;   // 0.1
pawl_hole_corner_radius = 1;       // 0.1


fc = fitment_clearance;
cr = corner_radius;
wall_thickness = glove_box_wall_thickness;
trunk_width = glove_box_hole_vertical - fc*2;
trunk_depth = glove_box_hole_horizontal - fc*2;
retainer_width = trunk_width + retainer_oversize*2;
retainer_depth = trunk_depth + retainer_oversize*2;
flange_width = trunk_width + flange_overhang*2;
flange_depth = trunk_depth + flange_overhang*2;
hole_width = trunk_width - pawl_hole_vertical_min_wall*2;
hole_depth = pawl_horizontal + pawl_clearance*2;
z_offset = $preview ? -flange_thickness : 0 ;

min_hole_width = pawl_vertical + pawl_clearance*2;
assert(hole_width >= min_hole_width);
// The hole width and depth come out almost the same, but they actually reference off of different things.
//
// The hole depth is the front-to-back size.
// It's the horizontal size of the pawl plus 2 times the pawl horizontal clearance.
// IE, it's as small as possible for the least door-rattle.
//
// The hole width is the top-to-bottom size.
// It's the vertical size of the grommet trunk minus 2 times the pawl hole minimum wall thickness.
// EI, it's as large as possible for the least chance of the side of the pawl hitting the side of the hole.
//
// In the case of the 2025 4Runner, the hole in the glove box and the shape of the pawl are both perfectly square,
// so the hole ends up coming out close to square too. But other vehicles have other dimensions where the distiction may have more effect.

/* [Hidden] */
// arc smoothness
//$fn = 32;
$fa = 6;
$fs = 0.1;

include <lib/handy.scad>;

translate([0,0,z_offset]) difference() {
  tt = flange_thickness + wall_thickness + retainer_thickness;
  union() {
    qt = retainer_thickness/4;
    it = flange_thickness/2 + wall_thickness + qt;
    // flange
    difference() {
      translate([0,0,flange_thickness]) rounded_cube(w=flange_width,d=flange_depth,h=flange_thickness*2,rh=cr+flange_overhang,rv=flange_thickness); // double thick
      translate([0,0,flange_thickness*2]) cube([flange_width+1,flange_depth+1,flange_thickness*2],center=true); // cut away half
    }
    // trunk
    translate([0,0,it/2+flange_thickness/2]) rounded_cube(w=trunk_width,d=trunk_depth,h=it,rh=cr,rv=0);
    // retainer
    translate([0,0,flange_thickness+wall_thickness]) hull() {
      translate([0,0,qt]) rounded_cube(w=retainer_width,d=retainer_depth,h=qt*2,rh=cr+retainer_oversize,rv=qt); // big end
      translate([0,0,qt*3]) rounded_cube(w=trunk_width-tip_undersize*2,d=trunk_depth-tip_undersize*2,h=qt*2,rh=cr+retainer_oversize,rv=qt); // small end
    }
  }
  // hole
  translate([0,pawl_hole_horizontal_offset,tt/2]) rounded_cube(w=hole_width,d=hole_depth,h=tt+2,rh=pawl_hole_corner_radius,rv=0);
}

echo ();
echo ("****************************************");
echo ();
echo (NOTES);
echo ();
echo ("****************************************");
echo ();

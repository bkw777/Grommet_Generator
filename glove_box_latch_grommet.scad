// Toyota glove box latch grommet
// Default values are for 2025 4runner.

// For other years/models, use the customizer panel to change these values
// and save the config with a name with the model & year:
//   NOTES
//   glove_box_hole_vertical
//   glove_box_hole_horizontal
//   pawl_hole_horizontal_offset

// all values in mm
// the "// 0.1" comments control the customizer panel numerical fields

/* [Vehicle Site Reference Dimensions] */
NOTES = "Install with the thick wall towards the door.";
glove_box_wall_thickness = 2.5;    // 0.1
glove_box_hole_vertical = 13;      // 0.1
glove_box_hole_horizontal = 13;    // 0.1
pawl_horizontal = 8;               // 0.1
pawl_vertical = 8;                 // 0.1

/* [Parameters] */
fitment_clearance = 0.05;          // 0.01
corner_radius = 1;                 // 0.1

retainer_thickness = 2;            // 0.1
retainer_oversize = 0.1;           // 0.01
tip_undersize = 0.2;               // 0.1
retainer_ramp_percent = 66;        // [25:100]
retainer_slots_width = 1;          // 0.1
retainer_slots_depth_percent = 0;  // [0:100]

flange_thickness = 1.2;            // 0.1

pawl_clearance = 0.5;              // 0.1
pawl_hole_horizontal_offset = 0.8; // 0.1
pawl_hole_vertical_min_wall = 1;   // 0.1
pawl_hole_corner_radius = 1;       // 0.1

/* [Hidden] */

e = 0.1; // epsilon

// arc smoothness
//$fn = 32;
$fa = 6;
$fs = 0.1;

fc = fitment_clearance;
cr = corner_radius;
wall_h = glove_box_wall_thickness;
trunk_w = glove_box_hole_vertical - fc*2;
trunk_d = glove_box_hole_horizontal - fc*2;
ret_o = retainer_oversize;
ret_u = tip_undersize;
ret_w = trunk_w + ret_o*2;
ret_d = trunk_d + ret_o*2;
ret_h = retainer_thickness;
ramp_h = ret_h - ret_o - (((ret_h-ret_o)/100) * retainer_ramp_percent);
flange_h = flange_thickness;
flange_w = trunk_w + flange_h*2;
flange_d = trunk_d + flange_h*2;
hole_w = trunk_w - pawl_hole_vertical_min_wall*2;
hole_d = pawl_horizontal + pawl_clearance*2;
csw = (retainer_slots_width<0.8) ? 0 : retainer_slots_width ;
csl = (trunk_w+trunk_d) / 2;
csh =  wall_h + ret_h + e;
csz = wall_h - ((wall_h/100) * retainer_slots_depth_percent);
z_offset = $preview ? -flange_h : 0 ;

min_hole_w = pawl_vertical + pawl_clearance*2;
assert(hole_w >= min_hole_w);
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

module mirror_copy(v) {
 children();
 mirror(v) children();
}

// square cylinder
module sqyl (w=0,d=0,h=0,r=0,r1=-1,r2=-1) {
 ra = (r1<0) ? r : r1 ;
 rb = (r2<0) ? r : r2 ;
 R = max(ra,rb);
 hull()
   mirror_copy([0,1,0])
     mirror_copy([1,0,0])
       translate([w/2-R,d/2-R,0])
         cylinder(h=h,r1=ra,r2=rb,center=true);
}

module u (w,d,h) {
  r = w/2;
  translate([0,0,r/2])
    cube([w,d,h-r],center=true);
  translate([0,0,r-h/2])
    rotate([90,0,0])
      cylinder(h=d,r=r,center=true);
}

module grommet() {
  difference() {
    union() {

      // flange
      translate([0,0,flange_h/2])
        sqyl(w=flange_w,d=flange_d,h=flange_h,r1=cr,r2=cr+flange_h);

      // trunk
      ht = wall_h + e*2;
      translate([0,0,ht/2+flange_h-e])
        sqyl(w=trunk_w,d=trunk_d,h=ht,r=cr);

      // retainer
      ha = ret_o; // 45 deg
      hb = ret_h - ramp_h - ha;
      translate([0,0,flange_h+wall_h]) hull() {
        tw = trunk_w+ret_o*2;
        td = trunk_d+ret_o*2;
        translate([0,0,ha/2])
          sqyl(w=tw,d=td,h=ha,r1=cr,r2=cr+ret_o);
        translate([0,0,ret_h-hb/2])
          sqyl(w=tw,d=td,h=hb,r1=cr+ret_o,r2=cr-ret_u);
      }
    }

    // hole
    hh = flange_h + wall_h + ret_h + e*2;
    translate([0,pawl_hole_horizontal_offset,hh/2-e])
      sqyl(w=hole_w,d=hole_d,h=hh,r=pawl_hole_corner_radius);

    // compliant slots
    if (csw&&retainer_slots_depth_percent)
      translate([0,0,csh/2+flange_h+csz])
        mirror_copy([0,1,0])
          mirror_copy([1,0,0])
            translate([trunk_w/2,trunk_d/2,0])
              rotate([0,0,-45])
                u(w=csw,d=csl,h=csh);
  }
}

translate([0,0,z_offset]) grommet();

echo ();
echo ("****************************************");
echo ();
echo (NOTES);
echo ();
echo ("****************************************");
echo ();

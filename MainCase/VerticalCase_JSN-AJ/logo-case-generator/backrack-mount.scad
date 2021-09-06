use <tjw-scad/spline.scad>
include <BOSL2/std.scad>
include <BOSL2/metric_screws.scad>
// measured distance between the two tubes to be used for mounting (inner edges).
tube_distance=80.6;

// diameter of the two tubes used for mounting
tube_diam_raw=12.4;

// relative position of obs clamp
position=0.8;

// clearance: added to tube radius for tolerance
clearance=.2;

// screwhole_diameter (screw) 
// 3.25 should comfortably fit m3
screwhole_diameter=3.25;

// hotmelt_hole_diameter
// this was ok for 4.6mm hotmelt nuts for me
hotmelt_hole_diameter = 4;

tube_diam=tube_diam_raw+2*clearance;
distance=tube_distance+tube_diam_raw-2*clearance;
b=-distance/2; 
f=distance/2;
r=tube_diam/2+4;
pos=b+position*distance;

module clamp() 
{
  translate([14.5,0,0])difference()
  {
    import("../OBS-Mounting-A-002_StandardSeatPostMount_v0.1.1.stl");
    translate([-13,0,17+7.48])cube([35,53,34],center=true);
  }
}

module cutter() {
    translate([0,31,0])rotate([90,0,0])linear_extrude(height=31)
polygon([
  [b-r,-r-0.1],[b-r,0],[b+r-2,0],[b+r+2,r/sqrt(2)-2],[f-r-2,r/sqrt(2)-2],[f-r+2,0],[f+r,0],[f+r,-r-0.1]]);  
}

module tubus() {
    $fn=60;
    translate([distance/2,15,0])rotate([90,0,0])cylinder(100,r=tube_diam/2,center=true);
    translate([-distance/2,15,0])rotate([90,0,0])cylinder(100,r=tube_diam/2,center=true);

    
}

module screwholes(size=3., dz=1) {
    hole=size;
    $fn=20;
    translate([b+2*tube_diam,5,dz]) rotate([180,0,0]) metric_bolt(headtype="socket", anchor="base", size=hole, l=15, details=false, pitch=0);
translate([f-2*tube_diam,5,dz]) rotate([180,0,0]) metric_bolt(headtype="socket", anchor="base", size=hole, l=15, details=false, pitch=0);
        translate([b+2*tube_diam,31-5,dz]) rotate([180,0,0]) metric_bolt(headtype="socket", anchor="base", size=hole, l=15, details=false, pitch=0);
translate([f-2*tube_diam,31-5,dz]) rotate([180,0,0]) metric_bolt(headtype="socket", anchor="base", size=hole, l=15, details=false, pitch=0);
}

module braces() {
   
    difference(){
        union() {
    translate([0,31,00])rotate([90,0,0])
      linear_extrude(height=31) polygon(
       smooth(
    [[pos,r],[pos,r+18],[pos,r+30],[pos,69],[b*(1-position),31.5],[b+r,r+3],[b,r+1],[b-r/sqrt(2),r/sqrt(2)],[b-r,0],[b-r/sqrt(2),-r/sqrt(2)],[b,- r],[b+r/sqrt(2),-r/sqrt(2)],[b+2*r, -2],[f-2*r,-2],[f-r/sqrt(2),-r/sqrt(2)],[f, - r], [f+r/sqrt(2),-r/sqrt(2)],[f+r,0],[f+r/sqrt(2),r/sqrt(2)],[f, r],[f-r, r],[f-2*r,r]],4,loop=false
    ),convexity=5);
        translate([0.05,31,0])rotate([90,0,0])linear_extrude(height=31) polygon([[pos,4],[pos,64],[pos-2,64],[pos-2,4]]);}
       translate([pos+0.05,-40,r+0.5])cube([100,100,100]);
    }
}
module mount() {
    translate([-16.5,2.4+14+r,0])clamp();
}
module upper() {
    translate([7.5+pos,0,tube_diam/2+3+12])rotate([90,0,270])mount();

difference() {
    braces(); 
    #tubus();
    cutter();
    #screwholes(hotmelt_hole_diameter);
} 
}

module lower() {
intersection(){
    cutter();
    difference() {
    braces();
    #tubus();
    #screwholes(screwhole_diameter, -1);
} 
}
}

upper();

translate([0,0,-3]) lower();
echo(-b+f-tube_diam_raw);
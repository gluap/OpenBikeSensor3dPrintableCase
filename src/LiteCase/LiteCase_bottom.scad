use <../../lib/Round-Anything/polyround.scad>


corner_x = 24;
boardcorner_x = 17;
boardcorner_y = 23;
square_x = 5;
lite_l = 45;
lite_w = 80 - 18;


// 0,0,0: Mitte des Lite-PCB, auf der Seite mit dem OpenBIkeSensor logo, x: Richtung USB-Port, Z: Richtung Ultraschallsensoren
$fn = 120;

Lite_PCB_x = 44;
Lite_PCB_y = 29.2;
Lite_PCB_z = 1.7;
Lite_PCB_Dimensions = [Lite_PCB_x, Lite_PCB_y, Lite_PCB_z];

Lite_ESP_socket_x = 38;
Lite_ESP_socket_y = 2.54;
Lite_ESP_socket_z = 9;
Lite_ESP_socket_dimensions = [Lite_ESP_socket_x, Lite_ESP_socket_y, Lite_ESP_socket_z];

Lite_transducer_position = [23.8, 0, 20.1];
Lite_transducer_variance = 0.8;
Lite_transducer_diameter = 16 + Lite_transducer_variance;
Lite_transducer_diameter_small = 12.5 + Lite_transducer_variance;

Lite_ESP_position_x = 0;
Lite_ESP_position_y = 0;
Lite_ESP_position_z = - 15.2;

Lite_USB_position_x = 55;
Lite_USB_position_y = 0;
Lite_USB_position_z = - 15;

Lite_USB = [Lite_USB_position_x, Lite_USB_position_y, Lite_USB_position_z];

Lite_ESP_position = [Lite_ESP_position_x, Lite_ESP_position_y, Lite_ESP_position_z];

sensor_x = - Lite_transducer_position[2];
sensor_y = Lite_transducer_position[0];

function angle_three_points_2d(pa, pb, pc) = asin(cross(pb - pa, pb - pc) / (norm(pb - pa) * norm(pb - pc)));

module side_polygon() {
  corners = [
      [square_x, - lite_w / 2, 9],
    // chose radius so the corners match
      [- corner_x, - 0, (corner_x - boardcorner_x) / (1 / sin(angle_three_points_2d([0, 0], [- corner_x, - 0], [square_x, lite_w / 2])) - 1)],
      [square_x, lite_w / 2, 9],
      [lite_l, lite_w / 2, 5],
      [lite_l, - lite_w / 2, 5]
    ];
  translate([sensor_x, sensor_y])polygon(polyRound(corners, fn = 150));
}

module LidCutter() {
  translate([30, 0, Lite_ESP_position_z+1])cube([80, 40, 0.1], center = true);
}
module middle_polygon() {
  corners = [[square_x, - lite_w / 2, 5], [- boardcorner_x, - boardcorner_y, 5], [- boardcorner_x, boardcorner_y, 5], [square_x, lite_w / 2, 5], [lite_l, lite_w / 2, 5], [lite_l, -
  lite_w / 2, 5]];
  translate([sensor_x, sensor_y]) polygon(polyRound(corners));
}

module box_outside()
hull() {
  for (i=[-1,1]){
  translate([0, 0, i*9 - (i+1)/2])linear_extrude(1)middle_polygon();
  translate([0, 0, i*18 - (i+1)/2])linear_extrude(1)side_polygon();
}
}

module ESP() {
  difference() {
    color("black")translate([25, 0, 0])cube([51.5, 28.5, 4.5], center = true);
    for (i = [- 1, 1])for (j = [- 1, 1]) {
      #translate([i*24+23, j * 12.5-2.5, -4.3])cube([4,5,5]);
    }
  }
}

module Ultrasonic(i, onlyboards = false, h = 30) {
  translate([0, 0, - h / 2 + 34 / 2]) {
    color("blue") translate([23.9, i * 7.3, 17.99])cube([42.5, 1.4, h], center = true);
    hull() {
      translate([Lite_transducer_position[0], 0, 14.99])cube([42.5, 21.5, h], center = true);
      translate([Lite_transducer_position[0], 0, 16.99])cube([42.5, 16.5, h], center = true);
      translate([Lite_transducer_position[0], 0, 10.99])cube([49.5, 18.5, h], center = true);
    }
    intersection() {
      translate([0, 0, + h / 2 - 34 / 2])hull() {
        translate(Lite_transducer_position - [0, 8 * i, 100])rotate([i * 90, 0, 0])cylinder(d1 = Lite_transducer_diameter + 12, d2 = Lite_transducer_diameter, h = 8.5);
        translate(Lite_transducer_position - [0, 8 * i, 0])rotate([i * 90, 0, 0])cylinder(d1 = Lite_transducer_diameter + 12, d2 = Lite_transducer_diameter, h = 8.5);
      }
      color("blue") translate([23.9, i * 7, 17.99])cube([41.5, 60, h + 14], center = true);

    }
  }
  translate(Lite_transducer_position - [0, 8 * i, 0])rotate([i * 90, 0, 0])cylinder(d = Lite_transducer_diameter_small, h = 40);
}

module USB_hole() {
  translate(Lite_USB)cube([20, 12, 10], center = true);
}


module LiteElectronics(onlyboards = false) {
  // the rendered model from stls (not closed, only for preview)
  if (!$preview) translate([15, 0, 0])rotate([180, 00, 00])rotate([0, 0, 90])import("../../lib/OpenBikeSensor-Lite-PCB-0.1.2.stl");

  // board cube
  color("green")translate(- [0, Lite_PCB_y / 2, Lite_PCB_z])cube(Lite_PCB_Dimensions, center = false);
  color("green")translate(- [0.2, Lite_PCB_y / 2 + 0.2, Lite_PCB_z + 15])cube(Lite_PCB_Dimensions + [0.4, 0.4, 15], center = false);


  // sockets for ESP
  for (i = [- 1, 1]) color("darkgrey")translate([3.5, i * Lite_PCB_y / 2 - (i + 1) * Lite_ESP_socket_y / 2 - i * 0.45, - Lite_ESP_socket_dimensions[2] - Lite_PCB_Dimensions[2]])
    cube(Lite_ESP_socket_dimensions);

  translate(Lite_ESP_position)ESP();

  for (i = [- 1, 1])Ultrasonic(i, onlyboards = onlyboards, h = 50);
  USB_hole();
}
//LiteElectronics();
/*
intersection() {translate([- 5, - 17.5, 0])cube([80, 17.5 * 2, 50]);
  difference() {
    //rotate([90,90,0])box_outside();

    minkowski() {sphere(0.8);intersection() {
      translate([- 5, - 17.5, 0])cube([80, 17.5 * 2, 50]);
      for (i = [- 1, 1])Ultrasonic(i);}
    }
    intersection() {
      translate([- 5, - 30, 0])cube([80, 50, 50]);
      for (i = [- 1, 1])Ultrasonic(i);}
    for (i = [- 1, 1])translate(Lite_transducer_position - [0, 8 * i, 0])rotate([i * 90, 0, 0])cylinder(d = Lite_transducer_diameter_small, h = 40, $fn = 100);

  }

}
*/
difference() {
  rotate([90, 90, 0])box_outside();
  LiteElectronics();
  LidCutter();
}

if (!onlyboards) translate([15, 0, 0])rotate([180, 00, 00])rotate([0, 0, 90])import("../../lib/OpenBikeSensor-Lite-PCB-0.1.2.stl");

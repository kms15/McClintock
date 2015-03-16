include <dimensions.scad>
include <miscHardwareDimensions.scad>

offset=20;
height=40;
wallThickness=5;
centralTriangleWallLength = (offset + wallThickness) * 4/sqrt(3);
postDiameter=8;

module bodyFrame() {
    difference() {
        union() {
            rotate([-45, 0, 0])
                translate([0, 0, -height * sqrt(2)/2])
                cylinder(r=postDiameter/2 + clearance/2 + wallThickness,
                    h=sqrt(2)*height + wallThickness);
                for (i = [0:2]) {
                    rotate([0, 0, 120*i]) {
                        translate([-offset, -centralTriangleWallLength/2,
                                -height/2])
                            cube([wallThickness,
                                shoulderRadius + centralTriangleWallLength/2,
                                height]);
                        translate([-offset, shoulderRadius, 0])
                            rotate([0, 90, 0])
                            cylinder(r=height/2, h=wallThickness);
                    }
                }
        }
        rotate([-45, 0, 0]) {
            translate([0, 0, -overcut - height])
                cylinder(r=postDiameter/2 + clearance/2,
                    h=2*height + 2*overcut);
            translate([0, 0, -overcut - height])
                cylinder(r=postDiameter/2 + wallThickness + clearance,
                    h=(1 - sqrt(2)/2) * height + overcut);
        }
        //translate([0, 0, height/2])
        //    cylinder(r=shoulderRadius, h=height);
        translate([0, 0, -height * 3/2])
            cylinder(r=shoulderRadius, h=height);
        for (i = [0:2]) {
            rotate([0, 0, 120*i])
                translate([-offset - overcut, shoulderRadius, 0])
                rotate([0, 90, 0]) {
                    cylinder(r=stepperShaftKeepoutDiameter/2,
                        h=wallThickness + 2*overcut);

                    for (j = [0:7]) {
                        rotate([0, 0, j*45])
                            translate([0,
                                stepperInnerMountingHoleRingDiameter/2,
                                0])
                            cylinder(r=stepperMountingScrewDiameter/2 +
                                clearance/2,
                                h=wallThickness + 2*overcut);
                    }
                }
        }
    }
}

translate([0, 0, height/2])
bodyFrame();

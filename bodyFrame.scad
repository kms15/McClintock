include <dimensions.scad>
include <miscHardwareDimensions.scad>

offset=stepperShaftKeepoutLength + stepperShaftFlatLength / 2;
height=40;
wallThickness=5;
centralTriangleWallLength = offset * 4/sqrt(3) + wallThickness/2;
postDiameter=8;

module bodyFrame() {
    $fn = 30;
    difference() {
        union() {
            // mounting cylinder
            rotate([-45, 0, 0])
                translate([0, 0, -height * sqrt(2)/2])
                cylinder(r=postDiameter/2 + clearance/2 + wallThickness,
                    h=sqrt(2)*(height - postDiameter/2
                        - clearance/2 - wallThickness/2) + overcut);

            // the three radial walls
            for (i = [0:2]) {
                rotate([0, 0, 120*i]) {
                    // the wall to the center
                    translate([-offset, -centralTriangleWallLength/2,
                            -height/2])
                        cube([wallThickness,
                            shoulderRadius + centralTriangleWallLength/2,
                            height]);

                    // radius on outside of wall
                    translate([-offset, shoulderRadius, 0])
                        rotate([0, 90, 0])
                        cylinder(r=height/2, h=wallThickness);

                    // buttress for the overhang to make sure it is greater
                    // than or equal to 45 degrees.
                    translate([-offset, shoulderRadius, 0])
                        rotate([-135,0,0])
                        cube([wallThickness, height/2, height/2]);
                }
            }
        }

        rotate([-45, 0, 0]) {
            // the hole in the mounting cylinder
            translate([0, 0, -overcut - height])
                cylinder(r=postDiameter/2 + clearance/2,
                    h=2*height + 2*overcut);

            // clear out the lower shoulder on the mounting cylinder
            translate([0, 0, -overcut - height])
                cylinder(r=postDiameter/2 + wallThickness + clearance,
                    h=(1 - sqrt(2)/2) * height + overcut);

            // clear out the upper shoulder on the mounting cylinder
            translate([0, 0, sqrt(2)*(height/2 - postDiameter/2 -
                    clearance/2 - wallThickness/2)])
                cylinder(r=postDiameter/2 + wallThickness + clearance,
                    h=height + overcut);
        }

        // cut off the bottom of the mounting post to leave a smooth surface
        translate([0, 0, -height * 3/2])
            cylinder(r=shoulderRadius + height, h=height);

        // for each of the three radial walls
        for (i = [0:2]) {
            rotate([0, 0, 120*i])
                translate([-offset - overcut, shoulderRadius, 0])
                rotate([0, 90, 0]) {
                    // cut out the keep-out for the stepper
                    cylinder(r=stepperShaftKeepoutDiameter/2 + clearance,
                        h=stepperShaftKeepoutLength + overcut);

                    // cut out for the stepper shaft (and retaining ring)
                    cylinder(r=stepperShaftDiameter,
                        h=wallThickness + 2*overcut);

                    // cut out the stepper motor mounting holes
                    for (j = [0:3]) {
                        rotate([0, 0, j*90 + 45])
                            translate([0,
                                    stepperInnerMountingHoleRingDiameter/2,
                                    0]) {

                                // the hole for the screw
                                cylinder(r=stepperMountingScrewDiameter/2 +
                                    clearance/2,
                                    h=wallThickness + 2*overcut);

                                // the counter-bored hole
                                translate([0, 0, overcut + minWallThickness +
                                    stepperShaftKeepoutLength])
                                cylinder(r=m3SHCSHeadDiameter/2 +
                                    clearance/2,
                                    h=wallThickness);
                            }
                    }
                }
        }
    }
}

translate([0, 0, height/2])
bodyFrame();

// the distance from the base of a Traxis 5347 rod end to the center of the
// ball joint.
traxxas5347BallHeight = 17;
traxxas5347HornWidth = 6.75;

// a Traxxas 5347 rod end with the base at the origin, the ball on the positive
// z axis, and the ball axis along the x-axis.
module traxxas5347RodEnd(ballXAngle=0, ballZAngle=0) {
    baseDiameter=6.75;
    baseHeight=12;
    slantHeight=4;
    slantAngle=10;
    mountingHoleDiameter=4;
    mountingHoleDepth=6;
    ringDiameter=10;
    ringWidth=3.25;
    ringOpening=5.5;
    ballDiameter=6;
    ballHeight=17;
    buttressLength=8;
    buttressFilletDiameter=8;
    overcut=1;
    hornDiameter=5;
    traxxas5347HornWidth=6.75;
    hornHoleDiameter=3;

    // draw the rod part
    color([0.4, 0.4, 0.4]) {

        // the base below the ring holding the ball
        difference() {
            cylinder(r=baseDiameter/2, h=baseHeight);

            // taper the base towards the ring holding the ball
            translate([baseDiameter/2, -baseDiameter/2, slantHeight])
                rotate([0, -slantAngle, 0])
                cube([baseDiameter/2, baseDiameter, baseHeight]);
            translate([-baseDiameter, -baseDiameter/2, slantHeight])
                rotate([0, slantAngle, 0])
                cube([baseDiameter/2, baseDiameter, baseHeight]);

            // the screw hole in the bottom of the base
            translate([0,0,-overcut])
                cylinder(r=mountingHoleDiameter/2,
                    h=mountingHoleDepth + overcut);
        }

        // the flat ring holding the ball
        translate([0, 0, traxxas5347BallHeight])
        rotate([0,90,0]) {
            difference() {
                union() {
                    // the ring
                    translate([0,0,-ringWidth/2])
                        cylinder(r=ringDiameter/2, h=ringWidth);
                    // the tab connecting the ring to the base
                    translate([0,-ringDiameter/2, -ringWidth/2])
                        cube([buttressLength, ringDiameter, ringWidth]);
                }

                // the fillets between the tab and the base
                translate([
                        buttressLength,
                        -baseDiameter/2 - buttressFilletDiameter/2,
                        -ringWidth/2 - overcut])
                    cylinder(r=buttressFilletDiameter/2,
                        h=ringWidth + 2*overcut);
                translate([buttressLength,
                        baseDiameter/2 + buttressFilletDiameter/2,
                        -ringWidth/2 - overcut])
                    cylinder(r=buttressFilletDiameter/2,
                        h=ringWidth + 2*overcut);

                // the hole for the ball
                translate([0,0,-ringWidth/2 - overcut])
                    cylinder(r=ringOpening/2, h=ringWidth + 2*overcut);
            }
        }
    }

    // draw the ball
    color([0.85, 0.85, 0.85])
    translate([0, 0, traxxas5347BallHeight])
    rotate([-ballXAngle,0,0])
    rotate([0,0, -ballZAngle])
    {
        difference() {
            union() {
                // the ball
                sphere(r=ballDiameter/2);

                // the two horns/cones coming out of the ball
                rotate([0, -90, 0])
                    cylinder(r1=0, r2=hornDiameter/2,
                        h=traxxas5347HornWidth/2);
                rotate([0, 90, 0])
                    cylinder(r1=0, r2=hornDiameter/2,
                        h=traxxas5347HornWidth/2);
            }

            // the hole through the center of the ball and horns
            rotate([0,90,0])
                translate([0, 0, -traxxas5347HornWidth/2 - overcut])
                cylinder(r=hornHoleDiameter/2,
                    h=traxxas5347HornWidth + 2*overcut);
        }
    }
}

overcut = 1;
stepperShaftDiameter=8;
stepperShaftFlatDepth=1;
stepperShaftFlatLength=15;
stepperShaftKeepoutDiameter=22;
stepperShaftKeepoutLength=5;
stepperGearboxDiameter=36;
stepperGearboxLength=35;
stepperInnerMountingHoleRingDiameter=28;
stepperMountingScrewDiameter=3;
stepperBodyWidth=42.3;
stepperBodyLength=48;

// guesses on dimensions
mountingScrewDepth = 8;
gearboxFlangeDepth = 5;
gearboxFlangeWidth = stepperBodyWidth - 2;
silverBorderLength = 8;

// used to cut the corners off of the stepper motor
module stepperMotorBevel() {
    for (i = [0:3]) {
        rotate([0, 0, i*90 + 45])
            translate([-stepperBodyWidth/2, stepperBodyWidth*0.625,
                -stepperGearboxLength - stepperBodyLength - overcut])
            cube([stepperBodyWidth, stepperBodyWidth,
                stepperBodyLength + stepperGearboxLength + 2*overcut]);
    }
}

// a geared NEMA 17 stepper motor with the mounting plane at the origin and
// the shaft extending along the postive z-axis.
module gearedStepperMotor() {

    // the shaft with the machined flat
    color([0.9, 0.9, 0.9])
    difference() {
        // the shaft
        cylinder(r=stepperShaftDiameter/2,
            h=stepperShaftFlatLength + stepperShaftKeepoutLength);

        // the flat
        translate([-stepperShaftDiameter/2 - overcut, 3,
                stepperShaftKeepoutLength])
            cube([2*stepperShaftDiameter/2 + 2*overcut,
                stepperShaftFlatDepth + overcut,
                stepperShaftFlatLength + overcut]);
    }

    // the gearbox
    color([0.85, 0.85, 0.85]) {
        // the little ring extending up around the shaft
        cylinder(r=stepperShaftKeepoutDiameter/2, h=2);

        // the main cylindrical body of the gearbox
        difference() {
            // the main cylinder
            translate([0, 0, -stepperGearboxLength])
                cylinder(r=stepperGearboxDiameter/2,
                    stepperGearboxLength);

            // the eight mounting holes
            for (i = [0:7]) {
                rotate([0, 0, i*45])
                    translate([0, stepperInnerMountingHoleRingDiameter/2,
                        -mountingScrewDepth])
                    cylinder(r=stepperMountingScrewDiameter/2,
                        h=mountingScrewDepth + overcut);
            }

            // the notches in the top, bottom, and side mounting holes
            for (i = [0:3]) {
                rotate([0, 0, i*90])
                translate([0, stepperInnerMountingHoleRingDiameter/2,
                        -1]) {
                    cylinder(r=3, h=1 + overcut);
                    translate([-3,0,0])
                        cube([6, (
                                stepperGearboxDiameter -
                                    stepperInnerMountingHoleRingDiameter
                            )/2 + overcut,
                            1+overcut]);
                }
            }
        }

        // the flange attaching the gearbox to the stepper body
        difference() {
            // the main body of the flange
            translate([-gearboxFlangeWidth/2, -gearboxFlangeWidth/2,
                    -stepperGearboxLength])
                cube([gearboxFlangeWidth, gearboxFlangeWidth,
                    gearboxFlangeDepth]);

            // the beveling of the corners of the flange
            scale(0.95)
                stepperMotorBevel();

            // the four screws attaching the flange
            for (i = [0:3]) {
                rotate([0, 0, i*90 + 45])
                translate([0, stepperGearboxDiameter/2 + 3,
                        -stepperGearboxLength + gearboxFlangeDepth - 1])
                    cylinder(r=3, h=1 + overcut);
            }
        }
    }

    // the silver top and bottom of the body of the stepper motor
    color([0.75, 0.75, 0.75])
        difference() {
            translate([-stepperBodyWidth/2, -stepperBodyWidth/2,
                    -stepperGearboxLength - stepperBodyLength]) {

                // the bottom of the body
                cube([stepperBodyWidth, stepperBodyWidth, silverBorderLength]);

                // the top of the body
                translate([0, 0, stepperBodyLength - silverBorderLength])
                    cube([stepperBodyWidth, stepperBodyWidth,
                        silverBorderLength]);
            }

            // the beveling of the corners of the body
            scale(0.99)
                stepperMotorBevel();
        }

    // the black middle of the stepper motor body
    color([0.4, 0.4, 0.4])
        difference() {
            // the body
            translate([-stepperBodyWidth/2, -stepperBodyWidth/2,
                    -stepperGearboxLength - stepperBodyLength +
                        silverBorderLength])
                cube([stepperBodyWidth, stepperBodyWidth,
                    stepperBodyLength - 2*silverBorderLength]);

            // the beveling of the corners
            stepperMotorBevel();
        }
}


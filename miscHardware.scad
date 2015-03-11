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

    color([0.4, 0.4, 0.4]) {
        difference() {
            cylinder(r=baseDiameter/2, h=baseHeight);
            translate([baseDiameter/2, -baseDiameter/2, slantHeight])
                rotate([0, -slantAngle, 0])
                cube([baseDiameter/2, baseDiameter, baseHeight]);
            translate([-baseDiameter, -baseDiameter/2, slantHeight])
                rotate([0, slantAngle, 0])
                cube([baseDiameter/2, baseDiameter, baseHeight]);
            translate([0,0,-overcut])
                cylinder(r=mountingHoleDiameter/2, h=mountingHoleDepth + overcut);
        }

        translate([0, 0, traxxas5347BallHeight])
        rotate([0,90,0]) {
            difference() {
                union() {
                    translate([0,0,-ringWidth/2])
                        cylinder(r=ringDiameter/2, h=ringWidth);
                    translate([0,-ringDiameter/2, -ringWidth/2])
                        cube([buttressLength, ringDiameter, ringWidth]);
                }
                translate([buttressLength, -baseDiameter/2 - buttressFilletDiameter/2,
                        -ringWidth/2 - overcut])
                    cylinder(r=buttressFilletDiameter/2, h=ringWidth + 2*overcut);
                translate([buttressLength, baseDiameter/2 + buttressFilletDiameter/2,
                        -ringWidth/2 - overcut])
                    cylinder(r=buttressFilletDiameter/2, h=ringWidth + 2*overcut);
                translate([0,0,-ringWidth/2 - overcut])
                    cylinder(r=ringOpening/2, h=ringWidth + 2*overcut);
            }
        }
    }

    color([0.85, 0.85, 0.85])
    translate([0, 0, traxxas5347BallHeight])
    rotate([-ballXAngle,0,0])
    rotate([0,0, -ballZAngle])
    {
        difference() {
            union() {
                sphere(r=ballDiameter/2);
                rotate([0, -90, 0])
                    cylinder(r1=0, r2=hornDiameter/2, h=traxxas5347HornWidth/2);
                rotate([0, 90, 0])
                    cylinder(r1=0, r2=hornDiameter/2, h=traxxas5347HornWidth/2);
            }
            rotate([0,90,0])
                translate([0, 0, -traxxas5347HornWidth/2 - overcut])
                cylinder(r=hornHoleDiameter/2, h=traxxas5347HornWidth + 2*overcut);
        }
    }
}


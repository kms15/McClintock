include <dimensions.scad>
include <miscHardwareDimensions.scad>
use <miscHardware.scad>
use <bodyFrame.scad>

$fn=60;

module printedMaterial() {
    for (i = [0 : $children-1])
        color([0.5,0.5,1.0]) child(i);
}

//
// utility functions
//

// the square of the norm of a vector
function normSquared(v) = v[0]*v[0] + v[1]*v[1] + v[2]*v[2];

// these functions are built into later versions of openscad
function norm_(v) = sqrt(normSquared(v));
function dot_(v1, v2) = v1[0] * v2[0] + v1[1] * v2[1] + v1[2] * v2[2];
function cross_(v1, v2) = [
    v1[1] * v2[2] - v2[1] * v1[2],
    v1[2] * v2[0] - v2[2] * v1[0],
    v1[0] * v2[1] - v2[0] * v1[1]
];

// normalizes a vector to have length of 1
function normalize(v) = v/norm_(v);

// calculate the normal vector for a plane containing the given points
// (following the right hand rule for normal direction);
function normalOfPlaneWithPoints(points) =
    normalize(cross_(points[2] - points[0], points[1] - points[0]));

// calculate the radius of a circle containing the given points
// (see https://en.wikipedia.org/wiki/Circumscribed_circle)
function circumscribedRadius(p) = (
    norm_(p[0] - p[2]) * norm_(p[1] - p[2]) * norm_(p[0] - p[1]) /
        (2 * norm_(cross_(p[0] - p[2], p[1] - p[2])))
);

// calculate the center of a circle containing the given points
function circumscribedCenter(p) = (
    cross_(
        normSquared(p[0] - p[2]) * (p[1] - p[2]) -
        normSquared(p[1] - p[2]) * (p[0] - p[2]),
        cross_(p[0] - p[2], p[1] - p[2])
    ) /
    (2 * normSquared(cross_(p[0] - p[2], p[1] - p[2]))) +
    p[2]
);

// Calculate the center of a sphere of the given radius containing the given
// points
function sphereCenter(r, p) = circumscribedCenter(p) +
    normalOfPlaneWithPoints(p) * sqrt(
        r*r - circumscribedRadius(p) * circumscribedRadius(p));

// calculates the location of the elbow of the arms given the arm angles,
// in body coordinates.
function _elbowLocationR(angle) =
    shoulderRadius + sin(angle) * proximalArmLength;
function _elbowLocationZ(angle) = -cos(angle) * proximalArmLength;
function elbowLocation(angles) = [
    [0, _elbowLocationR(angles[0]), _elbowLocationZ(angles[0])],
    _elbowLocationR(angles[1]) * [-sin(120), cos(120), 0] +
        [0, 0, _elbowLocationZ(angles[1])],
    _elbowLocationR(angles[2]) * [sin(120), cos(120), 0] +
        [0, 0, _elbowLocationZ(angles[2])]
];

// shrinks the distance to the z axis by the wrist radius for each of the elbow
// points
function contractElbowsAroundZ(p) = p - wristRadius*[
    [0,1,0], [-sin(120),cos(120),0], [sin(120),cos(120),0]
];

// calculate the position of the center of the effector (in body coordinates)
// from the arm angles.
function effectorPosition(angles) = sphereCenter(distalArmLength,
    contractElbowsAroundZ(elbowLocation(angles)));

// calculate the angle between the point of intersection between two circles
// (of radius r and R), the center of the circle of radius r, and the line
// connecting the centers of the two circles.
function circleIntersectionAngle(r, R, d) = acos(
    (d + (r*r - R*R) / d) /(2 * r));

// calculate the radius of the circle formed by a sphere of radius R centered
// at point o intersecting the plane described by the point p and normal v.
function radiusOfSpherePlaneIntersection(R, o, p, v) = sqrt(
    R*R - dot_(o - p, v) * dot_(o - p, v)
);

// calculate the point on the plane described by the point p and normal v that
// is closest to the point o.
function nearestPointOnPlane(o, p, v) = (
    o - v * dot_(o - p, v)
);

// calculate the angle between v1 and v2 with the unit vector a (at a right
// angle to both) defining positive angles via the right hand rule.
function angleBetweenVectors(v1, v2, a=[0,0,1]) = asin(dot_(a,
    cross_(v1, v2) / (norm_(v1) * norm_(v2))));

// calculate the angle of the shoulder joint at position s with axis a and
// zero degree vector v given the position of the wrist at w.
function singleArmAngle(s, a, v, w) = (
    circleIntersectionAngle(proximalArmLength,
        radiusOfSpherePlaneIntersection(distalArmLength, w, s, a),
        norm_(s - nearestPointOnPlane(w, s, a))
    ) +
    angleBetweenVectors(
        nearestPointOnPlane(w, s, a) - s,
        v,
        a
    )
);

// calculate the arm angles from the position of the effector (in body
// coordinates).
function armAngles(p) = [
    singleArmAngle(
        shoulderRadius * [0, 1, 0],
        [-1, 0, 0],
        [0, 0, -1],
        p + wristRadius * [0, 1, 0]
    ),
    singleArmAngle(
        shoulderRadius * [sin(120), cos(120), 0],
        [-cos(120), -sin(120), 0],
        [0, 0, -1],
        p + wristRadius * [sin(120), cos(120), 0]
    ),
    singleArmAngle(
        shoulderRadius * [-sin(120), cos(120), 0],
        [-cos(120), sin(120), 0],
        [0, 0, -1],
        p + wristRadius * [-sin(120), cos(120), 0]
    )
];

//echo(angleBetweenVectors([1,0,0], [0,1,0], [0, 0, -1]));
//echo(singleArmAngle([150,0,0], [0,1,0], [0, 0, -1], [0,-200,-400]));
//echo(armAngles([200, 0, -400]));
echo(nearestPointOnPlane([200, 0, -400], [0, 0, 100], [0, 0, 1]));

//
// main components of the robot
//

// print bed of the robot, origin is at the center of the print bed
module bed() {
    circle(r=bedRadius);
}

// stand of the robot, origin is on ground directly below origin of body
module stand() {
    cylinder(r=8, h=standHeight);
}

// Body of the robot, origin is at the center of the plane containing the
// shoulder axes oriented so the origin of the first arm is on the positive
// y-axis and the effector side of the printer is facing downwards.
module body() {
    printedMaterial()
        bodyFrame();

    for (i = [0:2]) {
        rotate([0, 0, 120*i])
            rotate([0, 90, 0])
            translate([0, shoulderRadius, -12.5]) {
                gearedStepperMotor();

                // mounting screws
                for (j = [0:3]) {
                    rotate([0, 0, j*90 + 45])
                        translate([0,
                                stepperInnerMountingHoleRingDiameter/2,
                                0]) {

                            // the counter-bored hole
                            translate([0, 0, overcut + minWallThickness +
                                stepperShaftKeepoutLength])
                            m3SHCS();
                        }
                }
            }
    }
}

// Upper arm of the robot, origin is at the shoulder oriented so that the
// the x-axis is the axis of rotation and the arm extends along the positive
// z axis.
module proximalArm() {
    translate([-10,0,0])
        cylinder(r=3, h=proximalArmLength);
    translate([10,0,0])
        cylinder(r=3, h=proximalArmLength);
    translate([0, 0, proximalArmLength])
        rotate([0,90,0])
        translate([0, 0, -distalArmGap/2])
        cylinder(r=3, h=distalArmGap);
}

// lower arm of the robot, origin is at the elbow oriented so that the
// the x-axis is the axis of rotation and the arm extends along the positive
// z axis.
module distalArm(xAngle = 0, zAngle = 0) {
    for (xoffset = ([-1/2, 1/2] * (distalArmGap + traxxas5347HornWidth))) {
        translate([xoffset, 0, 0])
            rotate([0, 0, zAngle])
            rotate([xAngle, 0, 0])
            {
                rotate([180, 0, 0])
                    translate([0, 0, -traxxas5347BallHeight])
                    traxxas5347RodEnd(xAngle, 180 - zAngle);
                color([0.5, 0.5, 0.5])
                    translate([0, 0, traxxas5347BallHeight])
                    cylinder(r=3, h=distalArmLength - 2*traxxas5347BallHeight);
                translate([0, 0, distalArmLength - traxxas5347BallHeight])
                    traxxas5347RodEnd(xAngle, zAngle);
            }
    }
}

// effector of the robot.  Origin is at the center of the wrist axes with the
// axis connected to the first arm on the y axis.
module effector() {
    translate([0,0,-5])
        cylinder(r=wristRadius-3, h=10);
        for (zRot = [0, 120, 240]) {
            rotate([0, 0, zRot])
                translate([-distalArmGap/2, wristRadius, 0])
                rotate([0, 90, 0])
                cylinder(r=3, h=distalArmGap);
        }
}

// draws the arms at the given shoulder angles.  Origin is at the center of the
// plane containing the shoulder axes oriented so the origin of the first arm
// is on the positive y-axis and the effector side of the printer is facing
// downwards.  Angles are measured so that the proximal arm is downward and
// parallel to the z-axis when the angle is 0, and in the x-y plane when the
// angle is 90.
module arms(angles) {
    for (i = [0:2]) {
        rotate([0, 0, 120*i])
            translate([0, shoulderRadius, 0])
            rotate([angles[i] - 180, 0, 0])
            proximalArm();
        translate(elbowLocation(angles)[i])
            rotate([0, 0, 120*i])
            distalArm(
                180 - acos(
                    (elbowLocation(angles)[i] - effectorPosition(angles))[2] /
                    distalArmLength
                ),
                -90 + atan2(
                    (contractElbowsAroundZ(elbowLocation(angles))[i] -
                        effectorPosition(angles))[1],
                    (contractElbowsAroundZ(elbowLocation(angles))[i] -
                        effectorPosition(angles))[0]
                ) - 120*i
            );
    }
    translate(effectorPosition(angles))
        effector();
}

target = bedRadius * [0, 0, -2] +
    cos(10*360*$t) * bedRadius * [0, 1/1.41, -1/1.41] +
    sin(10*360*$t) * bedRadius * [1, 0, 0] +
    (sin(1*360*$t) * 100 - 50) * [0, 1/1.41, 1/1.41];


translate([-bedRadius, -bedRadius])
    bed();
stand();
translate([0, 0, standHeight]) rotate([0,0,135]) rotate([45,0,0]) {
    color([0.75, 0, 0.75])
        translate(target)
        sphere(r=20);
    body();
    arms(armAngles(target));
}

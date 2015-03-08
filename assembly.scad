//
// basic measurements of the robot
//

// radius of a circle tangent to the axes of the upper stepper motors
shoulderRadius = 50;

// radius of a circle tangent to the axes of rotation around the effector
wristRadius = 50;

// axis to axis length of the upper armature
proximalArmLength = 250;

// axis to axis length of the lower armature
distalArmLength = 288;

// height of center of the plane containing the stepper motors above the
// ground.
standHeight = 400;

// diameter of the printing bed
bedRadius = 175;

//
// utility functions
//

// the square of the norm of a vector
function normSquared(v) = v[0]*v[0] + v[1]*v[1] + v[2]*v[2];

// these functions are built into later versions of openscad
function norm_(v) = sqrt(normSquared(v));
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
    cylinder(r=80, h=distalArmLength);
}

// Upper arm of the robot, origin is at the shoulder oriented so that the
// the x-axis is the axis of rotation and the arm extends along the positive
// z axis.
module proximalArm() {
    translate([-10,0,0])
        cylinder(r=3, h=proximalArmLength);
    translate([10,0,0])
        cylinder(r=3, h=proximalArmLength);
}

// lower arm of the robot, origin is at the elbow oriented so that the
// the x-axis is the axis of rotation and the arm extends along the positive
// z axis.
module distalArm() {
    cylinder(r=3, h=distalArmLength);
    /*
    translate([-15,0,0])
        cylinder(r=6, h=distalArmLength);
    translate([15,0,0])
        cylinder(r=6, h=distalArmLength);
    */
}

// effector of the robot.  Origin is at the center of the wrist axes with the
// axis connected to the first arm on the y axis.
module effector() {
    translate([0,0,-5])
        cylinder(r=wristRadius, h=10);
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
            //rotate([0, 0, 120*i])
            rotate([0, 0, -90 + atan2(
                (contractElbowsAroundZ(elbowLocation(angles))[i] -
                    effectorPosition(angles))[1],
                (contractElbowsAroundZ(elbowLocation(angles))[i] -
                    effectorPosition(angles))[0]
                )])
            rotate([180 - acos(
                (elbowLocation(angles)[i] - effectorPosition(angles))[2] /
                distalArmLength),0,0])
            distalArm();
    }
    translate(effectorPosition(angles))
        effector();
}
echo(atan2(1,1));

translate([-bedRadius, -bedRadius])
    bed();
stand();
translate([0, 0, standHeight]) rotate([0,0,135]) rotate([45,0,0]) {
    body();
    arms([45 + 45*sin(360*2*$t),45+45*sin(360*3*$t),45+45*sin(360*5*$t)]);
}

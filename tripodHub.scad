include <dimensions.scad>
include <miscHardwareDimensions.scad>


$fn=60;

tripodTubeDiameter=16;
tripodBraceWidth=5;
tripodBraceDepth=10;
tripodTabWidth=5;
tripodTabDepth=8;
tripodBandThickness=2;
tripodBandHeight=50;
tripodSlitWidth=5;

module tripodArm() {
    difference () {
        union () {
            cylinder(r=tripodTubeDiameter/2 + tripodBandThickness,
                h=tripodBandHeight);
            translate([-tripodTubeDiameter/2 - tripodBandThickness -
                tripodBraceDepth, -tripodBraceWidth/2, 0])
                cube([tripodTubeDiameter/2 + tripodBandThickness +
                    tripodBraceDepth, tripodBraceWidth, tripodBandHeight]);
            translate([0, -tripodTabWidth - tripodSlitWidth/2, 0])
                cube([tripodTubeDiameter/2 + tripodBandThickness +
                    tripodTabDepth, tripodTabWidth*2 + tripodSlitWidth,
                    tripodBandHeight]);
        }
        union () {
            translate([0, 0, -overcut])
                cylinder(r=tripodTubeDiameter/2,
                    h=tripodBandHeight + 2*overcut);
            translate([0, -tripodSlitWidth/2, -overcut])
                cube([tripodTubeDiameter + tripodBandThickness +
                        tripodTabDepth + overcut,
                    tripodSlitWidth,
                    tripodBandHeight + 2*overcut]);
            translate([-tripodTubeDiameter/2 - tripodBandThickness,
                    -tripodTubeDiameter/2 - tripodBandThickness - overcut, 0])
                rotate([0,45,0])
                cube([100,100,100]);
        }
    }
}

module tripodHub() {
    tripodArm();
}

tripodArm();

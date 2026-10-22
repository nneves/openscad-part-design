// <Design name> - <one-line description>
// All dimensions in mm. Datum: base underside centre at the origin, Z up.
//
// Brief : <what it does; the purchased objects and their caliper measurements;
//          motions and ranges; mounting; cables; how it should look>
// Parts : base, arm, knob      (+ 2x M4 countersunk screws to mount the base)
// Print : part = "print_layout" shows every part in its print orientation.
//         No supports needed. Printer values come from printer.json in this folder.
//
// Assembly
//   1. Screw the base down (2x M4 countersunk).
//   2. Set the arm on the boss and screw the knob in through it; the knob sets
//      how stiffly the arm swings.
//
// This is the starter template of the openscad-part-design skill: replace the
// example parts (base, arm, knob) and keep the structure.

/* [View] */
part         = "assembly"; // [assembly, print_layout, base, arm, knob]
show_device  = true;       // reference only - never exported with the parts
// how the base and arm are drawn (transparent works in preview, F5)
housing_view = "solid";    // [solid, transparent, hidden]
// development labels (preview only, never exported)
refs         = "both";     // [off, names, numbers, both]
// smoothness of round shapes (fine = slower preview and render)
detail       = "normal";   // [draft, normal, fine]
// arm swing - one slider per motion, with its real range
swing        = 30;         // [0:5:90]
// drive the motion and the camera from $t (View > Animate, or --animate N)
animate      = false;

/* [Animation] */
anim_cam_rot  = [55, 0, 30];      // camera rotation
anim_cam_tgt  = [30, 10, 15];     // camera target
anim_cam_dist = 300;              // camera distance

cur_swing    = animate ? 45 - 45 * cos(360 * $t) : swing;
$vpr = animate ? anim_cam_rot : $vpr;
$vpt = animate ? anim_cam_tgt : $vpt;
$vpd = animate ? anim_cam_dist : $vpd;

/* [Printer] */
// copied from printer.json - update that file first, then copy the values here
min_wall     = 2.4;          // printer.json: min_wall_mm
hole_allow   = 0.3;          // printer.json: hole_allowance_mm
slide_clr    = 0.25;         // printer.json: slide_clearance_mm
bed          = [250, 210];   // printer.json: bed_mm (X, Y)

/* [Reference object] */
dev_d        = 40;   // purchased object diameter (caliper)
dev_h        = 18;   // purchased object height

/* [Base] */
base_w       = 60;   // base plate width (X)
base_l       = 40;   // base plate length (Y)
base_t       = 5;    // base plate thickness
boss_r       = 9;    // pivot boss radius
boss_h       = 12;   // pivot boss height above the plate
screw_d      = 4;    // mounting screw nominal diameter (M4)
screw_csk    = 8.4;  // countersunk head diameter
screw_pitch  = 44;   // distance between the mounting screws

/* [Arm] */
arm_len      = 70;   // pivot to device centre
arm_w        = 18;   // arm width
arm_t        = 8;    // arm thickness
cup_wall     = 2.4;  // cup wall around the device
cup_h        = 8;    // cup wall height above the arm

/* [Thumbscrew] */
pin_r        = 2.8;  // thread core radius
pin_e        = 0.45; // thread eccentricity (thread depth = 2x this)
pin_p        = 1.75; // thread pitch
pin_clr      = 0.42; // radial thread clearance (the flank gap is about half of it)
knob_r       = 8;    // knob radius over the lobes
knob_h       = 5;    // knob thickness
knob_lobes   = 7;    // grip lobes
knob_lobe_w  = 3.4;  // lobe width
knob_core    = 0.68; // core radius as a fraction of knob_r (depth of the valleys)

/* [Finish] */
edge         = 1.5;  // edge rounding radius
base_col     = "#6c6f7d";
arm_col      = "#f28c28";
knob_col     = "#e8e8e8";

// Round shapes: facet angle and length scale with each curve; renders and exports
// (F6) are one step finer than the preview (F5).
detail_i = detail == "draft" ? 0 : detail == "normal" ? 1 : 2;
$fa   = [[6, 3], [3, 1.5], [2, 1]][detail_i][$preview ? 0 : 1];
$fs   = [[0.8, 0.4], [0.4, 0.25], [0.3, 0.15]][detail_i][$preview ? 0 : 1];
steps = [24, 48, 96][detail_i];   // thread slices per turn scale with this

// --- derived ----------------------------------------------------------------

pin_major    = pin_r + pin_e;
pin_hole_d   = 2 * pin_major + 2 * slide_clr;     // clearance through the arm
thread_r     = pin_r + pin_clr + pin_e;           // outer radius of the printed thread
screw_hole   = screw_d + hole_allow;
cup_r        = dev_d / 2 + slide_clr + cup_wall;
pivot_z      = base_t + boss_h;                   // arm underside
knob_len     = arm_t + boss_h - 1;                // shank: through the arm into the boss
// print layout: positions, and the plate size they add up to
lay_arm      = [-arm_len / 2, base_l / 2 + cup_r + 8, 0];
lay_knob     = [base_w / 2 + knob_r + 8, 0, 0];
plate_size   = [max(base_w / 2, lay_knob.x + knob_r, lay_arm.x + arm_len + cup_r) - min(-base_w / 2, lay_arm.x - arm_w / 2),
                lay_arm.y + cup_r + base_l / 2];

echo(pin_hole_d = pin_hole_d, plate_size = plate_size);
assert(boss_r - thread_r >= min_wall, "boss wall around the thread under min_wall");
assert(arm_w / 2 - pin_hole_d / 2 >= min_wall, "arm wall around the pivot hole under min_wall");
assert(cup_wall >= min_wall, "cup wall under min_wall");
assert(plate_size.x <= bed.x && plate_size.y <= bed.y, "print layout larger than the bed");

// --- helpers ----------------------------------------------------------------

// Linear extrude with rounded (quarter-circle) top and bottom edges of radius c,
// built from thin slices that follow the curve (more slices at higher detail)
module chamfer_extrude(h, c = edge, bottom = true, top = true) {
    n = [3, 6, 10][detail_i];
    b = bottom ? c : 0;
    t = top ? c : 0;
    function inset(z) = c - sqrt(c * c - (c - z) * (c - z));   // z = distance from the edge
    translate([0, 0, b]) linear_extrude(h - b - t) children();
    if (bottom) for (i = [0 : n - 1])
        translate([0, 0, i * c / n]) linear_extrude(c / n + 0.001)
            offset(delta = -inset((i + 0.5) * c / n)) children();
    if (top) for (i = [0 : n - 1])
        translate([0, 0, h - (i + 1) * c / n]) linear_extrude(c / n + 0.001)
            offset(delta = -inset((i + 0.5) * c / n)) children();
}

module rounded_square(size, r, center = false) {
    offset(r = r) offset(delta = -r) square(size, center = center);
}

// Horizontal holes with a pointed tip (+Z, or -Z when down = true)
module teardrop_2d(d) {
    circle(d = d);
    rotate(45) square(d / 2);
}

module teardrop_x(d, l, down = false) {
    mirror([0, 0, down ? 1 : 0]) rotate([90, 0, 90]) linear_extrude(l, center = true) teardrop_2d(d);
}

module teardrop_y(d, l) {
    rotate([90, 0, 0]) linear_extrude(l, center = true) teardrop_2d(d);
}

// Single-start eccentric thread: prints cleanly upright, mates with itself + clearance
module ecc_thread(r, h) {
    linear_extrude(height = h, twist = -360 * h / pin_p,
                   slices = max(8, ceil(h / pin_p * [24, 36, 60][detail_i])), convexity = 4)
        translate([pin_e, 0]) circle(r = r);
}

// star grip: round core with wide rounded lobes, valleys filleted
module knob_2d(r) {
    offset(r = 0.8) offset(r = -0.8)          // round the lobe tips
    offset(r = -1) offset(r = 1) union() {    // fillet the valleys
        circle(r = r * knob_core);
        for (i = [0 : knob_lobes - 1]) rotate(i * 360 / knob_lobes) hull() {
            translate([r * knob_core * 0.5, -knob_lobe_w / 2]) square([0.01, knob_lobe_w]);
            translate([r - knob_lobe_w / 2, 0]) circle(d = knob_lobe_w);
        }
    }
}

// ---------------------------------------------------------------------------
// Reference stickers: [label, point on the surface, surface normal] in the part frame,
// drawn only in preview. Names: [text, point, normal, height, optional in-plane turn].

// local frame on a surface: Z along the normal, X/Y in the surface (text reads upright)
function unitv(v) = v / norm(v);
function surface_frame(p, n) =
    let(w = unitv(n),
        u = abs(w.z) > 0.9 ? [1, 0, 0] : unitv(cross([0, 0, 1], w)),
        v = cross(w, u))
    [[u.x, v.x, w.x, p.x], [u.y, v.y, w.y, p.y], [u.z, v.z, w.z, p.z], [0, 0, 0, 1]];

module ref_sticker(txt, p, n) {
    multmatrix(surface_frame(p + unitv(n) * 0.05, n)) {
        color("Red") cylinder(r = 3.6, h = 0.5, $fn = 32);
        color("White") translate([0, 0, 0.5]) linear_extrude(0.25)
            text(txt, size = len(txt) > 2 ? 2.1 : 2.7, halign = "center", valign = "center",
                 font = "Liberation Sans:style=Bold");
    }
}

module ref_stamp(name) {
    multmatrix(surface_frame(name[1] + unitv(name[2]) * 0.05, name[2])) rotate(is_undef(name[4]) ? 0 : name[4])
        color("Red") linear_extrude(0.4) text(name[0], size = name[3], halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
}

// marks for one part, in that part's frame
module part_marks(list, name = undef) {
    if ($preview) {
        if (ref_numbers) for (m = list) ref_sticker(m[0], m[1], m[2]);
        if (ref_names && !is_undef(name)) ref_stamp(name);
    }
}


// hull chain along a list of 2D points (curved arms, channels): children() at each point
module chain_2d(pts) {
    for (i = [0 : len(pts) - 2]) hull() for (p = [pts[i], pts[i + 1]]) translate([p[0], p[1]]) children();
}

// star-grip thumbscrew: head from z = 0 to knob_h, threaded shank above it
module thumb_pin(shank) {
    chamfer_extrude(knob_h, c = 0.8) knob_2d(knob_r);
    translate([0, 0, knob_h - 0.01]) intersection() {
        ecc_thread(pin_r, shank);
        cylinder(h = shank, r1 = pin_major + shank, r2 = pin_major - 0.6);
    }
}

// ---------------------------------------------------------------------------
// Reference: the purchased object (shown with show_device, never exported)

module device() {
    chamfer_extrude(dev_h, c = 3, bottom = false) circle(d = dev_d);
}

// ---------------------------------------------------------------------------
// Base: plate screwed down, with a boss the arm pivots on. The knob's thread is
// cut straight into the boss (vertical when printed, so it prints cleanly).
// Prints flat. Frame: world.

module base() {
    difference() {
        union() {
            chamfer_extrude(base_t) rounded_square([base_w, base_l], 6, center = true);
            translate([0, 0, base_t - 0.01]) chamfer_extrude(boss_h + 0.01, bottom = false) circle(r = boss_r);
        }
        // printed thread for the knob
        translate([0, 0, base_t + 1]) ecc_thread(pin_r + pin_clr, boss_h);
        // countersunk mounting screws
        for (s = [-1, 1]) translate([s * screw_pitch / 2, 0, 0]) {
            translate([0, 0, -1]) cylinder(d = screw_hole, h = base_t + 2);
            translate([0, 0, base_t - (screw_csk - screw_hole) / 2]) cylinder(d1 = screw_hole, d2 = screw_csk, h = (screw_csk - screw_hole) / 2 + 0.01);
        }
    }
}

// ---------------------------------------------------------------------------
// Arm: swings on the boss, carries a cup for the device. Prints flat.
// Frame: pivot at the origin, arm along +X, underside at z = 0.

module arm() {
    difference() {
        union() {
            chamfer_extrude(arm_t) hull() {
                circle(d = arm_w);
                translate([arm_len, 0]) circle(r = cup_r);
            }
            // cup wall around the device
            translate([arm_len, 0, arm_t - 0.01]) chamfer_extrude(cup_h + 0.01, bottom = false) circle(r = cup_r);
        }
        translate([arm_len, 0, arm_t]) cylinder(r = dev_d / 2 + slide_clr, h = cup_h + 1);
        // pivot hole for the knob's shank
        translate([0, 0, -1]) cylinder(d = pin_hole_d, h = arm_t + 2);
    }
}

module knob() { thumb_pin(knob_len); }

// knob frame -> world: head on top of the arm, shank pointing down into the boss
module at_knob() translate([0, 0, pivot_z + arm_t + knob_h]) rotate([180, 0, 0]) children();

// ---------------------------------------------------------------------------
// Reference stickers and names for each part, in the part's own frame.

ref_names    = refs == "names" || refs == "both";
ref_numbers  = refs == "numbers" || refs == "both";

marks_base = [
    ["B1", [base_w / 2, 0, base_t / 2],                 [1, 0, 0]],    // plate end
    ["B2", [0, -boss_r, base_t + boss_h / 2],           [0, -1, 0]],   // pivot boss
];
marks_arm = [
    ["A1", [arm_len / 2, -arm_w / 2 - 2.5, arm_t / 2],  [0, -1, 0]],   // arm side
    ["A2", [arm_len, -cup_r, arm_t + cup_h / 2],        [0, -1, 0]],   // cup wall
];
marks_knob = [["K1", [0, 0, 0], [0, 0, -1]]];                          // knob head

name_base = ["BASE", [0, -14.5, base_t], [0, 0, 1], 4];
name_arm  = ["ARM",  [arm_len / 2 - 4, 0, arm_t], [0, 0, 1], 5];

module base_m() { base(); part_marks(marks_base, name_base); }
module arm_m()  { arm();  part_marks(marks_arm, name_arm); }
module knob_m() { knob(); part_marks(marks_knob); }

// ---------------------------------------------------------------------------

housing_alpha = housing_view == "transparent" ? 0.25 : 1;

module assembly() {
    if (housing_view != "hidden") { color(base_col, housing_alpha) base(); part_marks(marks_base, name_base); }
    rotate(cur_swing) {
        translate([0, 0, pivot_z]) {
            if (housing_view != "hidden") { color(arm_col, housing_alpha) arm(); part_marks(marks_arm, name_arm); }
            if (show_device) color("DimGray") translate([arm_len, 0, arm_t]) device();
        }
        at_knob() { color(knob_col) knob(); part_marks(marks_knob); }
    }
}

// print orientations (stickers are preview-only, so exports stay clean)
module print_base() base_m();                       // flat
module print_arm()  arm_m();                        // flat
module print_knob() knob_m();                       // head down

if (part == "assembly") {
    assembly();
} else if (part == "print_layout") {
    color(base_col) print_base();
    color(arm_col)  translate(lay_arm)  print_arm();
    color(knob_col) translate(lay_knob) print_knob();
} else if (part == "base") {
    print_base();
} else if (part == "arm") {
    print_arm();
} else if (part == "knob") {
    print_knob();
}

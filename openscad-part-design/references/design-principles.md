# Design principles

Lessons from designs that went through many rounds before they were both functional
and good-looking. Use them when choosing a concept (layout, looks), when shaping
parts (cables, joints, shells, printability), and when checking (thin spots).

## Layout and looks

* **The silhouette comes from the layout.** A horizontal beam with a pivot lug under
  one end and a knob below reads as a pistol, whatever the fillets. Restyling the
  same layout didn't help; moving the joints did. Judge every concept from the
  front, the side and the top before detailing it.
* **Turn awkward constraints into features.** A connector overmold that sticks out of
  a device can become an axle or a handle; a mounting boss can become a hinge. An
  appendage that has a job stops looking like an appendage.
* **Put each rotation where it costs least space.**
  * Rotation about an axis perpendicular to a wall never changes the distance to that
    wall, so it can never hit it.
  * Pitching an object about its own diameter needs only its sweep radius of depth; a
    long arm costs much more.
  * Rearranging the axes this way moved one design's device 14 mm closer to the wall
    with full ranges kept.
* **Keep pivot parts outside the sweep zone.** Round tops centred on an axis,
  concentric cheeks, and pivots placed where the moving parts never go let parts sit
  0.4–0.8 mm apart and still move through the whole range.
* **Simplify before adding.** Every joint costs parts, clearance and looks. Drop
  features the user didn't ask for.
* **A product look** means:
  * quarter-circle fillets rather than stepped chamfers;
  * consistent radii (about 1.5 mm, or 1 mm on small parts);
  * smooth curves;
  * star-grip knobs (7 lobes) rather than fine knurls;
  * one colour per part;
  * assembly features (nut slots, screw holes, lay-in slots) on faces that end up
    hidden: against the wall, underneath, or between two halves.

## Cables

* **Cable on or near every rotation axis,** so motion twists it rather than bends it.
  Leave the bend room the user measured (about 10 mm past a USB plug overmold).
* **Model the cable, the plug and the fingers that assemble it as keep-out solids,**
  and include them in the collision checks. Otherwise a narrowed lug can silently
  squeeze the cable passage.
* **Lay-in paths rather than threading:** grooves closed by the mating part, or split
  shells. A short tunnel is acceptable when it saves a part.
* **Room during assembly:** make channels as large as the walls allow, so the cable
  and its plug can turn while being laid in.

## Joints and fasteners

* **Printed thumbscrews:** a single-start eccentric thread (`linear_extrude` with
  `twist` of an offset circle), printed with the axis vertical, with a star-grip
  head. Use one clearance parameter per thread size. The gap between the thread
  flanks is only about half the radial clearance, so use about 0.42 mm radial for a
  0.2 mm gap.
* **Friction joints that hold any angle:**
  * an axial thumbscrew clamping a stack of knuckles;
  * a split eye squeezed onto an axle by a screw, with each half's split face relieved
    about 0.2 mm around the eye so the screw has something to close;
  * a screw tip pressing into a groove on a stem, which brakes the rotation and keeps
    the stem from pulling out.
* **Captive printed nuts** sit in a slot that opens on a hidden face. A slot on the
  wall side is inserted before gluing, and the wall then captures the nut. Turn the
  hex so its flats face the thin wall (corners cost about 15 % more) and so the slot
  prints with a flat roof.
* **Threads straight into a part** whose screw axis is vertical in print save a nut.
* **Check fastener length against hole depth,** and check thread engagement.

## Split shells

* **Split a part on the plane that holds its cable path or axle.** Each half prints
  flat on the split face, the cable is laid in, and the halves clamp the axle.
  Screws or the clamp screw join the halves.
* **Hollow them as far as the walls allow** and keep solid bosses around screws. Two
  halves screwed together form a closed box section, which stays stiff.

## Printability (FDM, no supports)

* Every part has a designed print orientation with a flat face on the bed; show it
  in `print_layout`.
* **Horizontal holes are teardrops** with the tip up *in that part's print
  orientation* (in model space it may point along −Z, +X, +Y …). In split shells
  printed split face down, bore and channel tips point away from the split face.
* **Bridges and overhangs** stay within the limits in `printer.json`. Round the roof
  edges of hollow pockets so the flat roof that must bridge stays short. Use 45° cone
  seats and chamfered undersides.
* Print threads with the axis vertical, in the strong material, at 100 % infill.
* Export binary STL or 3MF at `normal` detail. ASCII STL of threads can exceed
  100 MB.

## Thin spots that only measuring finds

* **Teardrop tips:** wall at the tip = boss radius − (hole diameter / 2)·√2.
* **Knob valleys around a threaded bore:** a 7-lobe knob of radius 7 around a 6.5 mm
  thread leaves only about 1.1–1.3 mm at the valleys.
* **Hex corners against flats:** the same nut slot left 1.7 mm (corners toward the
  thin side) or 2.9 mm (flats) of wall.
* **Walls beside cable grooves, nut slots and pin holes,** and webs between two
  cut-outs: one design left a 0.5 mm web between a cable groove and a pin hole.
* **Fixes interact.** Raising a thread clearance thins the nut wall and the knob
  valleys. After a fix, re-measure the neighbours.

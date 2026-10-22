# File conventions

A layout that makers found worth reusing for every multi-part design.
`assets/template.scad` already follows it; this file explains why each piece is
there, so you can keep it intact while the design grows.

## One parametric file per design

* **Header comment:** the design name, the brief, the parts and hardware, the print
  notes, numbered assembly steps, the coordinate datum (for example "wall face at
  x = 0, Z up, drop axis along Y"), and that printer values come from
  `printer.json`.
* **Customizer View section first:**

  ```openscad
  /* [View] */
  part         = "assembly"; // [assembly, print_layout, <part_1>, <part_2>, ...]
  show_device  = true;       // reference only - never exported with the parts
  housing_view = "solid";    // [solid, transparent, hidden]
  refs         = "both";     // [off, names, numbers, both]
  detail       = "normal";   // [draft, normal, fine]
  drop         = 0;          // [0:5:90]   one slider per motion, with its real range
  tilt         = 0;          // [-90:5:90]
  animate      = false;      // drive the motions (and camera) from $t
  ```

* **The `part` modes:**
  * **`assembly`:** everything in its working pose, driven by the sliders; for fit
    and motion.
  * **`<part name>`:** one part, isolated, in its print orientation; for detail and
    single-part export.
  * **`print_layout`:** every part apart, each in its print orientation, as one plate
    for one export and one slice. Users value this most.
* **`housing_view`** (transparent or hidden) shows joints and cable paths without
  editing the file.
* **`show_device`** draws the reference model of each purchased object, built from
  the user's measurements. It is never exported.
* **`detail`** drives `$fa`, `$fs` and slice counts. Renders and exports run one step
  finer than the preview.
* **Animation section:** the motions and the camera (`$vpr/$vpt/$vpd`) driven from
  `$t`. Export frames with `--animate N`; join them with ffmpeg for a video.
* **Parameter sections** (`/* [Printer] */`, `/* [Cradle] */`, …): every parameter
  with a one-line comment, and derived values computed in a `// --- derived` block
  rather than repeated.
* **Colour constants** per part (`*_col`), used in the assembly and the print layout.
* **One module per part.** Add placement helpers (`at_<thing>()`) that move a part's
  own frame into the world. Then any part can be checked or exported on its own.
* `assert()` the printer rules and `echo()` the key derived sizes near the derived
  block.

## Reference stickers (`refs`)

Marks on each part's surface give the user a shared vocabulary: "make it rounder at
A4" instead of describing zones in words.

* **Numbered stickers:** a thin red disc with a white label (a letter prefix per
  part, e.g. B1, H2, C3) lying flat on the face it marks.
* **The part's name stamped** in red on a flat face.
* **On the surface, not floating:** users rejected floating labels with leader
  lines. A sticker on a hidden face is hidden, like a real sticker.
* **Drawn inside the part's own transform** (`<part>_m()` = part + `part_marks()`),
  so marks move and hide with the part in every view, including the print layout.
* **Preview only:** wrap them in `if ($preview)`. Prove once that an export with
  stickers on equals one with them off.
* **Data:**
  * a sticker is `[label, point on the surface, surface normal]` in the part's frame;
  * a name is `[text, point, normal, height, optional in-plane turn]`;
  * give each point a comment saying what it marks.
* **Placement:**
  * put points on the features most likely to be discussed: ends, slots, faces,
    joints, cable openings, corners that could be rounded;
  * a name must fit within a flat area (shrink the text rather than let it wrap
    round an edge);
  * after geometry changes, re-check that every point still sits on the surface.
* **New view options default to on.** A feature that starts switched off reads as
  "not applied".

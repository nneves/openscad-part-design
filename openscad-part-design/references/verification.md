# Verification

How to test a design before it is printed. When to run each check is in `SKILL.md`,
step 6.

## Contents

* Collision sweeps
* Full measured check
* When a render looks wrong
* Smallest dimension
* Checks by arithmetic
* Proofs
* Tool map (openscad-mcp)
* Command-line checks

## Collision sweeps

**Setup.**
* Fixed parts, plus the wall or mounting surface as a solid.
* Moving parts, posed by the motion variables.
* The hardware (knobs, screw heads, nuts).
* Keep-out solids for the cable, the plug and the fingers that assemble it.

**Grid.**
* Sweep each joint over its full range, with every other joint at the ends and the
  middle of its own range (for example tilt −90…90 at drop 0, 45 and 90).
* Use finer steps near the limits.
* Always include the pose the user saved in the file, because one saved pose once had
  the device inside the wall.

**Classify every overlap and report where it is.**
* **Contact:** zero thickness, such as a knob on its face, a screw head on its seat or
  a device on its floor. It is intended and passes.
* **Interference:** the overlap has volume, so it fails.

**Know the tessellation error before trusting a small number.**

| Quality | Facets | Typical error | Use for |
|---|---|---|---|
| draft | about 8 per circle | ~2.7 mm | quick screening; false contacts of a few hundredths are noise |
| normal | from `$fa/$fs` | ~0.2 mm | most sweeps |
| high | 64 per circle | 0.01–0.04 mm | bearings and fits of 0.1–0.2 mm |

**Bearings.** An axle turning in its bore (0.1 mm clearance) always shows up as a
near-contact. Leave it out of the sweep: cut the axle off the moving part, check the
axle alone with a concentric clearance check at high quality, and remember that the
cut itself creates a fake minimum gap.

## Full measured check

1. Syntax check, then render the front, top and isometric views, plus the user's
   angle.
2. Export a temporary STL of every part to a scratch folder (`normal` detail, stickers
   off).
3. Measure with probe rays, sections, hole features and clearance checks. Read
   derived values with an expression evaluator. Check:
   * **wall thickness:** every structural wall ≥ `min_wall_mm`, measured at the thin
     spots (`design-principles.md`, "Thin spots");
   * **holes:** clearance holes at nominal + `hole_allowance_mm`; pin holes and
     threads at their clearance parameters;
   * **spacing:** bolt circles, pitch, and coaxial alignment across mating parts;
   * **fits:** sliding fits at `slide_clearance_mm`, running gaps, and the purchased
     object in its pocket, with no interference.
4. Report a table:

   | Item | Requested | Measured | Result |
   |---|---|---|---|
   | Arm wall beside the nut | ≥ 2.4 | 2.55 | ✅ |
   | M3 clearance holes | 3.2–3.4 | 3.40 | ✅ |
   | Lug web beside the pin | ≥ 2.4 | 0.50 | ❌ |

5. For each failure, propose a fix and say what it would cost (size, looks, another
   wall). The user chooses. State what was not checked.

## When a render looks wrong

Missing faces, see-through walls, or a whole feature absent from one view while
present in another are usually preview artifacts, not geometry errors. Image
renders use OpenSCAD's preview (OpenCSG), which can draw an `intersection()` or a
`difference()` with large helper solids wrongly.

1. **Check the mesh first,** before changing any geometry: validate the geometry
   (watertight, one solid, no open edges) and compare its volume with a hand estimate
   from blocks and cylinders. If they agree, the geometry is right.
2. **Fix the picture:** wrap the part's module in `render()`, so the preview shows the
   computed mesh (quick with the Manifold engine). Also keep helper solids (trim
   boxes, cutters) close to the part's own size.
3. Render again, and tell the user that their OpenSCAD preview had the same problem,
   now fixed by the same `render()`.

## Smallest dimension

For "as compact as possible", sweep the deciding dimension over the pose grid (for
example the arm length from 66 to 74 mm: 73 was the first to clear). Then add margin
at least as large as the check's facet error, and report both values ("52 mm is the
shortest that clears; I set 53").

## Checks by arithmetic

Check these by hand as well as with the tools:
* fastener length against hole depth;
* thread engagement;
* the cable passage beside pins and through bores;
* walls beside every cut-out.

These are the places where designs broke silently.

## Proofs

* **Printed threads:** intersect the screw with its nut in the assembly; the result
  must be empty.
* **Preview-only stickers:** export with stickers on and off and compare the files;
  they must be identical.

## Tool map (openscad-mcp)

| Task | Tool and mode |
|---|---|
| Parse, asserts, echo output | `validate` mode `syntax` |
| Views of the assembly or a pose | `render` mode `views` (`variables` sets sliders); `grounded` + `look_at` to frame a region |
| Parts in colour, or one part isolated | `render` mode `parts` |
| Wall thickness, gaps along a line | `measure` mode `probe` with `rays` |
| Holes and bolt circles | `measure` mode `features` |
| Pairwise gaps and contacts | `check` mode `clearance` (add `pairs`; `quality: high` for small fits) |
| Sweeps | `check` mode `motion` (`moving`, `axis`, `center`, `range`, `steps`) |
| Derived values | `scad_eval` |
| Temporary or final STL/3MF | `export_model` (with `parts` for one file per part) |
| Fits and fastener data | `reference` |

Notes on this server:
* **Each part in `check` and `measure` must be a single module call.** Make a scratch
  copy of the design with its top-level `if (part == …)` dispatch removed, and add
  wrapper modules such as `module v_moving() { arm(); saddle(); }`.
* Checks that take longer than about 2 minutes continue in the background. Carry on
  with other work and pick up the result when it arrives.
* Passing variables prints harmless "was assigned … overwritten" warnings.
* Renders are cached; clear the cache if a render looks stale.

## Command-line checks

Use these with a preview-only MCP server, or with none.

* **Render** with `openscad -o view.png --imgsize=1280,960 --colorscheme=Tomorrow
  --camera=tx,ty,tz,rx,ry,rz,dist -D 'part="assembly"' design.scad`. Add
  `--projection=o` for true side views.
* **Collision test:** a harness file that `include`s the design (with `part="none"`
  so that nothing draws by itself) and contains
  `intersection() { moving_at_pose(); fixed_parts(); }`.
  * Pass the pose with `-D`.
  * If OpenSCAD reports "Current top level object is empty", the parts are clear.
  * Otherwise export the overlap to STL and print its bounding box: a flat box is a
    contact, a box with volume is an interference.
* **Exports:** `--export-format binstl` for binary STL, or a `.3mf` output.
* **Pitfalls:**
  * On Windows, use `openscad.com` for the command line.
  * Searching the output for "error" also matches the normal `Status: NoError` line.
  * Check that the output file exists rather than trusting a filtered log.
  * `-D '$t=…'` is ignored; use `--animate N`.
  * Setting `$vpr/$vpt/$vpd` in the file disables view-all.

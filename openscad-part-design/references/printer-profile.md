# Printer profile (`printer.json`)

The printer decides the walls, holes, fits, bridges and plate size, so the design
reads them from one file: `printer.json` in the same folder as the `.scad` file. One
profile serves every design in that folder. Ask for it once; if the user already gave
the specs, write it from those instead. Afterwards, read it and mention it in one
line.

## The questions

Ask them in one message, numbered, with the default in brackets, so the user can
answer "defaults except 4: PLA only". Mark every value that came from a default.

1. **Printer model and bed size** (X × Y × Z mm)? [no default: ask, e.g. "Prusa MK3S,
   250 × 210 × 210"]
2. **Nozzle diameter?** [0.4 mm]
3. **Layer height** for functional parts? [0.2 mm]
4. **Materials** you have, and which one for strong or threaded parts? [PLA for
   general parts, PETG for threads, pins and clips]
5. **Minimum structural wall?** [2.4 mm, about 5–6 perimeters at 0.4 mm]
6. **Hole allowance** over a screw's nominal diameter for a snug fit? [+0.3 mm,
   range 0.2–0.4; M3 → 3.3 mm]
7. **Sliding-fit clearance** per side? [0.25 mm, range 0.2–0.5]
8. **Longest bridge and steepest overhang** that print cleanly? [14 mm, 45°]
9. **Supports** allowed? [no: design every part to print without them]
10. **Slicer?** [whichever they use; it decides STL vs 3MF]
11. **Anything already calibrated** (a hole size, thread clearance or fit that worked
    before)? [none]

## File format

```json
{
  "printer": "Original Prusa i3 MK3S",
  "bed_mm": [250, 210, 210],
  "nozzle_mm": 0.4,
  "layer_mm": 0.2,
  "materials": { "general": "PLA", "strong": "PETG" },
  "min_wall_mm": 2.4,
  "hole_allowance_mm": 0.3,
  "slide_clearance_mm": 0.25,
  "max_bridge_mm": 14,
  "max_overhang_deg": 45,
  "supports": false,
  "slicer": "PrusaSlicer",
  "defaults_used": ["layer_mm", "max_bridge_mm", "max_overhang_deg"],
  "proven": [
    { "date": "2026-10-22", "design": "hook.scad", "what": "eccentric thread, 6.5 mm pin",
      "value": "radial clearance 0.42 mm", "result": "turns smoothly, no wobble" }
  ],
  "updated": "2026-10-22"
}
```

## Using it

* Copy the values the geometry needs into a `/* [Printer] */` section of the `.scad`
  file, each with a comment `// from printer.json`. OpenSCAD can't read JSON, so
  this one copy is the price of keeping the printer data in a single file the next
  session can find.
* Turn the limits into `assert()`s:
  * walls ≥ `min_wall_mm`;
  * each sliding fit ≥ `slide_clearance_mm` per side (for example GoPro finger gaps
    = 3.0 mm + 2 × the clearance);
  * every `print_layout` within `bed_mm`;
  * bridges ≤ `max_bridge_mm`.
* Quote the profile in verification reports ("min wall 2.4 mm from printer.json").
* After a test print, add what worked (or what didn't, and the correction) to
  `proven`, and use those values before the generic defaults next time. When you
  change an existing value, show the user the old and the new value.
* For a different printer, write a new profile in the new design's folder.

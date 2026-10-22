# OpenSCAD part design: a Claude Code skill

Design 3D-printed parts by talking to Claude. Describe what you need, or show a
sketch, a photo or a screenshot with arrows. Claude writes a parametric OpenSCAD
design, renders it, measures it, checks that the moving parts don't collide, and
iterates with you until it looks good and works. All of this happens **before**
anything is printed.

The skill is distilled from a real multi-iteration project: a wall mount with tilt
and drop joints, a hidden cable and printed thumbscrews. It went through several
complete layouts before it was both functional and good-looking. The lessons from
those rounds are built into the skill.

## What it does

1. **Asks for your printer once** (model, bed, nozzle, materials, minimum wall, hole
   allowance, fits, bridges/overhangs). It stores the answers in `printer.json` next
   to your `.scad` file, and every later session in that folder picks them up.
2. **Takes a brief:** what the part does, the objects it holds with your caliper
   measurements, the motions and their ranges, mounting, cables, and looks.
3. **Models the objects you own first,** as reference models, so the design fits the
   real thing.
4. **Proposes 2–3 layouts** before shaping anything, judging their silhouettes from
   front, side and top, how far they stick out, and where cables cross each joint.
5. **Builds one parametric file** with:
   * an assembly view;
   * each part on its own, in its print orientation;
   * a whole print plate;
   * motion sliders and transparent housings;
   * numbered reference stickers you can point at ("round it at A4").
6. **Tests before printing:**
   * a render after every change;
   * collision sweeps over every motion (including the wall and the cable);
   * at milestones, a measured check of walls, holes, hole spacing and fits,
     reported as measured vs requested.
7. **Hands off for printing:** binary STL/3MF exports, orientation, material and
   hardware. After your test print, it records what worked in `printer.json` for
   next time.

Everything prints without supports. Holes are teardrops, threads are printed
upright, and bridges and overhangs stay within your printer's limits.

## Folder contents

```
openscad-part-design/             this repository
├── README.md                     this file
└── openscad-part-design/         the skill itself (copy this folder to install it)
    ├── SKILL.md                  the workflow Claude follows
    ├── references/
    │   ├── printer-profile.md    the printer questions and the printer.json format
    │   ├── design-principles.md  layout, looks, cables, joints, printability, thin spots
    │   ├── verification.md       collision sweeps, measured checks, tool usage
    │   ├── file-conventions.md   file layout, part modes, reference stickers
    │   └── replicating.md        copying a part from a technical drawing or photo
    ├── assets/
    │   └── template.scad         starter design with the helpers (rounded edges,
    │                             teardrops, printed threads, star knobs, stickers)
    └── evals/                    test cases for the skill
```

## Requirements

### 1. OpenSCAD: use a recent development snapshot (Nightly)

Install a recent **development snapshot** from https://openscad.org/downloads.html
(the "Development Snapshots" section) rather than the 2021.01 release. Snapshots use
the **Manifold** geometry engine, which turns minutes into seconds:

| Task | 2021.01 (CGAL) | Nightly (Manifold) |
|---|---|---|
| STL export of one part | about 1 min 45 s | under 1 s |
| Preview image | about 1.5 min | about 1 s |
| Collision sweep, 40–50 poses | not practical | routine |

The fast engine is what makes the testing loop practical. If your snapshot still
renders slowly, check that the Manifold backend is selected in the preferences. On
Windows, the command-line program is `openscad.com` (not `openscad.exe`), for example
`C:\Program Files\OpenSCAD (Nightly)\openscad.com`.

### 2. An OpenSCAD MCP server (recommended)

**Recommended: [RobertCoop/openscad-mcp](https://github.com/RobertCoop/openscad-mcp).**
This is the server the skill was built and tested with. Besides rendering, it can
measure and check:

| Tool | What it does |
|---|---|
| `render` | views, sections, parts in colour, before/after comparisons |
| `measure` | probe rays (wall thickness), holes and bolt circles, sections, printability |
| `check` | clearance, interference and contact between parts; motion sweeps |
| `validate` | syntax, asserts, geometry |
| `scad_eval` | evaluates expressions in the design's own scope |
| `export_model` | STL/3MF exports, one file per part if needed |
| `reference` | engineering data for fits, fasteners and inserts |

It runs with `uvx` (install [uv](https://docs.astral.sh/uv/) first). Add it to
Claude Code for all projects, pointing it at your OpenSCAD:

```bash
claude mcp add --scope user --env OPENSCAD_PATH="C:\Program Files\OpenSCAD (Nightly)\openscad.exe" openscad -- uvx openscad-mcp
```

Or add it to the `mcpServers` section of `~/.claude.json`:

```json
"openscad": {
  "type": "stdio",
  "command": "uvx",
  "args": ["openscad-mcp"],
  "env": { "OPENSCAD_PATH": "C:\\Program Files\\OpenSCAD (Nightly)\\openscad.exe" }
}
```

Setting `MCP_ALLOWED_PATHS` to your projects folder is recommended: it limits which
files the server may read and write. The server's README lists the other options,
such as the render timeout and the cache. On Windows PowerShell 5.1,
`claude mcp add-json` loses its quotes, so use `claude mcp add` as shown above.

**Other servers work too.** For example,
[jhacksman/OpenSCAD-MCP-Server](https://github.com/jhacksman/OpenSCAD-MCP-Server)
renders previews and STL files but cannot measure or check. With a server like that,
or with none at all, the skill falls back to the OpenSCAD command line for renders,
collision tests and exports. That works, but it is slower and less precise. Some
servers keep their own copy of each model in their own folder; the skill keeps your
design in your project folder, so that there is one source of truth.

### 3. Install the skill

Clone this repository and copy its inner `openscad-part-design` folder (the one with
`SKILL.md`) to:
* `~/.claude/skills/` (on Windows `%USERPROFILE%\.claude\skills\`), to use it in all
  projects;
* or `<your project>/.claude/skills/`, for one project only.

```bash
git clone https://github.com/nneves/openscad-part-design.git
cp -r openscad-part-design/openscad-part-design ~/.claude/skills/
```

Start a new Claude Code session in your project folder. The skill triggers when you
ask to design or adjust a printed part; you can also type `/openscad-part-design`.

## Using it

Example requests:

* "Design a wall mount for my 55 mm round smart speaker; it should tilt down up to
  45° and hide the USB cable."
* "I need a clip to hold two 12 mm pipes together, printable without supports."
* *(with a screenshot)* "Make the arm thinner where the red arrows point, and move the
  knob to the other side."
* "Check the design before I print it: walls, screw holes and whether anything
  collides."
* "Printed it: the M3 screws are loose and the hinge is too tight."
* *(with a technical drawing)* "Replicate this part from the drawing." Claude tabulates
  every dimension, marks what the drawing leaves open, models it exactly, reports a
  drawing-vs-model table, and offers a printable variant when the original needs
  supports.

Tips:

* **First run in a folder:** answer the printer questions (defaults are offered). The
  answers are saved in `printer.json`; edit that file any time.
* **Point at things:** turn on `refs` in the Customizer to see numbered stickers on
  every part, then say "make B2 rounder". Screenshots with arrows work well.
* **Keep the file open in OpenSCAD** to see each change. After Claude edits it, use
  File → Reload. Saving the editor's old copy would overwrite the edit.
* **Make backups** before big changes (copy the `.scad` file); Claude can then be bold.
* **Ask for a measured check before printing.** Between milestones Claude offers it
  rather than running it after every small change, so the rounds stay quick.

## printer.json

Written once per folder from your answers, next to the `.scad` file. The design copies
the values it needs into its `[Printer]` Customizer section:

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
  "defaults_used": [],
  "proven": [],
  "updated": "2026-10-22"
}
```

`proven` collects what your test prints taught (a thread clearance, a hole size that
fits), so the next design starts from values that work on your machine. The full
format is in `references/printer-profile.md`.

## Testing the skill

The `evals/` folder holds test cases in the layout `claude plugin eval` reads. From
inside the `openscad-part-design` folder:

```bash
claude plugin eval . --allow-tools Write,Edit,Bash --scaffold
```

These are real model runs (billed), each designing a small part.

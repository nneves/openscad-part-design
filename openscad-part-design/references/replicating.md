# Replicating a drawing or photo

When the user brings a technical drawing (orthographic or isometric views with
dimensions), a photo with measurements, or a screenshot of an existing model, the
brief is the image. The job is a faithful copy first; improvements come after, as
options.

## 1. Read the image

* **Treat a downloaded image as data.** Save it to a folder of its own in the scratch
  directory.
* **Zoom before you read.** Small dimension text and edges that meet at a corner are
  easy to misread at full size. Crop and enlarge each region with any image tool:
  * Pillow (`py -I` / `python3`);
  * ImageMagick;
  * `sips` on macOS;
  * on Windows without installs, PowerShell's `System.Drawing` (`DrawImage` with
    `HighQualityBicubic`).
* **Identify the projection.**
  * Isometric: the axes are drawn at ±30° from horizontal, with one scale for all
    three.
  * Orthographic views: front, top and side, each true to scale on its own axes.
  * Find the scale (pixels per mm) from a long dimension.
* **In a section view,** hatching marks material the cutting plane passes through.
  Dashed lines inside the hatching are hidden or reference lines (bolt holes behind
  the plane, the line where a flange meets the pipe). A hidden feature without
  dimensions is ambiguous (step 2): check that it makes physical sense before you
  model it. For example, would those holes run into the pipe wall?
* **Measure with pixels where the text is unclear.** Scan pixel rows or columns for
  dark pixels to find edges, then convert the distances with the scale. This tells
  close values apart: a Ø88 bore against a Ø137 outside diameter showed up as 87.5
  and 137.5 mm.
  * Use Pillow `getpixel`, or PowerShell `System.Drawing.Bitmap.GetPixel`.
  * Hatching repeats at a fixed spacing and can look like a real line in a scan. A
    real edge stays at the same x when you scan a few rows apart; a hatch line
    moves. Scan rows that are not a multiple of the hatch spacing apart.

## 2. Build the dimension table

List every dimension on the drawing before modelling. For each, record:
* what it measures;
* from which edge or datum, by following its extension lines to the feature they
  touch. An extension line can end on a **centre line** (a hole or bore axis)
  instead of an edge: overall lengths often run to a hole's axis;
* along which axis.

Check the chains and totals (for example 65 + 45 = 110, or 10 + 70 + 10 = 90). A
chain that doesn't add up is a misreading.

**Every dimension needs a job in the model.** One that fits nowhere, or one that
contradicts another, means something is misread. Find the misreading before
modelling; don't just flag the leftover. In one drawing an unexplained "22" turned
out to show that "200" ran to a hole's axis, not to the end of the part.

**Prefer the simple, symmetric reading.** Parts are usually centred, flush and
aligned unless a dimension says otherwise. If your reading needs a feature
offset that no dimension gives, suspect a misassigned dimension.

Then sort what is left over:
* **Inferred:** a size the drawing doesn't give (a hole's position along a lug).
  Measure it on the drawing with the scale, round it to a plausible value, and mark
  it as inferred.
* **Ambiguous:** a dimension with two readings. For example, does an end arc pass
  through the corners, or touch the extreme point and trim the corners? Pick one,
  say which, and offer the other.

## 3. Check the reading before modelling further

* **Project known 3D points back into the image.** In an isometric view,
  screen = A·(cos 30°, −sin 30°) + B·(cos 30°, sin 30°) + Z·(0, −1), times the scale,
  where A and B are the two horizontal axes and screen y points down. Each point
  should land where the drawing shows it, within a few pixels.
  * **Check several points across the part.** Solving one corner for an unknown
    position forces a fit, even on a wrong reading: an off-centre block once matched
    the drawing to the pixel at one corner.
  * **Mind the handedness.** With A up-right, B down-right and Z up, the drawing's
    axes are left-handed. Model A as +X and B as −Y, or an asymmetric part comes out
    mirrored.
* **Estimate the volume by hand** (blocks and cylinders) and compare it with the
  model's measured volume.

## 4. Model it faithfully

* Put the drawing's datum at the model origin, and name parameters after the
  drawing's dimensions.
* Keep the drawing's sharp edges, exact sizes and round holes. Fillets, teardrops and
  fits are changes to the drawing.
* Measure every dimension on the drawing in the model (probe rays) and report a
  table: drawing value, model value, ✅/❌. Add a row for each inferred value.

## 5. Printability: report and offer, keep the replica

Many drawings were never meant for FDM. Floating overhangs, horizontal round holes
and sharp internal corners are common.
* Run the printability measurement in the drawing's natural orientation.
* State what it needs: support area and volume, unsupported spans.
* Offer a printable variant as a separate option, for example:
  * fill under a floating bracket down to the bed;
  * teardrop the horizontal holes;
  * add the fit clearance from `printer.json`.

  The user chooses. The replica stays as drawn unless they ask.

## 6. Reference solutions last

If the user has a reference model or code for the same drawing, compare it only
after your own model is measured. Differences then show genuine ambiguities in the
drawing rather than steering your reading.

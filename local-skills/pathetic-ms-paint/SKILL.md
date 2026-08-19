---
name: pathetic-ms-paint
description: Generate or redraw raster images as intentionally clumsy old-MS-Paint mouse doodles with a white background, shaky pixel lines, awkward proportions, and crude fills. Use for requests mentioning 故意画坏、鼠标涂鸦、低质像素、MS Paint, pathetic scribbles, or charmingly bad drawings; do not use for polished pixel art or clean illustration.
---

# Pathetic MS Paint

Create a deliberately incompetent-looking image while keeping the requested subject vaguely recognizable. Use the available built-in image-generation capability.

## Choose the input mode

- With an attached image, treat it as a broad subject and composition reference. Preserve the main subject, rough pose, and overall arrangement, but intentionally distort proportions, spacing, outlines, and small details. Do not claim close fidelity.
- Without an attached image, generate the subject described by the user. If the subject is reasonably inferable, proceed without asking for extra art direction.
- Follow explicit user overrides for background, text, aspect ratio, object count, or fidelity. Otherwise use the defaults below.

## Default style

Shape the generation prompt around this style block:

```text
Plain pure-white background. Drawn badly in an old version of MS Paint with a cheap mouse: shaky one-pixel black outlines, crude pixel-by-pixel marks, jagged stair-step edges, hard unpolished pixels, badly closed curves, tiny white gaps, uneven paint-bucket fills, accidental-looking overlaps, mismatched symmetry, lumpy anatomy, stiff poses, and obviously wrong proportions. Use simple flat default-Paint colors that may be slightly mismatched. The result should feel naïve, awkward, confusingly off, charmingly terrible, and genuinely amateur rather than like polished art imitating amateur art. Keep the main subject only vaguely recognizable.
```

Add these negative constraints unless the user requests otherwise:

```text
No smooth vector lines, polished cartoon rendering, professional pixel art, anti-aliased curves, gradients, realistic lighting, photorealism, detailed textures, decorative scenery, captions, signatures, logos, or watermarks.
```

## Generation behavior

- Generate one image unless the user asks for variants or multiple assets.
- Prefer a full view of the main subject, roughly centered but slightly awkwardly placed, with uncomfortable empty space.
- Do not introduce extra characters, props, scenery, or narrative elements that the user or reference did not imply.
- When a reference image exists, state clearly in the generation prompt that it is a reference and repeat the broad invariants that should remain recognizable.
- Preserve intentional badness during revisions. Fix only the element the user identifies; do not automatically clean up the rest.

---
name: cgd-non-designers-design-review
description: Review a visual design and recommend specific improvements using The Non-Designer's Design Book's four principles, color, and typography. Use when asked to critique a flyer, slide, document, brochure, business card, or web page, explain why a layout feels cluttered or weak, or assess font combinations and visual hierarchy. Return findings and proposed changes; use cgd-non-designers-design-create when the user asks to implement a redesign.
---

> [!NOTE]
> After reading this `SKILL.md`, say: `🔎 I read cgd-non-designers-design-review.`

# Review a design

Explain what the reader sees, how that affects the message, and which change would help. Evaluate the artifact against its purpose, audience, medium, and constraints.

## Inspect the evidence

Read the brief and inspect the supplied artifact. Prefer the rendered page for visual claims, using editable source to locate causes and propose exact changes. When given only text or a layout specification, evaluate what it establishes and mark visual conclusions as provisional. Request the missing artifact if no meaningful design assessment is possible.

A review returns findings. Do not edit the design unless the user requests implementation. Preserve intentional choices such as a formal centered layout, a monochrome palette, or a fixed brand family when evaluating possible fixes.

## Calibrate the visual judgment

Open the [original type comparison](references/type-comparison.png) with an image-capable tool before judging hierarchy or font relationships. Compare the quiet single-family treatment, the weak distinction between roles, and the stronger role contrast. Identify the visible relationship that supports a finding; a style different from the example is not itself a defect. If image inspection is unavailable, state that limit. The [editable SVG](references/type-comparison.svg) is its source.

For a rendered artifact, inspect both its intended viewing size and a reduced preview. Trace where attention goes first and whether the same groups remain recognizable. When hue carries the hierarchy, check a grayscale preview too. Keep these observations separate from measurements not actually taken.

## Diagnose relationships

First identify the intended focal point and the one that actually attracts attention. Trace the reading order and the reader's next action. Use the following checks where they explain an observed problem:

| Principle  | Evidence to look for                                                                                                                        | Corrective direction                                                                                                                                     |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Proximity  | Related headings, text, images, captions, or action details appear separate; equal gaps imply relationships that the content does not have. | Move related elements into one group and distinguish gaps within and between groups. Do not group unrelated content just to reduce the number of blocks. |
| Alignment  | Edges or baselines almost line up, nearby items use unrelated axes, or distant groups lack a visible connection.                            | Identify the specific shared edge, baseline, or column to use. Assess centered alignment by the brief rather than rejecting it automatically.            |
| Repetition | Equivalent headings, pages, navigation items, or graphics receive inconsistent treatments; repeated decoration distracts from the content.  | Reuse a meaningful treatment for the same role; reduce repetition that competes with the focal point.                                                    |
| Contrast   | Headings and details look nearly alike, several elements compete for first attention, or an accent promotes the wrong information.          | Unify equivalent roles and separate different roles through a deliberate change in size, weight, spacing, shape, or color.                               |

One defect may involve several principles. Report the defect once with the relevant reasoning rather than generating a finding for every checklist row.

## Diagnose type and color

Distinguish intentional harmony from accidental similarity. A quiet single-family design is not defective merely because it has little variation. For a conflicting combination, identify what the faces share before proposing a replacement.

Examine type contrast through size, weight, structure, form, direction, and color:

- Compare visible size and stroke weight together. A small heavy label can compete with a large light title; making both more emphatic may worsen the conflict.
- Compare structure through serifs, stroke modulation, stress, width, and x-height. Oldstyle serifs, modern serifs, slab serifs, sans serifs, scripts, and decorative faces provide useful Latin categories, but two category labels alone do not prove a good pairing.
- Distinguish form from structure. Capitals versus lowercase and upright versus flowing letters change form; two scripts or a script plus a similar italic can remain too alike.
- Treat a horizontal line and a tall text column as directional contrast. Do not recommend rotation without a communicative reason.
- Inspect typographic color even in black-and-white work: dense, dark text and light, open text create different textures. Consider line spacing, letter spacing, and weight before adding another font.
- Check long passages for readable line length and spacing, and fine strokes or decorative faces at the final size. Avoid prescribing one point size or banning a font regardless of audience and medium.

For palette problems, distinguish color relationships from readability. Complementary or analogous hues can still have insufficient light-dark separation. Check competing accent areas and foreground-background value; grayscale can reveal hierarchy that depends only on hue. Do not claim a measured contrast ratio from an unmeasured screenshot.

For print, inspect the stated size, folds, paper, ink, and color-space requirements where relevant. For screens, inspect the supplied viewports and navigation consistency. Do not infer print behavior or responsive behavior from a single preview. Apply Latin-specific typography advice only to the letterforms it describes.

## Return useful findings

Prioritize faults that obstruct the message or reading order before small refinements. For each finding, identify:

- The location and observable condition.
- The resulting ambiguity or difficulty for the intended reader.
- A specific revision, including the element to move, align, repeat, enlarge, simplify, or restyle.

Use exact locations and values when the source supports them; otherwise describe the relationship to change. Distinguish a defect from an optional stylistic alternative. Do not invent findings to fill a quota. If the design already satisfies the brief, say so and explain any remaining uncertainty briefly.

Return the critique in the user's requested format. It should be specific enough for the user or a creating agent to apply without a second design brief.

## Source

Robin Williams, _The Non-Designer's Design Book_, third edition, 2008. The diagnostic criteria draw on chapters 1-8 for composition and color, and chapters 9-12 for typographic relationships.

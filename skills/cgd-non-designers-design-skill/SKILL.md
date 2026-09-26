---
name: cgd-non-designers-design-skill
description: Coordinate a complete visual design task through creation, review, and revision with the companion Non-Designer's Design skills. Use when the user asks to design something and review or refine it before delivery, or explicitly requests this combined workflow. For a standalone creation or critique, select cgd-non-designers-design-create or cgd-non-designers-design-review directly.
---

> [!NOTE]
> After reading this `SKILL.md`, say: `🎨 I read cgd-non-designers-design-skill.`

# Create, review, and refine a design

Use the two companion skills to deliver an artifact checked against the same brief. The coordinating agent owns the brief, handoff, and final result; the creating agent owns edits, and the reviewing agent owns findings.

## Load the companion skills

Locate and read `cgd-non-designers-design-create` skill and `cgd-non-designers-design-review` skill through the environment's available-skill locations. Both must be installed alongside this skill. Each companion also works independently.

Do not assume another skill's resources were copied into this directory or claim to have used a missing companion. If one is unavailable, identify the missing skill and ask the user to make it available before running this combined workflow.

## Carry the brief through the work

1. Establish the audience, communication goal, required content, medium, output format, and constraints from the request and existing artifacts. Keep these unchanged through the handoffs unless the user changes them.
2. Use the create skill to produce or revise the artifact. Give it the brief and any existing design. Preserve a reviewable first version so the review can refer to a specific artifact.
3. Use the review skill on that version and the same brief. Give the reviewer the actual artifact and constraints; do not feed it the creator's desired verdict. When an independent agent is available, give it this bounded review task with no editing authority. Otherwise conduct a separate review pass and describe it as self-review.
4. Use the create skill to apply findings that affect communication, readability, or the stated brief. Do not implement a stylistic preference that contradicts a user constraint. Record why a material finding cannot be applied or needs a user choice.
5. Recheck the affected areas and any repeated treatment changed across the artifact. Finish when the brief is satisfied and no actionable material finding remains. If a further pass produces no useful improvement or reaches a user-owned decision, deliver the current artifact with that issue identified instead of looping indefinitely.

If the user supplies an existing design for review and improvement, begin with its review rather than recreating it first. If the review finds no material defect, keep the design.

## Deliver

Return the final artifact in the requested format, a concise account of the important revisions, and any unresolved findings or verification limits. Distinguish a rendered inspection from source-only checks. Do not publish, send, or deploy the artifact unless the user requested that action.

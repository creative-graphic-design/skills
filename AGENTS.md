# AGENTS.md

> [!NOTE]
> After reading this `AGENTS.md`, say: `🤖 I read AGENTS.md for creative-graphic-design/skills.`

## Repository context

- Purpose: This repository is the source of truth for public coding-agent skills maintained by Creative Graphic Design.
- Format: Each skill follows the Agent Skills format: a directory under `skills/` with a `SKILL.md` whose frontmatter has `name` and `description`.
- Public boundary: Do not add internal hosts, credentials, private endpoints, or organization-only procedures to this repository.
- Distribution: The repository is consumed by the `skills` CLI and can be installed as a Claude Code or Codex plugin.

## Skill layout

- Every skill lives at `skills/<collection>/<name>/` and contains `SKILL.md`.
- Every owned skill name starts with `cgd-`. The layout checker currently enforces the prefix but does not impose a domain allowlist.
- The frontmatter `name` must equal the skill directory name and must include a non-empty `description`.
- A `SKILL.md` must appear only at `skills/<collection>/<name>/SKILL.md`, not at the repository root, collection root, or a deeper level.
- The body of every `SKILL.md` starts with a read-receipt NOTE immediately after its frontmatter.
- Keep references, scripts, and evaluation files inside the skill directory because the installer copies that directory.
- Do not add a sample skill just to populate the repository. Add a real skill when its content is ready.

## Evaluation policy

- Routine checks are offline. Shuhari validation and model evaluations use the `manual` pre-commit stage.
- `make check-triggers` and `make eval` are explicit live evaluation commands. Run them only when evaluation work is part of the task.
- Shuhari writes workspaces beside the evaluated skill. They are gitignored and must never be committed because they contain agent transcripts.
- A completed evaluation writes `skills/<collection>/<name>/evals/results.json`. Commit that file with the skill change that produced it.
- Do not add `AGENTS.evals.json` to this repository.

## Development setup

- Run `make setup` in a fresh clone before editing or committing.
- `shuhari` must be on `PATH` when a task explicitly requests the live gates. The pinned mise tool is the source of truth.
- Never install Shuhari with a bare `go install`; it must resolve through the pinned mise tool.
- Keep shell scripts compatible with Bash 3.2 because macOS is a supported development environment.
- `make test` runs the Bats and Python tests. CI runs them on Linux and macOS.

## Documentation site

- `scripts/build_docs.py` generates `docs/` from the skill directories. Do not commit generated `docs/` or `site/` output.
- `make docs-build` builds the site with strict link checking.
- GitHub Actions builds docs on pull requests and deploys `main` to GitHub Pages.

## Prose and comments

- Keep Markdown prose on one physical line per paragraph. The textlint configuration rejects arbitrary hard wrapping.
- Write shell comments in English with shdoc-compatible annotations.
- Prefer concrete instructions and active voice in reader-facing documentation.

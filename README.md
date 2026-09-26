# Creative Graphic Design skills

[![CI](https://github.com/creative-graphic-design/skills/actions/workflows/ci.yaml/badge.svg)](https://github.com/creative-graphic-design/skills/actions/workflows/ci.yaml)
[![Docs](https://github.com/creative-graphic-design/skills/actions/workflows/docs.yaml/badge.svg)](https://github.com/creative-graphic-design/skills/actions/workflows/docs.yaml)
[![skills.sh](https://skills.sh/b/creative-graphic-design/skills)](https://skills.sh/creative-graphic-design/skills)

Public coding-agent skills from Creative Graphic Design for Claude Code and Codex. Install them with the [`skills`](https://github.com/vercel-labs/skills) CLI or use the repository as a plugin. Browse the generated documentation at [creative-graphic-design.github.io/skills](https://creative-graphic-design.github.io/skills/).

## Install

Install every published skill for Claude Code and Codex:

```bash
npx skills add creative-graphic-design/skills --skill '*' --agent claude-code --agent codex --global --yes
```

List published skills without installing them:

```bash
npx skills add creative-graphic-design/skills --list
```

## Use as a plugin

For Claude Code:

```bash
claude plugin marketplace add creative-graphic-design/skills
claude plugin install cgd-skills@creative-graphic-design
```

For Codex:

```bash
codex plugin marketplace add creative-graphic-design/skills
codex plugin add cgd-skills@creative-graphic-design
```

Both plugins read the same `skills/` directory. The `skills` CLI installs selected skills, while the plugins install the repository as a whole.

## Skills

No skills have been added yet. Each published skill will use the `cgd-` prefix and appear in the generated documentation.

## Layout

Each skill is one directory under `skills/`:

```text
skills/<name>/
├── SKILL.md            # required; frontmatter `name` must equal <name>
├── agents/             # optional per-agent wrappers
├── references/         # optional supporting documents
├── scripts/            # optional executables shipped with the skill
└── evals/              # optional evaluation cases and results
```

The repository root must not contain `SKILL.md`, and a skill must not be nested below `skills/<name>/SKILL.md`. The installer copies each skill directory, so files needed at runtime belong inside that directory.

## Development

```bash
make setup            # install the pinned toolchain and pre-commit hooks
make gate             # run the offline checks used by CI
make validate         # check skill layout and naming
make test             # run the Bats and Python tests
make docs-build       # generate and build the documentation site
make check-triggers   # run live trigger checks for skills that define them
make eval             # run live evaluations for skills that define them
make format           # show shell formatting changes
make bump-shuhari     # update the pinned Shuhari version
```

The trigger and evaluation commands make model calls. Run them only when evaluation work is part of the change.

## Renovate

The repository includes the shared Renovate configuration and workflow. The workflow reads `MY_SELF_HOSTED_RENOVATE_CLIENT_ID` from GitHub repository or organization variables and `MY_SELF_HOSTED_RENOVATE_APP_PRIVATE_KEY` from GitHub secrets. Their values do not belong in git.

## License

[Apache-2.0](LICENSE)

#!/usr/bin/env bash

# @file scripts/check_skill_layout.sh
# @brief Enforce the repository's skill layout and naming rules.
# @description
#   Shuhari validates only the skills that carry eval files, and the `skills`
#   CLI reports discovery problems as missing skills rather than as errors. This
#   script covers the gap with offline checks that need no agent:
#
#   1. No `SKILL.md` at the repository root, which would stop CLI discovery and
#      hide every other skill.
#   2. Every skill directory holds a `SKILL.md`.
#   3. Each `SKILL.md` has closed YAML frontmatter with a non-empty `name` and
#      `description`.
#   4. The frontmatter `name` equals the skill directory name.
#   5. Each skill opens with a read-receipt NOTE naming that skill.
#   6. `evals/evals.json` and `evals/triggers.json` agree with that name.
#   7. Each skill directory starts with the repository's `cgd-` prefix.
#   8. Every `SKILL.md` is at `skills/<collection>/<name>/SKILL.md`.
#   9. No Shuhari workspace directory is tracked by git.
#  10. The README skill index lists every skill exactly once and no removed skill.
# @exitcode 0 When every check passes.
# @exitcode 1 When any check fails.
# @example
#   scripts/check_skill_layout.sh

set -Eeuo pipefail
shopt -s nullglob

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
readonly REPO_ROOT
readonly SKILLS_ROOT="${REPO_ROOT}/skills"
readonly README_FILE="${REPO_ROOT}/README.md"

# Every skill this repository owns starts with this prefix. The rest of the
# name stays open until the first real skill establishes a useful domain rule.
readonly OWNED_PREFIX="cgd-"

failures=()

# @description Record a failure without aborting the remaining checks.
# @arg $1 message The failure description.
function fail() {
    failures+=("$1")
}

# @description Read a scalar field from a `SKILL.md` YAML frontmatter block.
# @description
#   Only the leading frontmatter block is considered, and only simple
#   `key: value` scalars are supported. Surrounding quotes are stripped.
# @arg $1 file The `SKILL.md` path.
# @arg $2 key The frontmatter key to read.
# @stdout The field value, or nothing when the key is absent.
function frontmatter_field() {
    local file="$1"
    local key="$2"
    awk -v key="${key}" '
        NR == 1 { if ($0 != "---") exit 0; in_block = 1; next }
        in_block && $0 == "---" { exit 0 }
        in_block {
            prefix = key ":"
            if (index($0, prefix) == 1) {
                value = substr($0, length(prefix) + 1)
                sub(/^[ \t]+/, "", value)
                sub(/[ \t]+$/, "", value)
                gsub(/^["'"'"']|["'"'"']$/, "", value)
                print value
                exit 0
            }
        }
    ' "${file}"
}

# @description Read the first two non-empty lines after a `SKILL.md` frontmatter block.
# @arg $1 file The `SKILL.md` path.
# @stdout The first two non-empty body lines, one per line.
function skill_opening_lines() {
    local file="$1"
    awk '
        NR == 1 { if ($0 != "---") exit 0; in_block = 1; next }
        in_block && $0 == "---" { in_block = 0; in_body = 1; next }
        in_body && $0 !~ /^[[:space:]]*$/ {
            print
            count++
            if (count == 2) exit 0
        }
    ' "${file}"
}

# @description Check whether a line is an English or Japanese read receipt for a skill.
# @arg $1 line The receipt line.
# @arg $2 name The expected skill name.
function is_valid_read_receipt() {
    local line="$1"
    local name="$2"
    local english_prefix="> After reading this \`SKILL.md\`, say: \`"
    local english_suffix=" I read ${name}."'`'
    local japanese_prefix="> この \`SKILL.md\` を読んだら、\`"
    local japanese_suffix=" 私は ${name} を読みました。"'` と言う。'
    local emoji

    case "${line}" in
    "${english_prefix}"*"${english_suffix}")
        emoji="${line#"${english_prefix}"}"
        emoji="${emoji%"${english_suffix}"}"
        ;;
    "${japanese_prefix}"*"${japanese_suffix}")
        emoji="${line#"${japanese_prefix}"}"
        emoji="${emoji%"${japanese_suffix}"}"
        ;;
    *) return 1 ;;
    esac

    [ -n "${emoji}" ]
}

# @description Read `skill_name` from a Shuhari eval or trigger file.
# @arg $1 file The JSON file path.
# @stdout The `skill_name` value, or nothing when it is absent.
function eval_skill_name() {
    local file="$1"
    sed -n 's/.*"skill_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "${file}" | head -n 1
}

# @description Reject a repository-root `SKILL.md`.
# @description
#   The `skills` CLI returns only the root skill when one exists, so this single
#   file would make every skill in `skills/` invisible to installers.
function assert_no_root_skill_file() {
    if [ -f "${REPO_ROOT}/SKILL.md" ]; then
        fail 'SKILL.md exists at the repository root, which hides every skill under skills/'
    fi
}

# @description Reject a `SKILL.md` outside `skills/<collection>/<name>/`.
# @description
#   Shuhari workspaces are pruned: they are run artifacts that can contain a
#   copy of the skill under evaluation, which is not a layout violation.
function assert_skill_depth() {
    local file relative
    while IFS= read -r file; do
        [ -n "${file}" ] || continue
        relative="${file#"${SKILLS_ROOT}/"}"
        case "${relative}" in
        */*/*/*) fail "SKILL.md nested too deep: ${file#"${REPO_ROOT}/"}" ;;
        */*/*) ;;
        *) fail "SKILL.md must be under a collection: ${file#"${REPO_ROOT}/"}" ;;
        esac
    done < <(find "${SKILLS_ROOT}" -type d -name '*-workspace' -prune -o -name 'SKILL.md' -print 2> /dev/null)
}

# @description Verify that an owned skill starts with the `cgd-` prefix.
# @arg $1 name The skill directory name.
function check_domain_prefix() {
    local name="$1"

    case "${name}" in
    "${OWNED_PREFIX}"*) return 0 ;;
    *) fail "skills/${name} is not named ${OWNED_PREFIX}<topic>" ;;
    esac
}

# @description Verify frontmatter and eval-file naming for one skill.
# @arg $1 skill_dir The absolute skill directory.
function check_skill() {
    local skill_dir="$1"
    local relative="${skill_dir#"${REPO_ROOT}/"}"
    local name
    name="$(basename -- "${skill_dir}")"
    local skill_file="${skill_dir}/SKILL.md"

    check_domain_prefix "${name}"

    if [ ! -f "${skill_file}" ]; then
        fail "${relative} has no SKILL.md"
        return 0
    fi

    local declared
    declared="$(frontmatter_field "${skill_file}" name)"
    if [ -z "${declared}" ]; then
        fail "${relative}/SKILL.md has no frontmatter name"
    elif [ "${declared}" != "${name}" ]; then
        fail "${relative}/SKILL.md declares name ${declared}, which does not match its directory"
    fi

    if [ -z "$(frontmatter_field "${skill_file}" description)" ]; then
        fail "${relative}/SKILL.md has no frontmatter description"
    fi

    local opening note receipt
    opening="$(skill_opening_lines "${skill_file}")"
    note="${opening%%$'\n'*}"
    receipt="${opening#*$'\n'}"
    if [ "${note}" != '> [!NOTE]' ] || [ "${receipt}" = "${opening}" ]; then
        fail "${relative}/SKILL.md has no read-receipt NOTE immediately after frontmatter"
    elif ! is_valid_read_receipt "${receipt}" "${name}"; then
        fail "${relative}/SKILL.md has an invalid read receipt for ${name}"
    fi

    local eval_file
    for eval_file in evals.json triggers.json; do
        local path="${skill_dir}/evals/${eval_file}"
        [ -f "${path}" ] || continue

        local declared_eval_name
        declared_eval_name="$(eval_skill_name "${path}")"
        if [ "${declared_eval_name}" != "${name}" ]; then
            fail "${relative}/evals/${eval_file} declares skill_name ${declared_eval_name:-<missing>}, which does not match its directory"
        fi
    done
}

# @description Reject tracked Shuhari workspace directories.
# @description
#   Workspaces hold verbatim agent transcripts. `.gitignore` covers them, but a
#   forced add would slip past it.
function assert_no_tracked_workspaces() {
    local tracked
    tracked="$(git -C "${REPO_ROOT}" ls-files -- 'skills/*-workspace/*' 2> /dev/null || true)"
    if [ -n "${tracked}" ]; then
        fail 'Shuhari workspace artifacts are tracked by git; they contain agent transcripts'
    fi
}

# @description Read skill paths linked from the README `## Skills` section.
# @stdout One collection/skill path per link.
function readme_skill_paths() {
    awk '
        $0 == "## Skills" { in_skills = 1; next }
        in_skills && /^## / { exit }
        in_skills { print }
    ' "${README_FILE}" | sed -n 's#.*](skills/\([^)]*\)/).*#\1#p'
}

# @description Verify that the README skill index matches the skill directories.
function assert_readme_skill_index() {
    if [ ! -f "${README_FILE}" ]; then
        fail 'README.md is missing'
        return 0
    fi

    local skill_dir path name count
    for skill_dir in "${SKILLS_ROOT}"/*/*/; do
        skill_dir="${skill_dir%/}"
        case "${skill_dir#"${SKILLS_ROOT}/"}" in
        *-workspace/* | *-workspace) continue ;;
        esac

        path="${skill_dir#"${SKILLS_ROOT}/"}"
        count="$(readme_skill_paths | awk -v expected="${path}" '$0 == expected { count++ } END { print count + 0 }')"
        if [ "${count}" -eq 0 ]; then
            fail "skills/${path} is missing from README.md"
        fi
    done

    while IFS= read -r path; do
        [ -n "${path}" ] || continue
        if [ ! -f "${SKILLS_ROOT}/${path}/SKILL.md" ]; then
            fail "README.md lists missing skill ${path}"
        fi
    done < <(readme_skill_paths | sort -u)

    while IFS= read -r name; do
        fail "README.md lists skill ${name} more than once"
    done < <(readme_skill_paths | awk -F/ '{print $NF}' | sort | uniq -d)
}

# @description Run every layout check and report the collected failures.
function main() {
    assert_no_root_skill_file
    assert_skill_depth
    assert_no_tracked_workspaces
    assert_readme_skill_index

    local skill_dir
    for skill_dir in "${SKILLS_ROOT}"/*/*/; do
        skill_dir="${skill_dir%/}"
        # Shuhari writes `<skill>-workspace/` beside the skill it evaluated.
        # Those are gitignored run artifacts, not skills, and they are present
        # whenever someone has run a gate locally.
        case "${skill_dir#"${SKILLS_ROOT}/"}" in
        *-workspace/* | *-workspace) continue ;;
        esac
        check_skill "${skill_dir}"
    done

    if [ "${#failures[@]}" -gt 0 ]; then
        printf 'skill layout check failed:\n' >&2
        printf '  %s\n' "${failures[@]}" >&2
        exit 1
    fi

    printf 'check_skill_layout: ok\n'
}

main "$@"

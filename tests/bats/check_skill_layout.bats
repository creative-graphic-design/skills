#!/usr/bin/env bats

# The layout check resolves `skills/` from its own location, so setup copies it
# into a disposable repository holding synthetic skills. That keeps these tests
# independent of the real tree, which starts without a published skill.

setup() {
    FIXTURE_ROOT="${BATS_TEST_TMPDIR}/repo"
    mkdir -p "${FIXTURE_ROOT}/scripts"
    cp "${BATS_TEST_DIRNAME}/../../scripts/check_skill_layout.sh" \
        "${FIXTURE_ROOT}/scripts/check_skill_layout.sh"
    CHECKER="${FIXTURE_ROOT}/scripts/check_skill_layout.sh"
    mkdir -p "${FIXTURE_ROOT}/skills"
    printf '# Skills\n\n## Skills\n\n' > "${FIXTURE_ROOT}/README.md"
}

# @description Create a minimal well-formed skill directory.
# @arg $1 name The skill directory name, also written as the frontmatter name.
function make_skill() {
    local name="$1"
    local collection="${2:-design}"
    local skill_dir="${FIXTURE_ROOT}/skills/${collection}/${name}"

    mkdir -p "${skill_dir}"
    printf -- '---\nname: %s\ndescription: d\n---\n\n> [!NOTE]\n> After reading this `SKILL.md`, say: `🧪 I read %s.`\n' "${name}" "${name}" > "${skill_dir}/SKILL.md"
    printf -- '- [`%s`](skills/%s/%s/)\n' "${name}" "${collection}" "${name}" >> "${FIXTURE_ROOT}/README.md"
}

@test "[common] a skill missing from the README index is rejected" {
    make_skill cgd-herdr-a
    sed -i.bak '/skills\/design\/cgd-herdr-a\//d' "${FIXTURE_ROOT}/README.md"
    rm "${FIXTURE_ROOT}/README.md.bak"

    run "${CHECKER}"
    [ "${status}" -eq 1 ]
    [[ "${output}" == *'skills/design/cgd-herdr-a is missing from README.md'* ]]
}

@test "[common] a stale skill in the README index is rejected" {
    make_skill cgd-herdr-a
    printf -- '- [`cgd-herdr-old`](skills/design/cgd-herdr-old/)\n' >> "${FIXTURE_ROOT}/README.md"

    run "${CHECKER}"
    [ "${status}" -eq 1 ]
    [[ "${output}" == *'README.md lists missing skill design/cgd-herdr-old'* ]]
}

@test "[common] a duplicate skill in the README index is rejected" {
    make_skill cgd-herdr-a
    printf -- '- [`cgd-herdr-a`](skills/design/cgd-herdr-a/)\n' >> "${FIXTURE_ROOT}/README.md"

    run "${CHECKER}"
    [ "${status}" -eq 1 ]
    [[ "${output}" == *'README.md lists skill cgd-herdr-a more than once'* ]]
}

@test "[common] a missing read receipt is rejected" {
    make_skill cgd-herdr-a
    printf -- '---\nname: cgd-herdr-a\ndescription: d\n---\n\n# Heading\n' > "${FIXTURE_ROOT}/skills/design/cgd-herdr-a/SKILL.md"

    run "${CHECKER}"
    [ "${status}" -eq 1 ]
    [[ "${output}" == *'has no read-receipt NOTE immediately after frontmatter'* ]]
}

@test "[common] a read receipt naming another skill is rejected" {
    make_skill cgd-herdr-a
    sed -i.bak 's/I read cgd-herdr-a\./I read cgd-herdr-b./' "${FIXTURE_ROOT}/skills/design/cgd-herdr-a/SKILL.md"
    rm "${FIXTURE_ROOT}/skills/design/cgd-herdr-a/SKILL.md.bak"

    run "${CHECKER}"
    [ "${status}" -eq 1 ]
    [[ "${output}" == *'has an invalid read receipt for cgd-herdr-a'* ]]
}

@test "[common] a Japanese read receipt is accepted" {
    make_skill cgd-research-a
    sed -i.bak 's/> After reading this `SKILL.md`, say: `🧪 I read cgd-research-a.`/> この `SKILL.md` を読んだら、`🧪 私は cgd-research-a を読みました。` と言う。/' "${FIXTURE_ROOT}/skills/design/cgd-research-a/SKILL.md"
    rm "${FIXTURE_ROOT}/skills/design/cgd-research-a/SKILL.md.bak"

    run "${CHECKER}"
    [ "${status}" -eq 0 ]
}

@test "[common] a cgd-prefixed skill passes" {
    make_skill cgd-design-principles

    run "${CHECKER}"
    [ "${status}" -eq 0 ]
}

@test "[common] a skill without the cgd prefix is rejected" {
    make_skill vendor-orchestrate-things

    run "${CHECKER}"
    [ "${status}" -eq 1 ]
    [[ "${output}" == *'is not named cgd-<topic>'* ]]
}

@test "[common] collection and deeply nested SKILL.md files are rejected" {
    make_skill cgd-design-a
    cp "${FIXTURE_ROOT}/skills/design/cgd-design-a/SKILL.md" "${FIXTURE_ROOT}/skills/design/SKILL.md"
    mkdir -p "${FIXTURE_ROOT}/skills/design/cgd-design-a/nested"
    cp "${FIXTURE_ROOT}/skills/design/cgd-design-a/SKILL.md" "${FIXTURE_ROOT}/skills/design/cgd-design-a/nested/SKILL.md"

    run "${CHECKER}"
    [ "${status}" -eq 1 ]
    [[ "${output}" == *'skills/design/SKILL.md'* ]]
    [[ "${output}" == *'skills/design/cgd-design-a/nested/SKILL.md'* ]]
}

@test "[common] workspaces at either depth are ignored" {
    make_skill cgd-design-a
    mkdir -p "${FIXTURE_ROOT}/skills/old-workspace/copied-skill"
    mkdir -p "${FIXTURE_ROOT}/skills/design/cgd-design-a-workspace/copied-skill"
    touch "${FIXTURE_ROOT}/skills/old-workspace/copied-skill/SKILL.md"
    touch "${FIXTURE_ROOT}/skills/design/cgd-design-a-workspace/copied-skill/SKILL.md"

    run "${CHECKER}"
    [ "${status}" -eq 0 ]
}

@test "[common] duplicate skill names across collections are rejected" {
    make_skill cgd-design-a first
    make_skill cgd-design-a second

    run "${CHECKER}"
    [ "${status}" -eq 1 ]
    [[ "${output}" == *'skill cgd-design-a more than once'* ]]
}

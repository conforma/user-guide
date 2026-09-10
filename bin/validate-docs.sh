#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MODULES_DIR="${REPO_ROOT}/modules"
PAGES_DIR="${MODULES_DIR}/ROOT/pages"
PARTIALS_DIR="${MODULES_DIR}/ROOT/partials"
NAV_FILE="${MODULES_DIR}/ROOT/nav.adoc"

ERROR_LOG=$(mktemp)
WORK_DIR=$(mktemp -d)
trap 'rm -f "${ERROR_LOG}"; rm -rf "${WORK_DIR}"' EXIT

error() {
    echo "ERROR: $1" >&2
    echo "x" >> "${ERROR_LOG}"
}

warn() {
    echo "WARN: $1" >&2
}

# --- AsciiDoc syntax validation ---
validate_syntax() {
    echo "==> Validating AsciiDoc syntax..."

    if ! command -v asciidoctor &>/dev/null; then
        warn "asciidoctor not found, skipping syntax validation."
        warn "Install with: gem install asciidoctor"
        return
    fi

    # Antora's partial$ prefix isn't understood by standalone asciidoctor.
    # Resolve it to a relative path via a temp copy with a symlinked partials dir.
    cp -a "${PAGES_DIR}" "${WORK_DIR}/pages"
    ln -s "${PARTIALS_DIR}" "${WORK_DIR}/partials"
    find "${WORK_DIR}/pages" -name '*.adoc' -exec \
        sed -i 's|include::partial\$|include::../partials/|g' {} +

    local syntax_errors=0
    while IFS= read -r -d '' file; do
        local basename="${file##*/}"
        local output
        output=$(asciidoctor \
            --failure-level=WARN \
            --backend=html5 \
            --safe-mode=unsafe \
            --out-file=/dev/null \
            "$file" 2>&1) || true

        if [[ -n "$output" ]]; then
            echo "$output" | while IFS= read -r line; do
                echo "  $line"
            done
            syntax_errors=$((syntax_errors + 1))
        fi
    done < <(find "${WORK_DIR}/pages" -name '*.adoc' -print0)

    if [[ ${syntax_errors} -gt 0 ]]; then
        error "${syntax_errors} file(s) produced asciidoctor warnings or errors"
    fi
}

# --- xref validation ---
validate_xrefs() {
    echo "==> Validating xref targets..."

    while IFS= read -r -d '' file; do
        local relpath="${file#"${REPO_ROOT}/"}"
        local matches
        matches=$(grep -noP 'xref:([^\[]+)\[' "$file" 2>/dev/null) || continue

        while IFS=: read -r lineno match; do
            local target="${match#xref:}"
            target="${target%\[}"
            target="${target%%#*}"

            # Skip cross-component xrefs (contain component:module: prefix)
            if [[ "$target" == *:* ]]; then
                continue
            fi

            if [[ ! -f "${PAGES_DIR}/${target}" ]]; then
                error "${relpath}:${lineno}: broken xref to '${target}' (file not found in pages/)"
            fi
        done <<< "$matches"
    done < <(find "${MODULES_DIR}" -name '*.adoc' -print0)
}

# --- include validation ---
validate_includes() {
    echo "==> Validating include targets..."

    while IFS= read -r -d '' file; do
        local relpath="${file#"${REPO_ROOT}/"}"
        local matches
        matches=$(grep -noP 'include::[^\[]+\[' "$file" 2>/dev/null) || continue

        while IFS=: read -r lineno match; do
            local target="${match#include::}"
            target="${target%\[}"

            if [[ "$target" == partial\$* ]]; then
                local partial_name="${target#partial\$}"
                if [[ ! -f "${PARTIALS_DIR}/${partial_name}" ]]; then
                    error "${relpath}:${lineno}: broken include, partial '${partial_name}' not found in partials/"
                fi
            fi
        done <<< "$matches"
    done < <(find "${MODULES_DIR}" -name '*.adoc' -print0)
}

# --- nav validation ---
validate_nav() {
    echo "==> Validating navigation references..."

    if [[ ! -f "${NAV_FILE}" ]]; then
        error "Navigation file not found: ${NAV_FILE}"
        return
    fi

    for navfile in "${NAV_FILE}" "${PARTIALS_DIR}/contents.adoc"; do
        [[ -f "$navfile" ]] || continue
        local relpath="${navfile#"${REPO_ROOT}/"}"
        local matches
        matches=$(grep -noP 'xref:([^\[]+)\[' "$navfile" 2>/dev/null) || continue

        while IFS=: read -r lineno match; do
            local target="${match#xref:}"
            target="${target%\[}"
            target="${target%%#*}"

            if [[ "$target" == *:* ]]; then
                continue
            fi

            if [[ ! -f "${PAGES_DIR}/${target}" ]]; then
                error "${relpath}:${lineno}: nav references non-existent page '${target}'"
            fi
        done <<< "$matches"
    done
}

echo "Validating documentation in ${REPO_ROOT}..."
echo

validate_syntax
validate_xrefs
validate_includes
validate_nav

echo
error_count=$(wc -l < "${ERROR_LOG}" | tr -d ' ')
if [[ ${error_count} -gt 0 ]]; then
    echo "FAILED: ${error_count} error(s) found."
    exit 1
else
    echo "PASSED: All validation checks passed."
    exit 0
fi

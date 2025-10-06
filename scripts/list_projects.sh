#!/usr/bin/env bash
set -euo pipefail

# list_projects.sh - List projects detected in index.html (cards managed by add_project.sh)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
INDEX_FILE="$ROOT_DIR/index.html"
PROJECTS_DIR="$ROOT_DIR/projects"
MODE="table"

usage() {
  cat <<EOF
Usage: $0 [--json]

Lists projects found between PROJECTS-START and PROJECTS-END in index.html.

Columns:
  Slug   - project page name (use with delete script)
  Name   - display title
  Cat    - category class (e.g. filter-app)
  Image  - card image path
  Exists - project HTML page present (Y/N)

Options:
  --json   Output JSON
  --help   Show help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --json) MODE="json"; shift;;
    --help|-h) usage; exit 0;;
    *) echo "Unknown arg: $1" >&2; usage; exit 1;;
  esac
done

[[ -f "$INDEX_FILE" ]] || { echo "Error: index.html not found" >&2; exit 1; }
[[ -d "$PROJECTS_DIR" ]] || echo "Warning: projects dir not found ($PROJECTS_DIR)" >&2

RAW_ENTRIES="$(
  awk '
    /PROJECTS-START/ { inside=1; next }
    /PROJECTS-END/   { inside=0 }
    !inside { next }

    /<div class="col-lg-4 col-md-6 portfolio-item / {
      # start of (or line within) a card; capture category on this line
      if (match($0, /portfolio-item[[:space:]]+([^" >]+)/)) {
        cat_start = RSTART + RLENGTH - length(substr($0, RSTART, RLENGTH)) + 16
        cat_match = substr($0, RSTART)
        sub(/^portfolio-item[[:space:]]+/, "", cat_match)
        sub(/[" >].*/, "", cat_match)
        category = cat_match
      }
    }

    /<center><h4>/ {
      if (match($0, /<center><h4>[^<]+<\/h4><\/center>/)) {
        title_match = substr($0, RSTART, RLENGTH)
        sub(/^<center><h4>/, "", title_match)
        sub(/<\/h4><\/center>$/, "", title_match)
        title = title_match
      }
    }

    /<img / {
      if (image=="" && match($0, /<img[^>]*src="[^"]+">/)) {
        img_match = substr($0, RSTART, RLENGTH)
        sub(/.*src="/, "", img_match)
        sub(/".*/, "", img_match)
        image = img_match
      }
    }

    /href="projects\/[^"]+\.html"/ {
      if (match($0, /href="projects\/[^"]+\.html"/)) {
        href_match = substr($0, RSTART, RLENGTH)
        sub(/.*href="projects\//, "", href_match)
        sub(/\.html".*/, "", href_match)
        slug = href_match
        if (title=="") title=slug
        if (image=="") image="(none)"
        if (category=="") category="?"
        printf "%s\x1f%s\x1f%s\x1f%s\n", slug, title, category, image
        # reset per-card fields (category may appear again on next card line)
        title=""; image=""
      }
    }
  ' "$INDEX_FILE"
)"

if [[ "$MODE" == "json" ]]; then
  echo "["
  first=1
  while IFS=$'\x1f' read -r slug name category image; do
    [[ -z "$slug" ]] && continue
    exists=false
    [[ -f "$PROJECTS_DIR/$slug.html" ]] && exists=true
    esc_name=${name//\\/\\\\}; esc_name=${esc_name//\"/\\\"}
    esc_img=${image//\\/\\\\}; esc_img=${esc_img//\"/\\\"}
    esc_cat=${category//\\/\\\\}; esc_cat=${esc_cat//\"/\\\"}
    [[ $first -eq 0 ]] && echo ","
    printf '  {"slug":"%s","name":"%s","category":"%s","image":"%s","exists":%s}' \
      "$slug" "$esc_name" "$esc_cat" "$esc_img" "$exists"
    first=0
  done <<< "$RAW_ENTRIES"
  echo
  echo "]"
  exit 0
fi

printf "%-20s %-28s %-14s %-30s %s\n" "Slug" "Name" "Cat" "Image" "Exists"
printf "%-20s %-28s %-14s %-30s %s\n" "--------------------" "----------------------------" "--------------" "------------------------------" "------"

while IFS=$'\x1f' read -r slug name category image; do
  [[ -z "$slug" ]] && continue
  exists="N"
  [[ -f "$PROJECTS_DIR/$slug.html" ]] && exists="Y"
  printf "%-20s %-28s %-14s %-30s %s\n" "$slug" "${name:0:28}" "$category" "${image:0:30}" "$exists"
done <<< "$RAW_ENTRIES"
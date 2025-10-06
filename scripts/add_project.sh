#!/usr/bin/env bash
set -euo pipefail

# add_project.sh - Add a project card (and optionally a detail page) to index.html
# Supports external link cards via --url (skips page generation).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
INDEX_FILE="$ROOT_DIR/index.html"
PROJECTS_DIR="$ROOT_DIR/projects"
DEFAULT_IMAGE="assets/img/placeholder.png"

NAME=""
SLUG=""
IMAGE=""
CATEGORY="filter-app"
DESCRIPTION=""
ALT=""
EXTERNAL_URL=""
SKIP_PAGE=0
DO_GIT=1
DRY_RUN=0

usage() {
  cat <<EOF
Usage: $0 --name "Project Title" --slug my-slug [options]

Required:
  --name STRING
  --slug STRING                (^[A-Za-z0-9_-]+$)

Optional:
  --image PATH_OR_URL          (default: $DEFAULT_IMAGE)
  --category filter-app|filter-project
  --description "Short text"
  --alt "Alt text"             (default: derived from name)
  --url https://...            (external link; skips page creation)
  --no-git                     Skip git add/commit/push
  --dry-run                    Show actions only
  --help                       Show help

Examples:
  bash scripts/add_project.sh --name "Neon Ray" --slug neon-ray
  bash scripts/add_project.sh --name "Slice Orch" --slug slice-orch --url https://github.com/unseen2004/slice_orch --image assets/img/slice_orch.png --category filter-project
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name) NAME="$2"; shift 2;;
    --slug) SLUG="$2"; shift 2;;
    --image) IMAGE="$2"; shift 2;;
    --category) CATEGORY="$2"; shift 2;;
    --description) DESCRIPTION="$2"; shift 2;;
    --alt) ALT="$2"; shift 2;;
    --url) EXTERNAL_URL="$2"; SKIP_PAGE=1; shift 2;;
    --no-git) DO_GIT=0; shift;;
    --dry-run) DRY_RUN=1; shift;;
    --help|-h) usage; exit 0;;
    *) echo "Unknown arg: $1" >&2; usage; exit 1;;
  esac
done

# Validate
[[ -f "$INDEX_FILE" ]] || { echo "Error: index.html not found" >&2; exit 1; }
if [[ -z "$NAME" || -z "$SLUG" ]]; then
  echo "Error: --name and --slug required" >&2
  exit 1
fi
if [[ ! "$SLUG" =~ ^[A-Za-z0-9_-]+$ ]]; then
  echo "Error: slug must match ^[A-Za-z0-9_-]+$" >&2
  exit 1
fi
if [[ -z "$IMAGE" ]]; then
  IMAGE="$DEFAULT_IMAGE"
fi
if [[ -z "$ALT" ]]; then
  ALT="$NAME image"
fi
if [[ -n "$EXTERNAL_URL" && ! "$EXTERNAL_URL" =~ ^https?:// ]]; then
  echo "Error: --url must start with http:// or https://" >&2
  exit 1
fi

# Escape helper
esc_html() {
  local s="$1"
  s="${s//&/&amp;}"
  s="${s//</&lt;}"
  s="${s//>/&gt;}"
  s="${s//\"/&quot;}"
  printf '%s' "$s"
}

ESC_NAME="$(esc_html "$NAME")"
ESC_DESC="$(esc_html "$DESCRIPTION")"
ESC_ALT="$(esc_html "$ALT")"

PROJECT_PAGE="$PROJECTS_DIR/$SLUG.html"

PAGE_CONTENT="<!DOCTYPE html>
<html lang=\"en\">
<head>
<meta charset=\"UTF-8\">
<title>$ESC_NAME</title>
<meta name=\"viewport\" content=\"width=device-width,initial-scale=1\">
<link rel=\"stylesheet\" href=\"../assets/css/style.css\">
</head>
<body>
<main style=\"padding:32px;max-width:860px;margin:0 auto;font-family:Arial,sans-serif;\">
  <h1>$ESC_NAME</h1>
  $( [[ -n "$DESCRIPTION" ]] && printf '<p>%s</p>' "$ESC_DESC" )
  <p><a href=\"../index.html\">&larr; Back</a></p>
</main>
</body>
</html>
"

# Build card snippet (kept compact)
build_card_external() {
  cat <<EOF

<div class="col-lg-4 col-md-6 portfolio-item $CATEGORY">
  <center><h4>$ESC_NAME</h4></center>
  <div class="portfolio-wrap">
    <img src="$IMAGE" class="img-fluid" alt="$ESC_ALT">
    <div class="portfolio-info">
$( [[ -n "$DESCRIPTION" ]] && printf '      <p style="font-size:12px;line-height:1.3;margin:4px 8px 8px;">%s</p>\n' "$ESC_DESC" )
      <div class="portfolio-links">
        <a href="$EXTERNAL_URL" target="_blank" rel="noopener" class="external-link" title="Open external link">
          <i class="bx bx-link-external"></i>
        </a>
      </div>
    </div>
  </div>
</div>
EOF
}

build_card_internal() {
  cat <<EOF

<div class="col-lg-4 col-md-6 portfolio-item $CATEGORY">
  <center><h4>$ESC_NAME</h4></center>
  <div class="portfolio-wrap">
    <img src="$IMAGE" class="img-fluid" alt="$ESC_ALT">
    <div class="portfolio-info">
$( [[ -n "$DESCRIPTION" ]] && printf '      <p style="font-size:12px;line-height:1.3;margin:4px 8px 8px;">%s</p>\n' "$ESC_DESC" )
      <div class="portfolio-links">
        <a href="projects/$SLUG.html" data-gall="portfolioDetailsGallery" data-vbtype="iframe"
           class="venobox" title="Project Details">
          <i class="bx bx-info-circle"></i>
        </a>
      </div>
    </div>
  </div>
</div>
EOF
}

if grep -q "projects/$SLUG.html" "$INDEX_FILE"; then
  echo "Error: A card referencing projects/$SLUG.html already exists" >&2
  exit 1
fi

CARD_SNIPPET=""
if [[ $SKIP_PAGE -eq 1 ]]; then
  CARD_SNIPPET="$(build_card_external)"
else
  CARD_SNIPPET="$(build_card_internal)"
fi

if [[ $DRY_RUN -eq 1 ]]; then
  if [[ $SKIP_PAGE -eq 0 ]]; then
    echo "[DRY-RUN] Would create: $PROJECT_PAGE"
  else
    echo "[DRY-RUN] External link mode: no page creation."
  fi
  echo "[DRY-RUN] Would inject card snippet:"
  echo "----------"
  printf "%s" "$CARD_SNIPPET"
  echo "----------"
else
  if [[ $SKIP_PAGE -eq 0 ]]; then
    mkdir -p "$PROJECTS_DIR"
    printf "%s" "$PAGE_CONTENT" > "$PROJECT_PAGE"
    echo "Created page: $PROJECT_PAGE"
  else
    echo "External link: skipping page creation."
  fi

  # Inject card before PROJECTS-END marker
  TMP="${INDEX_FILE}.tmp"
  awk -v snip="$CARD_SNIPPET" '
    /PROJECTS-END/ && !done { printf "%s", snip; done=1 }
    { print }
    END { if(!done) { printf "%s", snip } }
  ' "$INDEX_FILE" > "$TMP" && mv "$TMP" "$INDEX_FILE"
  echo "Updated index.html"
fi

if [[ $DO_GIT -eq 1 ]]; then
  if git -C "$ROOT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    if [[ $DRY_RUN -eq 1 ]]; then
      echo "[DRY-RUN] Would git add/commit/push"
    else
      pushd "$ROOT_DIR" >/dev/null
      git add "$INDEX_FILE"
      if [[ $SKIP_PAGE -eq 0 ]]; then
        git add "projects/$SLUG.html"
      fi
      if git diff --cached --quiet; then
        echo "No git changes to commit"
      else
        git commit -m "Add project: $SLUG"
        BRANCH=$(git rev-parse --abbrev-ref HEAD)
        git push origin "$BRANCH" || echo "Warning: git push failed"
      fi
      popd >/dev/null
    fi
  else
    echo "Not a git repo; skipping git operations" >&2
  fi
else
  echo "Git operations disabled (--no-git)"
fi

echo "Done."
#!/usr/bin/env bash
set -euo pipefail

# add_project.sh - Automate adding a new project (card + page) and optional git commit/push.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
INDEX_FILE="$ROOT_DIR/index.html"
PROJECTS_DIR="$ROOT_DIR/projects"
DEFAULT_IMAGE="assets/img/CPlusPlus1.jpg"

CATEGORY="filter-app"
DO_GIT=1
DRY_RUN=0
DESCRIPTION=""
NAME=""
SLUG=""
IMAGE=""
ALT=""

usage() {
  cat <<EOF
Usage: $0 --name "Project Title" --slug my-slug [options]

Required:
  --name STRING
  --slug STRING              (^[A-Za-z0-9_-]+$)

Optional:
  --image PATH_OR_URL        (default: $DEFAULT_IMAGE)
  --category filter-app|filter-project
  --alt "Alt text"           (default derived from name)
  --description "Short sentence"
  --no-git                   Skip git add/commit/push
  --dry-run                  Show actions only
  --help

Env:
  GIT_PUSH=0  same as --no-git
EOF
}

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --name) NAME="$2"; shift 2;;
    --slug) SLUG="$2"; shift 2;;
    --image) IMAGE="$2"; shift 2;;
    --category) CATEGORY="$2"; shift 2;;
    --alt) ALT="$2"; shift 2;;
    --description) DESCRIPTION="$2"; shift 2;;
    --no-git) DO_GIT=0; shift;;
    --dry-run) DRY_RUN=1; shift;;
    --help|-h) usage; exit 0;;
    *) echo "Unknown arg: $1" >&2; usage; exit 1;;
  esac
done

# Env override
if [[ -n "${GIT_PUSH:-}" && "${GIT_PUSH}" == "0" ]]; then
  DO_GIT=0
fi

# Validate
if [[ -z "$NAME" || -z "$SLUG" ]]; then
  echo "Error: --name and --slug are required" >&2; exit 1
fi
if [[ ! "$SLUG" =~ ^[A-Za-z0-9_-]+$ ]]; then
  echo "Error: slug must match ^[A-Za-z0-9_-]+$" >&2; exit 1
fi
[[ -f "$INDEX_FILE" ]] || { echo "Error: index.html not found at $INDEX_FILE" >&2; exit 1; }
grep -q 'PROJECTS-START' "$INDEX_FILE" || { echo "Error: PROJECTS-START marker missing" >&2; exit 1; }
grep -q 'PROJECTS-END' "$INDEX_FILE" || { echo "Error: PROJECTS-END marker missing" >&2; exit 1; }
if grep -q "projects/$SLUG.html" "$INDEX_FILE"; then
  echo "Error: Project with slug '$SLUG' already exists" >&2; exit 1
fi

# Defaults
[[ -n "$IMAGE" ]] || IMAGE="$DEFAULT_IMAGE"
[[ -n "$ALT" ]] || ALT="$NAME screenshot"

PROJECT_PAGE="$PROJECTS_DIR/$SLUG.html"

# Escape description for HTML (very light)
ESC_DESC="${DESCRIPTION//&/&amp;}"
ESC_DESC="${ESC_DESC//</&lt;}"
ESC_DESC="${ESC_DESC//>/&gt;}"
ESC_DESC="${ESC_DESC//\"/&quot;}"

# Build card snippet cleanly
build_card() {
  printf '\n<div class="col-lg-4 col-md-6 portfolio-item %s">\n' "%s"
  printf '  <center><h4>%s</h4></center>\n' "%s"
  printf '  <div class="portfolio-wrap">\n'
  printf '    <img src="%s" class="img-fluid" alt="%s">\n' "%s" "%s"
  printf '    <div class="portfolio-info">\n'
  if [[ -n "%s" ]]; then
    printf '      <p style="font-size:12px;line-height:1.3;margin:4px 8px 8px;">%s</p>\n' "%s"
  fi
  printf '      <div class="portfolio-links">\n'
  printf '        <a href="projects/%s.html" data-gall="portfolioDetailsGallery" data-vbtype="iframe" class="venobox" title="Project Details"><i class="bx bx-info-circle"></i></a>\n' "%s"
  printf '      </div>\n'
  printf '    </div>\n'
  printf '  </div>\n'
  printf '</div>\n'
}

CARD_SNIPPET="$(build_card \
  "$CATEGORY" \
  "$NAME" \
  "$IMAGE" "$ALT" \
  "$ESC_DESC" "$ESC_DESC" \
  "$SLUG")"

# Page content
read -r -d '' PAGE_CONTENT <<EOF || true
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>$NAME</title>
<link href="../assets/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">
<link href="../assets/vendor/boxicons/css/boxicons.min.css" rel="stylesheet">
<link href="../assets/css/style.css" rel="stylesheet">
<style>
 body{background:#010e1b;padding:18px;color:#eee;font-family:'Open Sans',sans-serif;}
 .project-header{margin-bottom:18px;}
 .project-header h1{font-size:26px;margin:0 0 6px;}
 .meta{font-size:12px;letter-spacing:1px;opacity:.65;text-transform:uppercase;}
 .content{font-size:14px;line-height:1.55;}
 .preview-img{max-width:100%;border:1px solid rgba(255,255,255,.08);border-radius:8px;margin:12px 0 18px;}
 a.back{display:inline-block;margin-top:10px;font-size:12px;}
</style>
</head>
<body>
  <div class="project-header">
    <h1>$NAME</h1>
    <div class="meta">Updated: $(date +%Y-%m-%d)</div>
  </div>
  <img src="../$IMAGE" alt="$ALT" class="preview-img">
  <div class="content">
    <p>${ESC_DESC:-This project page was auto-generated. Edit <code>projects/$SLUG.html</code> to add more details.}</p>
  </div>
  <a class="back" href="../index.html#portfolio">← Back to portfolio</a>
</body>
</html>
EOF

if [[ $DRY_RUN -eq 1 ]]; then
  echo "[DRY-RUN] Would create: $PROJECT_PAGE"
  echo "[DRY-RUN] Would inject card:"
  echo "----------"
  printf "%s" "$CARD_SNIPPET"
  echo "----------"
else
  mkdir -p "$PROJECTS_DIR"
  printf "%s" "$PAGE_CONTENT" >"$PROJECT_PAGE"
  echo "Created: $PROJECT_PAGE"
  # Inject before PROJECTS-END
  TMP="${INDEX_FILE}.tmp"
  awk -v snip="$CARD_SNIPPET" '
    BEGIN{done=0}
    /PROJECTS-END/ && !done { printf "%s", snip; done=1 }
    { print }
  ' "$INDEX_FILE" > "$TMP" && mv "$TMP" "$INDEX_FILE"
  echo "Updated index.html"
fi

if [[ $DO_GIT -eq 1 ]]; then
  if git -C "$ROOT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    if [[ $DRY_RUN -eq 1 ]]; then
      echo "[DRY-RUN] Would git add/commit/push"
    else
      pushd "$ROOT_DIR" >/dev/null
      git add "projects/$SLUG.html" "$INDEX_FILE"
      if git diff --cached --quiet; then
        echo "No changes staged; skipping commit"
      else
        git commit -m "Add project: $NAME" || true
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
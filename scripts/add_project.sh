#!/usr/bin/env bash
set -euo pipefail

# add_project.sh
# Automates adding a new project card + project page and optionally committing & pushing.
# Requires: bash, awk, git (optional), standard UNIX tools.

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

usage(){
  cat <<EOF
Usage: $0 --name "Project Title" --slug myProject [options]

Required:
  --name        Display name (Title on card)
  --slug        File/page slug (alphanumeric + dashes/underscores). Creates projects/<slug>.html

Optional:
  --image PATH_OR_URL   Card image (default: $DEFAULT_IMAGE)
  --category filter-app|filter-project  Portfolio filter class (default: filter-app)
  --alt "Alt text"      Accessible alt for image (default: derived from name)
  --description "Short sentence"  Shown inside the project page & card overlay (optional)
  --no-git             Skip git add/commit/push
  --dry-run            Show actions without modifying files
  --help               This help

Environment overrides:
  GIT_PUSH=0           Same as --no-git

Examples:
  $0 --name "Neon Raytracer" --slug neon-ray --image assets/img/ray.png --category filter-project \
     --description "GPU path tracing playground written in Rust"

  $0 --name "Tiny Tool" --slug tiny-tool --dry-run
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

if [[ -n "${GIT_PUSH:-}" && "${GIT_PUSH}" == "0" ]]; then
  DO_GIT=0
fi

# Validate
if [[ -z "$NAME" || -z "$SLUG" ]]; then
  echo "Error: --name and --slug are required" >&2
  usage
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
  ALT="$NAME screenshot"
fi
if [[ ! -f "$INDEX_FILE" ]]; then
  echo "Error: index.html not found at $INDEX_FILE" >&2
  exit 1
fi
if grep -q "projects/$SLUG.html" "$INDEX_FILE"; then
  echo "Error: A project with slug '$SLUG' already exists in index.html" >&2
  exit 1
fi
if ! grep -q 'PROJECTS-START' "$INDEX_FILE" || ! grep -q 'PROJECTS-END' "$INDEX_FILE"; then
  echo "Error: PROJECTS-START / PROJECTS-END markers missing in index.html" >&2
  exit 1
fi

PROJECT_PAGE="$PROJECTS_DIR/$SLUG.html"

CARD_SNIPPET='\n<div class="col-lg-4 col-md-6 portfolio-item __CATEGORY__">\n  <center><h4>__TITLE__</h4></center>\n  <div class="portfolio-wrap">\n    <img src="__IMAGE__" class="img-fluid" alt="__ALT__">\n    <div class="portfolio-info">'
if [[ -n "$DESCRIPTION" ]]; then
  CARD_SNIPPET+="\n      <p style=\"font-size:12px;line-height:1.3;margin:4px 8px 8px;\">${DESCRIPTION//"/\"}</p>"
fi
CARD_SNIPPET+='\n      <div class="portfolio-links">\n        <a href="projects/__SLUG__.html" data-gall="portfolioDetailsGallery" data-vbtype="iframe" class="venobox" title="Project Details"><i class="bx bx-info-circle"></i></a>\n      </div>\n    </div>\n  </div>\n</div>\n'

CARD_SNIPPET=${CARD_SNIPPET/__CATEGORY__/$CATEGORY}
CARD_SNIPPET=${CARD_SNIPPET/__TITLE__/$NAME}
CARD_SNIPPET=${CARD_SNIPPET/__IMAGE__/$IMAGE}
CARD_SNIPPET=${CARD_SNIPPET/__ALT__/$ALT}
CARD_SNIPPET=${CARD_SNIPPET/__SLUG__/$SLUG}

# Create project page template
read -r -d '' PAGE_CONTENT <<EOF || true
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>$NAME</title>
  <link href="../assets/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">
  <link href="../assets/vendor/boxicons/css/boxicons.min.css" rel="stylesheet">
  <link href="../assets/css/style.css" rel="stylesheet">
  <style>
    body { background:#010e1b; padding:18px; color:#eee; font-family: 'Open Sans', sans-serif; }
    .project-header { margin-bottom: 18px; }
    .project-header h1 { font-size: 26px; margin:0 0 6px; }
    .meta { font-size: 12px; letter-spacing:1px; opacity:.65; text-transform:uppercase; }
    .content { font-size: 14px; line-height:1.55; }
    .preview-img { max-width: 100%; border:1px solid rgba(255,255,255,0.08); border-radius:8px; margin:12px 0 18px; }
    a.back { display:inline-block; margin-top:10px; font-size:12px; }
  </style>
</head>
<body>
  <div class="project-header">
    <h1>$NAME</h1>
    <div class="meta">Updated: $(date +%Y-%m-%d)</div>
  </div>
  <img src="../$IMAGE" alt="$ALT" class="preview-img" />
  <div class="content">
    <p>${DESCRIPTION:-This project page was auto-generated. Customize <code>projects/$SLUG.html</code> with more details (tech stack, features, screenshots, links).}</p>
  </div>
  <a class="back" href="../index.html#portfolio">← Back to portfolio</a>
</body>
</html>
EOF

if [[ $DRY_RUN -eq 1 ]]; then
  echo "[DRY-RUN] Would create: $PROJECT_PAGE" >&2
  echo "[DRY-RUN] Would inject card snippet before PROJECTS-END marker:" >&2
  echo "-----------" >&2
  echo -e "$CARD_SNIPPET" >&2
  echo "-----------" >&2
else
  mkdir -p "$PROJECTS_DIR"
  echo "$PAGE_CONTENT" > "$PROJECT_PAGE"
  echo "Created project page: $PROJECT_PAGE"
  # Inject card snippet
  TMP_FILE="${INDEX_FILE}.tmp"
  awk -v snip="$CARD_SNIPPET" 'BEGIN{inserted=0} /PROJECTS-END/ && !inserted { printf "%s", snip; inserted=1 } { print }' "$INDEX_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$INDEX_FILE"
  echo "Updated index.html with new project card."
fi

if [[ $DO_GIT -eq 1 ]]; then
  if git -C "$ROOT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    if [[ $DRY_RUN -eq 1 ]]; then
      echo "[DRY-RUN] Would git add + commit + push" >&2
    else
      pushd "$ROOT_DIR" >/dev/null
      git add "projects/$SLUG.html" "$INDEX_FILE"
      git diff --cached --name-only | grep -q . || { echo "No staged changes; skipping commit"; exit 0; }
      git commit -m "Add project: $NAME" || true
      CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
      git push origin "$CURRENT_BRANCH" || echo "Warning: git push failed."
      popd >/dev/null
    fi
  else
    echo "Git repository not found at $ROOT_DIR; skipping git operations." >&2
  fi
else
  echo "Git operations disabled (--no-git)." >&2
fi

echo "Done."

#!/usr/bin/env bash
set -euo pipefail

# delete_project.sh - Remove a project (card + page) previously added by add_project.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
INDEX_FILE="$ROOT_DIR/index.html"
PROJECTS_DIR="$ROOT_DIR/projects"

SLUG=""
DO_GIT=1
DRY_RUN=0
FORCE=0

usage() {
  cat <<EOF
Usage: $0 --slug my-slug [options]

Required:
  --slug STRING              (project slug, must match ^[A-Za-z0-9_-]+$)

Optional:
  --no-git                   Skip git add/commit/push
  --dry-run                  Show actions only
  --force                    Do not prompt for confirmation
  --help                     Show this help

Examples:
  bash scripts/delete_project.sh --slug neon-ray
  bash scripts/delete_project.sh --slug neon-ray --dry-run
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --slug) SLUG="$2"; shift 2;;
    --no-git) DO_GIT=0; shift;;
    --dry-run) DRY_RUN=1; shift;;
    --force) FORCE=1; shift;;
    --help|-h) usage; exit 0;;
    *) echo "Unknown arg: $1" >&2; usage; exit 1;;
  esac
done

if [[ -z "$SLUG" ]]; then
  echo "Error: --slug required" >&2
  exit 1
fi

if [[ ! "$SLUG" =~ ^[A-Za-z0-9_-]+$ ]]; then
  echo "Error: slug must match ^[A-Za-z0-9_-]+$" >&2
  exit 1
fi

[[ -f "$INDEX_FILE" ]] || { echo "Error: index.html not found" >&2; exit 1; }

PROJECT_FILE="$PROJECTS_DIR/$SLUG.html"
if [[ ! -f "$PROJECT_FILE" ]]; then
  echo "Warning: project page $PROJECT_FILE not found (will continue to try removing card)."
fi

# Detect if card exists
if ! grep -q "projects/$SLUG.html" "$INDEX_FILE"; then
  echo "Error: No card referencing projects/$SLUG.html found in index.html"
  exit 1
fi

if [[ $FORCE -ne 1 && $DRY_RUN -ne 1 ]]; then
  read -r -p "Delete project '$SLUG' (page + card)? [y/N] " ans
  case "${ans,,}" in
    y|yes) ;;
    *) echo "Aborted."; exit 1;;
  esac
fi

TMP="${INDEX_FILE}.tmp"

remove_card() {
  # Uses depth counting to remove exactly the <div class="... portfolio-item ..."> block containing the slug
  awk -v slug="$SLUG" '
    function count_divs(s,   n){ n=gsub(/<div[ >]/,"",s); return n }
    function count_end_divs(s,   n){ n=gsub(/<\/div>/,"",s); return n }
    BEGIN{
      inblock=0; depth=0; del=0
    }
    {
      if(!inblock){
        if($0 ~ /<div class="col-lg-4 col-md-6 portfolio-item /){
          # Potential start
          inblock=1
          depth=count_divs($0)-count_end_divs($0)
          buf[0]=$0
          blen=1
          if(depth==0){
            # Single-line div unlikely; flush decision
            if($0 ~ ("projects/" slug ".html")) { next } else { print $0; inblock=0 }
          }
        } else {
          print
        }
      } else {
        buf[blen]=$0; blen++
        depth += count_divs($0)
        depth -= count_end_divs($0)
        if($0 ~ ("projects/" slug ".html")) del=1
        if(depth<=0){
          # End of block
            if(!del){
              for(i=0;i<blen;i++) print buf[i]
            }
            inblock=0; del=0; blen=0; depth=0
        }
      }
    }
    END{
      if(inblock && !del){
        for(i=0;i<blen;i++) print buf[i]
      }
    }
  ' "$INDEX_FILE"
}

if [[ $DRY_RUN -eq 1 ]]; then
  echo "[DRY-RUN] Would remove card containing projects/$SLUG.html from index.html"
  [[ -f "$PROJECT_FILE" ]] && echo "[DRY-RUN] Would delete file: $PROJECT_FILE"
else
  remove_card > "$TMP" && mv "$TMP" "$INDEX_FILE"
  echo "Updated index.html (card removed)"
  if [[ -f "$PROJECT_FILE" ]]; then
    rm -f "$PROJECT_FILE"
    echo "Deleted $PROJECT_FILE"
  fi
fi

if [[ $DO_GIT -eq 1 ]]; then
  if git -C "$ROOT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    if [[ $DRY_RUN -eq 1 ]]; then
      echo "[DRY-RUN] Would git add/commit/push"
    else
      pushd "$ROOT_DIR" >/dev/null
      git add "$INDEX_FILE"
      [[ -f "$PROJECT_FILE" ]] || git rm -f --ignore-unmatch "projects/$SLUG.html" >/dev/null 2>&1 || true
      if git diff --cached --quiet; then
        echo "No git changes to commit"
      else
        git commit -m "Remove project: $SLUG" || true
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
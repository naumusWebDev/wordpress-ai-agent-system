#!/usr/bin/env bash
# =============================================================================
# skill-content-writer.sh — WordPress Content Generation & Management Skill
#
# This script acts as a "skill" for the Copywriter agent.
# It helps identify missing content, process image alts, and prepare
# content packages for the Scripter.
#
# Usage:
#   ./skill-content-writer.sh --project-json=data/myproject/briefing.json --action=report
#   ./skill-content-writer.sh --project-json=data/myproject/briefing.json --action=sync-assets
# =============================================================================

ACTION="report"
PROJECT_JSON=""
RECURSOS_DIR="./recursos"

for arg in "$@"; do
  case "$arg" in
    --project-json=*)   PROJECT_JSON="${arg#*=}" ;;
    --action=*)         ACTION="${arg#*=}" ;;
    --recursos-dir=*)   RECURSOS_DIR="${arg#*=}" ;;
    *) ;;
  esac
done

if [[ -z "$PROJECT_JSON" ]]; then
  echo "[ERROR] --project-json is required."
  exit 1
fi

if [[ ! -f "$PROJECT_JSON" ]]; then
  echo "[ERROR] Project JSON not found: $PROJECT_JSON"
  exit 1
fi

# Utility: extract project name from JSON (assuming the path structure or a "project" key)
PROJECT_NAME=$(basename $(dirname "$PROJECT_JSON"))
PROJECT_RECURSOS="$RECURSOS_DIR/$PROJECT_NAME"

case "$ACTION" in
  "report")
    echo "--- CONTENT STATUS REPORT: $PROJECT_NAME ---"
    
    echo ""
    echo "[PAGES]"
    # Extract page slugs from JSON (simple grep/sed for demo, should use jq if available)
    # This is a placeholder for actual logic
    if command -v jq >/dev/null 2>&1; then
      PAGES=$(jq -r '.pages[].slug' "$PROJECT_JSON")
      for slug in $PAGES; do
        TXT_FILE="$PROJECT_RECURSOS/paginas/$slug/$slug.txt"
        if [[ -f "$TXT_FILE" ]]; then
          echo "  [OK]  $slug (Content file exists)"
        else
          echo "  [MISSING] $slug (NEEDS CONTENT GENERATION)"
        fi
      done
    else
      echo "  [WARNING] 'jq' not found. Cannot parse JSON accurately."
    fi
    
    echo ""
    echo "[CPTs]"
    if command -v jq >/dev/null 2>&1; then
      CPTS=$(jq -r '.cpts[].slug' "$PROJECT_JSON")
      for slug in $CPTS; do
        echo "  - Checking CPT: $slug"
        # Logic to check CPT entries if they exist in JSON
      done
    fi
    ;;

  "sync-assets")
    echo "--- SYNCING ASSETS & ALTS ---"
    # This action could generate a helper script or JSON for the Scripter
    echo "Scanning $PROJECT_RECURSOS..."
    
    find "$PROJECT_RECURSOS" -type f \( -name "*.webp" -o -name "*.png" \) | while read img; do
      filename=$(basename "$img")
      rel_path=${img#$RECURSOS_DIR/}
      echo "Image found: $rel_path"
      # Potential: suggest an alt text based on naming convention
    done
    ;;

  "prepare-drafts")
    echo "--- PREPARING CONTENT DRAFTS ---"
    if command -v jq >/dev/null 2>&1; then
      jq -r '.pages[] | .slug' "$PROJECT_JSON" | while read slug; do
        DIR="$PROJECT_RECURSOS/paginas/$slug"
        mkdir -p "$DIR"
        FILE="$DIR/$slug.txt"
        if [[ ! -f "$FILE" ]]; then
           echo "Creating placeholder for $slug..."
           echo "TITLE: $slug" > "$FILE"
           echo "CONTENT: [Copywriter, please generate content for $slug here]" >> "$FILE"
        fi
      done
    fi
    ;;

  *)
    echo "[ERROR] Unknown action: $ACTION"
    exit 1
    ;;
esac

#!/bin/bash

# Known internal/built-in display IDs
KNOWN_IDS=("37D8832A-2D66-02CA-B9F7-8F30A301B230" "AC3244C3-7411-4FEF-85D2-559A9ED73ECF")

# Get current displayplacer output
CURRENT_DISPLAYS=$(displayplacer list)

# Extract all display IDs
ALL_IDS=$(echo "$CURRENT_DISPLAYS" | grep -oE 'id:[A-F0-9-]+' | cut -d: -f2)

# Find the first display ID that isn't in the known list
EXTERNAL_ID=""
while read -r id; do
  SKIP=false
  for known_id in "${KNOWN_IDS[@]}"; do
    if [[ "$id" == "$known_id" ]]; then
      SKIP=true
      break
    fi
  done
  if ! $SKIP; then
    EXTERNAL_ID="$id"
    break
  fi
done <<< "$ALL_IDS"

if [[ -z "$EXTERNAL_ID" ]]; then
  echo "❌ Could not find external display."
  exit 1
fi

# Run your displayplacer config with dynamic external ID
# Replace the below command with your actual desired config
/opt/homebrew/bin/displayplacer \
  "id:$EXTERNAL_ID res:2560x1067 hz:60 color_depth:8 enabled:true scaling:on origin:(0,0) degree:0" \
  "id:37D8832A-2D66-02CA-B9F7-8F30A301B230 res:1352x878 hz:120 color_depth:8 enabled:true scaling:on origin:(-1352,189) degree:0" \
  "id:AC3244C3-7411-4FEF-85D2-559A9ED73ECF res:1080x1920 hz:50 color_depth:8 enabled:true scaling:off origin:(2560,-573) degree:90"


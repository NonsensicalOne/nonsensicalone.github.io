#!/bin/bash
#
# A script to generate Wordle solutions for a given month, clearing old ones first.
# Usage: ./wordler.sh [YYYY] [MM]
# Example: ./wordler.sh 2025 07
# If no arguments are given, it defaults to the current year and month.

# --- Configuration ---
YEAR=${1:-$(date +%Y)}
MONTH=${2:-$(date +%m)}
OUTPUT_FILE="content/posts/cheat-on-wordle.md"
MARKER_TEXT="If you are lazy to do the steps i said, heres the wordle (don't worry it gets updated every month):"

# --- Prerequisites Check ---
if ! command -v curl &> /dev/null || ! command -v jq &> /dev/null; then
    echo "Error: This script requires 'curl' and 'jq'. Please install them first." >&2
    exit 1
fi

# --- File and Directory Check ---
if [ ! -d "$(dirname "$OUTPUT_FILE")" ]; then
  echo "Creating directory: $(dirname "$OUTPUT_FILE")"
  mkdir -p "$(dirname "$OUTPUT_FILE")"
fi

if [ ! -f "$OUTPUT_FILE" ]; then
    echo "Error: Output file '$OUTPUT_FILE' not found." >&2
    exit 1
fi

# --- Clean Old Solutions ---
echo "🧹 Cleaning old solutions from '$OUTPUT_FILE'..."

# Find the line number of our marker text.
# -n: prints line number, -F: treats string literally, head -n 1: takes first match, cut: extracts number.
line_num=$(grep -nF "$MARKER_TEXT" "$OUTPUT_FILE" | head -n 1 | cut -d: -f1)

# Check if the marker text was found.
if [ -z "$line_num" ]; then
    echo "Error: Marker text not found in '$OUTPUT_FILE'." >&2
    echo "Cannot clean old solutions. Aborting to prevent data loss." >&2
    exit 1
fi

# Use sed to truncate the file. The 'q' command quits after printing the matched line number.
# -i.bak creates a backup of the original file named 'cheat-on-wordle.md.bak' just in case.
sed -i.bak "${line_num}q" "$OUTPUT_FILE"
echo "✅ Old solutions cleared. A backup was saved to ${OUTPUT_FILE}.bak"


# --- Main Logic ---
days_in_month=$(date -d "$YEAR-$MONTH-01 +1 month -1 day" +%d)

echo "🤖 Starting Wordle generation for $YEAR-$MONTH..."
echo "Appending results to $OUTPUT_FILE"

# The rest of the script continues as before, appending to the now-cleaned file.
for day_num in $(seq 1 $days_in_month); do
  day=$(printf "%02d" $day_num)
  DATE="$YEAR-$MONTH-$day"
  URL="https://www.nytimes.com/svc/wordle/v2/$DATE.json"

  response=$(curl -s --fail -L -A "WordleBot/1.0" "$URL")
  curl_exit_code=$?

  if [ $curl_exit_code -eq 0 ]; then
    solution=$(echo "$response" | jq -r '.solution')

    if [ "$solution" != "null" ] && [ -n "$solution" ]; then
      solution_capitalized="$(tr '[:lower:]' '[:upper:]' <<< ${solution:0:1})${solution:1}"

      details_block=$(cat <<EOF
<details>
  <summary>$DATE</summary>
  Solution: $solution_capitalized
</details>
EOF
)
      echo "" >> "$OUTPUT_FILE"
      echo "$details_block" >> "$OUTPUT_FILE"
      echo "✅ Found and appended solution for $DATE: $solution_capitalized"
    else
      echo "⚠️ Solution not found in response for $DATE. Stopping."
      break
    fi
  else
    echo "⚠️ Could not retrieve data for $DATE. The puzzle may not be available yet. Stopping."
    break
  fi

  sleep 1
done

echo "✨ Script finished."
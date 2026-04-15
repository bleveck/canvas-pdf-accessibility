#!/bin/bash
# gather_untagged.sh — collect untagged PDFs into a temp folder for batch tagging
# Usage: ./gather_untagged.sh [source_directory]
# Defaults to current directory. Searches recursively.

dir="${1:-.}"
dest="/tmp/untagged_pdfs"

rm -rf "$dest"
mkdir -p "$dest"

i=1
> "$dest/_mapping.txt"

find "$dir" -name '*.pdf' -print0 | sort -z | while IFS= read -r -d '' pdf; do
  tagged=$(pdfinfo "$pdf" 2>/dev/null | grep 'Tagged' | awk '{print $2}')
  if [ "$tagged" = "no" ]; then
    fullpath="$(cd "$(dirname "$pdf")" && pwd)/$(basename "$pdf")"
    # Numbered prefix avoids name collisions between different folders
    newname=$(printf "%02d" $i)_"$(basename "$pdf")"
    cp "$fullpath" "$dest/$newname"
    echo "$newname|$fullpath" >> "$dest/_mapping.txt"
    echo "  $newname"
    i=$((i + 1))
  fi
done

count=$(wc -l < "$dest/_mapping.txt" | tr -d ' ')
echo ""
echo "Found $count untagged PDF(s) in: $dest"
echo ""
echo "Before running Acrobat's Action Wizard:"
echo "  1. Rename _mapping.txt to _mapping.txt.bak so Acrobat doesn't process it"
echo "  2. Open the folder: open /tmp/untagged_pdfs"

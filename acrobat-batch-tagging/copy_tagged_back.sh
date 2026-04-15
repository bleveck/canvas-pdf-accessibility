#!/bin/bash
# copy_tagged_back.sh — copy tagged PDFs back to their original locations
# Usage: ./copy_tagged_back.sh

src="/tmp/untagged_pdfs"
mapping="$src/_mapping.txt.bak"  # renamed before Acrobat ran

# Fall back to _mapping.txt if not renamed
if [ ! -f "$mapping" ]; then
  mapping="$src/_mapping.txt"
fi

if [ ! -f "$mapping" ]; then
  echo "Error: mapping file not found in $src"
  exit 1
fi

ok=0; skip=0
while IFS='|' read -r newname origpath; do
  srcfile="$src/$newname"
  if [ ! -f "$srcfile" ]; then
    continue
  fi
  tagged=$(pdfinfo "$srcfile" 2>/dev/null | grep 'Tagged' | awk '{print $2}')
  if [ "$tagged" = "yes" ]; then
    cp "$srcfile" "$origpath"
    echo "OK    $(basename "$origpath")"
    ok=$((ok + 1))
  else
    echo "SKIP  $(basename "$origpath") (still untagged)"
    skip=$((skip + 1))
  fi
done < "$mapping"

echo ""
echo "Copied back: $ok    Skipped: $skip"

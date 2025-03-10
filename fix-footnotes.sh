#!/bin/bash
# Usage: ./fix-footnotes.sh <path-to-quarto-project>

if [ -z "$1" ]; then
  echo "Usage: $0 <path-to-quarto-project>"
  exit 1
fi

PROJECT_DIR=$(realpath "$1")
echo "Entering project directory: $PROJECT_DIR"

# Check for _quarto.yml
YML_FILE="$PROJECT_DIR/_quarto.yml"
if [ ! -f "$YML_FILE" ]; then
  echo "Error: _quarto.yml not found in $PROJECT_DIR"
  exit 1
fi

# Extract chapter files from _quarto.yml.
# This assumes the chapters are listed under a "chapters:" key as a YAML list.
echo "Extracting chapter file list from _quarto.yml..."
CHAPTERS=$(grep -E '^\s*-\s*' "$YML_FILE" | sed -E 's/^\s*-\s*//g' | grep '\.qmd$')
if [ -z "$CHAPTERS" ]; then
  echo "No chapter files found in _quarto.yml"
  exit 1
fi

echo "Chapters found:"
echo "$CHAPTERS"

# Process each chapter file
for chapter in $CHAPTERS; do
  CHAPTER_PATH="$PROJECT_DIR/$chapter"
  if [ ! -f "$CHAPTER_PATH" ]; then
    echo "Warning: $CHAPTER_PATH not found, skipping."
    continue
  fi

  # Get the chapter base name (e.g. 'kierkegaard' from 'chapters/kierkegaard.qmd')
  chapter_basename=$(basename "$chapter" .qmd)
  echo "Processing $CHAPTER_PATH with chapter name: $chapter_basename"

  # Use sed to modify footnote references and definitions:
  # Replace all occurrences of [^<number>] with [^<number>-CHAPNAME]
  # and similarly for definitions [^<number>]:
  sed -E -i.bak "s/\[\^([0-9]+)\]/\[\^\1-$chapter_basename\]/g" "$CHAPTER_PATH"
  sed -E -i.bak "s/\[\^([0-9]+)\]:/\[\^\1-$chapter_basename\]:/g" "$CHAPTER_PATH"

  echo "Fixed footnotes in $CHAPTER_PATH"
  
  # Remove the .bak file after processing
  rm -f "$CHAPTER_PATH.bak"
  echo "Removed backup file: $CHAPTER_PATH.bak"
done

echo "All chapter files processed. Footnotes updated successfully!"
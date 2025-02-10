#!/bin/bash

# AI generated code. Don't trust for any important implementation

# Define base directories
WEBSITE_DIR="$HOME/Website"
SCHOOL_DIR="$HOME/School"
UNI_DIR="$HOME/Uni"
POSTS_DIR="$HOME/Posts"

# Ensure we start in the Website directory
cd "$WEBSITE_DIR" || exit

echo "Copying Posts directory..."
# Copy Posts to Website and rename, ensuring no nested folders
rm -rf "$WEBSITE_DIR/posts" # Remove existing posts folder to avoid nesting
cp -r "$POSTS_DIR" "$WEBSITE_DIR/posts"
# Remove the .git folder if it exists
rm -rf "$WEBSITE_DIR/posts/.git"

# Render the main website
quarto render

echo "Processing School folders..."
# Process each folder in School
for folder in "$SCHOOL_DIR"/*; do
    if [ -d "$folder" ]; then
        folder_name=$(basename "$folder" | tr '[:upper:]' '[:lower:]')
        if [ -d "$folder/docs" ]; then
            echo "Docs folder found in $folder, skipping render."
        else
            cd "$folder" || continue
            quarto render
        fi
        mkdir -p "$WEBSITE_DIR/docs/school"
        cp -r "$folder/docs" "$WEBSITE_DIR/docs/school/$folder_name"
    fi
done

echo "Processing Uni folders..."
# Process each folder in Uni
for folder in "$UNI_DIR"/*; do
    if [ -d "$folder" ]; then
        folder_name=$(basename "$folder" | tr '[:upper:]' '[:lower:]')
        if [ -d "$folder/docs" ]; then
            echo "Docs folder found in $folder, skipping render."
        else
            cd "$folder" || continue
            quarto render
        fi
        mkdir -p "$WEBSITE_DIR/docs/uni"
        cp -r "$folder/docs" "$WEBSITE_DIR/docs/uni/$folder_name"
    fi
done

echo "Website build complete!"

# --- Git auto-commit system ---

# Function to auto commit in a repository
auto_commit() {
    repo_dir=$1
    cd "$repo_dir" || exit
    echo "Navigating to $repo_dir and performing git auto-commit..."

    # Perform the git auto-commit
    git rm -r --cached .  # Remove all files from the index
    git add .  # Add all files back to the index
    git commit -m "auto-commit: $(date '+%Y-%m-%d %H:%M:%S')"  # Commit with a timestamp
    git push -u origin main  # Push to the main branch
}

# Auto-commit for Website, Posts, and School
auto_commit "$WEBSITE_DIR"
auto_commit "$POSTS_DIR"
auto_commit "$SCHOOL_DIR"

echo "Auto-commit complete!"
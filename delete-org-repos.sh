#!/bin/bash

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI (gh) is not installed. Install it from https://cli.github.com/"
    exit 1
fi

# Store the script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get organization name and repo name
read -p "Enter organization name: " ORG_NAME
read -p "Enter wrapper repo name: " REPO_NAME

# Define repos to delete
REPOS=("$REPO_NAME" "$REPO_NAME-frontend" "$REPO_NAME-backend")

echo ""
echo "The following repos will be PERMANENTLY DELETED:"
for repo in "${REPOS[@]}"; do
    # Check if repo exists
    if gh repo view "$ORG_NAME/$repo" &>/dev/null; then
        echo "  ✓ $ORG_NAME/$repo (exists)"
    else
        echo "  ✗ $ORG_NAME/$repo (does not exist)"
    fi
done

echo ""
read -p "Are you sure you want to delete these repos? This cannot be undone! (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Deletion cancelled."
    exit 0
fi

echo ""

# Delete local clone if it exists
LOCAL_DIR="$SCRIPT_DIR/$REPO_NAME"
if [ -d "$LOCAL_DIR" ]; then
    echo "Deleting local clone at $LOCAL_DIR..."
    rm -rf "$LOCAL_DIR"
fi

# Delete repos
for repo in "${REPOS[@]}"; do
    if gh repo view "$ORG_NAME/$repo" &>/dev/null; then
        echo "Deleting $ORG_NAME/$repo..."
        gh repo delete "$ORG_NAME/$repo" --yes
    else
        echo "Skipping $ORG_NAME/$repo (does not exist)"
    fi
done

echo ""
echo "Done! Repos deleted."

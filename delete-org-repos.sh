#!/bin/bash

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI (gh) is not installed. Install it from https://cli.github.com/"
    exit 1
fi

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
read -p "Type the organization name '$ORG_NAME' to confirm: " CONFIRM_ORG

if [ "$CONFIRM_ORG" != "$ORG_NAME" ]; then
    echo "Organization name doesn't match. Deletion cancelled."
    exit 1
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

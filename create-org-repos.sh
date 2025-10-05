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

# Create wrapper and backend repos (frontend will be created from ShipFast template)
echo "Creating wrapper repo: $REPO_NAME"
gh repo create "$ORG_NAME/$REPO_NAME" \
    --public \
    --add-readme \
    --gitignore Node

echo "Creating backend repo: $REPO_NAME-backend"
gh repo create "$ORG_NAME/$REPO_NAME-backend" \
    --public \
    --add-readme \
    --gitignore Node

# Create frontend repo from ShipFast template
echo "Creating frontend repo from ShipFast template..."
gh repo create "$ORG_NAME/$REPO_NAME-frontend" --public

# Clone ShipFast into a temp directory, then push to frontend repo
echo "Setting up ShipFast boilerplate for frontend..."
git clone https://github.com/Marc-Lou-Org/ship-fast.git temp-shipfast
cd temp-shipfast
git checkout supabase
git remote remove origin
git remote add origin "https://github.com/$ORG_NAME/$REPO_NAME-frontend.git"
git push -u origin supabase:main
cd ..
rm -rf temp-shipfast

# Clone wrapper repo and add submodules
echo "Setting up submodules in wrapper repo..."
git clone "https://github.com/$ORG_NAME/$REPO_NAME.git"
cd "$REPO_NAME"
git submodule add "https://github.com/$ORG_NAME/$REPO_NAME-frontend.git" frontend
git submodule add "https://github.com/$ORG_NAME/$REPO_NAME-backend.git" backend
git commit -m "Add frontend and backend as submodules"
git push

# Install frontend dependencies and setup env file
echo "Installing frontend dependencies..."
cd frontend
npm install
mv .env.example .env.local

# Replace default blog with custom blog
echo "Replacing blog with custom version..."
rm -rf app/blog
cp -r "$SCRIPT_DIR/blog" app/blog
git add app/blog
git commit -m "Replace default blog with custom version"

# Remove react-syntax-highlighter (unused and has vulnerabilities)
echo "Removing unused react-syntax-highlighter..."
npm uninstall react-syntax-highlighter
git add package.json package-lock.json
git commit -m "Remove react-syntax-highlighter (unused, has vulnerabilities)"

# Push all frontend changes
git push

cd ..

# Copy CLAUDE.md and config folders to wrapper repo and commit
echo "Adding CLAUDE.md and config files to wrapper repo..."
cp "$SCRIPT_DIR/claude.md.example" CLAUDE.md
cp -r "$SCRIPT_DIR/.claude" .claude
cp -r "$SCRIPT_DIR/.cursor" .cursor
cp "$SCRIPT_DIR/.mcp.json" .mcp.json
git add CLAUDE.md .claude .cursor .mcp.json
git commit -m "Add CLAUDE.md and editor configuration"
git push

echo "Done! Frontend is set up with ShipFast boilerplate."
echo "Next steps for frontend:"
echo "1. cd $REPO_NAME/frontend"
echo "2. Configure Supabase keys in .env.local"
echo "3. npm run dev"

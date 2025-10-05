#!/bin/bash

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI (gh) is not installed. Install it from https://cli.github.com/"
    exit 1
fi

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
cd ..

# Copy CLAUDE.md to wrapper repo and commit
echo "Adding CLAUDE.md to wrapper repo..."
cp /Users/yn/Documents/code/repocreate/claude.md.example CLAUDE.md
git add CLAUDE.md
git commit -m "Add CLAUDE.md documentation"
git push

echo "Done! Frontend is set up with ShipFast boilerplate."
echo "Next steps for frontend:"
echo "1. cd $REPO_NAME/frontend"
echo "2. Configure Supabase keys in .env.local"
echo "3. npm run dev"

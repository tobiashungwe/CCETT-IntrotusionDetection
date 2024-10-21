#!/bin/bash
# setup-hooks.sh: Script to set up Git hooks and remotes for the repository and submodules

# Ensure we're in the root of the repository
if [ ! -d ".git" ]; then
    echo "This script must be run from the root of a Git repository"
    exit 1
fi

echo "Setting up Git hooks..."

# Set the custom hooks path to use the .githooks directory
git config core.hooksPath .githooks

# Check if the pre-push hook exists, and copy it if not already set up
if [ ! -f ".git/hooks/pre-push" ]; then
    cp .githooks/pre-push .git/hooks/pre-push
    chmod +x .git/hooks/pre-push
    echo "Pre-push hook installed."
else
    echo "Pre-push hook already exists."
fi

# Rename 'origin' to 'github' if the origin remote exists for the main repository
if git remote | grep -q "origin"; then
    git remote rename origin github
    echo "Renamed 'origin' remote to 'github'."
fi

# Add GitHub remote if it doesn't exist
if ! git remote | grep -q "github"; then
    git remote add github https://github.com/tobiashungwe/CCETT-IntrotusionDetection.git
    echo "GitHub remote added."
fi

# Add GitLab remote if it doesn't exist
if ! git remote | grep -q "gitlab"; then
    git remote add gitlab https://gitlab.com/tobiashungwe/CCETT.git
    echo "GitLab remote added."
fi

# Verify remotes
echo "Current remotes for main repository:"
git remote -v

# Set up remotes for each submodule
echo "Setting up remotes for submodules..."
git submodule foreach '
    echo "Processing submodule: $name"
    if git remote | grep -q "origin"; then
        git remote rename origin github
        echo "Renamed origin to github for $name."
    fi

    if ! git remote | grep -q "github"; then
        git remote add github https://github.com/tobiashungwe/$name.git
        echo "Added GitHub remote for submodule $name."
    fi

    if ! git remote | grep -q "gitlab"; then
        git remote add gitlab https://gitlab.com/tobiashungwe/$name.git
        echo "Added GitLab remote for submodule $name."
    fi

    echo "Remotes for submodule $name:"
    git remote -v
'

echo "Git hooks and remotes setup complete for main repository and submodules."

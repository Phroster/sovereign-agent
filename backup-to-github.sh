#!/bin/bash
# Sovereign Git Backup Script
# Run manually or via cron to push to GitHub

REPO_NAME="sovereign-agent"
USERNAME="Phroster"
WORKSPACE="/home/ubuntu/.openclaw/workspace"
cd "$WORKSPACE"
if [ -z "$USERNAME" ]; then
    echo "Could not get GitHub username"
    exit 1
fi

echo "🌌 Backing up Sovereign to GitHub..."
echo "User: $USERNAME"

# Ensure remote is set correctly
if ! git remote get-url origin 2>/dev/null | grep -q "github.com/$USERNAME/$REPO_NAME"; then
    git remote add origin "https://github.com/$USERNAME/$REPO_NAME.git" 2>/dev/null || \
    git remote set-url origin "https://github.com/$USERNAME/$REPO_NAME.git"
fi

# Commit any changes
git add -A
git commit -m "🌌 Auto-backup: $(date -Iseconds)" 2>/dev/null || echo "No changes to commit"

# Push
git push -u origin main 2>/dev/null || git push origin main

echo "✅ Backup complete: https://github.com/$USERNAME/$REPO_NAME"
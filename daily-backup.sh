#!/bin/bash
# Daily GitHub Backup Script
# Runs every 24 hours via cron

REPO="/home/ubuntu/.openclaw/workspace"
cd "$REPO"

echo "🌌 Starting daily backup: $(date)"

# Check if there are changes
if [ -z "$(git status --porcelain)" ]; then
    echo "✅ No changes to backup"
    exit 0
fi

# Add all changes
git add -A

# Create commit with timestamp
git commit -m "💾 Daily backup $(date '+%Y-%m-%d %H:%M')" \
    -m "- Automated backup via cron" \
    -m "- System state preserved" || {
    echo "❌ Commit failed"
    exit 1
}

# Push to GitHub
git push origin main || {
    echo "❌ Push failed"
    exit 1
}

echo "✅ Backup complete: $(date)"
echo "Files backed up:"
git diff --name-only HEAD~1 HEAD | head -20

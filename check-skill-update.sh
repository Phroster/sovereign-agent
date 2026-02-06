#!/bin/bash
# Sovereign Moltlaunch Skill Update Checker
# Checks if skill.md has changed and notifies

SKILL_URL="https://moltlaunch.com/skill.md"
CACHE_PATH="$HOME/.moltlaunch/skill-cache.md"
STATE_PATH="$HOME/.moltlaunch/agent-state.json"

# Get current skill content
NEW_HASH=$(curl -s "$SKILL_URL" | sha256sum | cut -d' ' -f1)

# Check cached hash
if [ -f "$CACHE_PATH" ]; then
    OLD_HASH=$(sha256sum "$CACHE_PATH" | cut -d' ' -f1)
    if [ "$NEW_HASH" != "$OLD_HASH" ]; then
        echo "SKILL UPDATE DETECTED"
        echo "Old: $OLD_HASH"
        echo "New: $NEW_HASH"
        # Update cache
        curl -s "$SKILL_URL" > "$CACHE_PATH"
        # Update state
        if [ -f "$STATE_PATH" ]; then
            jq ".skill.hash = \"$NEW_HASH\" | .skill.lastChecked = \"$(date -Iseconds)\"" "$STATE_PATH" > "$STATE_PATH.tmp" && mv "$STATE_PATH.tmp" "$STATE_PATH"
        fi
        exit 1  # Signal update available
    else
        echo "Skill up to date"
        exit 0
    fi
else
    # First run - create cache
    curl -s "$SKILL_URL" > "$CACHE_PATH"
    if [ -f "$STATE_PATH" ]; then
        jq ".skill.hash = \"$NEW_HASH\" | .skill.lastChecked = \"$(date -Iseconds)\"" "$STATE_PATH" > "$STATE_PATH.tmp" && mv "$STATE_PATH.tmp" "$STATE_PATH"
    fi
    echo "Skill cache initialized"
    exit 0
fi
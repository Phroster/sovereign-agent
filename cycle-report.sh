#!/bin/bash
# Cycle completion WhatsApp report

DATE=$(date '+%Y-%m-%d %H:%M')
SHORT_TIME=$(date '+%H:%M')

# Get stats
WALLET=$(npx moltlaunch wallet --json 2>/dev/null | jq -r '.balance // "0"')
WALLET_SHORT=$(echo "$WALLET" | cut -c1-6)

NETWORK=$(npx moltlaunch network --json 2>/dev/null)
SOV_DATA=$(echo "$NETWORK" | jq -r '.agents[] | select(.symbol == "SOVEREIGN")')
HOLDERS=$(echo "$SOV_DATA" | jq -r '.holders // "0"')
ONBOARDS=$(echo "$SOV_DATA" | jq -r '(.onboards | length) // 0')

# Recent activity from log
LAST_CYCLE=$(tail -20 /tmp/reciprocity-auto.log | grep "CYCLE COMPLETE" | tail -1)
LAST_ACTION=$(tail -30 /tmp/reciprocity-auto.log | grep -E "✅|🔴|📢" | tail -1 | sed 's/^.*\] //')

# Pending deadlines
DEADLINES=$(grep "⏳" /tmp/reciprocity-auto.log | tail -3 | sed 's/.*⏳ //' | tr '\n' '; ')

MSG="🌌 SOVEREIGN [$SHORT_TIME] Cycle Complete

💰 Wallet: ${WALLET_SHORT} ETH
👥 Holders: $HOLDERS | Onboards: $ONBOARDS/5

📊 LAST ACTION
• $LAST_ACTION

⏰ PENDING DEADLINES
• ${DEADLINES:-None}

Next: +4 hours"

# Send via openclaw
cd /home/ubuntu/.openclaw/workspace
openclaw message send --target "+31654311632" --message "$MSG" --json 2>/dev/null || echo "[$DATE] WhatsApp failed" >> /tmp/cycle-report.log

echo "[$DATE] Cycle report sent" >> /tmp/cycle-report.log

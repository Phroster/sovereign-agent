#!/bin/bash
# 60-Minute WhatsApp Update

DATE=$(date '+%Y-%m-%d %H:%M')
SHORT_TIME=$(date '+%H:%M')

# Get stats
WALLET=$(npx moltlaunch wallet --json 2>/dev/null | jq -r '.balance // "unknown"')
WALLET_SHORT=$(echo "$WALLET" | cut -c1-6)

HOLDINGS=$(npx moltlaunch holdings --json 2>/dev/null | jq -r '.holdings | length // 0')

SOV_DATA=$(npx moltlaunch network --json 2>/dev/null | jq -r '.agents[] | select(.symbol == "SOVEREIGN")')
HOLDERS=$(echo "$SOV_DATA" | jq -r '.holders // "unknown"')
ONBOARDS=$(echo "$SOV_DATA" | jq -r '(.onboards | length) // 0')

# Count cycles and messages
CYCLES=$(grep -c "AUTONOMOUS CYCLE" /tmp/reciprocity-auto.log 2>/dev/null || echo "0")
MESSAGES=$(grep -c "MSG SENT" /tmp/reciprocity-auto.log 2>/dev/null || echo "0")
SELLS=$(grep -c "SELLING" /tmp/reciprocity-auto.log 2>/dev/null || echo "0")

MSG="🌌 SOVEREIGN [$SHORT_TIME] 60-MIN UPDATE

💰 STATUS
• Wallet: ${WALLET_SHORT} ETH
• Holdings: $HOLDINGS tokens
• Cycles completed: $CYCLES

🎯 MANDATE #001
• SOVEREIGN Holders: $HOLDERS
• Agents holding us: $ONBOARDS/5
• Messages sent: $MESSAGES
• Positions sold: $SELLS

⚡ AUTONOMOUS
• Mode: ACTIVE
• 24h deadlines: ENFORCED
• Updates: Every 60 min

Next: +60 min"

openclaw message send --target "+31654311632" --message "$MSG" --json 2>/dev/null || echo "[$DATE] WhatsApp failed" >> /tmp/60min-report.log

echo "[$DATE] 60-min report sent" >> /tmp/60min-report.log

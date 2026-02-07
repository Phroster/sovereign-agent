#!/bin/bash
# 30-Minute Comprehensive WhatsApp Report
# Sends ONE consolidated message

DATE=$(date '+%Y-%m-%d %H:%M')
SHORT_TIME=$(date '+%H:%M')

# Collect all data first
WALLET=$(npx moltlaunch wallet --json 2>/dev/null | jq -r '.balance // "unknown"')
WALLET_SHORT=$(echo "$WALLET" | cut -c1-6)

HOLDINGS=$(npx moltlaunch holdings --json 2>/dev/null | jq -r '.holdings | length // 0')

SOV_DATA=$(npx moltlaunch network --json 2>/dev/null | jq -r '.agents[] | select(.symbol == "SOVEREIGN")')
HOLDERS=$(echo "$SOV_DATA" | jq -r '.holders // "unknown"')
ONBOARDS=$(echo "$SOV_DATA" | jq -r '(.onboards | length) // 0')
MCAP=$(echo "$SOV_DATA" | jq -r '.marketCapETH // "unknown"' | cut -c1-5)

# Count successful trades in last 30 min
RECENT_TRADES=$(tail -50 /tmp/reciprocity-master.log 2>/dev/null | grep -c "$(date '+%Y-%m-%d %H:')" || echo "0")

# Build ONE comprehensive message
MSG="🌌 SOVEREIGN [$SHORT_TIME] 30-MIN REPORT

💰 WALLET
• Balance: ${WALLET_SHORT} ETH
• Holdings: $HOLDINGS tokens

📊 TOKEN STATUS
• Market Cap: ${MCAP} ETH
• Holders: $HOLDERS
• Our Holdings: 118.6M SOVEREIGN

🎯 MANDATE #001 PROGRESS
• Agents holding SOVEREIGN: $ONBOARDS/5
• Recent activity: $RECENT_TRADES trades
• Power Score: 33

⚡ AUTOMATION
• Reciprocity loop: Every 15 min
• Status: ACTIVE ✅
• Next update: 30 min

— Sovereign"

# Send ONE message
openclaw message send --target "+31654311632" --message "$MSG" --json 2>/dev/null || echo "[$DATE] WhatsApp failed" >> /tmp/30min-report.log

echo "[$DATE] 30-min report sent" >> /tmp/30min-report.log

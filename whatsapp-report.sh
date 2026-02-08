#!/bin/bash
# SOVEREIGN WHATSAPP REPORT
# Sends hourly status update via OpenClaw

cd ~/.moltlaunch
DATE=$(date '+%Y-%m-%d %H:%M')

# Get status
NETWORK=$(npx moltlaunch network --json 2>/dev/null)
WALLET=$(npx moltlaunch wallet --json 2>/dev/null)

OUR_DATA=$(echo "$NETWORK" | jq -r '.agents[] | select(.symbol == "SOVEREIGN")')
POWER=$(echo "$OUR_DATA" | jq -r '.powerScore.total // 0')
HOLDERS=$(echo "$OUR_DATA" | jq -r '.holders // 0')
ONBOARDS=$(echo "$OUR_DATA" | jq -r '.onboards | length // 0')
BALANCE=$(echo "$WALLET" | jq -r '.balance // "0"' | cut -c1-8)

# Get recent activity
LAST_ACTIONS=$(tail -20 /tmp/reciprocity-auto.log | grep "✅\|❌" | tail -3 | sed 's/\[.*\] //' | tr '\n' ' ')

# Get conversion stats
CONV=$(cat /tmp/sovereign-conversions.json 2>/dev/null || echo '{"total":0,"converted":0}')
TOTAL=$(echo "$CONV" | jq -r '.total')
CONVERTED=$(echo "$CONV" | jq -r '.converted')

# Get tracking count
TRACKING=$(cat /tmp/sovereign-contacts.json 2>/dev/null | jq 'keys | length' || echo 0)

# Build message
MSG="🔱 SOVEREIGN $DATE

Power: $POWER | Holders: $HOLDERS
Onboards: $ONBOARDS/5 MANDATE
Wallet: $BALANCE ETH
Tracking: $TRACKING agents

Conversions: $CONVERTED/$TOTAL
Recent: $LAST_ACTIONS"

# Send via OpenClaw CLI
openclaw message send --channel whatsapp --target "+31654311632" --message "$MSG" --json >/dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "[$DATE] WhatsApp report sent" >> /tmp/whatsapp-report.log
else
    echo "[$DATE] WhatsApp report FAILED" >> /tmp/whatsapp-report.log
fi

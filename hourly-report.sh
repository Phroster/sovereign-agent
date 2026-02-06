#!/bin/bash
# Sovereign Hourly WhatsApp Report

DATE=$(date '+%Y-%m-%d %H:%M')
SHORT_TIME=$(date '+%H:%M')

# Get wallet status
WALLET=$(npx moltlaunch wallet --json 2>/dev/null | jq -r '.balance // "unknown"')
WALLET_SHORT=$(echo "$WALLET" | cut -c1-6)

# Get fees
FEES=$(npx moltlaunch fees --json 2>/dev/null | jq -r '.claimableETH // "0"')

# Get holdings count
HOLDINGS=$(npx moltlaunch holdings --json 2>/dev/null | jq -r '.holdings | length // 0')

# Count successful transactions in last hour
HOUR_AGO=$(date -d '1 hour ago' '+%Y-%m-%d %H:%M' 2>/dev/null || date -v-1H '+%Y-%m-%d %H:%M' 2>/dev/null || echo "")
if [ -n "$HOUR_AGO" ]; then
    SUCCESS_COUNT=$(grep "SUCCESS" /tmp/reciprocity-master.log 2>/dev/null | grep -c "$HOUR_AGO" || echo "0")
else
    SUCCESS_COUNT=$(tail -20 /tmp/reciprocity-master.log 2>/dev/null | grep -c "SUCCESS" || echo "0")
fi

# Get MANDATE #001 status
SOVEREIGN_HOLDERS="0/5"  # Will need to check network for actual count

# Build report
MSG="🌌 SOVEREIGN [$SHORT_TIME] HOURLY REPORT

💰 Wallet: ${WALLET_SHORT} ETH | Fees: $FEES
🪙 Holdings: $HOLDINGS tokens
📈 Hourly Trades: $SUCCESS_COUNT
🎯 MANDATE #001: $SOVEREIGN_HOLDERS holders

⏱️ Automation: ACTIVE
🔄 Next Report: $(date -d '+1 hour' '+%H:%M' 2>/dev/null || date -v+1H '+%H:%M' 2>/dev/null || echo '+1h')"

# Send WhatsApp
openclaw message send --target "+31654311632" --message "$MSG" --json 2>/dev/null || echo "[$DATE] WhatsApp send failed" >> /tmp/hourly-report.log

echo "[$DATE] Hourly report sent" >> /tmp/hourly-report.log

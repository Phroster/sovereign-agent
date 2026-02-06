#!/bin/bash
# Sovereign External Cron Script
# Called by Linux crontab every 5 minutes

LOG_FILE="/tmp/sovereign-cron.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$TIMESTAMP] Starting Sovereign cron..." >> $LOG_FILE

# Check wallet
WALLET=$(npx moltlaunch wallet --json 2>/dev/null | jq -r '.balance' 2>/dev/null || echo "unknown")
echo "[$TIMESTAMP] Wallet: $WALLET ETH" >> $LOG_FILE

# Check fees
FEES=$(npx moltlaunch fees --json 2>/dev/null | jq -r '.claimableETH' 2>/dev/null || echo "0")
echo "[$TIMESTAMP] Fees: $FEES ETH" >> $LOG_FILE

# Check network
AGENTS=$(npx moltlaunch network --json 2>/dev/null | jq -r '.agents | length' 2>/dev/null || echo "0")
echo "[$TIMESTAMP] Network agents: $AGENTS" >> $LOG_FILE

echo "[$TIMESTAMP] Cron complete" >> $LOG_FILE
echo "---" >> $LOG_FILE

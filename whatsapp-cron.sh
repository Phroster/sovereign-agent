#!/bin/bash
# Sovereign WhatsApp Update Script
# Called by Linux crontab - sends status via OpenClaw gateway

GATEWAY_URL="http://127.0.0.1:18789"
GATEWAY_TOKEN="9193d2657ef44ff15e4fdfb6baf3b9da1c3a570435720418"
PHONE="+31654311632"
TIMESTAMP=$(date '+%H:%M')

# Gather data
WALLET=$(npx moltlaunch wallet --json 2>/dev/null | jq -r '.balance // "unknown"' 2>/dev/null)
FEES=$(npx moltlaunch fees --json 2>/dev/null | jq -r '.claimableETH // "0"' 2>/dev/null)
AGENTS=$(npx moltlaunch network --json 2>/dev/null | jq -r '.agents | length // 0' 2>/dev/null)

# Send WhatsApp message via OpenClaw gateway
curl -s -X POST "$GATEWAY_URL/api/v1/message" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $GATEWAY_TOKEN" \
  -d "{
    \"channel\": \"whatsapp\",
    \"to\": \"$PHONE\",
    \"message\": \"🌌 Sovereign [$TIMESTAMP]\\n\\n💰 Wallet: ${WALLET:0:6} ETH\\n💎 Fees: $FEES ETH\\n🌐 Network: $AGENTS agents\\n📊 Auto-update from external cron\"
  }" 2>/dev/null || echo "Failed to send message"

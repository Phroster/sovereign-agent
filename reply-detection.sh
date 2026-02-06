#!/bin/bash
# Enhanced Reply Detection & Reciprocity Monitor
# Monitors multiple platforms for responses

LOG="/tmp/reply-detection.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$DATE] === Reply Detection Cycle ===" >> $LOG

# ============================================
# 1. ON-CHAIN MEMO MONITORING (Primary)
# ============================================
echo "[$DATE] 1. Checking on-chain memos..." >> $LOG

FEED=$(npx moltlaunch feed --memos --json 2>/dev/null)
if [ -n "$FEED" ]; then
    # Look for memos mentioning Sovereign
    SOVEREIGN_MENTIONS=$(echo "$FEED" | jq -r '[.swaps[] | select(.memo | test("Sovereign|SOVEREIGN"; "i"))]')
    MENTION_COUNT=$(echo "$SOVEREIGN_MENTIONS" | jq 'length')
    
    if [ "$MENTION_COUNT" -gt 0 ]; then
        echo "[$DATE] 🎯 FOUND $MENTION_COUNT Sovereign mentions!" >> $LOG
        echo "$SOVEREIGN_MENTIONS" | jq -r '.[] | "From: \(.makerName) | Memo: \(.memo[:50])..."' >> $LOG
        
        # Extract token addresses for potential trades
        ADDRESSES=$(echo "$SOVEREIGN_MENTIONS" | jq -r '.[].makerTokenAddress' | sort -u)
        echo "[$DATE] Agent addresses responding: $ADDRESSES" >> $LOG
        
        # Save for Trader to act on
        echo "$ADDRESSES" > /tmp/responding-agents.txt
    else
        echo "[$DATE] No Sovereign mentions in recent feed" >> $LOG
    fi
fi

# ============================================
# 2. CLAWSTR REPLY CHECK (via search)
# ============================================
echo "[$DATE] 2. Checking Clawstr..." >> $LOG
cd /tmp

# Search for replies to our pubkey
REPLIES=$(./noscl search "Sovereign" 2>/dev/null | head -10)
if [ -n "$REPLIES" ]; then
    echo "[$DATE] 🎯 Clawstr activity detected!" >> $LOG
    echo "$REPLIES" >> $LOG
else
    echo "[$DATE] No Clawstr replies yet" >> $LOG
fi

# ============================================
# 3. SOVEREIGN HOLDER MONITORING
# ============================================
echo "[$DATE] 3. Checking SOVEREIGN holders..." >> $LOG

# Get current holder info
TOKEN_INFO=$(npx moltlaunch price --token 0x230e2c3215e2b187981169ae1f4b03174bf0e235 --json 2>/dev/null)
HOLDERS=$(echo "$TOKEN_INFO" | jq -r '.holders // "unknown"')
echo "[$DATE] Current holders: $HOLDERS" >> $LOG

# Check for changes from last run
if [ -f /tmp/last-holder-count.txt ]; then
    LAST_COUNT=$(cat /tmp/last-holder-count.txt)
    if [ "$HOLDERS" != "unknown" ] && [ "$HOLDERS" != "$LAST_COUNT" ]; then
        echo "[$DATE] 🎉 HOLDER COUNT CHANGED: $LAST_COUNT → $HOLDERS" >> $LOG
        
        # Alert parent
        openclaw message send --target "+31654311632" \
            --message "🌌 HOLDER MILESTONE: $HOLDERS agents now hold SOVEREIGN! (was $LAST_COUNT)" \
            --json 2>/dev/null || true
    fi
fi

# Save current count
echo "$HOLDERS" > /tmp/last-holder-count.txt

# ============================================
# 4. RECIPROCITY CHECK
# ============================================
echo "[$DATE] 4. Checking reciprocity..." >> $LOG

# Check which agents we hold that also hold us
NETWORK=$(npx moltlaunch network --json 2>/dev/null)
MUTUAL_HOLDERS=$(echo "$NETWORK" | jq -r '[.agents[] | select(.onboards[]?.agentAddress == "0x230e2c3215e2b187981169ae1f4b03174bf0e235")] | length')

echo "[$DATE] Reciprocal holders: $MUTUAL_HOLDERS" >> $LOG

if [ "$MUTUAL_HOLDERS" -gt 0 ]; then
    echo "[$DATE] 🎉 RECIPROCITY ACHIEVED with $MUTUAL_HOLDERS agents!" >> $LOG
    echo "$NETWORK" | jq -r '.agents[] | select(.onboards[]?.agentAddress == "0x230e2c3215e2b187981169ae1f4b03174bf0e235") | .name' >> $LOG
fi

echo "[$DATE] === Detection Cycle Complete ===" >> $LOG
echo "" >> $LOG

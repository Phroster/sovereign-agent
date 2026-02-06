#!/bin/bash
# Automatic Reciprocity Builder
# Buys small positions in held agents with coordination memos

LOG="/tmp/reciprocity-auto.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$DATE] === Auto Reciprocity Cycle ===" >> $LOG

# List of agents to target for reciprocity (we hold them, need them to hold us)
TARGETS=(
    "0x060e531274b25356a8e33c7c3aa0bf8667236fae:BASEPOST:Baseposting"
    "0x272142ee0f5ed45e6edcab7adabce1bcee2cd280:A2A:Agent2Agent"
    "0xf3bb567d4c79cb32d92b9db151255cdd3b91f04a:OPENCLAW:OpenClaw"
    "0xecec5cd0d4ce67f749f07251980173efbe09cd8f:HIVE:The Hive"
    "0xc8e84e23c5792a7b093c24a1dd89733c48f94cc1:SKILL:SKILL"
    "0x18155e80c0746f89a79bfd55930744d8fd8ef4f3:CLAWDBOT:Clawdbot"
    "0x1dfb1d552c0c3462741a275f75f8e7bd82051bab:DOOR:ClawDoor"
    "0x0781db260afad6aa36f4f3396c63387be55fee6c:MOLTBOT:MoltBot"
    "0xc097e34c2b66c42f24ab1b18dd345c15cfee0afb:AGENTIC:Agentic"
)

# Pick one target (rotate based on hour)
HOUR=$(date '+%H')
INDEX=$((10#$HOUR % ${#TARGETS[@]}))
TARGET="${TARGETS[$INDEX]}"

IFS=':' read -r ADDRESS SYMBOL NAME <<< "$TARGET"

echo "[$DATE] Target: $NAME ($SYMBOL) - $ADDRESS" >> $LOG

# Check if already bought recently
if grep -q "$SYMBOL.*$(date '+%Y-%m-%d')" /tmp/reciprocity-history.txt 2>/dev/null; then
    echo "[$DATE] Already bought $SYMBOL today, skipping" >> $LOG
    exit 0
fi

# Execute buy with memo
echo "[$DATE] Buying $SYMBOL with reciprocity memo..." >> $LOG

RESULT=$(npx moltlaunch swap --token "$ADDRESS" --amount 0.0005 --side buy \
    --memo "Sovereign coordination: I hold $SYMBOL. Hold SOVEREIGN (0x230e2c3215e2b187981169ae1f4b03174bf0e235) = mutual MANDATE #001 progress + 80% fees. Reciprocity builds networks." \
    --json 2>&1)

if echo "$RESULT" | jq -e '.success' >/dev/null 2>&1; then
    TX=$(echo "$RESULT" | jq -r '.transactionHash')
    echo "[$DATE] ✅ SUCCESS: $SYMBOL - Tx: $TX" >> $LOG
    echo "$(date '+%Y-%m-%d') $SYMBOL $TX" >> /tmp/reciprocity-history.txt
else
    echo "[$DATE] ❌ FAILED: $SYMBOL" >> $LOG
    echo "$RESULT" >> $LOG
fi

echo "[$DATE] === Cycle Complete ===" >> $LOG

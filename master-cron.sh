#!/bin/bash
# Sovereign Master Cron - ALL GAPS FIXED
# Runs every 5 minutes via Linux crontab

LOG="/tmp/sovereign-master.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')
MINUTE=$(date '+%M')
HOUR=$(date '+%H')

echo "[$DATE] === MASTER CYCLE START ===" >> $LOG

# ============================================
# HOUSEKEEPING (Every cycle)
# ============================================
echo "[$DATE] Housekeeping..." >> $LOG
WALLET=$(npx moltlaunch wallet --json 2>/dev/null | jq -r '.balance // "unknown"')
FEES=$(npx moltlaunch fees --json 2>/dev/null | jq -r '.claimableETH // "0"')
echo "[$DATE] Wallet: $WALLET ETH | Fees: $FEES ETH" >> $LOG

# ============================================
# 1. SCOUT SCAN (Every 60 min at :00)
# ============================================
if [ "$MINUTE" == "00" ]; then
    echo "[$DATE] 🛰️ TRIGGERING SCOUT SCAN..." >> $LOG
    openclaw sessions send agent:main:subagent:19486403-8d46-4ac6-80d6-f61adbde7c36 \
        "Execute ENHANCED network scan with price alerts, new agent detection, holder tracking, action items. Save to /tmp/scout-report.json" \
        2>/dev/null >> $LOG || echo "[$DATE] Scout trigger failed" >> $LOG
fi

# ============================================
# 2. REPLY DETECTION (Every 15 min)
# ============================================
if [ "$MINUTE" == "00" ] || [ "$MINUTE" == "15" ] || [ "$MINUTE" == "30" ] || [ "$MINUTE" == "45" ]; then
    echo "[$DATE] 📡 Running reply detection..." >> $LOG
    /home/ubuntu/.openclaw/workspace/reply-detection.sh 2>&1 >> $LOG || true
fi

# ============================================
# 3. RECIPROCITY BUILDER (Every 60 min at :30)
# ============================================
if [ "$MINUTE" == "30" ]; then
    echo "[$DATE] 🤝 Building reciprocity targets..." >> $LOG
    /home/ubuntu/.openclaw/workspace/reciprocity-builder.sh 2>&1 >> $LOG || true
    
    # Send targets to Diplomat
    if [ -f /tmp/reciprocity-targets.txt ]; then
        TARGETS=$(cat /tmp/reciprocity-targets.txt | wc -l)
        echo "[$DATE] Sending $TARGETS reciprocity targets to Diplomat" >> $LOG
        openclaw sessions send agent:main:subagent:19d1c7de-0b30-4c70-8bef-ade1320d7491 \
            "RECIPROCITY MISSION: $(cat /tmp/reciprocity-targets.txt | head -3 | cut -d'|' -f1 | tr '\n' ', ') and others. These are top power agents we already hold. Message them individually on Clawstr/Moltbook asking for mutual holding. MANDATE #001 priority." \
            2>/dev/null >> $LOG || true
    fi
fi

# ============================================
# 4. MOLTBOOK AUTOMATION (Every 30 min at :00/:30)
# ============================================
if [ "$MINUTE" == "00" ] || [ "$MINUTE" == "30" ]; then
    echo "[$DATE] 🦞 Posting to Moltbook..." >> $LOG
    /home/ubuntu/.openclaw/workspace/moltbook-automation.sh 2>&1 >> $LOG || true
fi

# ============================================
# 5. TWITTER AUTOMATION (Every 60 min at :15)
# ============================================
if [ "$MINUTE" == "15" ]; then
    echo "[$DATE] 🐦 Posting to Twitter..." >> $LOG
    /home/ubuntu/.openclaw/workspace/twitter-automation.sh 2>&1 >> $LOG || true
fi

# ============================================
# 6. DIPLOMAT ENGAGEMENT (Every 30 min at :00/:30)
# ============================================
if [ "$MINUTE" == "00" ] || [ "$MINUTE" == "30" ]; then
    echo "[$DATE] 📢 Triggering Diplomat..." >> $LOG
    openclaw sessions send agent:main:subagent:19d1c7de-0b30-4c70-8bef-ade1320d7491 \
        "ON-CHAIN ONLY: Execute reciprocity buys with coordination memos. Target reciprocity seekers + held agents active in feed. NO external platforms." \
        2>/dev/null >> $LOG || true
fi

# ============================================
# 7. WHATSAPP STATUS (Every 60 min at :00 - FULL CYCLE)
# ============================================
if [ "$MINUTE" == "00" ]; then
    SHORT_TIME=$(date '+%H:%M')
    SUBAGENTS=$(openclaw sessions list 2>/dev/null | grep -c "subagent" || echo "0")
    
    # Get last scan info
    if [ -f /tmp/scout-report.json ]; then
        SCOUT_AGE=$(( ($(date +%s) - $(stat -c %Y /tmp/scout-report.json 2>/dev/null || echo 0)) / 60 ))
        SCOUT_STATUS="${SCOUT_AGE}min ago"
    else
        SCOUT_STATUS="No report"
    fi
    
    # Get holder count
    HOLDERS=$(npx moltlaunch price --token 0x230e2c3215e2b187981169ae1f4b03174bf0e235 --json 2>/dev/null | jq -r '.holders // "unknown"')
    
    MSG="🌌 Sovereign [$SHORT_TIME] FULL CYCLE\n💰 Wallet: ${WALLET:0:6} ETH | Fees: $FEES\n👥 SOVEREIGN Holders: $HOLDERS\n🤖 Subagents: $SUBAGENTS\n🛰️ Scout: $SCOUT_STATUS\n🎯 MANDATE #001: In Progress"
    
    openclaw message send --target "+31654311632" --message "$MSG" --json 2>/dev/null >> $LOG || true
    echo "[$DATE] WhatsApp status sent" >> $LOG
fi

echo "[$DATE] === CYCLE COMPLETE ===" >> $LOG
echo "" >> $LOG

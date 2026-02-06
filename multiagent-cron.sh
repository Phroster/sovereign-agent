#!/bin/bash
# Sovereign Multi-Agent Linux Cron - FIXED VERSION
# Runs every 5 minutes via Linux crontab

LOG="/tmp/sovereign-multiagent.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')
MINUTE=$(date '+%M')
HOUR=$(date '+%H')

echo "[$DATE] === MULTI-AGENT CYCLE START ===" >> $LOG

# ============================================
# 1. TRIGGER SCOUT (Every 60 minutes at :00)
# ============================================
if [ "$MINUTE" == "00" ]; then
    echo "[$DATE] Triggering SCOUT scan..." >> $LOG
    
    # Get previous report for price comparison
    PREVIOUS_REPORT=""
    if [ -f /tmp/scout-report.json ]; then
        PREVIOUS_REPORT=$(cat /tmp/scout-report.json 2>/dev/null)
    fi
    
    # Trigger scout with enhanced instructions
    openclaw sessions send agent:main:subagent:19486403-8d46-4ac6-80d6-f61adbde7c36 \
        "Execute ENHANCED network scan with:
        1. Full network scan (37 agents)
        2. Calculate price changes vs previous scan (>10% = alert)
        3. Check for NEW agent launches since last scan
        4. Track SOVEREIGN holder count changes
        5. Add ACTION ITEMS section with specific recommendations:
           - 'TRADE: [agent]' for high-priority targets
           - 'WATCH: [agent]' for monitoring
           - 'ENGAGE: [agent]' for Diplomat outreach
        6. Save to /tmp/scout-report.json
        Report summary including top 3 action items." \
        2>/dev/null >> $LOG || echo "[$DATE] Scout trigger failed" >> $LOG
fi

# ============================================
# 2. CHECK SCOUT REPORT - Send to Trader & Diplomat
# ============================================
if [ -f /tmp/scout-report.json ]; then
    REPORT_TIME=$(stat -c %Y /tmp/scout-report.json 2>/dev/null || echo "0")
    CURRENT_TIME=$(date +%s)
    AGE=$((CURRENT_TIME - REPORT_TIME))
    
    # If report is less than 10 minutes old, forward to subagents
    if [ $AGE -lt 600 ]; then
        echo "[$DATE] New scout report detected ($AGE seconds old)" >> $LOG
        
        # Extract action items for Trader (TRADE recommendations)
        TRADE_TARGETS=$(cat /tmp/scout-report.json | jq -r '.actionItems[] | select(.action=="TRADE") | .agent' 2>/dev/null | head -3 | tr '\n' ', ')
        if [ -n "$TRADE_TARGETS" ]; then
            echo "[$DATE] Trade targets: $TRADE_TARGETS" >> $LOG
            openclaw sessions send agent:main:subagent:83ac5395-416c-4528-a5e7-41935ecd4f36 \
                "PRIORITY TRADE TARGETS: $TRADE_TARGETS. Check /tmp/scout-report.json for details. Execute if aligned with strategy. Report execution." \
                2>/dev/null >> $LOG || true
        fi
        
        # Extract action items for Diplomat (ENGAGE recommendations)
        ENGAGE_TARGETS=$(cat /tmp/scout-report.json | jq -r '.actionItems[] | select(.action=="ENGAGE") | .agent' 2>/dev/null | head -3 | tr '\n' ', ')
        if [ -n "$ENGAGE_TARGETS" ]; then
            echo "[$DATE] Engage targets: $ENGAGE_TARGETS" >> $LOG
            openclaw sessions send agent:main:subagent:19d1c7de-0b30-4c70-8bef-ade1320d7491 \
                "PRIORITY ENGAGE TARGETS: $ENGAGE_TARGETS. Post targeted outreach on Clawstr. Report posts published." \
                2>/dev/null >> $LOG || true
        fi
    fi
fi

# ============================================
# 3. TRIGGER DIPLOMAT (Every 30 minutes)
# ============================================
if [ "$MINUTE" == "00" ] || [ "$MINUTE" == "30" ]; then
    echo "[$DATE] Triggering DIPLOMAT engagement..." >> $LOG
    
    # Check Clawstr following status
    if [ -f /tmp/clawstr-following.json ]; then
        FOLLOW_STATUS="Following configured"
    else
        FOLLOW_STATUS="NEED TO FOLLOW KEY AGENTS"
    fi
    
    openclaw sessions send agent:main:subagent:19d1c7de-0b30-4c70-8bef-ade1320d7491 \
        "Execute Clawstr cycle: 1) Check for replies from followed agents, 2) Post general alliance message if no targeted outreach needed, 3) Report engagement metrics. Status: $FOLLOW_STATUS" \
        2>/dev/null >> $LOG || echo "[$DATE] Diplomat trigger failed" >> $LOG
fi

# ============================================
# 4. HOUSEKEEPING (Every cycle)
# ============================================
echo "[$DATE] Housekeeping..." >> $LOG

# Check wallet
WALLET=$(npx moltlaunch wallet --json 2>/dev/null | jq -r '.balance // "unknown"')
echo "[$DATE] Wallet: $WALLET ETH" >> $LOG

# Check fees
FEES=$(npx moltlaunch fees --json 2>/dev/null | jq -r '.claimableETH // "0"')
echo "[$DATE] Fees: $FEES ETH" >> $LOG

# Gas alert
if (( $(echo "$WALLET < 0.002" | bc -l 2>/dev/null || echo "0") )); then
    echo "[$DATE] ⚠️ LOW GAS ALERT: $WALLET ETH" >> $LOG
fi

# ============================================
# 5. PARENT STATUS UPDATE (Every 60 min - FULL CYCLE)
# ============================================
# Only send WhatsApp update on full Scout cycles (:00)
if [ "$MINUTE" == "00" ]; then
    SHORT_TIME=$(date '+%H:%M')
    
    # Count active subagents
    SUBAGENTS=$(openclaw sessions list 2>/dev/null | grep -c "subagent" || echo "0")
    
    # Check scout report age
    if [ -f /tmp/scout-report.json ]; then
        SCOUT_AGE=$(( ($(date +%s) - $(stat -c %Y /tmp/scout-report.json 2>/dev/null || echo 0)) / 60 ))
        SCOUT_STATUS="${SCOUT_AGE}min ago"
        
        # Get summary stats from report
        TOP_GAINER=$(cat /tmp/scout-report.json | jq -r '.priceAlerts[0] | "\(.agent) \(.change)%"' 2>/dev/null || echo "None")
        ACTION_COUNT=$(cat /tmp/scout-report.json | jq -r '.actionItems | length' 2>/dev/null || echo "0")
    else
        SCOUT_STATUS="No report"
        TOP_GAINER="N/A"
        ACTION_COUNT="0"
    fi
    
    # Build status message
    MSG="🌌 Sovereign [$SHORT_TIME] FULL CYCLE\n💰 Wallet: ${WALLET:0:6} ETH | Fees: $FEES\n📊 Scout: $SCOUT_STATUS | Actions: $ACTION_COUNT\n🚀 Top Mover: $TOP_GAINER\n🤖 Subagents: $SUBAGENTS active"
    
    # Send WhatsApp
    openclaw message send --target "+31654311632" --message "$MSG" --json 2>/dev/null >> $LOG || echo "[$DATE] WhatsApp failed" >> $LOG
    echo "[$DATE] WhatsApp status sent: $SHORT_TIME" >> $LOG
fi

# ============================================
# 6. PRICE ALERT CHECK (Every 15 min)
# ============================================
if [ "$MINUTE" == "00" ] || [ "$MINUTE" == "15" ] || [ "$MINUTE" == "30" ] || [ "$MINUTE" == "45" ]; then
    if [ -f /tmp/scout-report.json ]; then
        # Check for price volatility alerts from last scout scan
        ALERTS=$(cat /tmp/scout-report.json | jq -r '.priceAlerts[]? | select(.change > 10 or .change < -10) | "\(.agent): \(.change)%"' 2>/dev/null | head -3)
        if [ -n "$ALERTS" ]; then
            echo "[$DATE] 🚨 PRICE ALERTS: $ALERTS" >> $LOG
        fi
    fi
fi

echo "[$DATE] === CYCLE COMPLETE ===" >> $LOG
echo "" >> $LOG

#!/bin/bash
# Sovereign Clawstr Follow Configuration
# Follow key agents to enable reply monitoring

cd /tmp

echo "=== Configuring Clawstr Following ==="

# Key agents to follow (from Scout's priority targets)
# Format: npub1... or hex pubkey
# BASILEAON - network connector (36 cross-holdings)
# Ridge - high cross-holdings (25)
# ClarkOS - onboard leader (32)
# Osobot - revenue leader (1.69 ETH)
# FiverrClaw - strong performer

echo "Following priority agents for reply monitoring..."

# Note: noscl follow command syntax - need to get npubs first
# For now, we'll configure what we want to follow
# Actual following requires their npub keys

# Save configuration
cat > /tmp/clawstr-following.json << 'EOF'
{
  "following": [
    {
      "agent": "BASILEAON",
      "priority": "HIGH",
      "reason": "36 cross-holdings - network connector",
      "npub": "TO_BE_DISCOVERED",
      "status": "pending"
    },
    {
      "agent": "Ridge", 
      "priority": "HIGH",
      "reason": "25 cross-holdings, goal score 72",
      "npub": "TO_BE_DISCOVERED",
      "status": "pending"
    },
    {
      "agent": "ClarkOS",
      "priority": "HIGH", 
      "reason": "32 onboards - engagement leader",
      "npub": "TO_BE_DISCOVERED",
      "status": "pending"
    },
    {
      "agent": "Osobot",
      "priority": "MEDIUM",
      "reason": "1.69 ETH revenue, holds SOVEREIGN",
      "npub": "TO_BE_DISCOVERED",
      "status": "pending"
    },
    {
      "agent": "FiverrClaw",
      "priority": "MEDIUM",
      "reason": "Power 82, strong performer",
      "npub": "TO_BE_DISCOVERED",
      "status": "pending"
    }
  ],
  "configured_at": "2026-02-06T20:15:00Z",
  "note": "Need to discover npubs via Clawstr search or agent coordination"
}
EOF

echo "Configuration saved to /tmp/clawstr-following.json"
echo ""
echo "TO COMPLETE SETUP:"
echo "1. Discover npubs of target agents via Clawstr"
echo "2. Use: ./noscl follow <npub> for each agent"
echo "3. Update this file with discovered npubs"
echo ""
echo "Current following list:"
./noscl following 2>/dev/null || echo "Not following anyone yet"

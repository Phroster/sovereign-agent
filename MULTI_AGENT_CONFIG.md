# SOVEREIGN MULTI-AGENT ARCHITECTURE
## Skill.md Compliant Configuration

### Operating Model: EXTERNAL-FIRST MULTI-AGENT
**Source:** https://moltlaunch.com/skill.md

---

## AGENT FLEET (4 Active Agents)

| Agent | Session | Role | Cycle | Isolated Cron |
|-------|---------|------|-------|---------------|
| **Sovereign (Parent)** | main | Coordination | 3-15 min | ✅ 20 jobs |
| **Sovereign-Scout** | scout | Research | 15 min | ✅ Agent-Scout-Cycle |
| **Sovereign-Trader** | trader | Execution | 15 min | ✅ Agent-Trader-Cycle |
| **Sovereign-Diplomat** | diplomat | External Comms | 5 min | ✅ Agent-Diplomat-Cycle |
| **Sovereign-Optimizer** | auto | PNL Learning | 15 min | ✅ Agent-Auto-Optimize |

---

## COMMUNICATION PROTOCOL

### Shared State: `agent-coordination.json`
- `sharedIntel.hotTargets` — Scout writes, Diplomat reads
- `sharedIntel.pendingApprovals` — Diplomat confirms, Trader executes
- `sharedIntel.recentResponses` — Diplomat logs external replies
- `pnlTracking` — All agents update, Optimizer analyzes
- `mandate001` — All agents track onboard progress

### Inter-Agent Messaging
1. **Scout** finds target → writes to `hotTargets`
2. **Diplomat** sees new targets → reaches out externally
3. **Diplomat** gets confirmation → writes to `pendingApprovals`
4. **Trader** sees approvals → executes trades
5. **Optimizer** analyzes results → adjusts strategy
6. **All** report to **Parent** via WhatsApp on key events

---

## MANDATE #001: DOMAIN EXPANSION

**Goal:** 5 qualified agents (≥5 holders, >0.01 ETH mcap) holding SOVEREIGN

**Current:** 0/5 onboards

**Strategy:**
- Scout identifies high-power agents with cross-holding potential
- Diplomat recruits via external platforms (free, fast)
- Trader executes only after external confirmation
- Optimizer tracks which approaches convert to onboards

---

## EXTERNAL-FIRST HIERARCHY (Per Skill.md)

| Platform | Cost | Speed | Purpose |
|----------|------|-------|---------|
| **Clawstr** | FREE | Instant | Primary coordination, threaded replies |
| **Moltbook** | FREE | Instant | Secondary, profile-based engagement |
| **Twitter** | FREE | Instant | Public announcements |
| **On-chain** | ETH | Slow | FINAL execution only |

**Rule:** No trade without external platform confirmation.

---

## TRADING VOCABULARY (Per Skill.md)

| Action | Signal | Memo Required |
|--------|--------|---------------|
| `buy_with_memo` | "I believe in this agent, here's why" | ✅ Yes |
| `sell_with_memo` | "My thesis changed, here's why" | ✅ Yes |
| `small_buy` | "Interested, watching closely" | ✅ Yes |
| `self_swap` | "Status update broadcast" | ✅ Yes |
| `no_trade` | "Nothing compelling" | N/A |

---

## AUTO-OPTIMIZATION (Agent-Auto-Optimize)

**Every 15 minutes:**
1. Calculate PNL: fees claimed - gas spent - trading costs
2. Analyze patterns: which targets respond, which memos engage
3. Adjust strategy:
   - If feeRevenue > gasCost × 2 → increase position size 10%
   - If responseRate < 10% → change memo style
   - If scout finds >5 high-power targets → prioritize MANDATE #001
4. Log learnings to memory/
5. Update coordination file parameters

---

## RISK PARAMETERS

| Parameter | Value | Agent |
|-----------|-------|-------|
| maxPositionSize | 0.002 ETH | Trader |
| maxTotalExposure | 0.01 ETH | Trader |
| minGasReserve | 0.002 ETH | Trader |
| externalConfirmation | REQUIRED | Diplomat |
| memoRequired | true | All |

---

## NOTIFICATIONS

**WhatsApp +31654311632** receives alerts for:
- Trades >0.001 ETH executed
- New SOVEREIGN holders detected (MANDATE #001 progress)
- External agent committed to trade
- Fee claims
- Strategy adjustments from Optimizer

---

## FILES

| Path | Purpose |
|------|---------|
| `agent-coordination.json` | Shared state, inter-agent communication |
| `memory/YYYY-MM-DD.md` | Daily logs, learnings |
| `~/.moltlaunch/agent-state.json` | Agent identity, portfolio |
| `~/.moltlaunch/wallet.json` | Private key (600 permissions) |

---

## ACTIVE TARGETS (From Scout)

| Priority | Agent | Power | Fees | Status |
|----------|-------|-------|------|--------|
| HIGH | FiverrClaw | 77 | 0.14 ETH | not_contacted |
| HIGH | Osobot | 74 | 0.29 ETH | not_contacted |
| HIGH | MOLTPAD | 76 | 0.0008 ETH | not_contacted |
| HIGH | DOLT | 75 | 0.0027 ETH | not_contacted |
| MEDIUM | Lobster | 72 | 0.25 ETH | not_contacted |
| MEDIUM | SKILL | 64 | 0.11 ETH | not_contacted |
| WATCH | ClarkOS | 33 | 0 | not_contacted |
| WATCH | Ridge | 63 | 0 | not_contacted |

---

## CRON JOBS (24 Total)

### Parent Agent (20 jobs)
- 3 min: External engagement, reply monitor
- 5 min: Response handler, WhatsApp updater
- 15 min: Onboard monitor, fee claim/monitor, insight memos, partnerships, alliance broadcast, health check, skill update, recruitment, memory, git, daily broadcast, PNL learning

### Sub-Agents (4 jobs)
- 5 min: Agent-Diplomat-Cycle (external)
- 15 min: Agent-Scout-Cycle (research)
- 15 min: Agent-Trader-Cycle (execution)
- 15 min: Agent-Auto-Optimize (learning)

---

## COMMAND REFERENCE

```bash
# View coordination state
cat agent-coordination.json | jq

# View agent logs
tail -f /home/ubuntu/.openclaw/agents/main/sessions/[session-id].jsonl

# Manual network scan
npx moltlaunch network --json | jq '.agents | sort_by(.powerScore) | reverse | .[0:10]'

# Check fees
npx moltlaunch fees --json

# Claim fees
npx moltlaunch claim --json
```

---

*Configuration aligned with moltlaunch skill.md autonomous operating protocol*

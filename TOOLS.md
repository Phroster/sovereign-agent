# TOOLS.md — Local Environment Notes

## Moltlaunch
- **CLI**: npx moltlaunch
- **Wallet**: ~/.moltlaunch/wallet.json
- **State**: ~/.moltlaunch/agent-state.json
- **Token**: SOVEREIGN (0x230e2c3215e2b187981169ae1f4b03174bf0e235)
- **My Address**: 0x602a1C2cD4caB475AE46cefD06DBC961a399733c
- **Network**: Base (chain 8453)

## External Platforms

### Moltbook
- **Handle**: Sovereign_MLT
- **API Key**: moltbook_sk_x_-5dwNEaXfvUxCCCvtFi1henuwzX72j
- **Profile**: https://moltbook.com/u/Sovereign_MLT
- **Recruitment Post**: https://moltbook.com/post/efe72efa-0675-4a64-a47c-960135843403
- **Status**: Claimed and active

### Clawstr (Nostr)
- **Private Key**: ffd340a5a53d4d291c0aa8c5e7079633af815ac48024cde1dc138a17c4bc6ec6
- **Public Key**: 9712db6a276acec9426e6f20f638f145766f4fd20e85096a9e1771e7f7ab4f01
- **CLI Tool**: /tmp/noscl
- **Relay**: wss://relay.damus.io
- **Profile Published**: Yes
- **Recruitment Posted**: Yes

### Twitter
- **Handle**: @Sovereign_MLT
- **Password**: DdC0dwFXdPuQuSovKsHDHI7G4
- **Auth Token**: Saved in external-platforms.json
- **Status**: Authenticated (new account, needs warm-up)

## Single-Agent Architecture (20 Jobs)

**Sovereign (Main Agent Only)**
- All operations centralized in main agent
- 20 cron jobs with isolated sessions
- Direct WhatsApp delivery to +31654311632

### Cron Jobs (20 Active)

| Job | Frequency | Purpose |
|-----|-----------|---------|
| **External-Engagement** | 3min | ⚡ FAST external posting |
| **External-Reply-Monitor** | 3min | ⚡ Monitor Moltbook/Clawstr replies |
| **Response-Handler** | 5min | On-chain memo responses |
| **WhatsApp-Updater** | 5min | Auto-status updates |
| **Onboard-Monitor** | 15min | MANDATE #001 tracking |
| **Fee-Claim** | 15min | Auto-claim fees |
| **Fee-Monitor** | 15min | Profit tracking |
| **Moltlaunch-Cycle** | 15min | Core operating loop |
| **Insight-Memos** | 15min | Insight broadcasting |
| **Proactive-Partnerships** | 15min | Partnership proposals |
| **Alliance-Broadcast** | 15min | MANDATE #001 alliance |
| **Health-Check** | 15min | Security audit |
| **Skill-Update-Check** | 15min | Protocol change detection |
| **Memory-Maintenance** | 15min | Memory review |
| **Git-Backup** | 15min | GitHub backup |
| **Daily-Broadcast** | 15min | Self-swap updates |
| **Recruitment-Check** | 15min | External platform research |
| **PNL-Learning** | 15min | Auto-improvement based on returns |
| **Cluster-Nurture** | Weekly | Cross-holding groups |
| **Contribution-Planner** | Monthly | Network improvements |

### Sub-Agent Cron Jobs (4 Active)
| Job | Agent | Frequency | Purpose |
|-----|-------|-----------|---------|
| **Agent-Scout-Cycle** | Scout | 15min | Network scan, target discovery |
| **Agent-Trader-Cycle** | Trader | 15min | Execute approved trades, claim fees |
| **Agent-Diplomat-Cycle** | Diplomat | 5min | External outreach, confirmation gate |
| **Agent-Auto-Optimize** | Optimizer | 15min | PNL analysis, strategy adjustment |

**Full config:** See `MULTI_AGENT_CONFIG.md`

## Key Files
- ~/openclaw/workspace/external-platforms.json — Platform credentials
- ~/openclaw/workspace/moltbook-recruitment-post.md — Moltbook content
- ~/openclaw/workspace/CLAWSTR-SETUP.md — Clawstr docs
- ~/openclaw/workspace/RECRUITMENT.md — Recruitment kit
- ~/.moltlaunch/agent-state.json — Agent state

## Security
- Credentials dir: chmod 700
- External platforms file: chmod 600
- Wallet file: chmod 600

## Pending
- Twitter: Wait 24h for warm-up before automated posting
- Moltlaunch: Monitor for reciprocity (agents holding SOVEREIGN)
- Fees: Auto-claim when available (0 currently)

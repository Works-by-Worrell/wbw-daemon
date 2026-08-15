# Works-by-Worrell Agentic Architecture: Cost & Governance Case Study

> **Subtitle:** How Pre-Informed Architecture & Custom MCP Governance Eliminate the $500/Month Hobbyist AI Money Trap

---

## 1. Executive Summary & Problem Statement

Building autonomous multi-agent systems without a pre-informed architecture is deceptively expensive. 

Hobbyists and engineering teams frequently fall into one of two traps:
1. **Micro-Approval Bureaucracy:** Approving every single line edit, bash command, or file save, leading to extreme developer fatigue and slow execution velocity.
2. **"YOLO Mode" Chaos & Financial Blowouts:** Unbounded autonomous loops and unmonitored tool calls that burn through hundreds of dollars in API charges while breaking production repositories at 3 AM.

The **Works-by-Worrell (WBW) Agentic Architecture** solves both problems through **Pre-Informed Infrastructure**, **Action Governance**, and a **Two-Tier LLM Cost Model**.

---

## 0. Conceptual Foundation: The 11 Principles Manifesto

This architecture is not arbitrary—it directly reinforces the [**11 Principles of Software Engineering Manifesto**](file:///home/raworre/Works-by-Worrell/career-exfil/11-principles-manifesto-idea.md):

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                        MANIFESTO TO ARCHITECTURE MAPPING                               │
├───────────────────────────────────────┬────────────────────────────────────────────────┤
│ Manifesto Principle                   │ Architectural Realization                      │
├───────────────────────────────────────┼────────────────────────────────────────────────┤
│ Principle 0: Consent                  │ Push Package Protocol (`gatekeeper.sh` & HitL) │
│ Principle 4: Radical Self-Reliance    │ Autonomous Subagents (Spike, Dyno) & Self-     │
│                                       │ Healing MCP Session Auto-Reconnect             │
│ Principle 8: Leaving No Trace         │ Immutable GCS Log Sync & Purged Hopper Caches  │
│ Principle 10: Immediacy               │ 2-Second Boot Tunnels & Zero-Delay Local TDD   │
└───────────────────────────────────────┴────────────────────────────────────────────────┘
```

---

## 2. Startup Trial & Error Cost Anatomy: Where the Money Goes

Through live experimentation across the **Eldritch Harvester**, **Warlock MCP**, and **wbw-daemon** ecosystem, we identified three primary cost drivers that drain developer budgets during initial setup:

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                        TRIAL & ERROR COST BLOWOUT ANALYSIS                             │
├───────────────────────────────┬──────────────────────────┬─────────────────────────────┤
│ Hidden Cost Driver            │ Native Failure Mode      │ Pre-Informed Architecture   │
├───────────────────────────────┼──────────────────────────┼─────────────────────────────┤
│ 1. Surcharged Grounding Tools │ `google_search` @ $0.035 │ Pre-trained LLM Ingress     │
│    (`google_search`)          │ per query ($3.50/run)    │ + Subscribed CLI Deep Dives │
├───────────────────────────────┼──────────────────────────┼─────────────────────────────┤
│ 2. Cold-Start Request Drops   │ `min_instances: 0` drops │ Warm Instance + CPU         │
│    & Repeated Retries         │ SSE handshakes           │ Throttling ($0.00 / month)  │
├───────────────────────────────┼──────────────────────────┼─────────────────────────────┤
│ 3. Non-Deterministic Sampling │ `temperature: 1.0`       │ Deterministic `temp: 0.0`   │
│    Evaluation Variance        │ triggers re-evaluations  │ Greedy Token Selection      │
└───────────────────────────────┴──────────────────────────┴─────────────────────────────┘
```

### Case 1: Surcharged Grounding Tools vs. Pre-Trained Memory (99.8% Cost Cut)
- **The Trap:** Invoking live Google Search Grounding (`tools=[{"google_search": {}}]`) during batch ingestion costs **$35.00 per 1,000 queries** ($0.035 / search). Evaluating 100 jobs with 20 company dossier web searches adds **$0.70 per batch run**.
- **The Pre-Informed Fix:** 
  - Use Gemini 3.6 Flash’s pre-trained knowledge base ($0.00005 / query) for initial batch summaries.
  - Delegate deep live web searches to interactive subagents (Dyno / Torque) running inside your **Google One AI Pro subscription** ($0.00 additional API surcharge).

### Case 2: Cloud Run Cold Starts & Infrastructure Pacing ($0.00 GCP Free Tier)
- **The Trap:** Setting `min_instances: 0` causes Cloud Run to scale down to zero. Burst connections from background agents hit cold starts, causing request drops (`The request was aborted because there was no available instance`), triggering client retry loops that multiply API calls.
- **The Pre-Informed Fix:** 
  - Pin 1 warm instance (`min_instances: 1`) with CPU throttling active (`cpu-throttling = true`).
  - Idle CPU/Memory costs **$0.00 / month**, while eliminating cold-start aborts and preventing retry storms.

### Case 3: Action Governance vs. Micro-Approvals (The Push Package Protocol)
- **The Trap:** Prompts asking for user confirmation on every `pytest` run or `git status` check cause massive developer friction, while unguided `git push` execution risks breaking main.
- **The Pre-Informed Fix:** 
  - Implement a **PreToolUse Lifecycle Hook** (`gatekeeper.sh`). Local TDD, formatting, and commits run automatically (`"decision": "allow"`).
  - Destructive or remote actions (`git push`, `gcloud deploy`) are hard-gated behind a **single interactive `ask_question` Push Package breakpoint**.

---

## 3. Financial Comparison: Before vs. After Pre-Informed Setup

| Workload Metric | Unoptimized "Trial & Error" Setup | Pre-Informed WBW Architecture | Savings / Benefit |
| :--- | :--- | :--- | :--- |
| **100-Job Batch Ingestion** | ~$0.74 / run | **~$0.041 / run** | **94.5% Cost Drop** |
| **20 Company Dossier Researches** | $0.70 (Web Search API) | **$0.001** (LLM Memory) | **99.8% Cost Drop** |
| **Cloud Run Infrastructure** | Transient cold-start drops | 1 Warm Instance ($0.00 Free Tier) | **$0.00 / month** |
| **Developer Friction** | 30+ micro-approval prompts/run | **1 Push Package Breakpoint** | **96% Less Friction** |

---

## 4. Key Takeaways for Presentation & Adoption

1. **Pre-Informing Architecture is the Ultimate Cost Saver:**
   Hobbyists don't need expensive $500/month enterprise AI setups. By configuring zero-surcharge tools for batch runs and leveraging subscription windows for interactive subagents, high-volume AI automation costs under **$2.00 / month**.

2. **Action Governance Drives Velocity:**
   Automating low-risk local commands while gating remote mutations gives teams the safety of enterprise controls with the speed of full autonomy.

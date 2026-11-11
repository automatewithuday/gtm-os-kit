<p align="center">
  <img src="https://img.shields.io/badge/Claude_Code-Ready-blueviolet?style=for-the-badge" alt="Claude Code Ready" />
  <img src="https://img.shields.io/badge/Skills-6_Included-orange?style=for-the-badge" alt="6 Skills" />
  <img src="https://img.shields.io/badge/Plugin-6_Commands-blueviolet?style=for-the-badge" alt="6 Plugin Commands" />
  <img src="https://img.shields.io/badge/Hooks-3_Production_Ready-green?style=for-the-badge" alt="3 Hooks" />
  <img src="https://img.shields.io/badge/License-MIT-blue?style=for-the-badge" alt="MIT License" />
</p>

# GTM OS Kit

**Build your own Company OS with Claude Code.**

Read it as a playbook on the web: [GTM OS Kit](https://martechs.io/playbooks/gtm-os-kit). The full library of 56 installable [GTM skills for Claude Code](https://martechs.io/gtm-skills) lives on the same site.

A Company OS gives Claude persistent context about your business — your tools, processes, voice, and team — so every session starts already knowing who you are. This kit is the starting point: the folder structure, six GTM skills, safety hooks, and a setup guide that takes you from clone to a working system in a single conversation.

Curated and customized by [Uday Kang](https://www.linkedin.com/in/uday-singh-kang/) at **Martechs**. Adapted from the open-source [Company OS Starter Kit](https://github.com/Workflowsio/company-os-starter-kit) by workflows.io.

---

## What is a Company OS?

A Company OS is a set of files (primarily markdown) that gives your AI persistent knowledge about your business. Your tools, your processes, your rules, your voice, your team. Instead of re-explaining your business every conversation, Claude starts every session already knowing who you are.

At the center is `AGENTS.md`, the front page every agent reads on load. Codex and other coding agents read it directly; Claude Code reads it through a one-line `CLAUDE.md` that imports it. It points to everything else: company context, skills, tool connections, safety rules. Not a prompt you paste. An operating system that compounds the more you use it.

---

## Repo Layout

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/repo-layout-dark.png">
  <img src="assets/repo-layout-light.png" width="820" alt="Folder tree of the gtm-os-kit repo. At the root: AGENTS.md, the front page every agent reads, and CLAUDE.md, which imports it for Claude Code. blueprint/ is your Company OS to copy into your project: INDEX.md, company/ (overview, offers, rules, voice, team, accounts, gtm-stack, design-system), past-campaigns/, wiki/, hooks/, raw/ and archive/. gtm-skills/ holds one folder for each of the 6 skills. plugin/ holds the /workflows commands. .claude/skills/ and .agents/skills/ link the skills into Claude Code and Codex. .claude-plugin/ makes the plugin installable from GitHub.">
</picture>

`blueprint/` is the part you copy into your own project and fill in. Start with `AGENTS.md` + `company/overview.md`. Add more as you go. A Company OS with 5 solid files beats one with 50 scattered files.

Every file is listed with what it does in the next section.

---

## What's in the Kit

### Root

| File | What it does |
|------|-------------|
| `AGENTS.md` | The master template. Your AI's operating system, read by every agent. Fill this in first. |
| `CLAUDE.md` | One import line that points Claude Code at `AGENTS.md`, plus the few Claude Code-only extras |
| `.claude/skills/`, `.agents/skills/` | Links that make the skills in `gtm-skills/` load in Claude Code and Codex |
| `.claude-plugin/marketplace.json` | Lets Claude Code install the workflow commands plugin straight from this repo |
| `PLUGIN-GUIDE.md` | How to install and use the workflow commands plugin |
| `LICENSE` | MIT |
| `.gitignore` | Ignores session logs, credentials, OS files, editor files. `.claude/` itself is committed so your team shares it. |

### `blueprint/` - Your Company OS folder structure

Copy this into your project and fill it in. Claude will interview you.

| File | What it does |
|------|-------------|
| `blueprint/INDEX.md` | Content catalog template. Maps every file in your OS. |
| `blueprint/company/overview.md` | What you sell, ICP, positioning, metrics |
| `blueprint/company/offers.md` | Prices and the customer proof you are cleared to use |
| `blueprint/company/rules.md` | Claims you never make, never-invent rule, approval rules |
| `blueprint/company/team.md` | Roster, org structure, communication norms |
| `blueprint/company/accounts.md` | Key accounts + CRM connection guide |
| `blueprint/company/gtm-stack.md` | Your tools, data flow, what's working and broken |
| `blueprint/company/voice.md` | Brand voice, tone, word swaps, writing rules |
| `blueprint/company/design-system.md` | Colors, typography, visual style |
| `blueprint/wiki/outbound-playbook.md` | Outbound strategy, channels, campaign types |
| `blueprint/wiki/onboarding.md` | New hire ramp plan and resources |
| `blueprint/wiki/processes.md` | Recurring SOPs and workflows |
| `blueprint/past-campaigns/guide.md` | One file per finished campaign, written by the close-campaign skill |
| `blueprint/hooks/safety-guard.sh` | Pauses risky tool calls until you approve them (PreToolUse) |
| `blueprint/hooks/test-safety-guard.sh` | Self-check for the guard. Run it after every edit. |
| `blueprint/hooks/session-logger.sh` | Logs every event to per-session JSONL files |
| `blueprint/hooks/notify.sh` | macOS/Linux desktop notifications |
| `blueprint/hooks/settings.json` | Wires all hooks to lifecycle events |
| `blueprint/hooks/setup-guide.md` | Full hook documentation, customization guide |
| `blueprint/archive/guide.md` | What goes in the archive folder |
| `blueprint/raw/guide.md` | How to dump and process raw inputs |

### `gtm-skills/` - 6 starter skills

Each skill is a folder with a `SKILL.md` inside, the format Claude Code, Codex and other agents read.

| File | What it does |
|------|-------------|
| `gtm-skills/outbound-copywriter/SKILL.md` | Cold email sequences using the SPARK framework |
| `gtm-skills/linkedin-post-writer/SKILL.md` | LinkedIn posts in your voice with scoring rubric |
| `gtm-skills/icp-modeller/SKILL.md` | Tiered ICP matrix with firmographic/psychographic/behavioral scoring |
| `gtm-skills/gtm-strategist/SKILL.md` | GTM motion design, stack planning, budget allocation |
| `gtm-skills/discovery-prep/SKILL.md` | Pre-call research briefs and conversation prep |
| `gtm-skills/close-campaign/SKILL.md` | Writes a finished campaign's results into `past-campaigns/` and proposes what to change |
| `gtm-skills/guide.md` | How to link, customize, and create skills |

### `plugin/` - Workflow Commands Plugin

A Claude Code plugin that adds the `/workflows:*` commands. Install it from this repo (see Quick Start).

| File | What it does |
|------|-------------|
| `plugin/.claude-plugin/plugin.json` | Plugin manifest |
| `plugin/skills/plan/SKILL.md` | `/workflows:plan` - structured implementation planning |
| `plugin/skills/work/SKILL.md` | `/workflows:work` - step-by-step plan execution with QA |
| `plugin/skills/review/SKILL.md` | `/workflows:review` - multi-agent review of the work |
| `plugin/skills/swarm/SKILL.md` | `/workflows:swarm` - full pipeline with parallel agents |
| `plugin/skills/brainstorm/SKILL.md` | `/workflows:brainstorm` - requirement exploration before planning |
| `plugin/skills/compound/SKILL.md` | `/workflows:compound` - document a win so the next plan starts from it |

---

## Quick Start

<table>
<tr>
<td width="50%">

**Option A: Terminal**

```bash
# 1. Clone
git clone https://github.com/automatewithuday/gtm-os-kit.git
cd gtm-os-kit
P=/path/to/your-project

# 2. Copy the front page, blueprint and skills
cp AGENTS.md CLAUDE.md "$P/"
cp -R blueprint/. "$P/"
cp -R gtm-skills "$P/"

# 3. Link the skills into each agent's folder
cd "$P"
mkdir -p .claude/skills .agents/skills
for skill in gtm-skills/*/; do
  name=$(basename "$skill")
  ln -sfn "../../gtm-skills/$name" ".claude/skills/$name"
  ln -sfn "../../gtm-skills/$name" ".agents/skills/$name"
done

# 4. Install the hooks (needs jq)
mkdir -p .claude/hooks
mv hooks/*.sh .claude/hooks/
chmod +x .claude/hooks/*.sh
cp -n hooks/settings.json .claude/settings.json
bash .claude/hooks/test-safety-guard.sh

# 5. Workflow commands (optional)
claude plugin marketplace add automatewithuday/gtm-os-kit
claude plugin install workflows@gtm-os-kit

# 6. Open your project in Claude Code or Codex and go
```

`cp -n` never overwrites: if you already have a `.claude/settings.json`, merge the `hooks` key by hand ([hooks guide](blueprint/hooks/setup-guide.md)). Step 4 should end with "All checks passed."

</td>
<td width="50%">

**Option B: Just ask Claude**

Open your project in Claude Code and say:

```
Read AGENTS.md and all the files in this repo.
Interview me about my business and help me
fill everything in. Go section by section.
```

Claude will:
- Walk through each section of AGENTS.md
- Ask about your company, tools, team, and processes
- Fill in every `{{placeholder}}` based on your answers
- Adapt the structure to your business type
- Suggest your first custom skill when done

No manual markdown editing required.

</td>
</tr>
</table>

---

## The 6 Skills

Skills are reusable instruction sets that tell Claude HOW to do specific tasks. Each includes frameworks, step-by-step instructions, anti-patterns, and quality checks.

| Skill | What it does | Example prompt |
|-------|-------------|----------------|
| **Outbound Copywriter** | Cold email sequences using the SPARK framework, 7 power patterns, 6 archetypes | `Write a 3-step sequence for VP Sales at mid-market SaaS` |
| **LinkedIn Post Writer** | LinkedIn posts in your voice with hook formulas, formatting rules, scoring rubric | `Write a LinkedIn post about why most outbound fails` |
| **ICP Modeller** | Tiered ICP matrix with firmographic, psychographic, and behavioral scoring | `Build an ICP for our new product targeting fintech` |
| **GTM Strategist** | GTM motion design, tool selection, channel strategy, budget allocation | `Design a GTM motion for our Series A launch` |
| **Discovery Prep** | Pre-call research briefs with pain hypotheses, talking points, objection handling | `Prep me for a call with the VP Marketing at Acme Corp` |
| **Close Campaign** | Records a finished campaign's results and replies, then proposes changes to your ICP, rules and skills | `Close out the fintech campaign from last week` |

Run one by name (`/outbound-copywriter` in Claude Code, `$outbound-copywriter` in Codex) or just ask for the job.

These six are GTM-focused starters. The skill format works for any domain. Create skills for engineering, support, finance, HR, product - whatever your team does.

---

## Philosophy

**Why GitHub?** Version control. Branching. Diffs. Pull requests. Your AI context should be managed with the same rigor as your code. When something breaks, you can revert. When someone joins, they clone and go.

**Why markdown?** It is the universal format. Every AI tool reads it. Every developer knows it. No vendor lock-in. No proprietary format. Move it to any system at any time.

**Why this structure?** AGENTS.md is the hub. Brain files are the spokes. Skills are the playbooks. Hooks are the guardrails. Each piece has one job. Add what you need, skip what you don't.

**AI-agnostic.** `AGENTS.md` and `SKILL.md` are the formats Claude Code, Codex and other coding agents read, so the same front page and the same skills load in each. The files are plain markdown. If you switch tools tomorrow, the context transfers. Only the hooks and the workflow plugin are Claude Code-specific, so in other agents the approval rules in `AGENTS.md` are the only guard.

**Multiplayer.** Share the repo with your team. Everyone gets the same context, the same skills and the same safety hooks, because `.claude/` is committed. Skills compound across sessions. Brain files stay current through commits. This is how AI context scales past one person.

---

## Credits

Curated and maintained by [Uday Kang](https://www.linkedin.com/in/uday-singh-kang/) at Martechs, built on the open-source [Company OS Starter Kit](https://github.com/Workflowsio/company-os-starter-kit) by [Dan Rosenthal](https://linkedin.com/in/dan-m-rosenthal) / [workflows.io](https://workflows.io).

The workflow commands plugin is built on [Compound Engineering](https://github.com/EveryInc/compound-engineering-plugin) by [EveryInc](https://github.com/EveryInc); the core commands (plan, work, review, swarm, brainstorm) come from their open-source foundation.

---

**[Follow Uday Kang on LinkedIn](https://www.linkedin.com/in/uday-singh-kang/)** for more on GTM systems, automation, and building with AI.

**Star this repo** if you found it useful.

# Workflow Commands Plugin

Structured workflow commands for Claude Code. Included in this starter kit.

---

## What is it?

A plugin that adds structured commands for planning, building, and reviewing work. Instead of ad-hoc prompting, you get a repeatable pipeline: plan, execute, review.

Built on top of [**Compound Engineering**](https://github.com/EveryInc/compound-engineering-plugin) by EveryInc, extended by this starter kit with:
- Tool references matched to current Claude Code capabilities (subagents, hooks, skills)
- The `/workflows:swarm` command for parallel multi-agent execution
- Prompts tuned for GTM, content, and ops use cases, not just engineering

The core workflow (plan, work, review, brainstorm, compound) is inherited from Compound Engineering. Credit to that team for building something genuinely useful.

---

## What You Get

| Command | What it does |
|---------|-------------|
| `/workflows:plan` | Turns a description into a structured implementation plan |
| `/workflows:work` | Executes a plan step by step with QA checks |
| `/workflows:review` | Multi-agent review (architecture, security, performance, simplicity) |
| `/workflows:swarm` | Full pipeline in one command with 5-20 parallel agents |
| `/workflows:brainstorm` | Explore requirements before committing to a plan |
| `/workflows:compound` | Document a win in `docs/wins/`, where the next `/workflows:plan` looks first |

---

## Installation

The plugin lives in this repo under `plugin/`, and the repo doubles as a Claude Code plugin marketplace. Copying the folder into your project does not load it; install it one of these ways.

**Option 1: Install from GitHub (recommended)**
```bash
claude plugin marketplace add automatewithuday/gtm-os-kit
claude plugin install workflows@gtm-os-kit
```

Inside a Claude Code session the same thing is `/plugin marketplace add automatewithuday/gtm-os-kit`, then `/plugin install workflows@gtm-os-kit`.

**Option 2: Load it from a local clone, for one session**
```bash
claude --plugin-dir /path/to/gtm-os-kit/plugin
```

Check it loaded with `claude plugin list`. You should see the six `/workflows:*` commands when you type `/workflows` in a session.

The commands are self-contained: they call no other plugin, skill or agent. Reviewer and researcher roles run as ordinary subagents. Anything that would leave your machine (a push, a pull request, an issue) asks you first.

Agent swarms (`/workflows:swarm`) work best on the **Claude Max plan** due to parallel token usage. On lower plans, use `/workflows:plan` then `/workflows:work` sequentially.

---

## Your First Workflow

**Plan:**
```
/workflows:plan "Build a cold email campaign targeting VP Sales at Series B SaaS"
```

**Execute:**
```
/workflows:work
```

**Review (optional):**
```
/workflows:review
```

**Or do it all at once:**
```
/workflows:swarm "Build a cold email campaign targeting VP Sales at Series B SaaS"
```

---

## Quick Reference

| I want to... | Run this |
|--------------|----------|
| Plan a feature | `/workflows:plan "description"` |
| Execute a plan | `/workflows:work` |
| Review code | `/workflows:review` |
| Do everything at once | `/workflows:swarm "description"` |
| Think before planning | `/workflows:brainstorm "topic"` |
| Document a solution | `/workflows:compound` |

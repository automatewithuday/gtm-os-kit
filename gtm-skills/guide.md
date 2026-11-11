# GTM Skills

Six starter skills for go-to-market work. Each one is a folder with a `SKILL.md` inside, the format Claude Code, Codex and other coding agents all read.

## The skills

- **outbound-copywriter** - Cold email sequences (SPARK framework, 7 power patterns, Chris Voss techniques)
- **linkedin-post-writer** - LinkedIn posts in your voice (voice calibration, 7 frameworks, 12 hooks)
- **icp-modeller** - Ideal customer profile (3-dimension scoring, tier system, validation)
- **gtm-strategist** - GTM motion design (5-layer stack, channel strategy, budget allocation)
- **discovery-prep** - Pre-call research briefs (4-layer research, objection handling, call playbooks)
- **close-campaign** - Writes a finished campaign's results into past-campaigns/ and proposes what to change

## Where they live

`gtm-skills/` is the one source of truth. Each agent looks for skills in its own folder, so that folder holds a link back here:

```bash
mkdir -p .claude/skills .agents/skills
for skill in gtm-skills/*/; do
  name=$(basename "$skill")
  ln -sfn "../../gtm-skills/$name" ".claude/skills/$name"   # Claude Code
  ln -sfn "../../gtm-skills/$name" ".agents/skills/$name"   # Codex
done
```

Edit a skill once in `gtm-skills/` and every agent gets the change. On Windows, ask your agent to create the links for you.

## How to use them

Run one by name: `/outbound-copywriter` in Claude Code, `$outbound-copywriter` in Codex. Or just ask for the job ("write a cold email for...") and the agent picks the skill from its description.

The five writing and strategy skills are templates. The first time you use one, say: "Read this skill and customize it for my business. Interview me about what needs to change." The agent asks about your ICP, voice, tools and process, then rewrites the skill in place.

## Adding your own

Create `gtm-skills/<name>/SKILL.md` with a `name`, a `description` that says when to use it, and the steps. Run the link loop above again. Or ask: "Look at how the existing skills are structured and help me create one for [your workflow]."

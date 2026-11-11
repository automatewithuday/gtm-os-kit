---
name: swarm
description: Full autonomous workflow with swarm mode -- spawns parallel agents for maximum speed. Plan, then swarm-execute, then review, then resolve the findings.
argument-hint: "[what you want to build or accomplish]"
disable-model-invocation: true
---

Swarm-enabled autonomous workflow. Run these steps in order, parallelizing where indicated. Do not stop between steps -- complete every step through to the end.

## Phase 1: Plan (Sequential)

1. `/workflows:plan $ARGUMENTS`

## Phase 2: Execute (Swarm)

2. `/workflows:work` -- **Use swarm mode**: Create a Task list from the plan and launch `general-purpose` subagents to build it in parallel. Each agent claims tasks, completes them, and moves to the next unclaimed task.

## Phase 3: Verify

3. `/workflows:review` -- run it on the completed work and wait for it to finish.

## Phase 4: Finalize

4. Resolve the review findings: work through every P1 and P2 todo in `todos/`, fix it in the deliverable, and rename the file from `pending` to `complete`. Leave P3 todos as `pending` and list them in the summary.
5. Stop before anything leaves the repo. Do not push, open a PR, send, publish, or launch a campaign. Summarise what was produced and what still needs the user's approval.
6. Output `<promise>DONE</promise>` when complete

Start with step 1 now.

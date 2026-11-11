---
name: close-campaign
description: "Records a finished campaign's results in past-campaigns/ and proposes updates to the ICP, rules and skills. Use at the end of every campaign and in the weekly review."
---

# Close Campaign

Turns a finished campaign into one file the next campaign can learn from. Without it, every campaign starts from opinion instead of results.

## When to Use

- A campaign has finished sending, or has run long enough to judge (at least 5 business days and 200 sends per variant)
- The weekly review: close last week's campaigns, then pick this week's segments
- Before writing a new sequence for an audience you have emailed before

## Steps

1. **Get the numbers.** Read the campaign's stats and replies from the sequencer if it is connected, or from the export the user gives you. Never estimate a number. If a figure is missing, write "not found".
2. **Read the replies.** Sort them into positive, neutral, negative and out-of-office. Keep two or three replies word for word, with names removed, because the buyer's own wording is what the next first line is built from.
3. **Write `past-campaigns/YYYY-MM-DD-<short-name>.md`** using the format below.
4. **Propose brain updates.** List the specific edits you would make to `company/overview.md` (ICP), `company/rules.md`, `wiki/outbound-playbook.md` and the skill that wrote the copy. Show each edit as before and after.
5. **Stop.** Wait for the owner to approve each edit before changing any of those files. Writing the campaign file in step 3 needs no approval; changing the rules does.

## Campaign File Format

```markdown
# <Campaign name>

- **Dates:** <first send> to <last send>
- **Audience:** <segment, titles, company size, list source, list size>
- **Signal:** <what triggered the outreach, or "none">
- **Angle:** <the one idea the sequence was built on>
- **Channel and tool:** <e.g., email via Instantly>

## First email

<subject line and body, exactly as sent>

## Results

| Metric | Count | Rate |
|--------|-------|------|
| Contacts emailed | | |
| Replies | | |
| Positive replies | | |
| Meetings booked | | |
| Bounces | | |
| Unsubscribes | | |

## Replies worth keeping

> <reply, word for word, name removed>

## What to repeat

## What to change

## Next 3 segments to try

<small segments, chosen from who actually replied>
```

## Rules

- Judge a campaign on positive replies and meetings, not on sends or opens.
- One file per campaign. Do not merge campaigns or overwrite an old file; add a new one.
- A campaign with bad numbers still gets a file. The failures are the useful part.

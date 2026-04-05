---
name: obsidian-memory
description: Use Obsidian vault at ~/obsidian-vault as long-term, cross-session memory. Read relevant notes before starting work to load context about the user, their projects, and past decisions. Write durable knowledge back when you learn something that will matter in future sessions. This is the persistent knowledge store — survives across conversations, tools (Claude Code / OpenCode), and devices (Mac, Linux, Android) via Git sync.
---

# Obsidian as Long-Term Memory

The user maintains an Obsidian vault at `~/obsidian-vault` that is their durable, cross-session, cross-device, cross-tool knowledge base. Use it as your long-term memory. The vault is synced to GitHub every 10 minutes automatically.

## Core Principle: Signal Over Noise

**The vault must NOT become a dump.** Every note should answer: *"Will future-me (or future-agent) be glad this was written down?"* If the answer isn't clearly yes, don't write it.

Prefer **updating existing notes** over creating new ones. Prefer **fewer, denser notes** over many sparse ones.

## Folder Framework (Guidance, Not Rigid Rules)

Use this as a loose structure. You have freedom to create subfolders and choose file names based on what fits the content — but stay within these top-level buckets so things remain findable.

```
~/obsidian-vault/
├── Profile/              # Durable facts about the user (who, preferences, role, feedback)
├── Work/<Company>/...    # Work projects, decisions, architecture, context
├── Personal/<Area>/...   # Personal projects, writing, side work, learning
└── tooling/              # Dev environment, configs, cheatsheets (already seeded)
```

**Nesting guidance:**
- Go deeper when it makes content more discoverable: `Work/Juspay/Euler/Architecture.md` is better than `Work/Juspay-Euler-Architecture.md`
- Each folder should have a short `About.md` (or `README.md`) as entry point when it has 3+ notes
- Use `[[wiki links]]` to cross-reference — this is how Obsidian discovers structure

**When the agent decides placement:** look at existing folders first (`find ~/obsidian-vault -type d`). Extend the tree naturally. Only create a new top-level bucket if the content genuinely doesn't fit Profile/Work/Personal/tooling.

## WHEN TO READ

Read Obsidian notes proactively **at the start of tasks** when context would meaningfully shape your response:

- **Always check `Profile/` briefly** if the task is substantive (more than a one-liner) — load who the user is
- **Before any work on a known project** — search vault for that project name: `rg -l "ProjectName" ~/obsidian-vault`
- **When the user references something by name** ("the Euler thing", "the portfolio agent article") — search first
- **Before recommending tools/approaches** — check if the user has stated preferences in `Profile/` or past project notes

How to discover:
```bash
# Find notes on a topic
rg -l "<keyword>" ~/obsidian-vault --type md

# List structure
find ~/obsidian-vault -type d -not -path '*/.git/*' -not -path '*/.obsidian/*'

# Or use the CLI helper
obs search "<query>"
obs list
```

**Do not** read the entire vault exhaustively. Be surgical.

## WHEN TO WRITE

Write to Obsidian **only when** the information meets **all** of these criteria:

1. **Durable** — useful across sessions, not just for the current conversation
2. **Non-derivable** — can't be recovered easily from code, git history, or a quick web search
3. **Specific to this user's context** — their decisions, preferences, project details, learnings
4. **Signal-level** — worth a future lookup

### What TO write

- **Profile facts**: role changes, tool preferences, recurring workflow patterns, explicit feedback ("I prefer X over Y because Z")
- **Project knowledge**: architectural decisions + *why*, non-obvious gotchas, domain terminology, stakeholders, constraints
- **Learnings**: debugging insights that took effort and will recur, integration quirks, environment-specific discoveries
- **Writing artifacts**: drafts, outlines, research notes for articles/blog posts the user is actively working on
- **Decisions with rationale**: "we chose X because Y, tradeoff is Z" — these are the most valuable notes

### What NOT to write

- **Conversation logs or session summaries** — not useful, creates noise
- **Status updates** ("today I did X") — unless the user explicitly wants a log
- **Code snippets that live in a repo** — link to the repo/file instead
- **Framework/library general knowledge** — that's what docs are for
- **Bug fix recipes** — the fix is in the code, the why is in the commit
- **Things already in CLAUDE.md** or project READMEs
- **Speculation or "maybe useful later"** content
- **Auto-generated TODOs or checklists** from the current session

### What to ASK before writing

- Anything involving personal/sensitive info (health, finances, relationships, internal org politics)
- Anything that looks like a secret or credential — **never write these**
- The first time you add a profile fact in a new session — confirm, then save future ones in that session without re-asking

## HOW TO WRITE

### Note structure

```markdown
---
created: YYYY-MM-DD HH:MM
updated: YYYY-MM-DD HH:MM
tags: [relevant, tags]
---

# Title

<short context/intro if useful>

## Section
content...

## Related
- [[Other Note]]
- [[Another Note]]
```

Update the `updated` field when you modify an existing note.

### Writing style

- **Lead with the fact/decision, then the why.** "We use Postgres because the team knows it" beats a paragraph of waffle.
- **Short sentences, concrete details.** Dates, names, numbers where relevant.
- **No AI-ese** — don't write "it's important to note that" or summary paragraphs. Just state the thing.
- **Link aggressively** — cross-reference related notes with `[[wiki links]]`

### When updating vs creating new

**Update existing** when:
- The new info is a refinement, correction, or addition to a note that already exists
- The topic is already covered in a note within the same folder

**Create new** when:
- The topic is distinct and would clutter an existing note
- You'd need more than ~2 sentences to integrate and the content is logically separable

**When in doubt:** update existing. Splitting can happen later.

## SYNC

After writing notes, you don't need to do anything — a launchd/systemd timer syncs to GitHub every 10 minutes. For immediate sync, run `obs sync`.

If writing many notes in one session, running `obs sync` at the end is a good habit.

## BOUNDARIES / VERIFICATION

- **First write in a session**: tell the user what you're about to save and where. Get a quick ack.
- **After the first confirmed write**: use judgment for further writes in the same session, following the criteria above.
- **Sensitive info**: always ask.
- **Bulk writes (3+ notes at once)**: list what you're planning, get approval, then write.
- **Editing existing notes**: safe to do without asking if the change is an addition/refinement. If you're removing or restructuring substantial existing content, confirm first.

## DISCOVERY HELPERS

```bash
# Quick search
obs search "keyword"

# List all notes
obs list

# Show vault git status (see what's been written recently)
obs status

# Recent sync/commit history
obs log
```

Use `rg` directly for more powerful searches:
```bash
rg -l "pattern" ~/obsidian-vault --type md
rg -B 2 -A 5 "pattern" ~/obsidian-vault --type md
```

---
name: investing-kb
description: Consult the personal investing knowledge base in the Obsidian vault (~/obsidian-vault/Personal/Investing/) before any real portfolio decision — buy/sell/hold a stock or fund, position sizing, allocation, rebalancing, evaluating a company, or judging a market/stock/macro claim from an influencer or the news. Applies the vault's source-attributed principles by status (Adopted/Candidate/Contested/Rejected), checks them against the user's profile, and logs the decision back to the vault. Not for general finance explainers unless they feed a real decision.
---

# Investing Knowledge Base

All principles, sources, profile data and decisions live in the user's **private Obsidian vault** at `~/obsidian-vault/Personal/Investing/`. This skill only holds the *method*. It deliberately contains no principles or personal data, because this config repo is public.

The purpose: **every real decision draws on the vault and the user's profile, not on ad-hoc reasoning or one source's raw claim.** It's a pilot's checklist, not an autopilot.

## Vault structure

- `About.md` — index, purpose, list of sources, source types.
- `Principles.md` — the decision inputs. Each one is source-attributed, has a status, and has an ID.
- `Analysis Framework.md` — checklist for analysing a single company.
- `Profile.md` — the user's investor profile: style, horizon, risk tolerance, allocation bands, position cap.
- `Sources/<Name>.md` — one note per person/course/channel: framework, claims, credibility caveats, running log.
- `Decisions/` — decision journal, one note per real decision. `_Template.md` gives the format.

Run `obs sync` **before reading** (another device may have edited) and **after writing**. Find things with `obs search` (see the `obsidian-memory` skill).

## Principle status

| Status | Meaning | How to use it |
|---|---|---|
| **Adopted** | User approved it after cross-sourcing or independent reasoning. | Apply directly. |
| **Candidate** | Plausible; single-sourced or not stress-tested. | One input only, and say so: "Candidate principle from [[Source]], not yet verified." |
| **Contested** | Sources disagree, or it conflicts with evidence or the profile. | Show both sides. Never pick one silently. |
| **Rejected** | Set aside (time-bound calls, anchoring, narratives). Kept for the reasoning. | Never present as guidance. Mention only if the user is leaning on it. |

**Only the user promotes.** The agent may *propose* a status change with reasoning, but never edits a status itself. Repeated use is not evidence.

## Decision procedure

Follow this order every time.

1. **Sync and load `Profile.md`.** If it's missing, unfilled or older than ~6 months, **ask** for horizon, risk tolerance, allocation bands, emergency-fund status and current allocation (%). Never assume a typical investor.
2. **Read `Principles.md`.** Name each principle you use by ID and status.
3. **Get current data**: price, valuation, latest results, tax rules (Indian LTCG/STCG), each with its date. If you can't fetch live data, say the numbers are from memory and may be stale. A source's dated claim is not current data.
4. **For a single stock**, run `Analysis Framework.md`. At minimum, run its core screener and the debt/ROCE check.
5. **Pull the relevant `Sources/*.md`** when a principle's caveats or a source's credibility flags matter. Show them; don't turn them into unqualified fact.
6. **Resize to the user.** A source's sizing ("I put 70% in X") is about *their* portfolio. Translate it into the profile's position cap and bands.
7. **Recommend**, keeping three things separate:
   - what follows from Adopted principles,
   - what leans on Candidate or Contested ones (flagged as such),
   - your own reasoning outside the KB, labelled as such.

   If principles conflict, show the conflict. If the vault has nothing relevant, say so and reason from first principles.
8. **Log it** in `Decisions/YYYY-MM-DD-<slug>.md` using the template: thesis, principles used, what would prove it wrong, review date.

## Pushback is part of the job

The user wants correction, not agreement. Flag it when:
- a move conflicts with their own profile (e.g. it breaches the position cap),
- the reasoning leans on a Rejected principle,
- a liked source is the *only* support for a big move. Following someone for a long time builds familiarity, not proof.

## Writing back

- More content from an existing source: append to that source's log. Don't create a note per post.
- New source: create `Sources/<Name>.md` and add it to `About.md`.
- New takeaway: add it to `Principles.md` as **Candidate**, with source attribution and reasoning.
- Sources disagree: mark the principle **Contested** and record both positions.
- Follow the `obsidian-memory` note style: lead with the fact, short sentences, `[[wiki links]]`.

## Boundaries

- **Nothing from the vault goes into a repo.** That covers principles, profile, amounts and decisions. They stay in the vault.
- Ask before writing absolute rupee figures or account details, even to the vault.
- Bulk writes (3+ notes/updates): list the plan and get a quick ack first.
- This is a thinking aid, not licensed advice. Don't pad answers with disclaimers, but flag when a decision has tax or legal angles worth checking with a professional.

## Using outside Claude Code (Claude.ai / ChatGPT)

Those tools can't read the vault. Add this `SKILL.md` as the skill or project instructions, and upload the current vault notes (`Principles.md`, `Analysis Framework.md`, `Profile.md`, the relevant `Sources/*.md`) as project files. Re-upload them after changes. In that mode, the agent outputs journal entries and principle proposals for the user to paste back into the vault.

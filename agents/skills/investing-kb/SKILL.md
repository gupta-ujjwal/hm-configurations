---
name: investing-kb
description: Consult the personal investing knowledge base (~/obsidian-vault/Personal/Investing/) before any real financial or portfolio decision — buy/sell/hold calls, allocation, rebalancing, evaluating a stock/sector/macro claim. Applies vetted Principles (respecting Adopted/Candidate/Rejected status, never treating a single source's opinion as settled fact) and writes new learnings, sources, and decisions back into the same KB. Trigger on "should I buy/sell X", "how should I allocate", "rebalance my portfolio", "is this a good time to Y", or any request to apply investing principles/learnings to a real decision.
---

# Investing Knowledge Base

The user's durable investing research lives at `~/obsidian-vault/Personal/Investing/` — built up from studying specific investors/sources (starting with Akshat Shrivastava, more to be added over time) and distilled into decision-usable principles. The stated purpose (set 2026-08-14): **any real portfolio-level decision draws on this KB, not on ad-hoc reasoning or a single source's raw claim.**

## Structure

- `About.md` — index, purpose, list of sources covered.
- `Principles.md` — the actual decision inputs. Each principle is source-attributed with a status:
  - **Adopted** — reasoned through independently, safe to lean on.
  - **Candidate** — plausible, not yet stress-tested or cross-sourced. Usable, but flag the uncertainty when applying it.
  - **Rejected** — considered and set aside (kept for the reasoning) — includes single-source opinions and time-bound market calls that don't belong in durable principles.
- `Sources/<Name>.md` — one note per person/channel. Background, stated framework, specific claims, credibility caveats, and a running post log.

## When to invoke

Any time the user is about to make or reason about a real financial decision: what to buy, sell, hold, how to size a position, how to allocate or rebalance, or whether to trust a specific market/stock/macro claim. Also invoke when the user wants to add a new source, log new posts/content reviewed, or update a principle's status.

## How to use it for a decision

1. **Read `Principles.md` first.** It's the thing actually meant to be consulted — don't reason from a source's raw claims directly.
2. **Check status before applying anything.** Adopted principles can be applied directly. Candidate principles can inform the decision but the response must say so explicitly ("this is a candidate principle from [[Source]], not independently verified — treat as one input, not the answer"). Never present a Rejected/opinion-tier entry (e.g. a time-bound market call) as if it were settled guidance.
3. **Pull the relevant `Sources/*.md`** when a principle's rationale, caveats, or credibility flags matter to the specific decision — e.g. if applying a principle traced to a source with known credibility incidents, surface that alongside the advice, don't launder it into unqualified fact.
4. **Cross-check against the user's actual situation** — their real holdings/risk tolerance/horizon, not the source's. A principle sized for someone else's portfolio (e.g. "I put 70% of my net worth in X") needs to be resized, not copied.
5. **Note gaps.** If `Principles.md` has an `Open gaps` section relevant to the decision (e.g. still single-sourced, no second source to cross-check), say so rather than filling the gap with confident-sounding synthesis.

## Writing back

New learnings belong in the same structure, not as new top-level files:
- New content reviewed from an existing source (more posts, videos, tweets) → append to that source's post log, don't spin up a note per post.
- A new investor/source → new `Sources/<Name>.md` file, add to `About.md`'s source list.
- A genuinely new, decision-usable takeaway → add to `Principles.md` with correct status (default to Candidate unless independently reasoned through) and source attribution.
- A real decision made using this KB, with rationale → worth a brief note if the reasoning itself is durable (why we chose X over Y) — follow the general note-writing conventions in the `obsidian-memory` skill (lead with the fact, short sentences, link with `[[wiki links]]`).

Run `obs sync` after writing so it's available across devices.

## Boundaries

- Specific dollar/rupee amounts, account numbers, or other sensitive financial specifics — ask before writing these to the vault, same as any other sensitive-info rule.
- Don't silently promote a Candidate to Adopted just because it's been applied a few times — promotion requires independent stress-testing or a second corroborating source, not repeated use.
- Bulk writes (3+ notes/updates at once) — list what's planned, get a quick ack, same as `obsidian-memory` conventions.

## Related

- Vault path: `~/obsidian-vault/Personal/Investing/`
- Relies on the same sync mechanism as the `obsidian-memory` skill — use `obs search`, `obs sync` etc. from that skill's discovery helpers.

---
name: editorial-deck
description: >
  Build clean, professional, single-file HTML slide decks in a distinctive "editorial dark"
  design language — serif display headings, mono technical accents, a warm restrained accent
  colour, and a calm engineering-memo tone that reads as credible rather than salesy. Use this
  skill whenever the user asks for an HTML presentation, slide deck, pitch deck, internal brief,
  or "slides" that should look polished and consistent — ESPECIALLY for technical, engineering,
  product, or enterprise/B2B audiences (clients, banks, leadership, investors). Also use it when
  the user references "the usual deck style", "that editorial style", "the same kind of
  presentation as before", or wants to reuse a house design system across multiple decks. Covers
  both the visual system (tokens, components, layout) and the narrative approach (audience-first
  framing, evidence-based claims, controls-alongside-capability). Do NOT use for PowerPoint/.pptx
  files (use the pptx skill) or for Word/PDF deliverables.
---

# Editorial Deck

A house style for building self-contained HTML slide decks that look like a thoughtful
engineering memo, not a vendor pitch. This skill encodes both halves of what makes these decks
work: the **visual system** (so every deck looks like it came from the same studio) and the
**narrative approach** (so the content earns trust instead of asserting it).

The output is always **one portable `.html` file** — all CSS inline, images base64-embedded,
keyboard + click navigation built in. It opens in any browser, ships as a single attachment, and
has no broken-link surface.

## When you're invoked

1. **Read `references/design-system.md` first.** It is the authoritative source for colour tokens,
   typography, spacing, and the full component library with copy-paste markup. Do not reconstruct
   tokens from memory — load the file. (The frontend-design skill's general guidance still applies;
   this skill is the specific house style layered on top.)
2. Establish **audience and purpose** before writing a single slide. The same content is framed
   very differently for engineers vs. leadership vs. a regulated enterprise client. See
   "The narrative approach" below — this is the part people skip and it's the part that matters most.
3. Build the deck in `/home/claude` first, embed any images, then copy the final file to
   `/mnt/user-data/outputs/` and present it.

## The non-negotiables (what makes it "this style")

These are the load-bearing choices. Change them and it stops being the house style.

- **Three-font system.** Fraunces (serif) for all display headings and emphasis. IBM Plex Sans
  for body. JetBrains Mono for technical tokens, labels, eyebrows, and code. Loaded from Google
  Fonts. The serif/mono contrast is the signature.
- **Dark editorial palette.** Near-black background (`#0d0d0e`), warm off-white ink (`#f3eee5`),
  and ONE warm accent — amber (`#d4a24a`) by default. The warmth is deliberate: it reads
  "financial / considered", not "tech-startup blue". Use a second functional colour (desaturated
  green `#6b9a8a`) ONLY to mark safety/control/governance content so it's visually distinct from
  capability content.
- **Restraint over decoration.** Thin 1px rules, generous whitespace, no drop shadows except on
  embedded screenshots, no gradients except a single faint radial on the cover. The deck should
  feel quiet and confident. If it looks busy, you've over-built it.
- **Eyebrows + italic serif emphasis.** Every content slide opens with a mono uppercase "eyebrow"
  (a short kicker with a leading rule). Key words in headings are wrapped in `<em>` and rendered
  in italic accent-colour serif. This is the rhythm that ties slides together.
- **Self-contained.** No external JS libraries, no build step, no localStorage. Inline `<style>`,
  inline `<script>` for navigation, base64 images. One file.

## The narrative approach

The visual system is the easy half. The decks that landed did so because of *how the content was
framed*. Apply these in order — they're roughly a decision sequence.

### 1. Frame to the audience's actual fears, not your feature list

A feature inventory ("here are nine cool things we built") is the weakest possible structure.
Find the organising question the audience is actually asking and structure around it. Some patterns:

- **Engineers** want depth and to see the real parts. Name the tools. Show the architecture.
- **Leadership** wants leverage and outcomes. Lead with what changed, not how.
- **Regulated / enterprise clients (banks, healthcare, gov)** want *control*. Every capability
  must be paired with the control that bounds it. They are asking: "Can you go faster without
  adding risk? Is this auditable? Does it survive your key people leaving?" If the deck doesn't
  proactively answer the risk questions, capability claims *reduce* trust instead of building it.

When two audiences share the room (common: engineers + risk/leadership), serve both — keep the
depth but frame it as risk-control where it genuinely is, and push raw tooling to an appendix.

### 2. Pair every capability with its control

For credibility-sensitive audiences, the strongest single move is a two-column "what it enables /
what it contains" treatment on each capability slide (see the `cc-grid` component). Capability in
the accent colour, control in the green. This says "we thought about risk as hard as you do"
without a single defensive sentence.

Add dedicated governance slides where the stakes warrant: a controls matrix, an explicit
"what AI does / what humans must do" table, and a "production-safe vs experimental" distinction.
For a regulated client these are mandatory, not optional.

### 3. Never invent numbers

If the user has real metrics, feature them. If they don't, **go qualitative — do not fabricate
percentages.** A soft number a technical evaluator can puncture is worse than an honest
qualitative claim. Only make quantitative claims that are (a) given by the user, (b) visually
demonstrable in the deck itself, or (c) directly entailed by a stated fact. When unsure whether a
claim holds, flag it to the user rather than shipping it silently.

### 4. Demote the tools

Outside an all-engineer audience, specific product names (model names, IDE, orchestrators) are
evidence, not headlines. Lead with the capability and the control; mention the tool in passing or
collect tools in a single appendix slide "for the engineers in the room". Naming tools in an
appendix builds *more* trust than scattering them through the body or hiding them entirely.

### 5. Kill the hype vocabulary

Avoid: "AI-powered", "next-generation", "revolutionary", "smart", "10X", "game-changing".
Prefer: "controlled", "bounded", "auditable", "reproducible", "contextual", "encoded",
"pressure-tested". Sophisticated audiences read hype as a tell. Let the substance carry it.

### 6. Show one end-to-end journey

A worked example walking a single real task through the whole system is more trustable than any
feature list. For control-sensitive audiences, pair each step with the control or gate that
applies to it.

## Build process

1. **Read `references/design-system.md`** for tokens and components.
2. Lock the **structure** with the user before building — a slide-by-slide outline. Restructuring
   a 15-slide deck after the fact is expensive; agreeing the arc up front is cheap.
3. Build in `/home/claude/deck.html`. Use Python string replacement for base64 image embedding
   rather than pasting giant base64 blobs inline (see `references/design-system.md` →
   "Embedding images").
4. For images: downscale to ~1600px wide, JPEG quality ~78, then base64-embed so the deck stays a
   single file. Flag any sensitive content visible in screenshots (internal URLs, names, secrets)
   and offer a redacted version.
5. Copy to `/mnt/user-data/outputs/` and `present_files`.
6. **Push back honestly.** The decks improved because each round flagged where a claim overreached,
   where a frame was weak, or where the user's instinct ("10X productivity") was the less credible
   choice. Offer the disagreement, explain the reasoning, let the user decide.

## House structure for a control-sensitive technical deck

A proven arc (adapt freely; this is a starting skeleton, not a mandate):

1. Cover — title states the *posture*, not the topic ("Controlled engineering acceleration")
2. Context / problem — frame the real tension the audience feels
3. The frame — the organising structure (e.g. pillars / phases), one overview slide
4. Capability slides — one per pillar/area, each with capability + control split
5. Controls model — the governance matrix
6. Human-in-the-loop boundaries — what's automated vs. what requires a human
7. Safe vs. experimental — explicit scoping of anything autonomous
8. End-to-end journey — one real task, every step, every gate
9. Continuity — why this doesn't depend on individuals (strong for B2B/TSP relationships)
10. Roadmap — framed as "where capability AND controls go next"
11. Closing — restate the posture
12. Appendix — tooling reference for the engineers

## Worked example

`assets/example-deck.html` is a complete, shipped deck in this exact style — a 17-slide
"controlled engineering acceleration" brief built for a regulated enterprise client. When you need
to see how a component renders in context, how the narrative arc flows, or how the SVG loop and
manifest diagrams are authored, open it and read the source. It's the canonical reference for
"what good looks like" in this house style.

## Quick reference: the test

Before shipping a deck for a high-stakes audience, ask: *if the toughest skeptic in the room asked
the single hardest question, does the deck answer it confidently in under two minutes?* If not, the
deck isn't ready — find the question and build the answer in.

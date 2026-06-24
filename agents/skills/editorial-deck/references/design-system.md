# Editorial Deck — Design System Reference

The authoritative spec for the editorial-deck house style. Copy tokens and components from here
rather than reconstructing from memory.

## Table of contents

1. Design tokens (CSS variables)
2. Typography rules
3. Deck shell & navigation (required boilerplate)
4. Component library
   - Cover slide
   - Content slide + eyebrow + heading + lede
   - Pillar header strip
   - Capability/Control split (`cc-grid`)
   - Overview grid (`pillars`)
   - Cards (`grid-2`, `grid-3`, `card`)
   - Controls matrix (`controls-grid`)
   - Can/Cannot table (`can-cannot`)
   - Change classification (`change-class`)
   - Journey timeline (`journey`)
   - Numbered flow (`flow`)
   - SVG loop diagram
   - Manifest / config diagram (`nix-diagram` pattern)
   - Embedded screenshot (`kolu-shot` pattern)
   - Appendix grid
5. Embedding images (Python workflow)
6. Responsive rules

---

## 1. Design tokens

Drop this `:root` block verbatim into the deck's `<style>`. These exact values ARE the house style.

```css
:root {
  --bg:        #0d0d0e;   /* near-black background */
  --bg-soft:   #15151a;   /* raised surfaces, cards */
  --ink:       #f3eee5;   /* warm off-white, primary text */
  --ink-soft:  #b6b1a8;   /* body text, secondary */
  --ink-dim:   #6e6a62;   /* captions, metadata */
  --rule:      #2a2a2e;   /* 1px borders, dividers */
  --accent:    #d4a24a;   /* warm amber — THE accent. capability, emphasis */
  --accent-soft:#3a2f1d;  /* accent background tint */
  --control:   #6b9a8a;   /* desaturated green — safety/control/governance ONLY */
  --control-soft: #1c2926;/* control background tint */
  --serif:     "Fraunces", ui-serif, Georgia, serif;
  --sans:      "IBM Plex Sans", ui-sans-serif, system-ui, sans-serif;
  --mono:      "JetBrains Mono", ui-monospace, "SF Mono", monospace;
}
```

**Accent swaps:** amber is the default. If a deck needs a different accent (brand reasons), swap
`--accent` and `--accent-soft` only — keep everything else. Good alternates that preserve the
"considered, not flashy" feel: deep teal `#3f9c8f`, muted terracotta `#c2693f`, slate blue
`#5a7da8`. Avoid pure/bright saturated colours. Keep `--control` distinct from `--accent`.

**Font loading** (in `<head>`):

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Fraunces:ital,opsz,wght@0,9..144,400;0,9..144,500;0,9..144,600;1,9..144,400;1,9..144,500&family=IBM+Plex+Sans:wght@300;400;500;600&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
```

---

## 2. Typography rules

- **Display headings** (`h1.title`, `h2.heading`): Fraunces, weight 400, tight letter-spacing
  (`-0.02em` to `-0.025em`), `line-height` ~1.05. Use `clamp()` for fluid sizing.
- **Emphasis**: wrap key words in `<em>` → renders italic in `--accent`. This is the signature
  move. Use it 1–2 times per heading, never more.
- **Lede** (`p.lede`): Fraunces, larger than body (~20–26px), `--ink-soft`. The standfirst under a
  heading. One per slide.
- **Body**: IBM Plex Sans, 14–17px, `--ink-soft`, `max-width: ~64ch` for readability.
- **Eyebrow**: JetBrains Mono, 11px, uppercase, `letter-spacing: 0.18em`, `--accent`, with a 24px
  leading rule via `::before`. Opens every content slide.
- **Labels / kickers inside components**: JetBrains Mono, 10px, uppercase, `letter-spacing: 0.16em`.
- **Code / technical tokens**: JetBrains Mono in a `--bg-soft` chip with a `--rule` border.

---

## 3. Deck shell & navigation (required boilerplate)

Every deck uses this exact shell. Slides are absolutely-positioned, one `.active` at a time,
cross-fade transition. Navigation: arrow keys, space, PageUp/Down, Home/End, click nav buttons,
click dots.

```css
* { box-sizing: border-box; }
html, body { height: 100%; margin: 0; padding: 0; }
body {
  background: var(--bg); color: var(--ink);
  font-family: var(--sans); font-weight: 400; font-size: 17px;
  line-height: 1.55; overflow: hidden; letter-spacing: -0.005em;
}
.deck { position: relative; width: 100vw; height: 100vh; overflow: hidden; }
.slide {
  position: absolute; inset: 0; padding: 56px 80px 80px;
  display: flex; flex-direction: column;
  opacity: 0; visibility: hidden;
  transition: opacity 380ms ease; overflow-y: auto;
}
.slide.active { opacity: 1; visibility: visible; }

/* top chrome */
.chrome-top {
  position: fixed; top: 24px; left: 80px; right: 80px;
  display: flex; justify-content: space-between; align-items: center;
  font-family: var(--mono); font-size: 11px; letter-spacing: 0.12em;
  text-transform: uppercase; color: var(--ink-dim); z-index: 5;
}
.chrome-top .brand { display: flex; align-items: center; gap: 10px; }
.chrome-top .dot { width: 6px; height: 6px; border-radius: 50%; background: var(--accent); }

/* bottom chrome: nav + dots + counter */
.chrome-bottom {
  position: fixed; bottom: 28px; left: 80px; right: 80px;
  display: flex; justify-content: space-between; align-items: center;
  font-family: var(--mono); font-size: 11px; letter-spacing: 0.08em;
  color: var(--ink-dim); z-index: 5;
}
.chrome-bottom .dots { display: flex; gap: 6px; }
.chrome-bottom .dot { width: 5px; height: 5px; border-radius: 50%; background: var(--rule); transition: background 200ms ease; cursor: pointer; }
.chrome-bottom .dot.active { background: var(--accent); }
.chrome-bottom .nav { display: flex; gap: 18px; }
.chrome-bottom .nav button {
  background: none; border: none; color: var(--ink-dim);
  font-family: var(--mono); font-size: 11px; letter-spacing: 0.08em;
  text-transform: uppercase; cursor: pointer; padding: 4px 0; transition: color 150ms ease;
}
.chrome-bottom .nav button:hover { color: var(--ink); }

/* progress bar */
.progress { position: fixed; top: 0; left: 0; right: 0; height: 2px; background: transparent; z-index: 6; }
.progress-fill { height: 100%; background: var(--accent); width: 0%; transition: width 300ms ease; }

/* layout helpers */
.slide-body { flex: 1; display: flex; flex-direction: column; justify-content: center; max-width: 1100px; }
.slide-body.wide { max-width: 1280px; }
.slide-body.top { justify-content: flex-start; }
.grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 40px; margin-top: 12px; }
.grid-3 { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 32px; margin-top: 12px; }
```

HTML scaffold (chrome lives outside `.deck`):

```html
<div class="progress"><div class="progress-fill" id="progress"></div></div>
<div class="chrome-top">
  <div class="brand"><span class="dot"></span><span>ORG · Section</span></div>
  <div>Deck subtitle</div>
</div>
<div class="deck" id="deck">
  <!-- slides go here -->
</div>
<div class="chrome-bottom">
  <div class="nav"><button id="prev">← Prev</button><button id="next">Next →</button></div>
  <div class="dots" id="dots"></div>
  <div id="counter">01 / NN</div>
</div>
```

Navigation script (drop in before `</body>`):

```html
<script>
  const slides = document.querySelectorAll('.slide');
  const dotsEl = document.getElementById('dots');
  const counter = document.getElementById('counter');
  const progress = document.getElementById('progress');
  let current = 0;
  slides.forEach((_, i) => {
    const d = document.createElement('span');
    d.className = 'dot' + (i === 0 ? ' active' : '');
    d.addEventListener('click', () => go(i));
    dotsEl.appendChild(d);
  });
  const pad = n => String(n).padStart(2, '0');
  function go(n) {
    if (n < 0 || n >= slides.length) return;
    slides[current].classList.remove('active');
    slides[n].classList.add('active');
    document.querySelectorAll('.chrome-bottom .dot').forEach((d, i) => d.classList.toggle('active', i === n));
    current = n;
    counter.textContent = `${pad(n + 1)} / ${pad(slides.length)}`;
    progress.style.width = `${((n + 1) / slides.length) * 100}%`;
  }
  document.getElementById('next').addEventListener('click', () => go(current + 1));
  document.getElementById('prev').addEventListener('click', () => go(current - 1));
  document.addEventListener('keydown', e => {
    if (['ArrowRight', ' ', 'PageDown'].includes(e.key)) { e.preventDefault(); go(current + 1); }
    else if (['ArrowLeft', 'PageUp'].includes(e.key)) { e.preventDefault(); go(current - 1); }
    else if (e.key === 'Home') go(0);
    else if (e.key === 'End') go(slides.length - 1);
  });
  progress.style.width = `${(1 / slides.length) * 100}%`;
</script>
```

The counter `NN` is auto-filled by JS from `slides.length` — no need to hardcode the total.

---

## 4. Component library

### Cover slide

```css
.eyebrow {
  font-family: var(--mono); font-size: 11px; letter-spacing: 0.18em;
  text-transform: uppercase; color: var(--accent); margin-bottom: 28px;
  display: flex; align-items: center; gap: 12px;
}
.eyebrow::before { content: ""; width: 24px; height: 1px; background: var(--accent); }
h1.title {
  font-family: var(--serif); font-weight: 400; font-size: clamp(40px, 5.4vw, 76px);
  line-height: 1.02; letter-spacing: -0.025em; margin: 0 0 32px; color: var(--ink); max-width: 18ch;
}
h1.title em { font-style: italic; color: var(--accent); font-weight: 400; }
.cover { justify-content: flex-end; padding-bottom: 110px; }
.cover .meta { font-family: var(--mono); font-size: 12px; color: var(--ink-dim); letter-spacing: 0.12em; text-transform: uppercase; margin-top: 36px; }
.cover-bg {
  position: absolute; top: 0; left: 0; right: 0; bottom: 0; pointer-events: none; z-index: 0;
  background:
    radial-gradient(ellipse at 80% 20%, rgba(212, 162, 74, 0.10), transparent 60%),
    radial-gradient(ellipse at 10% 90%, rgba(107, 154, 138, 0.04), transparent 60%);
}
.cover > * { position: relative; z-index: 1; }
```

```html
<section class="slide cover active" data-title="Cover">
  <div class="cover-bg"></div>
  <div class="eyebrow">A working brief from our team</div>
  <h1 class="title">Controlled engineering <em>acceleration.</em></h1>
  <p class="lede">One-line standfirst describing what the deck argues.</p>
  <div class="meta">Org · Internal Reference Deck</div>
</section>
```

### Content slide: heading + lede

```css
h2.heading {
  font-family: var(--serif); font-weight: 400; font-size: clamp(34px, 4vw, 54px);
  line-height: 1.05; letter-spacing: -0.02em; margin: 0 0 24px; color: var(--ink); max-width: 22ch;
}
h2.heading em { font-style: italic; color: var(--accent); }
p.lede {
  font-family: var(--serif); font-weight: 400; font-size: clamp(20px, 1.65vw, 24px);
  line-height: 1.45; color: var(--ink-soft); max-width: 60ch; margin: 0 0 22px; letter-spacing: -0.01em;
}
p { color: var(--ink-soft); max-width: 64ch; margin: 0 0 14px; }
code, .mono {
  font-family: var(--mono); font-size: 0.86em; color: var(--ink);
  background: var(--bg-soft); padding: 2px 7px; border-radius: 3px; border: 1px solid var(--rule);
}
```

### Pillar header strip

Anchors a slide to a section. Number + italic name on the left, question on the right.

```css
.pillar-header {
  display: flex; align-items: baseline; gap: 18px; margin-bottom: 16px;
  padding-bottom: 16px; border-bottom: 1px solid var(--rule); flex-wrap: wrap;
}
.pillar-header .ph-num { font-family: var(--mono); font-size: 11px; color: var(--accent); letter-spacing: 0.18em; }
.pillar-header .ph-name { font-family: var(--serif); font-style: italic; font-size: 22px; color: var(--ink); letter-spacing: -0.01em; }
.pillar-header .ph-q { font-family: var(--sans); font-size: 14px; color: var(--ink-dim); margin-left: auto; }
```

```html
<div class="pillar-header">
  <span class="ph-num">PILLAR I</span>
  <span class="ph-name">Setup</span>
  <span class="ph-q">Reproducibility as a control surface.</span>
</div>
```

### Capability / Control split (`cc-grid`) — the signature move

The most important component for credibility-sensitive decks. Left = what it enables (accent),
right = what it contains (green). Use `✓` bullets on the control side.

```css
.cc-grid { display: grid; grid-template-columns: 1.15fr 0.85fr; gap: 24px; margin-top: 8px; }
.cc-block { border: 1px solid var(--rule); background: var(--bg-soft); padding: 22px 24px; border-radius: 4px; }
.cc-block.control { border-color: var(--control-soft); background: rgba(107, 154, 138, 0.04); }
.cc-block .cc-label { font-family: var(--mono); font-size: 10px; letter-spacing: 0.16em; text-transform: uppercase; color: var(--accent); margin-bottom: 12px; }
.cc-block.control .cc-label { color: var(--control); }
.cc-block h4 { font-family: var(--serif); font-weight: 500; font-size: 20px; color: var(--ink); margin: 0 0 12px; letter-spacing: -0.01em; }
.cc-block p { font-size: 14px; line-height: 1.55; margin: 0 0 10px; }
.cc-block ul { list-style: none; padding: 0; margin: 8px 0 0; }
.cc-block ul li { font-size: 14px; color: var(--ink-soft); padding: 7px 0; border-bottom: 1px solid var(--rule); display: flex; align-items: baseline; gap: 12px; }
.cc-block ul li:last-child { border-bottom: none; }
.cc-block ul li::before { content: "→"; color: var(--accent); font-family: var(--mono); font-size: 11px; flex-shrink: 0; }
.cc-block.control ul li::before { content: "✓"; color: var(--control); }
```

```html
<div class="cc-grid">
  <div class="cc-block">
    <div class="cc-label">What it enables</div>
    <h4>Capability headline</h4>
    <ul><li>Benefit one</li><li>Benefit two</li></ul>
  </div>
  <div class="cc-block control">
    <div class="cc-label">Controls in place</div>
    <h4>What this contains</h4>
    <ul><li>Control one</li><li>Control two</li></ul>
  </div>
</div>
```

### Overview grid (`pillars`)

Four-up (or N-up) framing strip. Number, italic name, question, then a mono footer of items.

```css
.pillars { display: grid; grid-template-columns: repeat(4, 1fr); gap: 0; margin-top: 24px; border: 1px solid var(--rule); border-radius: 4px; overflow: hidden; }
.pillar { padding: 26px 22px; background: var(--bg-soft); border-right: 1px solid var(--rule); display: flex; flex-direction: column; }
.pillar:last-child { border-right: none; }
.pillar .pillar-num { font-family: var(--mono); font-size: 11px; color: var(--accent); letter-spacing: 0.18em; margin-bottom: 12px; }
.pillar .pillar-name { font-family: var(--serif); font-style: italic; font-size: 26px; color: var(--ink); margin-bottom: 10px; letter-spacing: -0.01em; line-height: 1.1; }
.pillar .pillar-q { font-size: 13.5px; color: var(--ink-soft); line-height: 1.5; margin-bottom: 18px; flex: 1; }
.pillar .pillar-controls { font-family: var(--mono); font-size: 10px; color: var(--control); letter-spacing: 0.06em; line-height: 1.7; border-top: 1px solid var(--rule); padding-top: 12px; }
```

### Cards (`card`)

Generic content block with a top rule, mono label, serif heading, body.

```css
.card { border-top: 1px solid var(--rule); padding-top: 18px; }
.card .label { font-family: var(--mono); font-size: 10px; letter-spacing: 0.16em; text-transform: uppercase; color: var(--accent); margin-bottom: 10px; }
.card h3 { font-family: var(--serif); font-weight: 500; font-size: 20px; line-height: 1.25; margin: 0 0 10px; color: var(--ink); letter-spacing: -0.01em; }
.card p { font-size: 14px; color: var(--ink-soft); line-height: 1.55; }
```

Wrap 2–4 cards in `.grid-2` or `.grid-3`.

### Controls matrix (`controls-grid`)

Governance slide: a grid of small tiles, each a named control. Green labels.

```css
.controls-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 14px; margin-top: 22px; }
.control-tile { border: 1px solid var(--rule); background: var(--bg-soft); padding: 16px 18px; border-radius: 4px; }
.control-tile .ct-label { font-family: var(--mono); font-size: 9.5px; color: var(--control); letter-spacing: 0.16em; text-transform: uppercase; margin-bottom: 8px; }
.control-tile .ct-name { font-family: var(--serif); font-size: 16px; color: var(--ink); margin-bottom: 6px; letter-spacing: -0.005em; }
.control-tile .ct-desc { font-size: 12.5px; color: var(--ink-soft); line-height: 1.5; }
```

### Can / Cannot table (`can-cannot`)

Two-column "what AI does / what humans must do". Each `<li>` gets a mono tag prefix.

```css
.can-cannot { display: grid; grid-template-columns: 1fr 1fr; gap: 0; margin-top: 18px; border: 1px solid var(--rule); border-radius: 4px; overflow: hidden; }
.can-cannot > div { padding: 24px 26px; background: var(--bg-soft); }
.can-cannot .can { border-right: 1px solid var(--rule); }
.can-cannot .cannot { background: rgba(107, 154, 138, 0.04); }
.can-cannot .cc-head { font-family: var(--mono); font-size: 11px; letter-spacing: 0.18em; text-transform: uppercase; margin-bottom: 16px; display: flex; align-items: center; gap: 10px; }
.can-cannot .can .cc-head { color: var(--accent); }
.can-cannot .cannot .cc-head { color: var(--control); }
.can-cannot ul { list-style: none; padding: 0; margin: 0; }
.can-cannot li { font-size: 14px; color: var(--ink-soft); padding: 9px 0; border-bottom: 1px dotted var(--rule); display: flex; align-items: baseline; gap: 12px; line-height: 1.5; }
.can-cannot li:last-child { border-bottom: none; }
.can-cannot .can li::before { content: "AI"; font-family: var(--mono); font-size: 9px; color: var(--accent); background: var(--accent-soft); padding: 2px 5px; border-radius: 2px; flex-shrink: 0; letter-spacing: 0.08em; }
.can-cannot .cannot li::before { content: "HUMAN"; font-family: var(--mono); font-size: 9px; color: var(--control); background: var(--control-soft); padding: 2px 5px; border-radius: 2px; flex-shrink: 0; letter-spacing: 0.08em; }
```

### Change classification (`change-class`)

Two cards distinguishing modes (e.g. production-safe vs experimental), each with a coloured left
border and a mono detail footer.

```css
.change-class { display: grid; grid-template-columns: 1fr 1fr; gap: 18px; margin-top: 22px; }
.change-card { border: 1px solid var(--rule); background: var(--bg-soft); border-radius: 4px; padding: 22px 24px; }
.change-card.experimental { border-left: 3px solid var(--accent); }
.change-card.production { border-left: 3px solid var(--control); }
.change-card .cc-band { font-family: var(--mono); font-size: 10px; letter-spacing: 0.16em; text-transform: uppercase; margin-bottom: 12px; }
.change-card.experimental .cc-band { color: var(--accent); }
.change-card.production .cc-band { color: var(--control); }
.change-card h4 { font-family: var(--serif); font-weight: 500; font-size: 19px; color: var(--ink); margin: 0 0 10px; letter-spacing: -0.01em; }
.change-card .cc-detail { font-family: var(--mono); font-size: 11px; color: var(--ink-dim); margin-top: 14px; padding-top: 12px; border-top: 1px solid var(--rule); line-height: 1.7; }
```

### Journey timeline (`journey`)

The end-to-end example. Each row: number | action (with pillar tag) | control (green tint).

```css
.journey { margin-top: 22px; border: 1px solid var(--rule); border-radius: 4px; overflow: hidden; }
.journey-step { display: grid; grid-template-columns: 64px 1fr 1fr; gap: 0; border-bottom: 1px solid var(--rule); background: var(--bg-soft); }
.journey-step:last-child { border-bottom: none; }
.journey-step .j-num { padding: 18px 0 18px 22px; font-family: var(--mono); font-size: 11px; color: var(--accent); letter-spacing: 0.16em; border-right: 1px solid var(--rule); }
.journey-step .j-action { padding: 18px 22px; border-right: 1px solid var(--rule); }
.journey-step .j-action .j-pillar { font-family: var(--mono); font-size: 9.5px; color: var(--ink-dim); letter-spacing: 0.14em; text-transform: uppercase; margin-bottom: 4px; }
.journey-step .j-action .j-what { font-family: var(--serif); font-size: 16px; color: var(--ink); letter-spacing: -0.005em; line-height: 1.3; }
.journey-step .j-control { padding: 18px 22px; background: rgba(107, 154, 138, 0.03); }
.journey-step .j-control .j-cl { font-family: var(--mono); font-size: 9.5px; color: var(--control); letter-spacing: 0.14em; text-transform: uppercase; margin-bottom: 4px; }
.journey-step .j-control .j-cdesc { font-size: 13px; color: var(--ink-soft); line-height: 1.5; }
```

### Numbered flow (`flow`)

Horizontal sequence of steps (e.g. a workflow). Equal-width, divided cells.

```css
.flow { margin-top: 24px; display: flex; align-items: stretch; gap: 0; border: 1px solid var(--rule); border-radius: 4px; overflow: hidden; }
.flow .step { flex: 1; padding: 22px 20px; border-right: 1px solid var(--rule); background: var(--bg-soft); }
.flow .step:last-child { border-right: none; }
.flow .step .step-num { font-family: var(--mono); font-size: 10px; color: var(--accent); letter-spacing: 0.16em; margin-bottom: 8px; }
.flow .step .step-name { font-family: var(--serif); font-size: 19px; color: var(--ink); margin-bottom: 6px; letter-spacing: -0.01em; }
.flow .step .step-desc { font-size: 13px; color: var(--ink-soft); line-height: 1.5; }
```

### SVG loop diagram

For cyclical processes. Hand-authored SVG using token hex values (SVG can't read CSS vars
reliably across renderers, so hardcode: bg `#15151a`, rule `#2a2a2e`, accent `#d4a24a`, ink
`#f3eee5`, dim `#6e6a62`). Boxes with mono numbers + serif-italic names, a curved return path on
top labelled in mono, straight arrows between boxes. See the Euler deck's autoloop SVG for a
complete worked example — 4 boxes at x=75/265/455/645, width 160, a bezier return
`M 725,100 C 725,25 155,25 155,100`. Pair with a legend below using `.autoloop-legend`.

### Manifest / config diagram (`nix-diagram` pattern)

For showing structured configuration as an editorial artifact (not a flowchart). A header bar
(filename + note), categorised rows (italic serif category | mono code chips), and a deploy footer
(`$ command → targets`). Good for "here's what's declared" content. Full CSS in the Euler deck
under `.nix-diagram`.

### Embedded screenshot (`kolu-shot` pattern)

```css
.kolu-shot { margin: 18px 0 0; border: 1px solid var(--rule); border-radius: 4px; overflow: hidden; background: var(--bg-soft); box-shadow: 0 12px 40px rgba(0,0,0,0.45); }
.kolu-shot img { display: block; width: 100%; height: auto; }
.kolu-shot figcaption { font-family: var(--mono); font-size: 11px; color: var(--ink-dim); letter-spacing: 0.04em; padding: 10px 16px; border-top: 1px solid var(--rule); background: var(--bg); }
```

The only place a drop shadow is allowed. Always caption screenshots in mono.

### Appendix grid

Tooling reference "for the engineers in the room". Mono tiles, dim labels.

```css
.appendix-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 18px; margin-top: 22px; }
.appendix-tile { border: 1px solid var(--rule); background: var(--bg-soft); padding: 16px 18px; border-radius: 4px; }
.appendix-tile .at-cat { font-family: var(--mono); font-size: 10px; color: var(--ink-dim); letter-spacing: 0.14em; text-transform: uppercase; margin-bottom: 8px; }
.appendix-tile .at-tools { font-family: var(--mono); font-size: 12px; color: var(--ink); line-height: 1.7; }
```

---

## 5. Embedding images (Python workflow)

Keep the deck a single portable file: downscale, compress, base64-embed. Don't paste raw base64
into the HTML by hand — use a placeholder token and substitute via Python.

```python
from PIL import Image
import base64, os

img = Image.open('/mnt/user-data/uploads/screenshot.png')
w, h = img.size
new_w = 1600
img.resize((new_w, int(h * new_w / w)), Image.LANCZOS).save('/home/claude/shot.jpg', 'JPEG', quality=78, optimize=True)
with open('/home/claude/shot.jpg', 'rb') as f:
    b64 = base64.b64encode(f.read()).decode()

# In the HTML, write:  <img src="data:image/jpeg;base64,SHOT_B64" ...>
with open('/home/claude/deck.html') as f: html = f.read()
html = html.replace('SHOT_B64', b64)
with open('/mnt/user-data/outputs/deck.html', 'w') as f: f.write(html)
```

~1600px / quality 78 keeps a full-screen screenshot legible while staying ~200KB. Always offer a
redacted version if the screenshot shows internal URLs, names, or secrets.

---

## 6. Responsive rules

Decks are built for projector/laptop (wide) but should degrade gracefully. Standard breakpoints:

```css
@media (max-width: 1100px) {
  .pillars { grid-template-columns: 1fr 1fr; }
  .cc-grid { grid-template-columns: 1fr; }
  .controls-grid, .appendix-grid { grid-template-columns: 1fr 1fr; }
}
@media (max-width: 900px) {
  .slide { padding: 56px 32px 80px; }
  .chrome-top, .chrome-bottom { left: 32px; right: 32px; }
  .grid-2, .grid-3, .change-class, .can-cannot, .pillars { grid-template-columns: 1fr; }
  .controls-grid, .appendix-grid { grid-template-columns: 1fr; }
  .flow { flex-direction: column; }
  .journey-step { grid-template-columns: 1fr; }
}
```

When stacking multi-column components on mobile, remember to swap `border-right` for
`border-bottom` on the cells so dividers still read correctly.

---

## Layout discipline

- One lede per slide. One eyebrow per slide.
- 1–2 `<em>` emphases per heading, no more.
- A slide that needs scrolling on a 16:9 projector is too dense — split it or cut the lede.
- Whitespace is a feature. When in doubt, remove an element rather than shrink everything.
- Don't introduce new colours. Accent for capability/emphasis, green for control/safety, the
  greys for everything else. That's the whole palette.

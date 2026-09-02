---
name: web-component-libraries
description: >
  Use this skill whenever building a website, web app, landing page, or any React/Next.js
  frontend that needs animated, interactive, or visually striking UI components. Provides
  guidance on when and how to use React Bits (reactbits.dev) and Skiper UI (skiper-ui.com)
  — two copy-paste component libraries that drop source code directly into your project.
  Only free components are referenced; paid components are flagged so the agent can skip them.
  Trigger on "build a website", "create a landing page", "add animations", "make it look
  better", "component library", "react components", or any web frontend task that would
  benefit from pre-built animated/interactive components.
---

# Web Component Libraries

Two copy-paste component libraries that drop source code directly into your repo.
No npm dependency — you own the code. Use them when building any React/Next.js website
to avoid reinventing animated backgrounds, scroll effects, carousels, navbars, etc.

## When to use which

### React Bits (reactbits.dev)
**Use for:** Animated backgrounds, text effects, canvas/WebGL animations, cursor effects,
and visual UI patterns. Best when you need eye-catching hero sections, ambient backgrounds,
or creative text animations.

- **License:** MIT — free forever, open source, no attribution required
- **Components:** 165+ across 4 categories: Backgrounds, Text Animations, Animations, Components
- **Stack:** React (JS or TS) + CSS or Tailwind — 4 flavors per component
- **Dependencies:** Uses `ogl`, `gsap`, and friends directly in the source (no react-bits wrapper package)
- **Compatible with:** Vite, Next.js, Astro, Remix
- **Install:** `npx shadcn@latest add @react-bits/<ComponentName>-<TS|JS>-<TW|CSS>`
  - Example: `npx shadcn@latest add @react-bits/Aurora-TS-TW`
  - Or via jsrepo: `npx jsrepo add @react-bits/Aurora-TS-TW`
- **Import after install:** `import Aurora from './Aurora';` (source lives in your `components/` dir)
- **Browse all:** https://reactbits.dev/get-started/index

#### React Bits component catalog (free — all components are free)

**Backgrounds:** Aurora, Balatro, Ballpit, Beams, ColorBends, DotField, Gradient Waves,
Grainient, Line Waves, Radar, Shape Grid, Soft Aurora, Waves

**Text Animations:** Shiny Text, Decoding Text, Gradient Text, Split Text, Blur Text,
Typography, Scroll Velocity, and more

**Animations:** Blob Cursor, Splash Cursor, Pixel Trail, Magnet Lines, Antigravity,
Ribbons, Magic Rings, Orbit Images, Metallic Paint, Fluid Cursor, and more

**Components:** Dock, Accordion, Card Spotlight, Color Picker, Tilt Card, Drag Card,
Text Shimmer, Animated Modal, and more

**Visual Editors:** Three free tools on the site to customize component props and copy
the configured code — ColorBends editor, DotField editor, and others.

---

### Skiper UI (skiper-ui.com)
**Use for:** Interactive UI patterns inspired by Apple, Vercel, Nike, and Rauno —
navbars, preloaders, scroll effects, carousels, hover interactions, and web3 UI.
Best when you need polished, production-quality interaction patterns that feel like
top-tier product websites.

- **License:** Free to use and modify (attribution required for free tier; no attribution with Pro)
- **Components:** 106+ across 15 categories
- **Stack:** Built for shadcn/ui ecosystem — Tailwind CSS, Next.js, Motion.dev (framer-motion)
- **Dependencies:** framer-motion, tailwindcss, react, clsx, tailwind-merge, lucide-react,
  react-use-measure, gsap
- **Install (free components):** `npx shadcn add @skiper-ui/skiper<NN>`
  - Example: `npx shadcn add @skiper-ui/skiper40` (installs to `src/components/ui/skiper-ui/skiper40.tsx`)
- **Import after install:** `import { Skiper40 } from '@/components/v1/skiper40';`
- **Browse all:** https://skiper-ui.com/components
- **Prerequisites:** Set up `lib/utils.ts` with `cn()` helper (clsx + tailwind-merge):
  ```ts
  import clsx, { ClassValue } from "clsx";
  import { twMerge } from "tailwind-merge";
  export function cn(...inputs: ClassValue[]) {
    return twMerge(clsx(inputs));
  }
  ```

#### Skiper UI — FREE components only (do NOT use Premium/Paid components)

**Minimal Interactions (Free):**
- skiper3 — Apple play button
- skiper4 — Theme toggle buttons
- skiper25 — Music toggle btn
- skiper26 — Theme toggle btn
- skiper37 — Animated number
- skiper40 — CssLink
- skiper58 — Text roll navigation
- skiper61 — Mouse follow animations
- skiper63 — Apple squicircle effect
- skiper64 — Gooey Effect
- skiper66 — SVG clip path mask
- skiper87 — Scroll with fade effect
- skiper99 — Animated icons 002
- skiper106 — Smooth caret input (new)

**Crazy Hover (Free):**
- skiper52 — ExpandOnHover
- skiper53 — ExpandOnHover vertical

**Scroll Effects (Free):**
- skiper16 — Card stack scroll
- skiper17 — Card stack with gsap and rotate
- skiper19 — Svg follow scroll
- skiper28 — 3D perspective text
- skiper30 — Oliver parallax
- skiper31 — Text Scroll animation
- skiper34 — Scroll images reveal 003
- skiper89 — Scroll progress 001

**Carousels (Free):**
- skiper47 — Perspective carousel
- skiper48 — Card swipe carousel
- skiper49 — Inverted perspective carousel
- skiper50 — Creative carousel 001
- skiper51 — Creative carousel 002
- skiper54 — Shadcn clipPath Carousal

**Crazy Hero (Free):**
- skiper39 — Canvas crowd

**Rauno (Free):**
- skiper41 — Progressive Blur

**Out of the box (Free):**
- skiper101 — Custom tooltip

**Development Tools (Free):**
- skiper62 — Loop animation hook
- skiper65 — Breakpoint indicator
- skiper102 — Debug Pannel

**Video Players (Free):**
- skiper67 — Video player 001

**New Releases (Free):**
- skiper106 — Smooth caret input

> **IMPORTANT:** Any component marked "Premium Component" on skiper-ui.com is PAID ($129
> one-time for all premium components). Do NOT use premium components unless the user has
> explicitly purchased a license. Premium components include (but are not limited to):
> skiper1, skiper2, skiper5, skiper6, skiper7, skiper8, skiper9, skiper10, skiper11,
> skiper12, skiper13, skiper14, skiper15, skiper18, skiper20, skiper21, skiper22,
> skiper23, skiper24, skiper27, skiper29, skiper32, skiper33, skiper35, skiper36,
> skiper38, skiper42, skiper43, skiper44, skiper45, skiper46, skiper55, skiper56,
> skiper57, skiper59, skiper60, skiper68, skiper69, skiper70, skiper71, skiper72,
> skiper73, skiper74, skiper75, skiper76, skiper77, skiper78, skiper79, skiper80,
> skiper81, skiper82, skiper83, skiper84, skiper85, skiper86, skiper88, skiper90,
> skiper91, skiper92, skiper94, skiper95, skiper96, skiper97, skiper98, skiper100,
> skiper103, skiper104, skiper105, skiper107

## Decision guide: which library for what?

| Need | Library | Example components |
|------|---------|-------------------|
| Animated hero background | React Bits | Aurora, Gradient Waves, ColorBends, Ballpit |
| Scroll-triggered reveal | Skiper UI | Card stack scroll, Scroll images reveal, Text Scroll animation |
| Interactive carousel | Skiper UI | Perspective carousel, Creative carousel, Card swipe |
| Cursor effects | React Bits | Blob Cursor, Splash Cursor, Pixel Trail |
| Text animations | React Bits | Shiny Text, Gradient Text, Decoding Text, Split Text |
| Navbar / navigation | Skiper UI | (Premium only — build custom instead) |
| Preloader / loading | Skiper UI | (Premium only — build custom instead) |
| Hover interactions | Skiper UI | ExpandOnHover, ExpandOnHover vertical |
| Parallax / scroll effects | Both | React Bits: Ribbons, Shape Grid. Skiper: Oliver parallax, 3D perspective text |
| Theme toggle | Skiper UI | Theme toggle buttons, Theme toggle btn |
| Apple-style UI patterns | Skiper UI | Apple play button, Apple squicircle effect |
| Dev tools (debug, breakpoints) | Skiper UI | Breakpoint indicator, Debug Pannel |

## Workflow when building a website

1. **Check both libraries** before writing custom animation/interaction code.
2. **Browse the sites** if unsure what's available:
   - https://reactbits.dev/get-started/index — full component grid with live previews
   - https://skiper-ui.com/components — filter by "Free" to see only free components
3. **Install via CLI** — both use the shadcn CLI to drop source files into your project:
   ```bash
   # React Bits
   npx shadcn@latest add @react-bits/Aurora-TS-TW

   # Skiper UI (free components only)
   npx shadcn add @skiper-ui/skiper40
   ```
4. **Customize the source** — the code is yours. Modify props, styles, shaders freely.
5. **When a needed component is Premium on Skiper UI**, check if React Bits has a free
   alternative. If not, build it custom rather than using paid components.
6. **Attribution:** React Bits requires no attribution (MIT). Skiper UI free tier requires
   attribution to skiper-ui.com.

## Compatibility notes

- Both libraries work with Next.js (App Router and Pages Router).
- Both use Tailwind CSS. React Bits also offers plain CSS variants.
- Skiper UI requires the shadcn/ui ecosystem setup (`components.json`, `lib/utils.ts` with `cn()`).
- React Bits works standalone — no shadcn setup required, but integrates well with it.
- For GSAP-based components, ensure `gsap` is installed: `pnpm add gsap`
- For framer-motion components (Skiper UI), ensure `framer-motion` is installed: `pnpm add framer-motion`

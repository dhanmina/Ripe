---
name: Ripe
description: A native macOS menu bar Pomodoro timer, built to Apple's own current Human Interface Guidelines
colors:
  phase-work: "#FF9500"
  phase-short-break: "#00C7BE"
  phase-long-break: "#5856D6"
  stat-complete: "#34C759"
  accent: "#0A84FF"
typography:
  ring-time:
    fontFamily: "SF Pro Rounded (system, .rounded design)"
    fontSize: "30pt"
    fontWeight: 600
  section-title:
    fontFamily: "SF Pro (system default)"
    fontSize: "13pt (headline)"
    fontWeight: 600
  stat-label:
    fontFamily: "SF Pro (system default)"
    fontSize: "11pt (subheadline)"
    fontWeight: 500
  day-caption:
    fontFamily: "SF Pro (system default)"
    fontSize: "10pt (caption2)"
    fontWeight: 400
rounded:
  control: "circle"
  bar: "capsule (fully rounded)"
spacing:
  section-gap: "16px"
  control-gap: "20px"
  popover-padding: "16px"
components:
  primary-control:
    backgroundColor: "{colors.phase-work}"
    rounded: "{rounded.control}"
  secondary-control:
    backgroundColor: "system .bordered material"
    rounded: "{rounded.control}"
---

# Design System: Ripe

## Overview

**Creative North Star: "A Control Center Module"**

Ripe has no visual world of its own — that is the decision. It borrows macOS's own menu-bar-extra grammar wholesale: the same compact glass popover, the same circular countdown ring language as Screen Time and Focus, the same SF Symbols vocabulary and system materials that Control Center's own modules use. The interface is built to disappear into the OS rather than announce a brand. There is no illustrated identity, no custom iconography, no emoji standing in for icons, and no invented color story beyond mapping the three Pomodoro phases onto semantic system colors (Orange for focus, Mint for short break, Indigo for long break) the way Apple's own Focus modes assign a hue per mode.

Two things this system explicitly rejects: any decorative material (gradients, drop shadows, glass as ornament) beyond what `MenuBarExtra`'s own `.window` style already renders for free, and any content that isn't real — no placeholder copy, no fabricated stats, no icon that isn't a genuine SF Symbol carrying its literal meaning (a timer glyph for focus, a moon for rest, a checkmark seal for a completed session).

**Key Characteristics:**
- Native chrome only — the system-provided popover material is the surface; nothing is re-drawn on top of it.
- One SF Symbol + one semantic tint per phase, applied consistently across the menu bar label, the popover header, and the countdown ring.
- Real data only: the 7-day bar chart and the "today" count reflect actual `StatsStore` values, never sample data.

## Colors

Every color is a semantic system or platform-standard hue, never a custom hex baked into a design file — the app references `Color.orange`, `Color.mint`, `Color.indigo`, `Color.green`, and `Color.accentColor` directly in code so they continue tracking the system's own light/dark and accessibility (Increase Contrast) adjustments. The hexes below are sRGB approximations for portability only.

### Primary
- **Focus Orange** (`#FF9500`, `Color.orange`): the work-phase tint — menu bar icon, popover header icon+label, countdown ring, and the primary Start/Pause button when a focus session is active.

### Secondary
- **Rest Mint** (`#00C7BE`, `Color.mint`): the short-break-phase tint, applied identically to Focus Orange's role list.
- **Deep Indigo** (`#5856D6`, `Color.indigo`): the long-break-phase tint, applied identically.

### Tertiary
- **Complete Green** (`#34C759`, `Color.green`): reserved for the "today" completion indicator's checkmark seal — the one color that never changes with phase, so completed-session feedback stays legible regardless of what phase is active.

### Neutral
- **System Accent** (`Color.accentColor`, user-configurable): fills the 7-day bar chart's non-zero days. Left as the user's own macOS accent color rather than a fixed hue, matching how native charts (Screen Time, Battery) inherit accent rather than carrying their own palette.
- **Quaternary Material** (`.quaternary` hierarchical style): the countdown ring's background track and the bar chart's zero-count day baseline.
- **Primary / Secondary label** (`.primary`, `.secondary`): all body text, following system Dynamic Type and Increase Contrast automatically.

### Named Rules
**The One Phase, One Color Rule.** A phase's tint appears in exactly three places — the menu bar icon, the popover header, and the ring — and nowhere else. No secondary UI element borrows a phase color for decoration.

## Typography

**Body Font:** SF Pro (system default; inherited automatically, never overridden except where noted)
**Display Font:** SF Pro Rounded, `.rounded` design — used once, for the countdown itself

**Character:** The countdown is the one place typography gets personality — the `.rounded` design softens the numerals the way Apple's own Clock and Timer widgets do. Everything else is plain system type at its default weight, because a utility this small has no business asserting a voice over the OS's own.

### Hierarchy
- **Ring time** (semibold, 30pt, `.rounded` design, `.monospacedDigit()`): the countdown inside the progress ring. The only display-scale text in the app.
- **Section title** (semibold, headline / 13pt): the phase name in the popover header ("Focus", "Short Break", "Long Break").
- **Stat label** (medium, subheadline / 11pt): the "N today" line.
- **Day caption** (regular, caption2 / 10pt): the single-letter weekday labels under the 7-day bars.

### Named Rules
**The Monospaced Digit Rule.** Any text that changes every second (the ring countdown, the menu bar label) uses `.monospacedDigit()` so surrounding elements never jitter as digits change width.

## Layout

Single fixed-width popover, 240pt wide, content padded 16pt on all sides, sections separated by 16pt vertical spacing (header → ring → controls → divider → stats). There is no responsive behavior to design for — a `MenuBarExtra` popover is a single fixed surface, not a page that reflows. Controls sit in one centered horizontal row, 20pt apart. The 7-day stat row spans the full content width with `maxWidth: .infinity` per-day columns so seven days always distribute evenly regardless of digit width.

## Elevation & Depth

No authored elevation. The popover's glass/blur material is entirely system-provided by `MenuBarExtra`'s `.window` style — Ripe never draws its own background, shadow, or blur on top of it. The only "depth" cue in the interface is the countdown ring's own stroke (an 8pt line, no shadow) sitting over a lighter `.quaternary` track, which reads as inset rather than raised.

### Named Rules
**The No Re-Drawn Chrome Rule.** If the system already renders a material for this context (the popover background), Ripe does not add a second layer of blur, gradient, or card fill on top of it.

## Shapes

Two shapes, used consistently: **circle** (the countdown ring and every control button — `.buttonBorderShape(.circle)`) and **capsule** (the 7-day bar chart's individual bars). No rectangles with corner radii appear anywhere; the system's own popover corner radius is inherited, never redeclared.

## Components

### Countdown Ring
- **Shape:** circle, 140×140pt, 8pt stroke width, round line cap.
- **Track:** `.quaternary` hierarchical fill, full circle, static.
- **Progress:** phase-tint gradient, trimmed from the top (`-90°` rotation) to the fraction of time remaining — a full ring at phase start, draining to empty at zero, matching Screen Time and Live Activity countdown rings.
- **Content:** the `mm:ss` remaining time, centered, rounded-design semibold.

### Controls
- **Shape:** circle (`.buttonBorderShape(.circle)`), `.bordered` style.
- **Primary (Start/Pause):** `.controlSize(.extraLarge)`, tinted with the active phase color — the visually dominant control, centered between the two secondary ones.
- **Secondary (Reset, Skip):** `.controlSize(.large)`, default system tint, icon-only (`gobackward`, `forward.end.fill`) with an `.accessibilityLabel` since no visible text names the action.
- **Quit:** `.plain` button style, `power` SF Symbol, secondary foreground color, positioned top-trailing in the header — the one control that intentionally recedes, since it's a rare, non-primary action.

### Stats Bar Chart
- **Shape:** capsule bars, 6pt wide, height scaled 3–24pt proportional to that day's count against the week's max.
- **Fill:** `Color.accentColor` for any day with ≥1 completed session, `Color.primary.opacity(0.12)` baseline for zero — real data, never a placeholder sparkline.
- **Label:** single-letter weekday caption beneath each bar (`EEEEE` date format, locale-pinned).

### "Today" Indicator
- **Icon:** `checkmark.seal.fill`, tinted Complete Green — a semantic system icon for "done," never an emoji.
- **Layout:** `Label` pairing the icon with the numeric count, left-aligned above the bar chart.

### Settings Window
- **Trigger:** a `gearshape` icon button in the popover header, `.plain` style, secondary color, positioned before Quit — same visual weight as Quit, since both are rare non-primary actions.
- **Surface:** the platform's own `Settings` scene (`Form`-based), opened via `openSettings()`. Not a popover — a real, standard preferences window, the one exception to the single-surface rule below.
- **Content:** native `Form` with `.switch`-style toggles and plain text labels, matching System Settings' own preference-row convention. Every setting the app grows lives here, never bolted onto the popover.

## Do's and Don'ts

### Do:
- **Do** use only real SF Symbols for every icon — the app ships zero emoji and zero custom-drawn icons.
- **Do** let every color reference a semantic system value (`Color.orange`, `.accentColor`, `.quaternary`) so appearance mode and accessibility settings are inherited for free.
- **Do** keep the popover's background exactly what `MenuBarExtra(.window)` renders natively — no custom material layered on top.
- **Do** give every icon-only button an `.accessibilityLabel` naming its action.
- **Do** put every preference in the Settings window's `Form`, never as a new row bolted onto the popover — the popover stays the timer surface, Settings stays the preferences surface.

### Don't:
- **Don't** introduce a fourth phase color, a gradient text treatment, or any hue that isn't one of the four semantic colors this file names.
- **Don't** add a card, panel, or bordered container inside the popover — the popover itself is the only "card" this surface gets.
- **Don't** use emoji, decorative Unicode glyphs, or stock illustration anywhere in this app.
- **Don't** add a Dock-visible surface, a second popover, or any window beyond the popover and the one Settings window.

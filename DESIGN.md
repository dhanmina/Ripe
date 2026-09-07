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

Two things this system explicitly rejects: any decorative material (gradients, drop shadows, glass as ornament) beyond what `MenuBarExtra`'s own `.window` style already renders for free, and any content that isn't real — no placeholder copy, no fabricated stats, no icon that isn't a genuine SF Symbol carrying its literal meaning (a timer glyph for focus, a moon for rest, a checkmark seal for a completed session) — with one deliberate, named exception below.

**The One Exception: The Ripening Tomato.** The app is named Ripe; the Focus-phase header icon is the one place that name gets to mean something visually. A custom-drawn tomato (`TomatoIcon`) replaces the SF Symbol in the popover header during `.work` phases only, its fill color interpolating from unripe green to tomato red as the session's real elapsed time progresses — not a mascot, not a streak, a progress indicator wearing the app's own name. The actual `MenuBarExtra` status-item icon keeps the plain SF Symbol always — that slot is a stricter AppKit-managed rendering context than a normal popover view, not worth risking on a custom shape. Short and long breaks keep their SF Symbols everywhere.

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

Single fixed-width popover, 240pt wide, content padded 16pt on all sides, sections separated by 16pt vertical spacing (header → ring → controls on the timer screen). There is no responsive behavior to design for — a `MenuBarExtra` popover is a single fixed surface, not a page that reflows. Controls sit in one centered horizontal row, 20pt apart. The 7-day stat row (on its own Stats screen, not the timer screen) spans the full content width with `maxWidth: .infinity` per-day columns so seven days always distribute evenly regardless of digit width.

## Elevation & Depth

No authored elevation. The popover's glass/blur material is entirely system-provided by `MenuBarExtra`'s `.window` style — Ripe never draws its own background, shadow, or blur on top of it. The only "depth" cue in the interface is the countdown ring's own stroke (an 8pt line, no shadow) sitting over a lighter `.quaternary` track, which reads as inset rather than raised.

### Named Rules
**The No Re-Drawn Chrome Rule.** If the system already renders a material for this context (the popover background), Ripe does not add a second layer of blur, gradient, or card fill on top of it.

## Shapes

Two shapes, used consistently: **circle** (the countdown ring and every control button — `.buttonBorderShape(.circle)`) and **capsule** (the 7-day bar chart's individual bars). No rectangles with corner radii appear anywhere; the system's own popover corner radius is inherited, never redeclared.

## Components

### Tomato Icon
- **Shape:** a flat ellipse body plus a small rounded-capsule calyx notch at top — recognizable as a tomato at menu-bar scale (16×16pt) without literal leaf detail, which wouldn't survive that size.
- **Color:** linear RGB interpolation from unripe olive-green to tomato-red, driven by progress across the *whole cycle* of sessions before a long break (completed sessions in the cycle, plus the in-flight session's own fraction, divided by sessions-before-long-break) — not per-session. Finishing session 1 of 4 shows a quarter-ripe tomato, not a fully red one; full ripeness lands exactly at the session right before a long break.
- **Scope:** replaces the phase SF Symbol in exactly one place (the popover header) and only during `.work` phases. The `MenuBarExtra` status-item icon always stays a plain SF Symbol — that AppKit-managed slot is stricter than a normal SwiftUI view and isn't worth risking on a custom shape. Short/long breaks keep `cup.and.saucer.fill` / `moon.zzz.fill` everywhere.

### Countdown Ring
- **Shape:** circle, 140×140pt, 8pt stroke width, round line cap.
- **Track:** `.quaternary` hierarchical fill, full circle, static.
- **Progress:** phase-tint gradient, trimmed from the top (`-90°` rotation) to the fraction of time remaining — a full ring at phase start, draining to empty at zero, matching Screen Time and Live Activity countdown rings.
- **Content:** the `mm:ss` remaining time, centered, rounded-design semibold.

### Controls
- **Shape:** circle (`.buttonBorderShape(.circle)`), `.bordered` style.
- **Primary (Start/Pause):** `.controlSize(.extraLarge)`, tinted with the active phase color — the visually dominant control, centered between the two secondary ones.
- **Secondary (Reset, Skip):** `.controlSize(.large)`, default system tint, icon-only (`gobackward`, `forward.end.fill`) with an `.accessibilityLabel` since no visible text names the action.
- **Quit:** `.plain` button style, `power` SF Symbol, secondary foreground color, positioned top-trailing in the header — the one control that intentionally recedes, since it's a rare, non-primary action. Tapping it swaps the popover to an in-place "Quit Ripe?" confirmation styled to read as a native alert — centered layout, a large tinted SF Symbol, bold title, secondary message, centered Cancel/Quit buttons — rather than a real system `.alert` or `.confirmationDialog`. A `MenuBarExtra(.window)` popover closes itself the instant any separate system window takes key focus, so an actual dialog silently closes the popover out from under itself; this content swap gets the alert's look without spawning a second window.

### Stats Summary Row
- **Content:** three numbers, each answering a genuinely different question — Today (right now), This Week (sum of the 7-day data), All-Time (every session ever, since `StatsStore` persists daily counts indefinitely and never prunes them — the sum was free, just never surfaced before).
- **Layout:** three equal-width columns, `.title3.weight(.semibold)` number over a `.caption2`/`.secondary` label, no icons — three side-by-side numbers with clear text labels don't need three icons competing for attention, unlike the single "Today" count that used to stand alone.
- **Named Rule: The No Fabricated Time Rule.** Ripe never shows a "time focused" stat computed by multiplying a historical session count by the *current* duration setting — past sessions may have run under a different duration, and presenting that as real elapsed time would violate the "real data only" principle. Session counts are the only metric shown because they're the only one that stays accurate regardless of later setting changes.
- **Deliberately removed:** a "ripened today" count (`today ÷ sessionsBeforeLongBreak`) was tried and cut — changing the sessions-before-long-break setting mid-day silently changed the same completed sessions' derived count, which is a correctness smell, not a real stat. The ripening concept stays exactly where it started: a visual effect on the header's tomato icon, never a number.

### Stats Bar Chart
- **Shape:** capsule bars, 6pt wide, height scaled 3–24pt proportional to that day's count against the week's max.
- **Fill:** `Color.accentColor` for any day with ≥1 completed session, `Color.primary.opacity(0.12)` baseline for zero — real data, never a placeholder sparkline.
- **Label:** single-letter weekday caption beneath each bar (`EEEEE` date format, locale-pinned).

### Stats Screen
- **Trigger:** a `chart.bar` icon button in the popover header, `.plain` style, secondary color, positioned between the phase label and the Settings gear.
- **Surface:** the same second-screen-of-the-popover pattern as Settings — `showingStats` state, `chevron.backward` back button, a "Stats" title. The timer screen no longer shows stats inline; today's count and the 7-day chart moved here entirely rather than being duplicated.

### Settings Screen
- **Trigger:** a `gearshape` icon button in the popover header, `.plain` style, secondary color, positioned before Quit.
- **Surface:** not a second window — a second screen of the same popover. `MenuBarView` holds `showingSettings` state and swaps its content between the timer view and the settings view in place, so the popover never spawns another window and the menu bar icon never needs a second click target.
- **Navigation:** a `chevron.backward` back button plus a "Settings" title replaces the timer header while settings are shown; tapping back returns to the timer view. The swap is instant, not animated — a `MenuBarExtra(.window)` popover resizes its actual window frame to fit whichever screen is showing, and animating that resize flashes the window's raw backing before the vibrant material redraws at the new size. An instant swap has no resize animation to glitch during.
- **Content:** plain `.switch`-style toggles and text labels, no `Form` chrome (no grouped-list background) since it's sharing the popover's own padding and width, not owning a window of its own. Numeric preferences (durations, sessions-before-long-break) are a small editable `TextField` per row, clamped to a safe range on entry — no separate Stepper alongside it; a Stepper's +/- arrows next to a typed field is two controls doing one job, which is what made the screen feel cluttered before this settled. The sound choice is a plain `Picker`, previewed immediately via `NSSound` on selection, matching how System Settings' own sound pickers behave.
- **Sections:** three groups — Timer, Notifications, General — each introduced by a small uppercase `.caption`/`.secondary` label (not a card or panel, just a text header) so the screen reads as three short lists instead of one dense one. Ordered by how often each is touched: Timer (revisited often) first, General's Launch at Login (set once, forgotten) last.
- **Live sync while idle:** `PomodoroEngine` observes `SettingsStore` and re-derives the current phase's duration whenever the timer is idle, so a duration change is reflected the moment you back out of Settings — not just on the next Reset or phase completion. While a phase is running or paused, a `.caption`/`.secondary` line under the duration rows reads "Duration changes apply to the next session," since the in-flight session intentionally isn't touched.
- **Silent-failure surfacing:** any preference whose write can fail outside the app's control (Launch at Login blocked by the user in System Settings, notification authorization denied) shows a `.caption` message plus a plain-style link button to the relevant System Settings pane, directly under that control — never a silent revert with no explanation.

## Do's and Don'ts

### Do:
- **Do** use only real SF Symbols for every icon, with exactly one named exception: the ripening tomato (`TomatoIcon`) during Focus phases — see Overview.
- **Do** let every color reference a semantic system value (`Color.orange`, `.accentColor`, `.quaternary`) so appearance mode and accessibility settings are inherited for free.
- **Do** keep the popover's background exactly what `MenuBarExtra(.window)` renders natively — no custom material layered on top.
- **Do** give every icon-only button an `.accessibilityLabel` naming its action.
- **Do** put every preference behind the gear icon's settings screen, never as a new row bolted onto the timer view.

### Don't:
- **Don't** introduce a fourth phase color, a gradient text treatment, or any hue that isn't one of the four semantic colors this file names.
- **Don't** add a card, panel, or bordered container inside the popover — the popover itself is the only "card" this surface gets.
- **Don't** use emoji, decorative Unicode glyphs, or stock illustration anywhere in this app. `TomatoIcon` is hand-coded geometry in the app's own color system, not stock art — it doesn't reopen this door for anything else.
- **Don't** open a second window, a second popover, or any Dock-visible surface — there is exactly one popover, with exactly one back-and-forth screen swap inside it.
- **Don't** present a system `.alert` or `.confirmationDialog` from the popover — either one opens as its own window and focus-steals the `MenuBarExtra(.window)` popover into closing itself. Any confirmation is a content swap inside the popover instead.
- **Don't** animate a transition between the popover's screens when their content heights differ — the popover's window frame resizes to match, and animating that resize flashes the window's raw backing. Screen swaps are instant.

# Product

<!-- impeccable:product-schema 1 -->

## Platform

macOS (native SwiftUI menu bar app, no Dock icon)

## Users

The developer themself, using Ripe day to day at their own Mac to run Pomodoro work/break cycles while doing other work. Single-user, personal tool — not built for distribution to strangers, so no onboarding, first-run tour, or unfamiliar-user affordances are required.

## Product Purpose

A Pomodoro timer that lives entirely in the menu bar: run 25-minute focus / 5-minute short-break / 15-minute long-break cycles, get notified (banner + sound) when a phase ends, and see how many focus sessions were completed today and over the last week. Success is a timer that's always one click away and never demands a window or Dock slot.

## Positioning

Most Pomodoro apps ask for a Dock icon, a main window, or an account. Ripe's whole surface is the menu bar item and its popover — nothing else exists. That's the entire differentiation: minimal footprint, always accessible, zero ceremony.

## Operating Context

Used while the Mac is otherwise busy with other apps — the menu bar item and its popover are glanced at, not stared at. Runs across sleep/wake (countdown is derived from a stored end-time, not a running counter, so it stays correct). No persistent main window; the popover opens on click and closes on dismiss.

## Capabilities and Constraints

- Menu bar only: `LSUIElement = YES`, no Dock icon, no `WindowGroup`.
- Controls: Start, Pause, Reset, Skip, Quit.
- Phase cycle: work (25 min) → short break (5 min), repeating; every 4th work session is followed by a long break (15 min) instead.
- Notification (system banner) + sound fires on every phase completion, including while the app is frontmost (popover open).
- Stats: count of completed focus sessions today, plus a 7-day view, persisted in `UserDefaults` across launches and locale/region changes.
- macOS-only Xcode project (`SUPPORTED_PLATFORMS = macosx`); no unit test target exists by design — verification is `xcodebuild build` plus manual click-through.
- Single window surface: the `MenuBarExtra` popover. No settings screen, no preferences window, no additional windows.

## Brand Commitments

Name is "Ripe" — chosen and fixed by the developer. No logo, wordmark, or other brand asset exists yet.

Visual system: native to the current macOS Human Interface Guidelines, not an invented custom look — no emoji, no illustrated/decorative elements. Craft bar is macOS's own menu-bar-extra surfaces (Control Center modules, Now Playing, Focus): compact, glassy native materials, SF Symbols, system typography, standard control styles.

## Evidence on Hand

No existing screenshots, user research, or usage data — this is a from-scratch personal tool. Nothing to preserve as evidence beyond the current SwiftUI implementation itself.

## Product Principles

1. The menu bar item and its popover are the entire product — no feature should require leaving that surface.
2. Never demand attention beyond what a glance affords; this is a background companion to real work, not the main event.
3. Correctness under sleep/wake and across midnight/locale changes matters more than feature breadth.
4. Single-user tool: optimize for the developer's own daily use, not onboarding or unfamiliar users.

## Accessibility & Inclusion

No project-specific accessibility requirement has been established beyond standard macOS system behavior (Dynamic Type, VoiceOver, Increase Contrast, Reduce Motion) inherited for free from native SwiftUI controls.

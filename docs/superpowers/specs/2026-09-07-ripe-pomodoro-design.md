# Ripe — macOS Menu Bar Pomodoro Timer

## Purpose

Ripe is a native macOS menu bar Pomodoro timer. It lives entirely in the
menu bar (no dock icon, no main window), lets the user run standard
25/5/15-minute work/break cycles, notifies them (banner + sound) when a
phase ends, and keeps a simple log of completed pomodoros per day.

## Scope (v1)

- Menu bar only presence (`LSUIElement`), no dock icon.
- Core timer: work (25m) → short break (5m), repeating; after 4 work
  sessions, a long break (15m) instead of a short one.
- Start / pause / reset / skip controls.
- System notification + sound when a phase ends.
- Stats: count of completed work sessions per day, shown as "today" and
  a 7-day list, persisted across launches.

Out of scope for v1: user-editable durations, multiple concurrent
timers, iCloud sync, launch-at-login toggle (can be revisited later).

## Architecture

SwiftUI `MenuBarExtra` scene as the app's only UI surface. A single
`ObservableObject` (`PomodoroEngine`) owns the state machine and
countdown; the menu bar label and popover both observe it.

The countdown is computed from a stored end-`Date`, not a decrementing
counter, so it stays correct if the Mac sleeps or the app is
backgrounded — each 1-second tick recomputes `remaining = endDate.timeIntervalSinceNow`.

### State machine

Phases: `.work`, `.shortBreak`, `.longBreak`. A `sessionsCompleted`
counter (resets every 4 work sessions) decides whether the break after
a work session is short or long.

Transitions:
- `.work` completes → log completion in `StatsStore` → if
  `sessionsCompleted % 4 == 0` go to `.longBreak`, else `.shortBreak`.
- `.shortBreak` / `.longBreak` completes → go to `.work`.
- Each transition fires a notification via `NotificationManager`.

Engine states: `idle` (not running), `running`, `paused`. Reset returns
to `.work` phase, `idle`, full duration, without touching stats.

## Components

- `RipeApp.swift` — replaces `MyApp.swift`. `MenuBarExtra` scene, no
  window group, `LSUIElement` set in project settings. Label shows an
  SF Symbol + `mm:ss` of remaining time. Opens a popover with
  `MenuBarView`.
- `PomodoroEngine.swift` — phase state machine, `start()`, `pause()`,
  `reset()`, `skip()`; publishes `phase`, `remaining`, `runState`,
  `sessionsCompleted`.
- `MenuBarView.swift` — popover content: phase label, `mm:ss`
  countdown, start/pause/reset/skip buttons, embeds `StatsView`.
- `StatsStore.swift` — persists a `[String: Int]` (ISO date → completed
  count) in `UserDefaults`; exposes `today`, `last7Days`, and
  `recordCompletion()`.
- `StatsView.swift` — small section in the popover: today's count and
  a 7-day mini list (date + count).
- `NotificationManager.swift` — requests `UNUserNotificationCenter`
  authorization on launch, posts a banner with a default sound when a
  phase ends.

Removed: `ContentView.swift`, the `Playgrounds` import/usage in the
scaffold — not needed for a menu-bar-only app.

## Data flow

1. User taps start → engine sets `runState = .running`, `endDate = now + phaseDuration`.
2. A 1-second `Timer` ticks the engine; it recomputes `remaining` from
   `endDate`.
3. When `remaining <= 0`: engine finalizes the phase (stats log if
   `.work`), asks `NotificationManager` to notify, computes the next
   phase, and — if still `running` — immediately starts it (auto-advance).
4. Pause stops the timer and freezes `remaining`; resume recomputes a
   fresh `endDate` from the frozen `remaining`.
5. Reset cancels the timer, sets phase back to `.work`, `runState = .idle`,
   full duration, leaves stats untouched.

## Error handling

- Notification permission denied: engine still transitions phases and
  updates stats normally; `NotificationManager` simply no-ops on
  posting. No error surfaced to the user beyond the native permission
  prompt.
- App relaunch mid-timer: v1 does not persist in-flight timer state —
  on relaunch the engine starts fresh at `.work` / `idle`. Only
  completed-session stats persist.

## Testing

- `xcodebuild -project Ripe.xcodeproj -scheme Ripe -configuration Debug build` for compile verification.
- Manual run: launch app, confirm menu bar item appears (no dock icon),
  exercise start/pause/reset/skip, temporarily shrink a phase duration
  to verify notification + sound fire and stats increment, confirm
  popover UI updates live.

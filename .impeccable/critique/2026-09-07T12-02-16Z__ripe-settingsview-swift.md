---
target: Settings page UX/IA research
total_score: 20
max_score: 36
na_heuristics: 10
p0_count: 1
p1_count: 2
timestamp: 2026-09-07T12-02-16Z
slug: ripe-settingsview-swift
---
Method: dual-agent (A: opus design review · B: sonnet mechanical evidence). Adaptation note: Ripe is a native macOS SwiftUI app with no DOM/browser — Assessment B skipped the skill's normal browser-injection/live-server workflow (not applicable) and substituted an exhaustive code-level mechanical pass (exact control ranges, accessibility surface, layout-width math, persistence correctness) as the closest equivalent to deterministic detector evidence. This is a methodology substitution, not a degraded single-context run — both assessments ran as isolated subagents with no visibility into each other's output.

### Design Health Score

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | 1 | Duration edits don't visibly reach the timer while idle; login-toggle state sampled once at launch; notification-authorization state surfaced nowhere |
| 2 | Match System / Real World | 3 | Phase labels match exactly; "Sound" is unscoped (sound for what?), "Sessions Before Long Break" assumes the cycle model without explaining it |
| 3 | User Control and Freedom | 2 | Back nav is clean; every write is immediate and permanent — no undo, no cancel, no restore-defaults |
| 4 | Consistency and Standards | 4 | Textbook native controls, uniform type, matches its own committed DESIGN.md spec verbatim |
| 5 | Error Prevention | 3 | Stepper-not-textfield is a real authored decision with sane ranges; loses points for zero cross-field sanity (e.g. a longer break than focus session is reachable) |
| 6 | Recognition Rather Than Recall | 2 | Values are visible, but confirming an edit "took" requires recalling the timer's prior state; row 4's meaning requires recalling the cycle model |
| 7 | Flexibility and Efficiency | 1 | Not n/a — this is the single-user power case specifically. ~25 discrete clicks to move Focus 25→50, no presets, no typed entry, no reset |
| 8 | Aesthetic and Minimalist Design | 4 | The screen's best axis — nothing decorative, nothing extra, no chrome |
| 9 | Error Recovery | 0 | Three separate silent-failure paths (duration desync, login-item denial, notification-permission denial), zero messaging on any of them |
| 10 | Help and Documentation | n/a | Honest n/a for a personal single-user tool per PRODUCT.md — but the one thing docs would carry ("what does N mean") is charged against H2/H6 instead |
| **Total** | | **20/36** | **55.6% — Acceptable** |

### Design Specificity Verdict

**LLM assessment:** This screen could be dropped unchanged into any macOS menu-bar utility with a login preference, four integers, and a sound — nothing about the composition, ordering, or control choice says "Pomodoro." The four duration rows are actually one cycle definition (25 focus × 4, interleaved with 5-min breaks, closed by a 15-min long break) but are presented as four unrelated integers with no expressed relationship, no total, no sequence. Part of this is a defensible, deliberate constraint: DESIGN.md's "One Phase, One Color" rule forbids phase tints here, and its "No Re-Drawn Chrome" rule forbids grouped-list scaffolding — so the screen is correctly austere. But austerity isn't the same as anonymity: the cheapest specificity the design system already permits (a computed "full cycle" caption, a monochrome phase symbol per row) goes unused. The screen is a faithful implementation of DESIGN.md's own spec and nothing more — executed, not designed against.

**Deterministic scan:** `detect.mjs` returned exit 0 / `[]` — not a meaningful signal here; it's built for web markup and cannot parse Swift, so the empty result means "could not evaluate," not "clean." The mechanical code pass (Assessment B) found: every Stepper's range is explicit and sane (Focus 5–90, Short Break 1–30, Long Break 5–60, Sessions 1–12); every icon-only control elsewhere in the app has an `.accessibilityLabel`, and Settings' own rows are plain stock SwiftUI controls needing no manual accessibility work; layout risk is real but narrow — "Sessions Before Long Break" has no `.lineLimit`, so it wraps (not truncates) at larger system text sizes, stranding its value; all five settings persist correctly to `UserDefaults` with defaults matching the former hardcoded 25/5/15/4; there is no reset-to-defaults affordance anywhere in the code (confirmed by grep, zero hits); and the plain-control vocabulary (vs. the app's circle-button/capsule-bar language elsewhere) is explicitly documented in DESIGN.md's own Settings Screen section, not undocumented drift.

**Visual overlays:** N/A — native SwiftUI app, no DOM/browser to inject into.

### Overall Impression

The screen is clean, restrained, and correctly native — and it quietly doesn't work as well as it looks. The headline problem isn't visual, it's functional: changing a duration while the timer sits idle doesn't change what the timer shows, with nothing telling you that. For a settings screen whose entire job is "control the thing," that's the one failure that undermines the premise.

### What's Working

1. **Stepper-over-textfield is real design, not default-taking** (`SettingsView.swift` durationRow/countRow) — the explicit ranges eliminate an entire class of invalid input, and macOS disables the bound arrow at each limit, so the constraint communicates itself with no message needed.
2. **The in-popover navigation is correct and complete** (`MenuBarView.swift` settingsHeader) — explicit back-button accessibility label, a title occupying the same slot the phase label occupies on the timer screen, a short crossfade. Reads as navigation, not a mode switch, with zero window spawned.
3. **Genuine restraint under a rule that makes restraint hard** — no `Form`, no `GroupBox`, no drawn background, one type size throughout. It obeys DESIGN.md's own no-chrome rule without a single exception, which is rarer than it sounds for a settings screen.

### Priority Issues

**[P0] Duration edits don't reach the timer while idle, and nothing says so.**
- **Why it matters:** `PomodoroEngine` only re-reads `settingsStore.duration(for:)` at init, in `reset()`, and on phase completion — not continuously. Change Focus from 25 to 50 while sitting idle at 25:00 and back out of Settings: the ring still reads 25:00. The setting took (it's persisted), but the app looks like it ignored you. This is the screen's core purpose failing invisibly, on the four most-used controls.
- **Fix:** Have `PomodoroEngine` observe `settingsStore`'s changes and, whenever `runState == .idle`, re-derive `phaseDuration`/`remaining` for the current phase. Leave an in-progress phase untouched, and add a caption in Settings when a phase is running/paused: "Applies to the next session."
- **Suggested command:** `/impeccable harden`

**[P1] Launch at Login fails silently and can show stale state.**
- **Why it matters:** `LoginItemManager.setEnabled` swallows the error and just resyncs from actual status — if macOS refuses (user blocked it in System Settings), the switch visibly flips on then snaps back with zero explanation. Separately, status is sampled once at init, so a change made in System Settings itself shows stale here until relaunch.
- **Fix:** Surface the caught error as a published property, render it under the toggle with a link to System Settings' Login Items pane, and refresh status `.onAppear`.
- **Suggested command:** `/impeccable harden`

**[P1] Notification authorization state is invisible on the one screen that configures notifications.**
- **Why it matters:** Authorization is requested once at first launch and both the result and any later denial are discarded. If the user ever denies it, every phase-end notification silently vanishes forever — and Settings keeps cheerfully offering a sound picker for a banner that will never show. This is Ripe's only output channel when the popover is closed.
- **Fix:** Publish the real `UNAuthorizationStatus`, refresh it when Settings appears, and show a caption + "Open Notification Settings" button when it isn't authorized. Give the sound-preview optional chain a `NSSound.beep()` fallback so an unresolvable named sound doesn't fail silently.
- **Suggested command:** `/impeccable harden`

**[P2] No section grouping, and the hierarchy is inverted.**
- **Why it matters:** "Launch at Login" — a once-ever, system-level preference — sits in the most prominent top slot, above the four timer values actually revisited. Two unlabeled dividers carry all the grouping.
- **Fix:** Reorder to Timer → Notifications → General (login toggle moves to the bottom), add three small `.caption`/`.secondary` section headers. DESIGN.md's no-chrome rule forbids cards/panels, not a text label.
- **Suggested command:** `/impeccable layout`

**[P2] No restore-to-defaults, and the four durations never read as one cycle.**
- **Why it matters:** Every edit persists instantly with no way back to 25/5/15/4, and nothing shows that these four numbers compose a single Pomodoro cycle — which is also the cheapest fix for the design-specificity verdict above.
- **Fix:** Add a `restoreDefaults()` on `SettingsStore` behind a plain "Restore Defaults" button, and a live-updating caption under the steppers: "Full cycle: 2h 10m."
- **Suggested command:** `/impeccable clarify`

**[P3] "Sessions Before Long Break" wraps at larger text sizes.**
- **Why it matters:** No `.lineLimit`/`.layoutPriority` on that row's title — fits at default size, wraps to two lines with the value stranded above it at larger system text sizes.
- **Fix:** `.lineLimit(1).layoutPriority(1)`, or shorten the label to "Long Break After" with the value read as "4 sessions" (also fixes the H2 clarity ding on the same row).
- **Suggested command:** `/impeccable typeset`

### Persona Red Flags

**Alex (Power User):** Wants a 50/10 deep-work week, then back to 25/5 the next. That's ~50 stepper clicks each direction with no presets, no typed entry, and — per the P0 above — no guarantee the timer even reflects the change afterward. Alex is the app's *only* user, and the screen is tuned for someone who sets it once and never returns.

**Riley (Stress Tester):** Setting "Sessions Before Long Break" to 1 mid-run makes every subsequent completion a long break, because the session counter is a launch-lifetime total that `reset()` never clears — nothing in Settings hints that N is being applied against a running total the user can't see. Setting a longer short-break than focus-session is also fully accepted; there's no cross-field sanity anywhere.

**Sam (Accessibility):** Mostly solid and verified, not assumed — plain stock controls inherit VoiceOver/keyboard support correctly, and the back button carries an explicit label. Two real breaks: the sound picker fires a preview `onChange` per item, so a VoiceOver user arrowing through the menu gets a system sound stomping the speech announcing each option (gate the preview to a committed change, not every hover); and no row declares `.accessibilityValue`, so "Sessions Before Long Break, 4" announces a bare integer with no unit.

### Minor Observations

- One setting (sound) is read live at notify-time and applies immediately; the four duration settings are cached in the engine and don't — this asymmetry is invisible to the user and worth resolving as part of the P0 fix.
- `settingsContent`'s `minHeight: 140` plus a trailing `Spacer` makes the Settings screen visibly shorter than the timer screen, so the popover resizes across the 0.2s crossfade — reads as a jump rather than a slide.
- `Picker` has no explicit `.pickerStyle`; it currently renders correctly as a native pop-up by platform default, but pinning `.pickerStyle(.menu)` makes that intentional rather than implicit.
- The `SettingsView` `#Preview` constructs a `SettingsStore()` against real `UserDefaults.standard` — interacting with the Xcode preview writes to the actual app's saved preferences.

### Questions to Consider

1. If these durations get touched twice a year, is a Stepper the right control at all — or should Settings hold two named presets ("Classic 25/5/15", "Deep Work 50/10/20") plus a Custom disclosure, turning a 50-click round trip into one click and making the screen unmistakably Pomodoro-shaped in the same move?
2. The "One Phase, One Color" rule protects the *timer* screen from decoration — but here the three duration rows literally *are* the three phases. Is a small monochrome phase symbol per row the compliant way to buy back specificity, or was the rule written for one screen and over-applied to two?

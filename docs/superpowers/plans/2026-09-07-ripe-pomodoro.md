# Ripe Pomodoro Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build Ripe, a macOS-only menu bar Pomodoro timer with start/pause/reset/skip controls, notification+sound on phase end, and a persisted daily completed-session count.

**Architecture:** SwiftUI `MenuBarExtra` app (no dock icon) driven by a single `ObservableObject` (`PomodoroEngine`) that owns a work/short-break/long-break state machine. The countdown is derived from a stored end-`Date` each second so it stays correct across sleep. `StatsStore` persists completed work-session counts per day in `UserDefaults`; `NotificationManager` posts a system notification with sound when a phase ends.

**Tech Stack:** Swift 5, SwiftUI, Combine (`ObservableObject`), `UserNotifications`, `UserDefaults`. Xcode 26.3 project, file-system-synchronized group (`Ripe/` folder — adding/removing `.swift` files there needs no `project.pbxproj` edits).

**Spec:** `docs/superpowers/specs/2026-09-07-ripe-pomodoro-design.md`

## Global Constraints

- Menu bar only: no dock icon (`LSUIElement` / `INFOPLIST_KEY_LSUIElement = YES`), no `WindowGroup`.
- macOS only — the scaffold currently targets iOS/macOS/visionOS; narrow to macosx.
- Work phase = 25 min, short break = 5 min, long break = 15 min (every 4th work session).
- Countdown computed from `endDate.timeIntervalSinceNow`, never a decrementing counter.
- No unit test target exists in the project (single `application` target only) — verification is `xcodebuild build` after every task plus a manual pass at the end, per spec's Testing section. Do not add a test target; that's out of scope.
- Bundle identifier, signing, and other existing build settings stay as scaffolded — only touch settings called out below.

---

### Task 1: Narrow project to macOS-only menu bar app, remove scaffold cruft

**Files:**
- Modify: `Ripe.xcodeproj/project.pbxproj` (project-level Debug/Release configs, target-level Debug/Release configs)
- Delete: `Ripe/ContentView.swift`
- Rename+rewrite: `Ripe/MyApp.swift` → `Ripe/RipeApp.swift`

**Interfaces:**
- Consumes: nothing (first task).
- Produces: an `@main` app entry point named `RipeApp` in `Ripe/RipeApp.swift` that later tasks will extend with a `MenuBarExtra` scene and a `PomodoroEngine` instance. For now it stays a minimal placeholder scene so the project builds after every step.

- [ ] **Step 1: Trim project-level deployment targets to macOS only**

In `Ripe.xcodeproj/project.pbxproj`, in both `000000000000000011000000 /* Debug configuration for PBXProject "Ripe" */` and `000000000000000012000000 /* Release configuration for PBXProject "Ripe" */`, delete these lines from each (they don't apply once the app is macOS-only):
```
					APPLETVOS_DEPLOYMENT_TARGET = 27.0;
					DRIVERKIT_DEPLOYMENT_TARGET = 27.0;
					IPHONEOS_DEPLOYMENT_TARGET = 27.0;
					WATCHOS_DEPLOYMENT_TARGET = 27.0;
					XROS_DEPLOYMENT_TARGET = 27.0;
```
Keep `MACOSX_DEPLOYMENT_TARGET = 27.0;` in both.

- [ ] **Step 2: Narrow the target to macOS and mark it a menu bar (agent) app**

In the same file, in `000000000000000111000000 /* Debug configuration for PBXNativeTarget "Ripe" */`, replace this block:
```
					GENERATE_INFOPLIST_FILE = YES;
					"INFOPLIST_KEY_UIApplicationSceneManifest_Generation[sdk=iphoneos*]" = YES;
					"INFOPLIST_KEY_UIApplicationSceneManifest_Generation[sdk=iphonesimulator*]" = YES;
					"INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents[sdk=iphoneos*]" = YES;
					"INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents[sdk=iphonesimulator*]" = YES;
					"INFOPLIST_KEY_UILaunchScreen_Generation[sdk=iphoneos*]" = YES;
					"INFOPLIST_KEY_UILaunchScreen_Generation[sdk=iphonesimulator*]" = YES;
					"INFOPLIST_KEY_UIStatusBarStyle[sdk=iphoneos*]" = UIStatusBarStyleDefault;
					"INFOPLIST_KEY_UIStatusBarStyle[sdk=iphonesimulator*]" = UIStatusBarStyleDefault;
					INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
					INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
					LD_RUNPATH_SEARCH_PATHS = "@executable_path/Frameworks";
					"LD_RUNPATH_SEARCH_PATHS[sdk=macosx*]" = "@executable_path/../Frameworks";
					MARKETING_VERSION = 1.0;
					PRODUCT_BUNDLE_IDENTIFIER = "devplaceholder.$(PROJECT_UNIQUE_VALUE:identifier).$(PRODUCT_NAME:rfc1034identifier)";
					PRODUCT_NAME = "$(TARGET_NAME)";
					REGISTER_APP_GROUPS = YES;
					SDKROOT = auto;
					STRING_CATALOG_GENERATE_SYMBOLS = YES;
					SUPPORTED_PLATFORMS = "iphoneos iphonesimulator macosx xros xrsimulator";
					SWIFT_APPROACHABLE_CONCURRENCY = YES;
					SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor;
					SWIFT_EMIT_LOC_STRINGS = YES;
					SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY = YES;
					SWIFT_VERSION = 5.0;
					TARGETED_DEVICE_FAMILY = "1,2,7";
```
with:
```
					GENERATE_INFOPLIST_FILE = YES;
					INFOPLIST_KEY_LSUIElement = YES;
					LD_RUNPATH_SEARCH_PATHS = "@executable_path/../Frameworks";
					MARKETING_VERSION = 1.0;
					PRODUCT_BUNDLE_IDENTIFIER = "devplaceholder.$(PROJECT_UNIQUE_VALUE:identifier).$(PRODUCT_NAME:rfc1034identifier)";
					PRODUCT_NAME = "$(TARGET_NAME)";
					REGISTER_APP_GROUPS = YES;
					SDKROOT = macosx;
					STRING_CATALOG_GENERATE_SYMBOLS = YES;
					SUPPORTED_PLATFORMS = macosx;
					SWIFT_APPROACHABLE_CONCURRENCY = YES;
					SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor;
					SWIFT_EMIT_LOC_STRINGS = YES;
					SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY = YES;
					SWIFT_VERSION = 5.0;
```
Do the identical replacement in `000000000000000112000000 /* Release configuration for PBXNativeTarget "Ripe" */`.

- [ ] **Step 3: Remove the unused scaffold view and playground**

```bash
rm Ripe/ContentView.swift
```

- [ ] **Step 4: Replace the app entry point with a minimal placeholder**

```bash
git mv Ripe/MyApp.swift Ripe/RipeApp.swift
```

Overwrite `Ripe/RipeApp.swift` with:
```swift
import SwiftUI

@main
struct RipeApp: App {
    var body: some Scene {
        MenuBarExtra("Ripe", systemImage: "leaf.fill") {
            Text("Ripe")
                .padding()
        }
    }
}
```

- [ ] **Step 5: Build to verify the trimmed, menu-bar-only project compiles**

Run: `xcodebuild -project Ripe.xcodeproj -scheme Ripe -configuration Debug build`
Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 6: Commit**

```bash
git add Ripe.xcodeproj/project.pbxproj Ripe/RipeApp.swift
git rm Ripe/ContentView.swift
git commit -m "chore: narrow Ripe to a macOS-only menu bar app scaffold"
```

---

### Task 2: PomodoroPhase enum

**Files:**
- Create: `Ripe/PomodoroPhase.swift`

**Interfaces:**
- Consumes: nothing.
- Produces: `enum PomodoroPhase: String { case work, shortBreak, longBreak }` with `var duration: TimeInterval` and `var label: String`, used by `PomodoroEngine` (Task 5), `NotificationManager` (Task 4), and the UI (Task 6).

- [ ] **Step 1: Create the phase enum**

```swift
import Foundation

enum PomodoroPhase: String {
    case work
    case shortBreak
    case longBreak

    var duration: TimeInterval {
        switch self {
        case .work: return 25 * 60
        case .shortBreak: return 5 * 60
        case .longBreak: return 15 * 60
        }
    }

    var label: String {
        switch self {
        case .work: return "Focus"
        case .shortBreak: return "Short Break"
        case .longBreak: return "Long Break"
        }
    }
}
```

- [ ] **Step 2: Build to verify it compiles**

Run: `xcodebuild -project Ripe.xcodeproj -scheme Ripe -configuration Debug build`
Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 3: Commit**

```bash
git add Ripe/PomodoroPhase.swift
git commit -m "feat: add PomodoroPhase enum with durations and labels"
```

---

### Task 3: StatsStore persistence

**Files:**
- Create: `Ripe/StatsStore.swift`

**Interfaces:**
- Consumes: nothing.
- Produces: `final class StatsStore` with `init(userDefaults: UserDefaults = .standard)`, `func recordCompletion(on date: Date = Date())`, `var today: Int`, and `var last7Days: [(date: Date, count: Int)]`. Used by `PomodoroEngine` (Task 5).

- [ ] **Step 1: Create the stats store**

```swift
import Foundation

final class StatsStore {
    private let defaultsKey = "com.ripe.dailyCompletionCounts"
    private let userDefaults: UserDefaults
    private let calendar = Calendar.current

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func recordCompletion(on date: Date = Date()) {
        var counts = loadCounts()
        counts[dayKey(for: date), default: 0] += 1
        saveCounts(counts)
    }

    var today: Int {
        loadCounts()[dayKey(for: Date())] ?? 0
    }

    var last7Days: [(date: Date, count: Int)] {
        let counts = loadCounts()
        return (0..<7).reversed().compactMap { offset -> (date: Date, count: Int)? in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: Date()) else {
                return nil
            }
            return (date, counts[dayKey(for: date)] ?? 0)
        }
    }

    private func dayKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = calendar.timeZone
        return formatter.string(from: date)
    }

    private func loadCounts() -> [String: Int] {
        userDefaults.dictionary(forKey: defaultsKey) as? [String: Int] ?? [:]
    }

    private func saveCounts(_ counts: [String: Int]) {
        userDefaults.set(counts, forKey: defaultsKey)
    }
}
```

- [ ] **Step 2: Build to verify it compiles**

Run: `xcodebuild -project Ripe.xcodeproj -scheme Ripe -configuration Debug build`
Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 3: Commit**

```bash
git add Ripe/StatsStore.swift
git commit -m "feat: add StatsStore for persisting daily completed pomodoro counts"
```

---

### Task 4: NotificationManager

**Files:**
- Create: `Ripe/NotificationManager.swift`

**Interfaces:**
- Consumes: `PomodoroPhase.label` (Task 2).
- Produces: `final class NotificationManager` with `init()` (requests notification authorization) and `func notifyPhaseEnded(finishedPhase: PomodoroPhase, nextPhase: PomodoroPhase)`. Used by `PomodoroEngine` (Task 5).

- [ ] **Step 1: Create the notification manager**

```swift
import Foundation
import UserNotifications

final class NotificationManager {
    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func notifyPhaseEnded(finishedPhase: PomodoroPhase, nextPhase: PomodoroPhase) {
        let content = UNMutableNotificationContent()
        content.title = "\(finishedPhase.label) complete"
        content.body = "Starting \(nextPhase.label.lowercased())."
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
```

- [ ] **Step 2: Build to verify it compiles**

Run: `xcodebuild -project Ripe.xcodeproj -scheme Ripe -configuration Debug build`
Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 3: Commit**

```bash
git add Ripe/NotificationManager.swift
git commit -m "feat: add NotificationManager for phase-end banner and sound"
```

---

### Task 5: PomodoroEngine state machine

**Files:**
- Create: `Ripe/PomodoroEngine.swift`

**Interfaces:**
- Consumes: `PomodoroPhase` (Task 2: `.duration`, `.label`), `StatsStore` (Task 3: `init(userDefaults:)`, `recordCompletion()`, `today`, `last7Days`), `NotificationManager` (Task 4: `init()`, `notifyPhaseEnded(finishedPhase:nextPhase:)`).
- Produces: `final class PomodoroEngine: ObservableObject` with published `phase: PomodoroPhase`, `runState: PomodoroRunState`, `remaining: TimeInterval`, `sessionsCompleted: Int`, `statsToday: Int`, `statsLast7Days: [(date: Date, count: Int)]`; methods `start()`, `pause()`, `reset()`, `skip()`. `enum PomodoroRunState { case idle, running, paused }`. Used by `RipeApp` and `MenuBarView`/`StatsView` (Task 6).

- [ ] **Step 1: Create the engine**

```swift
import Foundation
import Combine

enum PomodoroRunState {
    case idle
    case running
    case paused
}

final class PomodoroEngine: ObservableObject {
    @Published private(set) var phase: PomodoroPhase = .work
    @Published private(set) var runState: PomodoroRunState = .idle
    @Published private(set) var remaining: TimeInterval = PomodoroPhase.work.duration
    @Published private(set) var sessionsCompleted: Int = 0
    @Published private(set) var statsToday: Int
    @Published private(set) var statsLast7Days: [(date: Date, count: Int)]

    private var endDate: Date?
    private var timer: Timer?
    private let statsStore: StatsStore
    private let notificationManager: NotificationManager

    init(statsStore: StatsStore = StatsStore(), notificationManager: NotificationManager = NotificationManager()) {
        self.statsStore = statsStore
        self.notificationManager = notificationManager
        self.statsToday = statsStore.today
        self.statsLast7Days = statsStore.last7Days
    }

    func start() {
        guard runState != .running else { return }
        endDate = Date().addingTimeInterval(remaining)
        runState = .running
        if timer == nil {
            let newTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                self?.tick()
            }
            RunLoop.main.add(newTimer, forMode: .common)
            timer = newTimer
        }
    }

    func pause() {
        guard runState == .running else { return }
        runState = .paused
        timer?.invalidate()
        timer = nil
    }

    func reset() {
        timer?.invalidate()
        timer = nil
        phase = .work
        runState = .idle
        remaining = phase.duration
        endDate = nil
    }

    func skip() {
        completeCurrentPhase()
        if runState == .running {
            endDate = Date().addingTimeInterval(remaining)
        }
    }

    private func tick() {
        guard let endDate else { return }
        let secondsLeft = endDate.timeIntervalSinceNow
        if secondsLeft <= 0 {
            completeCurrentPhase()
            self.endDate = Date().addingTimeInterval(remaining)
        } else {
            remaining = secondsLeft
        }
    }

    private func completeCurrentPhase() {
        let finishedPhase = phase
        if finishedPhase == .work {
            statsStore.recordCompletion()
            sessionsCompleted += 1
            statsToday = statsStore.today
            statsLast7Days = statsStore.last7Days
            phase = sessionsCompleted % 4 == 0 ? .longBreak : .shortBreak
        } else {
            phase = .work
        }
        remaining = phase.duration
        notificationManager.notifyPhaseEnded(finishedPhase: finishedPhase, nextPhase: phase)
    }
}
```

- [ ] **Step 2: Build to verify it compiles**

Run: `xcodebuild -project Ripe.xcodeproj -scheme Ripe -configuration Debug build`
Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 3: Commit**

```bash
git add Ripe/PomodoroEngine.swift
git commit -m "feat: add PomodoroEngine state machine with sleep-safe countdown"
```

---

### Task 6: MenuBarView, StatsView, and wire into RipeApp

**Files:**
- Create: `Ripe/MenuBarView.swift`
- Create: `Ripe/StatsView.swift`
- Modify: `Ripe/RipeApp.swift` (replace Task 1's placeholder scene)

**Interfaces:**
- Consumes: `PomodoroEngine` (Task 5: `phase`, `runState`, `remaining`, `statsToday`, `statsLast7Days`, `start()`, `pause()`, `reset()`, `skip()`), `PomodoroPhase.label` (Task 2).
- Produces: `struct MenuBarView: View` (`init(engine: PomodoroEngine)`) and `struct StatsView: View` (`init(engine: PomodoroEngine)`), wired as the `MenuBarExtra` content in `RipeApp`. Terminal task — nothing downstream depends on these.

- [ ] **Step 1: Create StatsView**

```swift
import SwiftUI

struct StatsView: View {
    @ObservedObject var engine: PomodoroEngine

    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Today: \(engine.statsToday) 🍅")
                .font(.subheadline)

            HStack(spacing: 6) {
                ForEach(engine.statsLast7Days, id: \.date) { entry in
                    VStack(spacing: 2) {
                        Text("\(entry.count)")
                            .font(.caption2)
                        Text(dayFormatter.string(from: entry.date))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

#Preview {
    StatsView(engine: PomodoroEngine())
}
```

- [ ] **Step 2: Create MenuBarView**

```swift
import SwiftUI

struct MenuBarView: View {
    @ObservedObject var engine: PomodoroEngine

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(engine.phase.label)
                .font(.headline)

            Text(timeString(from: engine.remaining))
                .font(.system(size: 36, weight: .medium, design: .monospaced))

            HStack {
                Button(engine.runState == .running ? "Pause" : "Start") {
                    if engine.runState == .running {
                        engine.pause()
                    } else {
                        engine.start()
                    }
                }
                Button("Reset") { engine.reset() }
                Button("Skip") { engine.skip() }
            }

            Divider()

            StatsView(engine: engine)
        }
        .padding()
        .frame(width: 220)
    }

    private func timeString(from interval: TimeInterval) -> String {
        let total = max(0, Int(interval.rounded()))
        return String(format: "%02d:%02d", total / 60, total % 60)
    }
}

#Preview {
    MenuBarView(engine: PomodoroEngine())
}
```

- [ ] **Step 3: Wire MenuBarView into RipeApp**

Overwrite `Ripe/RipeApp.swift`:
```swift
import SwiftUI

@main
struct RipeApp: App {
    @StateObject private var engine = PomodoroEngine()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(engine: engine)
        } label: {
            Label(menuBarTitle, systemImage: menuBarSymbol)
        }
        .menuBarExtraStyle(.window)
    }

    private var menuBarTitle: String {
        let total = max(0, Int(engine.remaining.rounded()))
        return String(format: "%02d:%02d", total / 60, total % 60)
    }

    private var menuBarSymbol: String {
        switch engine.phase {
        case .work: return "leaf.fill"
        case .shortBreak, .longBreak: return "cup.and.saucer.fill"
        }
    }
}
```

- [ ] **Step 4: Build to verify it compiles**

Run: `xcodebuild -project Ripe.xcodeproj -scheme Ripe -configuration Debug build`
Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 5: Commit**

```bash
git add Ripe/MenuBarView.swift Ripe/StatsView.swift Ripe/RipeApp.swift
git commit -m "feat: wire menu bar UI and stats view into RipeApp"
```

---

### Task 7: Manual verification pass

**Files:** none (no code changes; fix-forward only if a check fails).

**Interfaces:**
- Consumes: the fully wired app from Task 6.
- Produces: nothing — verification gate before calling the feature done.

- [ ] **Step 1: Launch the app**

```bash
open -a /Users/dhanmina/Library/Developer/Xcode/DerivedData/Ripe-*/Build/Products/Debug/Ripe.app 2>/dev/null || xcodebuild -project Ripe.xcodeproj -scheme Ripe -configuration Debug -derivedDataPath build build && open build/Build/Products/Debug/Ripe.app
```
Expected: a leaf icon with `25:00` appears in the menu bar; no Dock icon appears; no other window opens.

- [ ] **Step 2: Exercise controls**

Click the menu bar item, click Start — verify the countdown ticks down and the menu bar label updates every second. Click Pause — verify it freezes. Click Start again — verify it resumes from the frozen value, not from 25:00.

- [ ] **Step 3: Verify phase transition, notification, sound, and stats**

Click Skip once. Expected: a macOS notification banner appears ("Focus complete" / "Starting short break."), a sound plays, the phase label changes to "Short Break", the countdown resets to `05:00`, and "Today: 1 🍅" appears in the stats section.

- [ ] **Step 4: Verify Reset**

Click Reset at any point. Expected: phase returns to "Focus", countdown returns to `25:00`, controls return to idle (button reads "Start"), and the stats count from Step 3 is unchanged (Reset doesn't erase stats).

- [ ] **Step 5: Verify long-break cadence**

Click Skip repeatedly through 4 total work-session completions (use Skip on each break too, to move quickly). Expected: after the 4th work session completes, the phase goes to "Long Break" (`15:00`) instead of "Short Break", and "Today" count reads 4.

- [ ] **Step 6: Quit and relaunch**

Quit the app (menu bar item's window has no quit button in v1 — use `killall Ripe` or Activity Monitor), relaunch it. Expected: menu bar item reappears, timer state is fresh (`25:00`, "Focus", idle) but "Today" stat still shows 4 (stats persisted, timer state did not — matches spec's Error Handling section).

If any expectation fails, treat it as a bug: use systematic-debugging to find root cause in the relevant task's file, fix, re-run the build, re-verify, then commit the fix separately.

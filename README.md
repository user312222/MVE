# NEURO·V2

**Human v1.0 → v2.0** — a futuristic SwiftUI app that helps you plan your life and train your brain. At the center is a live 3D brain simulation: see in real time which task drives which brain region, and by what percentage.

> ⚠️ Region percentages are **rough estimates** based on neuroscience literature, not medical measurements. This app is not medical advice.

## Features

- **3D brain simulation:** ~900 neurons with connections and traveling signal pulses. Drag to rotate, tap a region to focus on it.
- **10 brain regions:** prefrontal, motor, sensory, parietal, occipital, temporal, hippocampus, amygdala, cerebellum, brainstem. Each one shows a live `%` label.
- **Task library:** 14 tasks (deep work, reading, language learning, cardio, meditation, music, sleep…). Selecting one moves the regions to that task's activation levels.
- **Daily plan:** add/remove tasks, mark them done, and press **Simulate Day** to watch your whole day play out on the brain.
- **Evolution progress:** Focus, Memory, Creativity, Body, and Emotion skills earn XP; when they all fill up, you reach `v2.00`.
- **Plan analysis:** finds the least-engaged region in your plan and suggests the task that works it best.
- **Feedback:** haptics (iOS and Mac trackpad) and optional procedurally generated ambient sound.

> The in-app UI is currently in Turkish.

## Requirements

- Xcode (project uses `objectVersion 90`, targeting iOS/macOS/visionOS 27.0)
- No external dependencies

## Running

1. Open `MVE.xcodeproj` in Xcode.
2. Select the `MVE` scheme and a destination (iPhone, iPad, or Mac).
3. Press ▶ to run.

To build from the command line:

```bash
xcodebuild -project MVE.xcodeproj -scheme MVE -destination 'generic/platform=macOS' build
```

## Usage

| Action | Result |
|---|---|
| Pick a task from the library | The brain switches to that task's activation map |
| Drag the brain | 3D rotation (eases back to the side view on release) |
| Tap a region | Region info card + the tasks that engage it most |
| **Simulate Day** | Plays the plan in order; completed tasks award XP |
| Circle on a plan card | Mark task done / undo |
| Right-click / long-press a plan card | Delete |
| Speaker icon | Toggle ambient sound |

The layout adapts to screen width: 3 columns on Mac and iPad, and *Brain / Tasks / Status* tabs on iPhone.

## Project structure

```
MVE/
├── MyApp.swift        App entry point
├── ContentView.swift  Wide / compact layouts
├── Models.swift       Regions, skills, tasks and activation data, theme
├── Store.swift        App state (@Observable): plan, XP, simulation, focus
├── Brain.swift        Neuron network generation, 3D projection, Canvas rendering, gestures
├── UI.swift           Panels: library, status, plan, banner
└── Feedback.swift     Haptics and ambient sound (AVAudioEngine)
```

## Customizing the data

- **Add a task / tweak percentages:** `BrainTask.all` in `Models.swift`. Each task's `activation` dictionary holds a 0–1 value per region.
- **Region position / label placement:** `center`, `radius`, and `labelPos` on the `Region` enum.
- **Evolution speed:** `skillCap` in `Store.swift` (default 600 XP per skill).

The plan and XP are stored in `UserDefaults`; completion checkmarks reset every new day.

## Roadmap

- [ ] HealthKit (sleep, steps, HRV) so the brain reacts to real data
- [ ] SwiftData for history, weekly reports, and charts
- [ ] Brain mini-games (n-back, Stroop, reaction time)
- [ ] Streaks, notifications, and level-up animations
- [ ] Widget / Live Activity (needs a separate extension target)
- [ ] AI coach
- [ ] iCloud sync and Apple Watch

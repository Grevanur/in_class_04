# In-Class Activity 04 — Pulse Forge Workout Tracker

**Team:** Solo Studio  
**Member:** Gowtham Revanur — Panther ID 002574540  
**Theme:** Workout Challenge Tracker

## How to Run

```bash
flutter pub get
flutter run
flutter test
flutter analyze
```

## Build Challenge

Pulse Forge turns the approved Workout Challenge Tracker concept into a tactile
training console. Four custom controls record squats, push-ups, lunges, and
completed sets. The dashboard updates reps, sets, progress, goal completion,
status text, intensity, and theme without any external state package.

State variables:

- `reps`: shared dashboard counter updated by exercise controls.
- `sets`: number of completed sets.
- `dailyGoal`: target used to compute progress.
- `streak`: displayed training streak.
- `goalCompleted`: derived completion condition that reveals the success message.
- `intensity`: slider-controlled training intensity.
- `lastExercise`: latest action shown in the status banner.
- `isDarkMode`: root-owned theme state.

The changed UI state is demonstrated by pressing an exercise control: the reps
metric, progress bar, status banner, and goal state update together.

## State Defense

`WorkoutChallengeApp` is a `StatefulWidget` because it owns the global
`isDarkMode` value. It passes the current theme and a callback into
`WorkoutDashboard`, so the parent remains the single source of truth for
brightness. `WorkoutDashboard` is also stateful because its mutable workout
values are shared by multiple controls and the progress card.

`_ProgressCard`, `_Metric`, and the presentation-only pieces are
`StatelessWidget`s because they render values received through constructor
parameters. `TactileExerciseButton` is a `StatefulWidget` because each
button owns its private `isPressed` value. This prevents one button's press
animation from leaking into every other button.

Each meaningful mutation is wrapped in `setState`: exercise actions update
reps/status/goal completion, finishing a set updates sets, slider movement
updates intensity, and the root callback updates theme. The resulting rebuild
scope is clear: the dashboard rebuilds shared metrics, while each tactile
button rebuilds its own press animation.

## Round 1 Findings

The six widget-identification scenarios distinguish immutable presentation
widgets from widgets that own mutable lifecycle state. Correct defenses:

1. `StatelessWidget` is appropriate when output depends only on immutable inputs.
2. `StatefulWidget` owns values that change during the widget lifetime.
3. `setState` schedules a rebuild for the affected state subtree.
4. A `GestureDetector` can separate `onTapDown`, `onTapUp`, and `onTapCancel`.
5. Parent callbacks lift shared state without giving children global ownership.
6. A local button flag prevents state scope collisions between sibling controls.

## Round 2 Bug Fixes

1. Move `isPressed` from the shared screen into each button's private State.
2. Wrap the slider mutation in `setState(() => powerLevel = newVal)`.
3. Use small `Offset(2, 2)` shadows for the pressed state and large
   `Offset(8, 8)` shadows for the elevated state.
4. Trigger the action in `onTapUp`, after visual press-down, and restore state
   in both `onTapUp` and `onTapCancel`.

## Graduate Extension — ValueNotifier Comparison

`setState` is a strong fit here because the dashboard has a small, cohesive
state model and the mutation methods are easy to read beside the widgets they
update. A `ValueNotifier<WorkoutState>` would move the state object outside
the widget's private fields and make the current value observable through a
`ValueListenableBuilder`. That can make ownership more explicit when a small
value is shared by a focused subtree, while `setState` keeps this classroom
example lower ceremony.

The rebuild scope differs: `setState` rebuilds the `WorkoutDashboard`
subtree, whereas separate `ValueNotifier`s or a single
`ValueNotifier<WorkoutState>` can rebuild only the `ValueListenableBuilder`
that listens to the changed value. Testability also improves when a notifier
owns a pure state object, because tests can change the value without needing
to simulate a widget event. For a larger app with several independently
updating panels, I would choose `ValueNotifier` for the shared workout
summary while keeping each tactile button's transient press animation local.

Pseudocode application:

```dart
final workout = ValueNotifier(WorkoutState(reps: 0, sets: 0));

void recordExercise() {
  workout.value = workout.value.copyWith(
    reps: workout.value.reps + 5,
  );
}

ValueListenableBuilder<WorkoutState>(
  valueListenable: workout,
  builder: (_, state, __) => ProgressCard(state: state),
);
```

Source: [Flutter ValueNotifier API](https://api.flutter.dev/flutter/foundation/ValueNotifier-class.html)

## Evidence Files

- `evidence/TeamSoloStudio-Demo.gif`: an 18-second capture of live exercise
  actions, changing progress, goal completion, set logging, and theme change.
- `evidence/TeamSoloStudio-Round2-BugProof.png`: live fixed behavior, the
  visible BUG #2 trace, and the team/member identifier in one frame.

The Round 1 score screenshot is intentionally not synthesized. Capture it from
the completed in-class Widget Identification Blitz with your team's actual
score and findings visible before uploading it to Canvas.
- `main.dart`

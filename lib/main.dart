import 'package:flutter/material.dart';

// In-Class Activity 04: Flutter Widget Wars & State Destruction Derby
// Team: Solo Studio | Gowtham Revanur | Panther ID: 002574540
// Theme: Workout Challenge Tracker

void main() => runApp(const WorkoutChallengeApp());

class WorkoutChallengeApp extends StatefulWidget {
  const WorkoutChallengeApp({super.key});
  @override
  State<WorkoutChallengeApp> createState() => _WorkoutChallengeAppState();
}

class _WorkoutChallengeAppState extends State<WorkoutChallengeApp> {
  bool isDarkMode = true;
  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF8B5CF6),
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
    );
    return MaterialApp(
      title: 'Pulse Forge Workout Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorScheme: scheme),
      home: WorkoutDashboard(
        isDark: isDarkMode,
        onToggleTheme: () => setState(() => isDarkMode = !isDarkMode),
      ),
    );
  }
}

class WorkoutDashboard extends StatefulWidget {
  const WorkoutDashboard({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });
  final bool isDark;
  final VoidCallback onToggleTheme;
  @override
  State<WorkoutDashboard> createState() => _WorkoutDashboardState();
}

class _WorkoutDashboardState extends State<WorkoutDashboard> {
  int reps = 0;
  int sets = 0;
  int dailyGoal = 25;
  int streak = 4;
  bool goalCompleted = false;
  double intensity = 65;
  String lastExercise = 'READY FOR YOUR FIRST SET';

  int get progress => (reps / dailyGoal * 100).round().clamp(0, 100);

  void _recordExercise(String exercise, {int amount = 5}) {
    setState(() {
      reps = (reps + amount).clamp(0, 999);
      lastExercise = '$exercise COMPLETE';
      goalCompleted = reps >= dailyGoal;
      if (goalCompleted && sets == 0) sets = 1;
    });
  }

  void _finishSet() {
    setState(() {
      sets++;
      lastExercise = 'SET $sets LOGGED';
      goalCompleted = reps >= dailyGoal;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final background = widget.isDark
        ? const Color(0xFF12121B)
        : const Color(0xFFF2F0FA);
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('PULSE FORGE'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            key: const Key('theme-toggle'),
            tooltip: 'Toggle theme',
            onPressed: widget.onToggleTheme,
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            children: [
              const Text(
                'SOLO STUDIO • GOWTHAM REVANUR • 002574540',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7,
                ),
              ),
              const SizedBox(height: 10),
              _ProgressCard(
                reps: reps,
                sets: sets,
                progress: progress,
                goalCompleted: goalCompleted,
              ),
              const SizedBox(height: 18),
              Text(
                lastExercise,
                key: const Key('status-text'),
                style: TextStyle(
                  color: goalCompleted ? Colors.greenAccent : colors.secondary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              const _BugFixTrace(),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  TactileExerciseButton(
                    key: const Key('squat-button'),
                    icon: Icons.accessibility_new,
                    label: 'SQUATS',
                    accentColor: Colors.orangeAccent,
                    isDark: widget.isDark,
                    onPressed: () => _recordExercise('SQUATS'),
                  ),
                  TactileExerciseButton(
                    key: const Key('pushup-button'),
                    icon: Icons.fitness_center,
                    label: 'PUSH-UPS',
                    accentColor: Colors.cyanAccent,
                    isDark: widget.isDark,
                    onPressed: () => _recordExercise('PUSH-UPS'),
                  ),
                  TactileExerciseButton(
                    key: const Key('lunge-button'),
                    icon: Icons.directions_run,
                    label: 'LUNGES',
                    accentColor: Colors.pinkAccent,
                    isDark: widget.isDark,
                    onPressed: () => _recordExercise('LUNGES'),
                  ),
                  TactileExerciseButton(
                    key: const Key('set-button'),
                    icon: Icons.check_circle_outline,
                    label: 'FINISH SET',
                    accentColor: Colors.greenAccent,
                    isDark: widget.isDark,
                    onPressed: _finishSet,
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Card(
                color: widget.isDark ? const Color(0xFF211D31) : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('TRAINING INTENSITY'),
                          Text(
                            '${intensity.toInt()}%',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Slider(
                        key: const Key('intensity-slider'),
                        value: intensity,
                        min: 0,
                        max: 100,
                        onChanged: (value) =>
                            setState(() => intensity = value),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('DAILY GOAL: $dailyGoal REPS'),
                          Text('STREAK: $streak DAYS'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Dashboard state is lifted only where it is shared; press state stays inside each button.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.reps,
    required this.sets,
    required this.progress,
    required this.goalCompleted,
  });
  final int reps;
  final int sets;
  final int progress;
  final bool goalCompleted;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: colors.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Metric(label: 'REPS', value: '$reps'),
                _Metric(label: 'SETS', value: '$sets'),
                _Metric(label: 'PROGRESS', value: '$progress%'),
              ],
            ),
            const SizedBox(height: 18),
            LinearProgressIndicator(value: progress / 100),
            if (goalCompleted) ...[
              const SizedBox(height: 12),
              const Text(
                'GOAL CRUSHED!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BugFixTrace extends StatelessWidget {
  const _BugFixTrace();

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          '// BUG #2 fixed: setState updates shared dashboard state',
          style: TextStyle(fontFamily: 'monospace', fontSize: 11),
        ),
      );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, letterSpacing: 1.1)),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ],
      );
}

class TactileExerciseButton extends StatefulWidget {
  const TactileExerciseButton({
    super.key,
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.isDark,
    required this.onPressed,
  });
  final IconData icon;
  final String label;
  final Color accentColor;
  final bool isDark;
  final VoidCallback onPressed;
  @override
  State<TactileExerciseButton> createState() =>
      _TactileExerciseButtonState();
}

class _TactileExerciseButtonState extends State<TactileExerciseButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final base =
        widget.isDark ? const Color(0xFF242132) : const Color(0xFFE6E2F0);
    final darkShadow =
        widget.isDark ? Colors.black87 : const Color(0xFFB8B1CB);
    final lightShadow =
        widget.isDark ? const Color(0xFF39324F) : Colors.white;
    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) {
        setState(() => isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 142,
        height: 122,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isPressed
              ? [
                  BoxShadow(
                    color: darkShadow.withValues(alpha: .65),
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                  BoxShadow(
                    color: lightShadow.withValues(alpha: .7),
                    offset: const Offset(-2, -2),
                    blurRadius: 4,
                  ),
                ]
              : [
                  BoxShadow(
                    color: darkShadow.withValues(alpha: .8),
                    offset: const Offset(8, 8),
                    blurRadius: 16,
                  ),
                  BoxShadow(
                    color: lightShadow.withValues(alpha: .9),
                    offset: const Offset(-8, -8),
                    blurRadius: 16,
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              size: isPressed ? 36 : 42,
              color: isPressed ? widget.accentColor : null,
            ),
            const SizedBox(height: 8),
            Text(
              widget.label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: isPressed ? widget.accentColor : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

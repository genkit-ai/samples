import 'package:flutter/material.dart';

class GenerationStep {
  final String label;
  final IconData icon;

  const GenerationStep({required this.label, required this.icon});
}

class GenerationProgress extends StatefulWidget {
  final int currentStep;
  final List<GenerationStep> steps;

  const GenerationProgress({
    super.key,
    required this.currentStep,
    this.steps = _defaultSteps,
  });

  static const _defaultSteps = [
    GenerationStep(label: 'Researching your question...', icon: Icons.search),
    GenerationStep(label: 'Writing your story...', icon: Icons.auto_stories),
    GenerationStep(label: 'Drawing illustrations...', icon: Icons.brush),
  ];

  @override
  State<GenerationProgress> createState() => _GenerationProgressState();
}

class _GenerationProgressState extends State<GenerationProgress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label:
          'Generating story, step ${widget.currentStep + 1} of ${widget.steps.length}',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < widget.steps.length; i++) ...[
            if (i > 0)
              Container(
                width: 2,
                height: 24,
                color: i <= widget.currentStep
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
              ),
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final isActive = i == widget.currentStep;
                final isDone = i < widget.currentStep;
                final opacity =
                    isActive ? 0.7 + _pulseController.value * 0.3 : 1.0;

                return Opacity(
                  opacity: i > widget.currentStep ? 0.4 : opacity,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone
                              ? colorScheme.primary
                              : isActive
                                  ? colorScheme.primaryContainer
                                  : colorScheme.surfaceContainerHighest,
                        ),
                        child: Icon(
                          isDone ? Icons.check : widget.steps[i].icon,
                          color: isDone
                              ? colorScheme.onPrimary
                              : isActive
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.steps[i].label,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight:
                              isActive ? FontWeight.bold : FontWeight.normal,
                          color: isActive
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme.dart';

/// Indicador de pasos para formularios multi-step
class RcStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const RcStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final step = index + 1;
        final isCompleted = step < currentStep;
        final isCurrent = step == currentStep;

        return Row(
          children: [
            // Círculo del paso
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted || isCurrent
                    ? rcColor5
                    : rcWhite.withOpacity(0.9),
              ),
              child: Center(
                child: Text(
                  step.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: (isCurrent || isCompleted)
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: (isCompleted || isCurrent)
                        ? rcWhite
                        : rcColor6.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            // Línea conectora (excepto después del último paso)
            if (step < totalSteps)
              Container(
                width: 32,
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? rcColor5
                      : rcColor2.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        );
      }),
    );
  }
}




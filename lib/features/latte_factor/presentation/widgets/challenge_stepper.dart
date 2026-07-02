import 'package:flutter/material.dart';

/// CBL 4단계 진행 표시. [currentStep]은 0=Engage ~ 3=Reflect.
class ChallengeStepper extends StatelessWidget {
  const ChallengeStepper({super.key, required this.currentStep});

  final int currentStep;

  static const _labels = ['시작', '학습', '실행', '회고'];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: List.generate(_labels.length, (index) {
        final active = index <= currentStep;
        final isLast = index == _labels.length - 1;
        return Expanded(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor:
                        active ? scheme.primary : scheme.surfaceContainerHighest,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: active ? Colors.white : scheme.outline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _labels[index],
                    style: TextStyle(
                      fontSize: 11,
                      color: active ? scheme.primary : scheme.outline,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
              if (!isLast)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Container(
                      height: 2,
                      color: index < currentStep
                          ? scheme.primary
                          : scheme.surfaceContainerHighest,
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

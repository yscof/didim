import 'package:flutter/material.dart';

/// 숫자를 강조하는 카드. 원금 / 미래가치 / 수익 표시에 사용.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.caption,
    this.accentColor,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final String? caption;
  final Color? accentColor;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = accentColor ?? scheme.primary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: emphasize ? accent.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: emphasize ? accent.withValues(alpha: 0.4) : const Color(0xFFEAECF0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: scheme.outline),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: emphasize ? 28 : 22,
              fontWeight: FontWeight.w800,
              color: emphasize ? accent : scheme.onSurface,
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: 4),
            Text(
              caption!,
              style: TextStyle(fontSize: 12, color: scheme.outline),
            ),
          ],
        ],
      ),
    );
  }
}

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/evidence_picker.dart';
import '../../data/models.dart';

/// 완료 확인 시트의 결과. 시트를 그냥 닫으면(null) 취소다.
class CompletionGateResult {
  const CompletionGateResult.executed({
    required this.reflection,
    required this.hasEvidence,
    required this.impactWon,
  }) : toPlanned = false;

  const CompletionGateResult.planned()
      : reflection = null,
        hasEvidence = false,
        impactWon = 0,
        toPlanned = true;

  final String? reflection;
  final bool hasEvidence;

  /// 실측 입력으로 계산된 확보효과(원). 입력형 챌린지가 아니면 0.
  final int impactWon;

  /// true면 실행 대신 계획 완료로 저장한다 (빈손 방지).
  final bool toPlanned;
}

/// 실행 완료 게이트 시트를 띄운다.
Future<CompletionGateResult?> showCompletionConfirmSheet(
    BuildContext context, Challenge challenge) {
  return showModalBottomSheet<CompletionGateResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => CompletionConfirmSheet(challenge: challenge),
  );
}

/// 실행 완료 게이트: 자가체크 질문 전부 긍정 + 회고 1문 입력 시에만 확정
/// (docs/02-challenge-system.md 완료 검증 방식). 인증샷은 선택이며 시트가
/// 열려 있는 동안만 메모리에 존재하고, 기록에는 첨부 여부만 남는다.
class CompletionConfirmSheet extends ConsumerStatefulWidget {
  const CompletionConfirmSheet({super.key, required this.challenge});

  final Challenge challenge;

  @override
  ConsumerState<CompletionConfirmSheet> createState() =>
      _CompletionConfirmSheetState();
}

class _CompletionConfirmSheetState
    extends ConsumerState<CompletionConfirmSheet> {
  final _agreed = <int>{};
  final _reflection = TextEditingController();
  final _impactAmount = TextEditingController();
  Uint8List? _evidenceBytes;

  @override
  void dispose() {
    _reflection.dispose();
    _impactAmount.dispose();
    super.dispose();
  }

  /// 실측 입력값. 유효하지 않으면(비었거나 0원, 1억 이상) null.
  /// 상한은 허위 과대 입력을 거르는 정합성 가드다.
  int? get _validImpactInput {
    final value = int.tryParse(_impactAmount.text.trim());
    if (value == null || value < 1 || value >= 100000000) return null;
    return value;
  }

  Future<void> _attachEvidence() async {
    final bytes = await ref.read(evidencePickerProvider)();
    if (bytes != null && mounted) {
      setState(() => _evidenceBytes = bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final challenge = widget.challenge;
    final impactSpec = challenge.impactInput;
    final canConfirm =
        _agreed.length == challenge.completionCheckQuestions.length &&
            _reflection.text.trim().isNotEmpty &&
            (impactSpec == null || _validImpactInput != null);

    return SafeArea(
      child: Padding(
        // 키보드가 올라오면 입력란이 가려지지 않게 밀어올린다.
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              children: [
                Text('완료 확인', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(challenge.title,
                    style: Theme.of(context).textTheme.bodySmall),
                if (challenge.type == ChallengeType.habit) ...[
                  const SizedBox(height: 4),
                  Text('습관 챌린지는 오늘 하루 체크인 기준으로 확인해요.',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
                const SizedBox(height: 12),
                for (final (index, question)
                    in challenge.completionCheckQuestions.indexed)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: _agreed.contains(index),
                    onChanged: (checked) => setState(() {
                      checked == true
                          ? _agreed.add(index)
                          : _agreed.remove(index);
                    }),
                    title: Text(question),
                  ),
                // 실측 입력: 실제 수치를 받아 확보효과를 그 자리에서 계산한다.
                if (impactSpec != null) ...[
                  const SizedBox(height: 8),
                  Text(impactSpec.label,
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  TextField(
                    key: const Key('impact-input'),
                    controller: _impactAmount,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: '숫자만 입력',
                      suffixText: '원',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _validImpactInput == null
                        ? '실제 금액을 입력하면 확보효과를 계산해 드려요 (${impactSpec.formulaNote}).'
                        : '확보효과: ${won(impactSpec.calc(_validImpactInput!))} (${impactSpec.formulaNote})',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 8),
                Text(challenge.reflectionQuestions.first,
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                TextField(
                  key: const Key('reflection-input'),
                  controller: _reflection,
                  maxLines: 2,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: '한 줄이면 충분해요',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                if (_evidenceBytes == null)
                  OutlinedButton.icon(
                    onPressed: _attachEvidence,
                    icon: const Icon(Icons.add_a_photo_outlined),
                    label: const Text('인증샷 첨부 (선택)'),
                  )
                else
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          _evidenceBytes!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('인증샷 첨부됨')),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () =>
                            setState(() => _evidenceBytes = null),
                      ),
                    ],
                  ),
                const SizedBox(height: 4),
                Text(
                  '사진은 이 기기에서만 잠깐 쓰이고 저장·전송되지 않아요. '
                  '첨부하면 보너스 배지를 드려요.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: canConfirm
                      ? () => Navigator.pop(
                            context,
                            CompletionGateResult.executed(
                              reflection: _reflection.text.trim(),
                              hasEvidence: _evidenceBytes != null,
                              impactWon: impactSpec == null
                                  ? 0
                                  : impactSpec.calc(_validImpactInput!),
                            ),
                          )
                      : null,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('실행 완료 확정'),
                  ),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () => Navigator.pop(
                      context, const CompletionGateResult.planned()),
                  child: const Text('아직이에요 — 계획 완료로 저장'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/compound_calculator.dart';
import '../domain/latte_input.dart';
import '../domain/latte_result.dart';

/// 챌린지 화면 간 공유되는 상태: 입력값 + 완료 여부.
/// 계산 결과는 입력값에서 파생된다.
class LatteState {
  const LatteState({required this.input, this.completed = false});

  final LatteInput input;
  final bool completed;

  LatteResult get result => calculateLatteFactor(input);

  LatteState copyWith({LatteInput? input, bool? completed}) {
    return LatteState(
      input: input ?? this.input,
      completed: completed ?? this.completed,
    );
  }
}

/// 라떼 팩터 챌린지 컨트롤러. 입력값을 갱신하면 결과가 자동 재계산된다.
class LatteController extends Notifier<LatteState> {
  @override
  LatteState build() => const LatteState(input: LatteInput());

  void setItemName(String value) =>
      state = state.copyWith(input: state.input.copyWith(itemName: value));

  void setAmount(double value) =>
      state = state.copyWith(input: state.input.copyWith(amountPerOccurrence: value));

  void setFrequency(Frequency value) =>
      state = state.copyWith(input: state.input.copyWith(frequency: value));

  void setYears(int value) =>
      state = state.copyWith(input: state.input.copyWith(years: value));

  void setRate(double value) =>
      state = state.copyWith(input: state.input.copyWith(annualRatePercent: value));

  void complete() => state = state.copyWith(completed: true);

  void reset() => state = const LatteState(input: LatteInput());
}

final latteControllerProvider =
    NotifierProvider<LatteController, LatteState>(LatteController.new);

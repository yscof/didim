import 'dart:math';

import 'latte_input.dart';
import 'latte_result.dart';

/// 습관적 소비 1회 금액을 월 적립액으로 환산한다.
double monthlyContribution(double amountPerOccurrence, Frequency frequency) {
  return amountPerOccurrence * frequency.perMonth;
}

/// 라떼 팩터 계산: 습관적 소비를 매월 적립·투자했을 때의 복리 미래가치를 구한다.
///
/// 정기적립(연금) 미래가치 공식을 사용한다.
///   FV = PMT × ((1 + i)^n − 1) / i   (i ≠ 0)
///   FV = PMT × n                     (i = 0)
/// 여기서 i = 월 이율, n = 개월 수.
LatteResult calculateLatteFactor(LatteInput input) {
  final pmt = monthlyContribution(input.amountPerOccurrence, input.frequency);
  final n = input.years * 12;
  final i = input.annualRatePercent / 100 / 12;

  final principal = pmt * n;
  final double futureValue;
  if (i == 0) {
    futureValue = pmt * n;
  } else {
    futureValue = pmt * (pow(1 + i, n) - 1) / i;
  }

  return LatteResult(
    monthlyContribution: pmt,
    principal: principal,
    futureValue: futureValue,
    gain: futureValue - principal,
  );
}

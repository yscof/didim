/// 라떼 팩터 계산 결과.
class LatteResult {
  const LatteResult({
    required this.monthlyContribution,
    required this.principal,
    required this.futureValue,
    required this.gain,
  });

  /// 월 적립 환산액 (원).
  final double monthlyContribution;

  /// 기간 동안 실제로 쓴(또는 넣은) 원금 총액 (원).
  final double principal;

  /// 복리로 굴렸을 때의 미래가치 (원).
  final double futureValue;

  /// 복리로 늘어난 수익 (미래가치 - 원금).
  final double gain;
}

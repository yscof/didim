/// 소비 빈도. 습관적 소비를 월 적립액으로 환산할 때 사용한다.
enum Frequency {
  daily('매일', 365 / 12),
  weekly('매주', 52 / 12),
  monthly('매월', 1);

  const Frequency(this.label, this.perMonth);

  /// 화면에 표시할 한글 라벨.
  final String label;

  /// 1회 금액을 월 적립액으로 환산할 때 곱하는 계수.
  final double perMonth;
}

/// 라떼 팩터 계산 입력값.
class LatteInput {
  const LatteInput({
    this.itemName = '아메리카노',
    this.amountPerOccurrence = 4500,
    this.frequency = Frequency.daily,
    this.years = 5,
    this.annualRatePercent = 7,
  });

  /// 소비 항목 이름 (예: 아메리카노).
  final String itemName;

  /// 1회 소비 금액 (원).
  final double amountPerOccurrence;

  /// 소비 빈도.
  final Frequency frequency;

  /// 투자 기간 (년). 기본 5년, 슬라이더로 1~30년 조절.
  final int years;

  /// 연 수익률 (%). 기본 7% (ETF 가정).
  final double annualRatePercent;

  LatteInput copyWith({
    String? itemName,
    double? amountPerOccurrence,
    Frequency? frequency,
    int? years,
    double? annualRatePercent,
  }) {
    return LatteInput(
      itemName: itemName ?? this.itemName,
      amountPerOccurrence: amountPerOccurrence ?? this.amountPerOccurrence,
      frequency: frequency ?? this.frequency,
      years: years ?? this.years,
      annualRatePercent: annualRatePercent ?? this.annualRatePercent,
    );
  }
}

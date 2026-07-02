import 'package:intl/intl.dart';

final NumberFormat _wonFormat = NumberFormat.currency(
  locale: 'ko_KR',
  symbol: '₩',
  decimalDigits: 0,
);

/// 원화 통화 포맷 (예: ₩1,234,567).
String formatWon(num value) => _wonFormat.format(value);

/// 큰 금액을 '억/만원' 단위로 읽기 쉽게 요약한다 (예: 1,234만원, 1억 2,345만원).
String formatWonCompact(num value) {
  final rounded = value.round();
  if (rounded < 10000) return formatWon(rounded);

  final eok = rounded ~/ 100000000; // 억
  final man = (rounded % 100000000) ~/ 10000; // 만
  final buf = StringBuffer();
  if (eok > 0) buf.write('$eok억 ');
  if (man > 0) buf.write('${NumberFormat.decimalPattern('ko_KR').format(man)}만');
  if (eok > 0 && man == 0) return '$eok억원';
  return '${buf.toString().trim()}원';
}

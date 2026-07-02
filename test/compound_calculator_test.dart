import 'package:didim/features/latte_factor/domain/compound_calculator.dart';
import 'package:didim/features/latte_factor/domain/latte_input.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('monthlyContribution', () {
    test('매일 소비는 amount × 365/12로 환산된다', () {
      expect(monthlyContribution(4500, Frequency.daily), closeTo(4500 * 365 / 12, 1e-9));
    });

    test('매주 소비는 amount × 52/12로 환산된다', () {
      expect(monthlyContribution(4500, Frequency.weekly), closeTo(4500 * 52 / 12, 1e-9));
    });

    test('매월 소비는 그대로다', () {
      expect(monthlyContribution(4500, Frequency.monthly), 4500);
    });
  });

  group('calculateLatteFactor', () {
    test('수익률 0%면 미래가치는 원금과 같다', () {
      const input = LatteInput(
        amountPerOccurrence: 100000,
        frequency: Frequency.monthly,
        years: 5,
        annualRatePercent: 0,
      );
      final r = calculateLatteFactor(input);
      expect(r.principal, 100000 * 60);
      expect(r.futureValue, closeTo(r.principal, 1e-6));
      expect(r.gain, closeTo(0, 1e-6));
    });

    test('수익률이 양수면 미래가치가 원금보다 크다', () {
      const input = LatteInput(
        amountPerOccurrence: 4500,
        frequency: Frequency.daily,
        years: 5,
        annualRatePercent: 7,
      );
      final r = calculateLatteFactor(input);
      expect(r.futureValue, greaterThan(r.principal));
      expect(r.gain, greaterThan(0));
    });

    test('연금 미래가치 공식이 알려진 값과 일치한다 (월 10만, 12%, 1년)', () {
      const input = LatteInput(
        amountPerOccurrence: 100000,
        frequency: Frequency.monthly,
        years: 1,
        annualRatePercent: 12,
      );
      final r = calculateLatteFactor(input);
      // FV = 100000 × ((1.01^12 − 1) / 0.01) ≈ 1,268,250.30
      expect(r.futureValue, closeTo(1268250.30, 0.5));
      expect(r.principal, 1200000);
    });
  });
}

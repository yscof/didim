import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ledger.dart' show sharedPreferencesProvider;

/// 디지털 월세(구독료) 관리. 매달 나가는 구독 결제를 '또 하나의 월세'로
/// 보여주고 줄일 수 있는 혜택과 방법을 안내한다. 자가 입력 기반 (docs/08).

class Subscription {
  const Subscription({
    required this.id,
    required this.name,
    required this.monthlyFeeWon,
    this.billingDay,
  });

  final String id;
  final String name;
  final int monthlyFeeWon;

  /// 매월 결제일 (1~31). 모르면 null.
  final int? billingDay;

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'monthlyFeeWon': monthlyFeeWon,
        'billingDay': billingDay,
      };

  static Subscription fromJson(Map<String, dynamic> json) => Subscription(
        id: json['id'] as String,
        name: json['name'] as String,
        monthlyFeeWon: json['monthlyFeeWon'] as int,
        billingDay: json['billingDay'] as int?,
      );
}

/// 구독 목록. shared_preferences(웹=localStorage)에 저장한다.
/// TODO: 백엔드 연동 시 서버 상태로 교체.
class SubscriptionsNotifier extends Notifier<List<Subscription>> {
  static const storageKey = 'subscriptions_v1';

  @override
  List<Subscription> build() {
    final raw = ref.watch(sharedPreferencesProvider).getString(storageKey);
    if (raw == null) return const [];
    try {
      return [
        for (final item in jsonDecode(raw) as List)
          Subscription.fromJson(item as Map<String, dynamic>),
      ];
    } on FormatException {
      return const [];
    }
  }

  void add({required String name, required int monthlyFeeWon, int? billingDay}) {
    state = [
      ...state,
      Subscription(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        monthlyFeeWon: monthlyFeeWon,
        billingDay: billingDay,
      ),
    ];
    _save();
  }

  void remove(String id) {
    state = state.where((s) => s.id != id).toList();
    _save();
  }

  void _save() {
    ref.read(sharedPreferencesProvider).setString(
          storageKey,
          jsonEncode([for (final s in state) s.toJson()]),
        );
  }
}

final subscriptionsProvider =
    NotifierProvider<SubscriptionsNotifier, List<Subscription>>(
        SubscriptionsNotifier.new);

/// 월 총액 = 내 디지털 월세.
final digitalRentMonthlyProvider = Provider<int>((ref) => ref
    .watch(subscriptionsProvider)
    .fold(0, (sum, s) => sum + s.monthlyFeeWon));

/// 구독 등록 시트의 이름 추천 칩. 추천·가입 유도가 아니라 입력 편의를 위한
/// 프리셋이다 (요금은 사용자가 직접 입력).
const subscriptionNamePresets = [
  '넷플릭스',
  '유튜브 프리미엄',
  '쿠팡 와우',
  '네이버 멤버십',
  '스포티파이',
  '멜론',
  '디즈니+',
  '티빙',
  '웨이브',
  '왓챠',
  '아이클라우드',
  '구글 원',
  'ChatGPT',
  '배민클럽',
];

/// 줄일 수 있는 혜택·방법 안내. 특정 상품 가입 유도가 아니라 일반적인
/// 절감 경로 안내이며, 조건은 서비스마다 다르다는 고지를 화면에서 함께 보여준다.
class SubscriptionTip {
  const SubscriptionTip({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}

const subscriptionTips = [
  SubscriptionTip(
    title: '연간 결제로 전환',
    description: '많은 서비스가 연간 결제 시 10~20% 정도를 할인해요. '
        '단, 1년 내내 쓸 것이 확실한 서비스만 전환하세요. 어중간하면 월 결제가 안전해요.',
  ),
  SubscriptionTip(
    title: '가족·공유 요금제 확인',
    description: '프리미엄 요금제 중엔 가족 구성원과 나눠 쓸 수 있는 공식 요금제가 있어요. '
        '가족과 함께 쓰면 1인당 부담이 절반 이하로 줄어요 (약관상 허용 범위 확인).',
  ),
  SubscriptionTip(
    title: '통신사 결합 혜택 점검',
    description: '내 통신 요금제에 OTT·음악 구독이 이미 포함돼 있는 경우가 있어요. '
        '따로 결제 중이면 이중 지출이에요. 통신사 앱에서 부가 혜택을 확인해보세요.',
  ),
  SubscriptionTip(
    title: '학생·청년 할인 확인',
    description: '음악·영상 서비스 상당수가 대학생 인증 시 반값 수준의 학생 요금제를 운영해요. '
        '해당된다면 같은 서비스를 더 싸게 쓸 수 있어요.',
  ),
  SubscriptionTip(
    title: '멤버십 중복 정리',
    description: '무료배송·적립형 멤버십이 2개 이상이면 역할이 겹칠 가능성이 커요. '
        '최근 한 달 사용 내역을 보고 하나만 남겨보세요.',
  ),
  SubscriptionTip(
    title: '해지 전 혜택 확인 후 해지',
    description: '해지를 진행하면 할인 쿠폰이나 일시정지 옵션을 제안하는 서비스가 많아요. '
        '계속 쓸 서비스라면 해지 화면까지 가서 제안을 확인하는 것도 방법이에요.',
  ),
];

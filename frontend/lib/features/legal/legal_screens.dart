import 'package:flutter/material.dart';

import '../../app/web_page_body.dart';

/// 법적 고지 페이지 3종 (면책·이용약관·개인정보처리방침).
/// MVP 베타 기준 초안으로, 정식 출시 전 법률 전문가 검토가 필요하다.
/// 근거 문서: docs/18-compliance.md

class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({super.key, this.showAppBar = true});

  /// 웹 셸(상단 메뉴바) 안에서 열릴 때는 자체 AppBar를 숨긴다.
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return _LegalScaffold(
      title: '면책 고지',
      updatedAt: '2026년 7월 13일',
      showAppBar: showAppBar,
      sections: const [
        (
          '금융상품 추천이 아닙니다',
          '디딤이 제공하는 챌린지, 계산 결과, 안내 콘텐츠는 일반적인 금융 정보와 교육을 목적으로 '
              '합니다. 디딤은 특정 금융상품의 추천·권유·판매·중개를 하지 않으며, '
              '투자자문업·투자일임업·유사투자자문업에 해당하는 서비스를 제공하지 않습니다.'
        ),
        (
          '모든 금액은 추정치입니다',
          '서비스에 표시되는 절감액, 환급 예상액, 확보효과 등의 금액은 사용자가 입력한 값과 '
              '일반적인 산식으로 계산한 추정치입니다. 실제 금액은 개인 상황, 기관 정책, '
              '법령 변경에 따라 달라질 수 있습니다.'
        ),
        (
          '정책·세법 정보는 변경될 수 있습니다',
          '연말정산, 정책금융, 청약 등의 정보는 작성 시점 기준이며 이후 변경될 수 있습니다. '
              '신청 자격과 조건의 최종 확인은 국세청, 홈택스, 주택도시기금 등 해당 기관의 '
              '공식 안내를 따르세요. 디딤은 개별 세무·법률 자문을 제공하지 않습니다.'
        ),
        (
          '금융 결정의 책임',
          '금융상품 가입, 해지, 투자 등 모든 금융 결정과 그 결과에 대한 책임은 이용자 본인에게 '
              '있습니다. 디딤은 이용자의 금융 행동으로 발생한 손실에 대해 책임을 지지 않습니다.'
        ),
      ],
    );
  }
}

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key, this.showAppBar = true});

  /// 웹 셸(상단 메뉴바) 안에서 열릴 때는 자체 AppBar를 숨긴다.
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return _LegalScaffold(
      title: '이용약관',
      updatedAt: '2026년 7월 13일',
      showAppBar: showAppBar,
      sections: const [
        (
          '제1조 (서비스의 성격)',
          '디딤(이하 "서비스")은 사회초년생을 위한 금융 행동 코칭 정보를 제공하는 무료 베타 '
              '서비스입니다. 서비스는 금융상품의 판매·중개·자문을 제공하지 않습니다.'
        ),
        (
          '제2조 (이용자의 책임)',
          '이용자는 서비스가 제공하는 정보를 참고 자료로 활용하며, 금융 결정의 최종 판단과 '
              '책임은 이용자 본인에게 있습니다. 이용자가 입력하는 정보의 정확성은 이용자가 '
              '관리합니다.'
        ),
        (
          '제3조 (데이터의 저장)',
          '현재 버전에서 이용자가 입력한 데이터(가계부, 구독, 카드, 챌린지 기록 등)는 '
              '이용자의 브라우저에만 저장되며 서버로 전송되지 않습니다. 브라우저 데이터를 '
              '삭제하면 기록이 사라질 수 있습니다.'
        ),
        (
          '제4조 (서비스의 변경과 중단)',
          '베타 기간 중 서비스의 기능은 사전 고지 없이 변경·추가·중단될 수 있습니다. '
              '중요한 변경은 서비스 내 공지로 안내합니다.'
        ),
        (
          '제5조 (약관의 변경)',
          '본 약관은 서비스 개선에 따라 변경될 수 있으며, 변경 시 서비스 내에 게시합니다. '
              '본 약관은 정식 출시 전 법률 검토를 거쳐 개정될 예정입니다.'
        ),
      ],
    );
  }
}

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key, this.showAppBar = true});

  /// 웹 셸(상단 메뉴바) 안에서 열릴 때는 자체 AppBar를 숨긴다.
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return _LegalScaffold(
      title: '개인정보처리방침',
      updatedAt: '2026년 7월 13일',
      showAppBar: showAppBar,
      sections: const [
        (
          '수집하는 개인정보',
          '현재 버전은 회원가입이 없으며, 이름·연락처·계좌정보 등 개인을 식별할 수 있는 '
              '정보를 수집하지 않습니다.'
        ),
        (
          '입력 데이터의 처리',
          '이용자가 서비스에 입력하는 금융 기록(가계부, 구독, 카드 실적, 챌린지 기록)은 '
              '이용자의 브라우저 저장소(localStorage)에만 저장되며, 디딤의 서버로 전송되거나 '
              '제3자에게 제공되지 않습니다. 챌린지 인증샷은 첨부 여부만 기록하고 이미지는 '
              '저장하지 않습니다.'
        ),
        (
          '쿠키와 분석 도구',
          '현재 버전은 광고·추적 목적의 쿠키와 외부 분석 도구를 사용하지 않습니다.'
        ),
        (
          '데이터의 삭제',
          '브라우저의 사이트 데이터 삭제 기능으로 이용자가 직접 모든 기록을 삭제할 수 있습니다.'
        ),
        (
          '방침의 변경',
          '계정 기능, 서버 저장, 분석 도구를 도입하는 경우 관련 법령(개인정보 보호법 등)에 '
              '따라 본 방침을 개정하고 시행 전에 고지합니다.'
        ),
      ],
    );
  }
}

class _LegalScaffold extends StatelessWidget {
  const _LegalScaffold({
    required this.title,
    required this.updatedAt,
    required this.sections,
    this.showAppBar = true,
  });

  final String title;
  final String updatedAt;
  final List<(String, String)> sections;
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar ? AppBar(title: Text(title)) : null,
      body: SafeArea(
        child: WebPageBody(
          maxWidth: 720,
          footer: !showAppBar,
          children: [
            // 웹은 AppBar가 없으므로 페이지 제목을 본문 상단에 보여준다.
            if (!showAppBar) ...[
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
            ],
            Text('시행일: $updatedAt (베타 기준 초안)',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            for (final (heading, body) in sections) ...[
              Text(heading,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(body),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}

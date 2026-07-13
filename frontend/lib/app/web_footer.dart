import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 웹 페이지 하단 공통 Footer. 주요 웹 페이지의 ListView 마지막 항목으로
/// 부착한다 (웹 레이아웃일 때만). 문구 근거: docs/18-compliance.md.
class WebFooter extends StatelessWidget {
  const WebFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(color: const Color(0xFF6B6B6B));

    return Container(
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 4),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE5E5E5))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('디딤',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text('사회초년생을 위한 금융 행동 코치', style: muted),
          const SizedBox(height: 12),
          Wrap(
            spacing: 4,
            children: [
              _FooterLink(label: '서비스 소개', onTap: () => context.go('/about')),
              _FooterDot(),
              _FooterLink(label: '이용약관', onTap: () => context.push('/terms')),
              _FooterDot(),
              _FooterLink(
                  label: '개인정보처리방침',
                  onTap: () => context.push('/privacy')),
              _FooterDot(),
              _FooterLink(
                  label: '면책 고지', onTap: () => context.push('/disclaimer')),
            ],
          ),
          const SizedBox(height: 12),
          Text('운영: 디딤 팀 · 문의 채널 준비 중', style: muted),
          const SizedBox(height: 8),
          Text(
            '디딤은 일반적인 금융 정보와 교육 콘텐츠를 제공하며, 특정 금융상품의 추천·권유·중개 '
            '또는 투자자문·세무자문을 제공하지 않습니다. 서비스 내 금액은 추정치이며, '
            '최종 조건은 각 기관의 공식 안내를 확인하세요.',
            style: muted,
          ),
          const SizedBox(height: 8),
          Text('© 2026 didim. All rights reserved.', style: muted),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
        child: Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _FooterDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('·',
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: const Color(0xFFB0B0B0)));
  }
}

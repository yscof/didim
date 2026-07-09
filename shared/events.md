# Event Naming

MVP 지표를 앱, 백엔드, AI 서비스가 같은 이름으로 기록하기 위한 이벤트 초안이다.

## 원칙

- 이벤트 이름은 snake_case를 사용한다.
- 이벤트에는 가능한 경우 `challengeId`, `assetStage`, `source`, `createdAt`을 포함한다.
- 민감한 원본 금융정보는 이벤트에 넣지 않는다.
- 금액은 필요한 경우 범주 또는 계산 결과만 기록한다.

## 온보딩/진단

- `onboarding_started`
- `onboarding_completed`
- `diagnosis_created`
- `diagnosis_viewed`
- `recommendation_reason_viewed`

## 챌린지

- `challenge_assigned`
- `challenge_accepted`
- `challenge_step_completed`
- `challenge_completed_planned`
- `challenge_completed_executed`
- `challenge_held`
- `challenge_retry_scheduled`
- `challenge_reflection_started`
- `challenge_reflection_completed`

## AI 코칭

- `ai_coach_opened`
- `ai_answer_viewed`
- `ai_source_opened`
- `ai_reflection_praise_viewed`
- `ai_next_action_accepted`

## 지도/보상

- `map_viewed`
- `map_region_viewed`
- `map_object_unlocked`
- `region_unlocked`
- `region_progress_updated`
- `region_completed`
- `completion_reaction_viewed`
- `completion_reaction_skipped`
- `completion_reaction_next_accepted`
- `badge_earned`
- `badge_detail_viewed`
- `badge_share_card_created`
- `weekly_streak_continued`
- `weekly_streak_recovered`
- `monthly_journey_report_viewed`

## 재방문/성장

- `streak_viewed`
- `growth_record_viewed`
- `last_visit_delta_viewed`
- `weekly_progress_viewed`
- `payday_reminder_viewed`
- `week_2_returned`
- `week_4_returned`

## CRM

- `crm_message_sent`
- `crm_message_opened`
- `crm_message_dismissed`
- `crm_message_to_challenge_resumed`
- `retry_prompt_viewed`
- `retry_prompt_accepted`

## 마케팅 전환

- `landing_viewed`
- `simple_diagnosis_started`
- `simple_diagnosis_completed`
- `content_to_challenge_clicked`
- `beta_signup_completed`

## 핵심 파라미터

- `challengeId`
- `assetStage`
- `completionStatus`: `planned`, `executed`, `held`
- `holdReason`
- `recommendationRuleId`
- `recommendationSource`: `rule`, `rule_plus_llm`
- `source`: `app`, `landing`, `instagram`, `youtube_shorts`, `community`
- `hasViewedSource`: boolean
- `privacyBurdenScore`: 1-5
- `crmTriggerId`
- `crmStage`: `activation`, `retention`, `revenue`, `referral`
- `daysSinceLastVisit`
- `completedCount`
- `estimatedMonthlyImpactRange`
- `regionId`
- `regionProgressPercent`
- `badgeId`
- `streakWeeks`
- `gainLabel`: `discovery`, `estimated`, `annualized`, `realized`

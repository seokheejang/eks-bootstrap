# 0008: AWS 자격증명·계정 전략 (Phase 1)

- Status: Accepted
- Date: 2026-06-08
- Tags: aws, security, identity, iam, account

## Context

이 레포의 목표 중 하나는 SOC 2 정합이다. SOC 관점에서 이상적인 자격증명·계정 구조는 (1) SSO(IAM Identity Center) 단기 토큰 — 디스크에 상주하는 장기 비밀 없음, (2) 워크로드를 별도 계정으로 격리(multi-account) — blast radius 축소다. 그러나 둘 다 day 1 비용이 있다:

- CLI/Terraform용 SSO(permission set)는 **organization instance**를 요구한다. account instance는 permission set을 지원하지 않아 AWS 계정 접근 불가 (2026-06-08 AWS 문서 확인). 즉 SSO를 쓰려면 org를 켜야 하고, 그러면 현재 단일 standalone 계정이 org의 **management account**가 된다.
- multi-account는 워크로드용 member 계정 생성 + cross-account 접근 + permission set 할당이 추가로 필요하다.

Phase 1의 우선순위는 Temporal-on-EKS PoC를 단일 계정에서 빠르게 굴려 학습하는 것이다.

## Decision

Phase 1은 **단일 AWS 계정 + 전용 IAM user(`terraform-eks-dev`)의 장기 access key**로 Terraform 프로그래매틱 접근을 한다. SSO와 multi-account는 시한부로 연기한다.

- 인증: IAM user `terraform-eks-dev` access key (개인 admin 유저 키 미사용)
- SSO (IAM Identity Center): **Phase 2**
- multi-account (워크로드 member 계정 분리): **Phase 3**
- dev 테스트 region: `us-east-2`

## Alternatives Considered

- **A. SSO now (org instance, 단일 계정)** — 단기 토큰으로 SOC-cleaner. 그러나 org 생성 + management account 셋업이 따라오고, 워크로드는 여전히 단일(관리) 계정에 남아 "관리계정에 워크로드" best-practice를 어긴다. PoC 진입이 지연됨.
- **B. multi-account now (member 계정 분리)** — SOC 정석 격리. 그러나 추가 계정 + cross-account + permission set 셋업으로 Phase 1 진도가 느려지고, org/계정 개념 학습 부담이 큼.
- **C. access key + 단일 계정, SSO/multi-account 연기 (채택)** — 가장 단순. Phase 1 PoC 허용선. 단 명시적 시한부 deviation으로 관리.

## Consequences

- 장기 access key는 콘솔 MFA를 우회한다 (프로그래매틱 접근은 기본적으로 MFA 미적용) -> SSO 대비 약점.
- 완화책: 전용 IAM user 사용(개인 admin 키 아님), 키 주기적 회전, 안 쓰는 키 비활성화, 레포 commit 금지(commit-gates의 gitleaks가 차단).
- 시한부 deviation 명시: "상주 비밀 없음"은 Phase 2(SSO)로, "워크로드 격리 계정"은 Phase 3(multi-account)로 해소.
- region `us-east-2`는 `environments/<env>/terraform.tfvars`의 `aws_region`으로 주입. 모듈은 region-무관.
- org 미생성 -> 나중에 SSO/multi-account 도입은 추가 작업. 단 그린필드라 재타겟 비용 낮음. 계정 경계 전환 시 워크로드는 이동이 아니라 재생성임을 유의 ([0002](0002-single-state-then-split.md)의 state 분리와 같은 결).

### Security Implications

- SOC 2 CC6.1/CC6.2/CC6.3 (논리적 접근·자격증명 관리): access key로도 *충족 가능*하나 SSO보다 약함. 본 deviation을 Phase 2/3로 시한부 관리하는 것이 통제 의도.
- [security-baseline.md](../security/security-baseline.md) 항목 변경 없음 (사전조건 Root MFA·EBS default encryption 등 그대로). 신규 위험 = 장기 키 유출, 완화책은 위 Consequences.

## References

- [security-baseline.md](../security/security-baseline.md) - 보안 baseline + Tier 분류
- [versions.md](../conventions/versions.md) - 버전 핀
- [0002-single-state-then-split.md](0002-single-state-then-split.md) - 단일 -> 분리 점진 전략 (같은 결의 경계 결정)
- [0007-soc2-primary-isms-reference.md](0007-soc2-primary-isms-reference.md) - SOC 2 1차 프레임워크
- AWS: account instance는 permission set 미지원 (organization instance 필요) - https://docs.aws.amazon.com/singlesignon/latest/userguide/account-instances-identity-center.html

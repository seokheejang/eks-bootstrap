# SOC 2 Type II Compliance Design

eks-bootstrap이 SOC 2 Type II Trust Services Criteria를 어떻게 충족하는지 *설계 차원에서* 정리. 본 디렉토리 진입점은 [README.md](README.md).

이 문서는 인스펙션(현황 점검) 문서가 아니라 *모듈·환경 설계 시 같이 보는* 문서. 자원이 늘면서 단계적으로 채워감.

## 리뷰 포커스

- **AICPA 명시 X · industry-common interpretation 5건**: CC1.5 / CC3.4 / CC4.2 / CC5.1 / CC5.2 / CC5.3. 표 disclaimer 박혀있음. audit firm 사전 협의 필요.
- **Phase 매핑 정합성**: 같은 통제(예: CC6.1)의 Phase 값이 [security-baseline.md](security-baseline.md) Phase 표와 모순 없는지.
- **Type I/II 시간축**: Phase 2 baseline 완료 = Type I 후보, +6~12개월 운영 = Type II first-time 후보. 본 레포 phase 일정과 정합한지.
- **Confidentiality C1.x**: Phase 3 도입. 글로벌 사업 (특히 EU 고객) 자주 묻힘.

## 범위

- 1차 프레임워크: **SOC 2 Type II** (Trust Services Criteria 중 Security 필수)
- 추후 확장: Availability, Confidentiality (Phase 3)
- Privacy: 본 레포 범위 밖 (앱 레이어 책임)
- 글로벌 사업 보조: [iso27001-mapping.md](iso27001-mapping.md) (EU·아시아 enterprise 대응)
- 한국 ISMS-P 매핑: [isms-mapping.md](isms-mapping.md)

기준 표준: **AICPA TSP-100 2017 Trust Services Criteria with Revised Points of Focus 2022**. 2022 update는 criteria 자체 불변, Points of Focus만 revised. AWS는 2025-07에 신규 *AICPA SOC 2 Compliance Guide on AWS*를 publish — 2026 audit expectation의 industry baseline.

## SOC 2가 자동 보장하지 않는 것

IaC만으로 충족 불가. 운영 절차·증거 필요:

- 통제가 *감사 기간 동안* 작동했다는 증거 (Type II 핵심)
- 접근 검토 실제 수행 기록 (quarterly recommended)
- 사고 대응 실제 수행 기록 (incident report)
- 백업 복원 시연 기록 (annual recommended)
- 직원 정책 준수 기록 (training, awareness)
- 벤더 위험 평가 (annual sub-processor review)

eks-bootstrap은 *기술 baseline*만 제공. 위는 별도 운영 단계에서 채움.

## Trust Services Criteria 매핑 (Security 우선)

각 통제별로: *대응 baseline 항목* + *현재 상태* + *목표 Phase*.

상태 값: **적용** / **부분** / **미적용**

**매핑 disclaimer**: AICPA TSP-100은 통제(criterion)만 명시하고 구체적 IaC evidence 매핑은 산업 통념·audit firm 해석에 의존. 본 문서의 **CC1.5, CC3.4, CC4.2, CC5.1~5.3** 매핑은 *industry-common interpretation*으로, audit firm마다 evidence 인정 범위가 다를 수 있음. 실제 audit 시 firm과 사전 협의 권장.

### CC1 — Control Environment

대부분 조직 영역. 일부는 IaC 흔적이 *partial evidence* (단, audit firm마다 해석 차이 — 박지 말고 보조로만).

| 통제 | Baseline / Evidence | 상태 | Phase |
|---|---|---|---|
| CC1.5 Accountability | git commit author + `CODEOWNERS` (도입 시) | 부분 | Phase 1~2 (industry-common 해석, AICPA 명시 X) |

### CC2 — Communication and Information

대부분 조직 영역. **IaC 범위 밖**.

### CC3 — Risk Assessment

| 통제 | Baseline / Evidence | 상태 | Phase |
|---|---|---|---|
| CC3.4 변경 위험 평가 | plan S5(Rollback Trigger) + S6(Rollback Procedure) — 변경 전 위험 식별 + 완화 절차 | 적용 (Phase 1) | Phase 1 |

### CC4 — Monitoring Activities

| 통제 | Baseline | 상태 | Phase |
|---|---|---|---|
| CC4.1 통제 평가 | drift detection (`terraform plan -detailed-exitcode`) | 미적용 | Phase 2 |
| CC4.2 결함 communication | ADR (Architecture Decision Records) + post-incident review docs |ㄴ 부분 | Phase 1~3 |

### CC5 — Control Activities

| 통제 | Baseline | 상태 | Phase |
|---|---|---|---|
| CC5.1 통제 활동 선택 | `docs/plans/` template (S3.5 Security Review) + [commit-gates.md](../conventions/commit-gates.md) | 적용 (Phase 1) | Phase 1 |
| CC5.2 기술적 통제 선택 | gitleaks, tfsec, terraform_trivy, fmt, validate, tflint | 적용 (Phase 1) | Phase 1 |
| CC5.3 정책 deploy | conventions 폴더 (resource-naming, tagging, terraform-variables 등) | 적용 (Phase 1) | Phase 1 |

### CC6 — Logical and Physical Access

| 통제 | Baseline | 상태 | Phase |
|---|---|---|---|
| CC6.1 논리적 접근 제어 | EKS `authentication_mode=API`, IRSA per pod, IAM least privilege | 부분 | Phase 1~2 |
| CC6.1 암호화 | EBS·RDS·EKS Secret 암호화 (AWS-managed key → Phase 2 CMK) | 부분 (Phase 1) | Phase 1~2 |
| CC6.1 KMS CMK rotation | annual rotation 활성 | 미적용 | Phase 2 |
| CC6.2 사용자 등록·인증 | ArgoCD OAuth, AWS IAM, Root MFA (사전조건) | 부분 | Phase 1~2 |
| CC6.3 인증 정보 관리 | IRSA (IAM access key 미사용), SSM/Secrets Manager, **Secrets rotation Lambda** | 부분 | Phase 1~2 |
| CC6.6 외부 위협 차단 | EKS API private, SG ingress 제한, S3 account-level public block, **WAF (Phase 3), NACL (Phase 3)** | 부분 | Phase 1~3 |
| CC6.7 데이터 전송 보호 | RDS TLS 강제, ALB ACM, mTLS (Phase 2) | 부분 (Phase 1) | Phase 1~2 |
| CC6.8 비인가 코드 차단 | Pod Security Standards, Kyverno | 미적용 | Phase 3 |

### CC7 — System Operations

| 통제 | Baseline | 상태 | Phase |
|---|---|---|---|
| CC7.1 보안 모니터링 | EKS control plane logs 5종, region default CloudTrail | 적용 (Phase 1) | Phase 1 |
| CC7.1 시간 동기화 | AWS Time Sync (EKS·EC2 기본) | 적용 (Phase 1) | Phase 1 |
| CC7.2 시스템 모니터링 (CloudTrail) | **multi-region trail + log file validation** | 미적용 | Phase 1~2 (multi-region + LFV) |
| CC7.2 audit log immutability | **S3 Object Lock on audit log buckets** | 미적용 | Phase 2 (bucket 생성 시 enable 필수) |
| CC7.2 log retention | Phase 1: 90일 → **Phase 2: 365일 (SOC 2 권장 최소)** | 부분 | Phase 2 (상향) |
| CC7.2 VPC Flow Logs / ALB access logs | S3 destination | 미적용 | Phase 2 |
| CC7.2 RDS audit logging (pgAudit) | parameter group + `shared_preload_libraries` | 미적용 | Phase 2 |
| CC7.3 보안 사건 탐지 | GuardDuty, Security Hub, Inspector | 미적용 | Phase 3 |
| CC7.4 보안 사건 대응 | 런북 + 자동 알람 | 미적용 | Phase 3 |
| CC7.5 복구 | 백업·복원·DR | 미적용 | Phase 3 |

### CC8 — Change Management

| 통제 | Baseline | 상태 | Phase |
|---|---|---|---|
| CC8.1 변경 관리 | `docs/plans/` + git history + ADR | 적용 (Phase 1) | Phase 1 |
| CC8.1 코드 품질 게이트 | [commit-gates.md](../conventions/commit-gates.md) | 적용 (Phase 1) | Phase 1 |
| CC8.1 CI 백업 게이트 | GitHub Actions에서 pre-commit 재실행 | 미적용 | Phase 2 |

### CC9 — Risk Mitigation

| 통제 | Baseline | 상태 | Phase |
|---|---|---|---|
| CC9.1 벤더 위험 | provider/chart 버전 핀 + [versions.md "버전 변경 시 검증 절차"](../conventions/versions.md#버전-변경-시-검증-절차) | 부분 | Phase 1~2 |
| CC9.2 비즈니스 영향 | 환경 분리 (dev/staging/prod), tfstate 환경별 bucket | 부분 (Phase 2부터) | Phase 2 |

## Availability TSC (Phase 3 진입 시 추가)

| 통제 | Baseline | Phase |
|---|---|---|
| A1.1 용량 관리 | Karpenter dynamic provisioning | Phase 3 |
| A1.2 백업·복원 | Aurora PITR 7일+, AWS Backup, restore test | Phase 3 |
| A1.3 복구 절차 | DR runbook | Phase 3 |

## Confidentiality TSC (Phase 3 진입 시 추가, 글로벌 사업 자주 묻힘)

| 통제 | Baseline | Phase |
|---|---|---|
| C1.1 기밀정보 식별 | 데이터 분류 정책 (앱 레이어와 협업) | Phase 3 |
| C1.2 기밀정보 파기 | Aurora PITR retention, S3 lifecycle, secrets rotation, EBS snapshot 보존 기간 | Phase 3 |

## Audit Timeline (Type I vs Type II)

SOC 2는 두 가지 audit type. 글로벌 사업이면 보통 둘 다 거침 (Type I 먼저 → Type II 후속).

### Type I — Point-in-time (설계 적합성)

- **소요**: 3~6개월 (prep 1~3개월 + audit 2~5주 + report 2~6주)
- **증거**: 특정 시점의 control 설계와 구현
- **본 레포 매핑**: Phase 2 baseline 완료 시점이 자연스러운 Type I 후보
- **용도**: enterprise procurement 첫 진입, "controls 있다"를 증명

### Type II — Operating effectiveness (운영 적합성)

- **소요**: 9~15개월 first-time (prep 3~6개월 + **observation 6~12개월** + audit/report 4~12주)
- **재인증**: annual 12개월 observation
- **증거**: control이 *audit 기간 동안 작동했음*
- **본 레포 매핑**:
  - Phase 1~2 진행 = Type I prep
  - Phase 2 baseline 완료 = Type I 후보
  - Phase 2 완료 + 6~12개월 운영 = Type II 후보 (실제 audit firm 협의로 단축 가능)

### Phase 로드맵 매핑 (대략)

| 시점 | Phase | Audit milestone |
|---|---|---|
| 2026-05 ~ 2026-09 | Phase 1 (PoC) | (audit-readiness 시작) |
| 2026-09 ~ 2027-02 | Phase 2 (staging) | Phase 2 baseline 완료 시점 — Type I 후보 |
| 2027-02 ~ 2027-08 | observation period | Type II 후보를 위한 운영 evidence 수집 |
| 2027-08 ~ | Type II audit | first-time Type II 후보 |

위 일정은 가설. 실제 시점은 사업 요구·고객 진입 timing·audit firm 가용성에 따라 조정.

## 단계별 진척

각 모듈·환경 변경 plan을 적용한 뒤 위 표의 *상태* 컬럼 갱신. plans/에서 baseline 항목을 건드린 변경이 있을 때마다 업데이트.

## References

- [security-baseline.md](security-baseline.md) — 기술 baseline + Tier 우선순위
- [iso27001-mapping.md](iso27001-mapping.md) — ISO 27001:2022 매핑
- [isms-mapping.md](isms-mapping.md) — 한국 ISMS-P 매핑
- [commit-gates.md](../conventions/commit-gates.md) — 코드 품질·시크릿 게이트
- AICPA TSP-100 2017 (Revised PoF 2022): https://www.aicpa-cima.com/resources/download/2017-trust-services-criteria-with-revised-points-of-focus-2022
- AWS AICPA SOC 2 Compliance Guide (2025-07): https://docs.aws.amazon.com/audit-manager/latest/userguide/SOC2.html
- AICPA TSC ↔ NIST crosswalk: https://www.nist.gov/itl/applied-cybersecurity/privacy-engineering/american-institute-certified-public-accountants-aicpa

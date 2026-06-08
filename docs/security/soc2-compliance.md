# SOC 2 Type II Compliance Design

eks-bootstrap이 SOC 2 Type II Trust Services Criteria를 어떻게 충족하는지 *설계 차원에서* 정리. 본 디렉토리 진입점은 [README.md](README.md).

이 문서는 인스펙션(현황 점검) 문서가 아니라 *모듈·환경 설계 시 같이 보는* 문서. 자원이 늘면서 단계적으로 채워감.

## 리뷰 포커스

- **전체 enumeration**: Common Criteria 33개(CC1.1~CC9.2)를 빠짐없이 표에 올림. `영역` 컬럼으로 기술/혼합/조직/AWS-inherited 구분. 조직·AWS 통제는 out-of-repo + owner 명시.
- **AICPA 명시 X · industry-common interpretation**: CC1.5 / CC3.4 / CC4.2 / CC5.1~5.3. 표 disclaimer 박혀있음. audit firm 사전 협의 필요.
- **CC9 의미 정합성**: CC9.1 = 사업중단 위험 완화, CC9.2 = 벤더·제3자 위험 (AICPA 정의 순서). 직관과 반대라 자주 swap됨 — 본 문서는 AICPA 정의 기준.
- **Phase 매핑 정합성**: 같은 통제(예: CC6.1)의 Phase 값이 [security-baseline.md](security-baseline.md) Phase 표와 모순 없는지.
- **Type I/II 시간축**: Phase 2 baseline 완료 = Type I 후보, +6~12개월 운영 = Type II first-time 후보. 본 레포 phase 일정과 정합한지.
- **Confidentiality C1.x**: Phase 3 도입. 글로벌 사업 (특히 EU 고객) 자주 묻힘.

## 범위

SOC 2 Trust Services Criteria는 **5개 카테고리·총 61개 기준**. 본 레포의 카테고리별 scope 결정:

| 카테고리 | 기준 수 | 본 레포 scope |
|---|---|---|
| **Security (Common Criteria, CC)** | 33 | **필수 — 전체 enumerate** (아래 매핑) |
| Availability (A1.x) | 3 | Phase 3 도입 (용량·백업·복구) |
| Confidentiality (C1.x) | 2 | Phase 3 도입 (글로벌 사업 대응) |
| Processing Integrity (PI1.x) | 5 | **범위 밖** — 트랜잭션 처리 정확성은 앱 레이어 책임 ([PI/P scope-out](#processing-integrity--privacy-범위-밖-선언)) |
| Privacy (P1~P8) | 18 | **범위 밖** — 개인정보 처리는 앱+법무 책임 ([PI/P scope-out](#processing-integrity--privacy-범위-밖-선언)) |

"Common Criteria"의 *Common*은 5개 카테고리 **전체에 공통 적용**된다는 뜻 (Security category가 곧 CC). A/C/PI/P는 그 위에 *supplemental* 기준을 얹음.

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

## Common Criteria 매핑 (Security — 전체 33 CC)

CC1.1~CC9.2 전체를 enumerate. 각 통제별로: *영역* + *owner* + *대응 baseline / evidence* + *현재 상태* + *목표 Phase*.

- **영역**: `기술`(IaC로 직접 충족) / `혼합`(IaC 일부 + 조직 절차·증거) / `조직`(순수 거버넌스·정책·HR, out-of-repo) / `AWS-inherited`(AWS 책임, AWS SOC 2 리포트로 상속).
- **상태 값**: `적용` / `부분` / `미적용` / `out-of-repo`(조직·AWS 책임 — 본 레포가 구현하지 않음).
- **Owner**: 통제 책임 주체. 기술/혼합은 `보안팀`(=보안·플랫폼팀). 조직 영역(`영역`=조직)은 구체 주체를 그대로 표기(이사회·경영진·HR·법무·조달 등 — `영역`이 이미 "조직"이라 owner는 *누가*에 집중). AWS-inherited는 `AWS`, 앱 레이어는 `앱 개발팀`. 한 통제에 둘 이상 걸리면 병기 (예: `보안팀·경영진`).

**매핑 disclaimer**: AICPA TSP-100은 통제(criterion)만 명시하고 구체적 IaC evidence 매핑은 산업 통념·audit firm 해석에 의존. 본 문서의 **CC1.5, CC3.4, CC4.2, CC5.1~5.3** 매핑은 *industry-common interpretation*으로, audit firm마다 evidence 인정 범위가 다를 수 있음. 실제 audit 시 firm과 사전 협의 권장.

### CC1 — Control Environment

거버넌스·tone at the top. 대부분 조직 영역. CC1.5만 IaC 흔적이 *partial evidence* (audit firm마다 해석 차이 — 박지 말고 보조로만).

| 통제 | 영역 | Owner | Baseline / Evidence | 상태 | Phase |
|---|---|---|---|---|---|
| CC1.1 integrity·윤리 commitment | 조직 | 경영진·이사회 | 행동강령, 윤리 정책 | out-of-repo | - |
| CC1.2 이사회 독립·감독 | 조직 | 이사회 | 거버넌스 차터, 감사위 oversight | out-of-repo | - |
| CC1.3 조직구조·보고체계·권한 | 조직 | 경영진 | 조직도, R&R 정의 | out-of-repo | - |
| CC1.4 역량 commitment | 조직 | HR | JD, 채용·교육·평가 기록 | out-of-repo | - |
| CC1.5 accountability | 혼합 | 경영진·보안팀 | git commit author + `CODEOWNERS` (도입 시, partial evidence — AICPA 명시 X) | 부분 | Phase 1~2 |

### CC2 — Communication and Information

내부·외부 communication. 대부분 조직 영역.

| 통제 | 영역 | Owner | Baseline / Evidence | 상태 | Phase |
|---|---|---|---|---|---|
| CC2.1 quality information (내부통제용) | 혼합 | 보안팀 | CloudTrail·control plane logs + `docs/` 문서화 (partial evidence) | 부분 | Phase 1~2 |
| CC2.2 내부 communication (책임·목표 전파) | 조직 | 경영진·HR | 보안 정책 공지, 온보딩·보안 교육 | out-of-repo | - |
| CC2.3 외부 communication | 조직 | 경영진·법무 | 고객 공지, status page, 보안 고지·SLA | out-of-repo | - |

### CC3 — Risk Assessment

| 통제 | 영역 | Owner | Baseline / Evidence | 상태 | Phase |
|---|---|---|---|---|---|
| CC3.1 목표 명확화 | 조직 | 경영진 | 비즈니스 목표·리스크 허용수준 정의 | out-of-repo | - |
| CC3.2 리스크 식별·분석 | 조직 | 경영진·보안팀 | 리스크 레지스터, threat model | out-of-repo | - |
| CC3.3 부정(fraud) 위험 고려 | 조직 | 경영진·감사 | fraud risk 평가 | out-of-repo | - |
| CC3.4 변경 위험 평가 | 혼합 | 보안팀 | plan S5(Rollback Trigger) + S6(Rollback Procedure) — 변경 전 위험 식별 + 완화 절차 | 적용 | Phase 1 |

### CC4 — Monitoring Activities

| 통제 | 영역 | Owner | Baseline / Evidence | 상태 | Phase |
|---|---|---|---|---|---|
| CC4.1 통제 평가 (ongoing/separate) | 혼합 | 보안팀 | drift detection (`terraform plan -detailed-exitcode`) + 정기 검토 기록 | 미적용 | Phase 2 |
| CC4.2 결함 communication | 혼합 | 보안팀·경영진 | ADR + post-incident review docs + escalation 절차 | 부분 | Phase 1~3 |

### CC5 — Control Activities

| 통제 | 영역 | Owner | Baseline / Evidence | 상태 | Phase |
|---|---|---|---|---|---|
| CC5.1 통제활동 선택·개발 | 혼합 | 보안팀 | `docs/plans/` template (S3.5 Security Review) + [commit-gates.md](../conventions/commit-gates.md) | 적용 | Phase 1 |
| CC5.2 기술 통제 선택 | 기술 | 보안팀 | gitleaks, tfsec, terraform_trivy, fmt, validate, tflint | 적용 | Phase 1 |
| CC5.3 정책·절차로 deploy | 혼합 | 보안팀 | conventions/ (resource-naming, tagging, terraform-variables 등) + 정책 준수 | 적용 | Phase 1 |

### CC6 — Logical and Physical Access

CC6.4/6.5는 물리 통제 — AWS 데이터센터 책임이라 **AWS SOC 2 리포트로 상속**(carve-out 또는 inclusive method). 본 레포 코드로 충족 불가.

| 통제 | 영역 | Owner | Baseline / Evidence | 상태 | Phase |
|---|---|---|---|---|---|
| CC6.1 논리적 접근 제어 | 기술 | 보안팀 | EKS `authentication_mode=API`, IRSA per pod, IAM least privilege | 부분 | Phase 1~2 |
| CC6.1 암호화 | 기술 | 보안팀 | EBS·RDS·EKS Secret 암호화 (AWS-managed key -> Phase 2 CMK) | 부분 | Phase 1~2 |
| CC6.1 KMS CMK rotation | 기술 | 보안팀 | annual rotation 활성 | 미적용 | Phase 2 |
| CC6.2 사용자 등록·인증 | 혼합 | 보안팀 | ArgoCD OAuth, AWS IAM, Root MFA (사전조건) + 등록 절차 | 부분 | Phase 1~2 |
| CC6.3 인증정보·접근권한 관리 | 혼합 | 보안팀 | IRSA (IAM access key 미사용), SSM/Secrets Manager, **rotation Lambda** + 분기 access review | 부분 | Phase 1~2 |
| CC6.4 시설 물리 접근 제한 | AWS-inherited | AWS | AWS 데이터센터 물리 보안 (AWS SOC 2 리포트 상속) | out-of-repo | - |
| CC6.5 자산 폐기 시 데이터 파기 | 혼합 | AWS·보안팀 | 물리 매체 파기 = AWS / 논리 삭제 = EBS·S3 삭제, crypto-shredding (KMS key 폐기) | 부분 | Phase 2~3 |
| CC6.6 외부 위협 차단 | 기술 | 보안팀 | EKS API private, SG ingress 제한, S3 account-level public block, **WAF (Phase 3), NACL (Phase 3)** | 부분 | Phase 1~3 |
| CC6.7 데이터 전송 보호 | 기술 | 보안팀 | RDS TLS 강제, ALB ACM, mTLS (Phase 2) | 부분 | Phase 1~2 |
| CC6.8 비인가 코드 차단 | 기술 | 보안팀 | Pod Security Standards, Kyverno | 미적용 | Phase 3 |

### CC7 — System Operations

| 통제 | 영역 | Owner | Baseline / Evidence | 상태 | Phase |
|---|---|---|---|---|---|
| CC7.1 보안 모니터링 | 기술 | 보안팀 | EKS control plane logs 5종, region default CloudTrail | 적용 | Phase 1 |
| CC7.1 시간 동기화 | 기술 | 보안팀 | AWS Time Sync (EKS·EC2 기본) | 적용 | Phase 1 |
| CC7.2 시스템 모니터링 (CloudTrail) | 기술 | 보안팀 | **multi-region trail + log file validation** | 미적용 | Phase 1~2 |
| CC7.2 audit log immutability | 기술 | 보안팀 | **S3 Object Lock on audit log buckets** (bucket 생성 시 enable 필수) | 미적용 | Phase 2 |
| CC7.2 log retention | 기술 | 보안팀 | Phase 1: 90일 -> **Phase 2: 365일 (SOC 2 권장 최소)** | 부분 | Phase 2 |
| CC7.2 VPC Flow Logs / ALB access logs | 기술 | 보안팀 | S3 destination | 미적용 | Phase 2 |
| CC7.2 RDS audit logging (pgAudit) | 기술 | 보안팀 | parameter group + `shared_preload_libraries` | 미적용 | Phase 2 |
| CC7.3 보안 사건 평가·triage | 혼합 | 보안팀 | GuardDuty, Security Hub, Inspector + triage 절차 | 미적용 | Phase 3 |
| CC7.4 보안 사건 대응 | 혼합 | 보안팀 | 런북 + 자동 알람 + IR 프로세스 | 미적용 | Phase 3 |
| CC7.5 복구 (BC/DR) | 혼합 | 보안팀·경영진 | 백업·복원·DR + 복구 절차·시연 기록 | 미적용 | Phase 3 |

### CC8 — Change Management

| 통제 | 영역 | Owner | Baseline / Evidence | 상태 | Phase |
|---|---|---|---|---|---|
| CC8.1 변경 관리 | 혼합 | 보안팀 | `docs/plans/` + git history + ADR + PR 승인 기록 | 적용 | Phase 1 |
| CC8.1 코드 품질 게이트 | 기술 | 보안팀 | [commit-gates.md](../conventions/commit-gates.md) | 적용 | Phase 1 |
| CC8.1 CI 게이트 | 기술 | 보안팀 | GitHub Actions에서 pre-commit 재실행 | 미적용 | Phase 2 |

### CC9 — Risk Mitigation

AICPA 정의: **CC9.1 = 사업 중단(business disruption) 위험 완화, CC9.2 = 벤더·제3자(business partner) 위험**. 직관과 반대라 자주 swap되니 주의.

| 통제 | 영역 | Owner | Baseline / Evidence | 상태 | Phase |
|---|---|---|---|---|---|
| CC9.1 사업 중단 위험 완화 | 혼합 | 경영진·보안팀 | 환경 분리 (dev/staging/prod), tfstate 환경별 bucket, BC·보험 계획 | 부분 | Phase 2 |
| CC9.2 벤더·제3자 위험 | 혼합 | 법무·조달·보안팀 | provider/chart 버전 핀 + [versions.md "버전 변경 시 검증 절차"](../conventions/versions.md#버전-변경-시-검증-절차) (partial) + sub-processor 평가 | 부분 | Phase 1~2 |

## Common Criteria 영역 분류 요약

33개 CC를 영역별로 집계. "코드만으로 SOC 2 안 됨"이 숫자로 드러남.

| 영역 | 개수 | 해당 통제 |
|---|---|---|
| **기술** (IaC로 직접 충족) | 7 | CC5.2, CC6.1, CC6.6, CC6.7, CC6.8, CC7.1, CC7.2 |
| **혼합** (IaC 일부 + 조직 절차·증거) | 16 | CC1.5, CC2.1, CC3.4, CC4.1, CC4.2, CC5.1, CC5.3, CC6.2, CC6.3, CC6.5, CC7.3, CC7.4, CC7.5, CC8.1, CC9.1, CC9.2 |
| **조직** (순수 거버넌스·정책·HR, out-of-repo) | 9 | CC1.1~1.4, CC2.2, CC2.3, CC3.1~3.3 |
| **AWS-inherited** (AWS SOC 2 리포트 상속) | 1 | CC6.4 (CC6.5 물리 매체 파기 부분 포함) |

합계 33 (= 7 + 16 + 9 + 1). 같은 CC 번호가 여러 baseline 행으로 쪼개진 경우(예: CC6.1 3행, CC7.2 5행)는 CC 번호 기준 1개로 집계. CC가 여러 영역 행에 걸치면(예: CC8.1 = 변경 관리[혼합] + 코드 품질·CI 게이트[기술]) criterion 수준의 *포괄* 영역(CC8.1 -> 혼합)으로 분류.

eks-bootstrap이 직접 책임지는 건 **기술 7 + 혼합 16의 기술 부분**. 조직 9 + 혼합의 절차·증거 + AWS-inherited 1은 코드 밖. fork 시 이 표가 "내가 조직으로 따로 해야 하는 것"의 체크리스트.

## Availability TSC (Phase 3 진입 시 추가)

| 통제 | 영역 | Owner | Baseline | Phase |
|---|---|---|---|---|
| A1.1 용량 관리 | 기술 | 보안팀 | Karpenter dynamic provisioning | Phase 3 |
| A1.2 백업·복원 | 혼합 | 보안팀 | Aurora PITR 7일+, AWS Backup, restore test 기록 | Phase 3 |
| A1.3 복구 절차 | 혼합 | 보안팀·경영진 | DR runbook + 복구 시연 | Phase 3 |

## Confidentiality TSC (Phase 3 진입 시 추가, 글로벌 사업 자주 묻힘)

| 통제 | 영역 | Owner | Baseline | Phase |
|---|---|---|---|---|
| C1.1 기밀정보 식별 | 혼합 | 보안팀·앱 개발팀 | 데이터 분류 정책 (앱 레이어와 협업) | Phase 3 |
| C1.2 기밀정보 파기 | 혼합 | 보안팀 | Aurora PITR retention, S3 lifecycle, secrets rotation, EBS snapshot 보존 기간 (CC6.5와 연계) | Phase 3 |

## Processing Integrity / Privacy (범위 밖 선언)

"전체 규격을 빠짐없이 보이게" 위해 두 카테고리도 명시적으로 scope-out. 누락이 아니라 *의도적 제외*.

| 카테고리 | 기준 | Owner | 범위 밖인 이유 |
|---|---|---|---|
| **Processing Integrity** (PI1.1~1.5) | 처리 완전성·정확성·적시성·승인 | 앱 개발팀 | 인프라 baseline이 아니라 *애플리케이션 트랜잭션 로직*의 속성. eks-bootstrap은 실행 플랫폼만 제공, 처리 정확성은 위에 올라가는 앱 책임. |
| **Privacy** (P1~P8, 18 기준) | 개인정보 고지·수집·이용·보관·파기·제3자 제공 | 앱 개발팀 + 법무·DPO | 개인정보 처리 흐름은 앱 레이어 + 법무 영역. GDPR/개인정보보호법과 직결 ([iso27001-mapping.md](iso27001-mapping.md) "GDPR과의 관계" 참조). 인프라는 C1.x(기밀성)·CC6.x(접근통제)로 *보조* 기여만. |

두 카테고리는 고객·audit firm이 명시적으로 요구할 때 앱 개발팀·법무와 별도 engagement로 채움. 인프라 레포 단독으로는 충족 대상 아님.

## Audit Timeline (Type I vs Type II)

SOC 2는 두 가지 audit type. 글로벌 사업이면 보통 둘 다 거침 (Type I 먼저 -> Type II 후속).

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
- AICPA TSC <-> NIST crosswalk: https://www.nist.gov/itl/applied-cybersecurity/privacy-engineering/american-institute-certified-public-accountants-aicpa

**기준 수 검증** (2026-06 web 확인): Common Criteria 33 = CC1(5)+CC2(3)+CC3(4)+CC4(2)+CC5(3)+CC6(8)+CC7(5)+CC8(1)+CC9(2). 전체 5개 카테고리 총 61 기준 (CC 33 + A 3 + C 2 + PI 5 + P 18). 일부 2차 자료는 **CC9.2를 누락해 "32"로 표기**하나 AICPA 원문에 CC9.2(벤더·제3자 위험) 존재 — 33이 정확.

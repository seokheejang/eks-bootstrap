# SOC 2 Type II Compliance Design

eks-bootstrap이 SOC 2 Type II Trust Services Criteria를 어떻게 충족하는지 *설계 차원에서* 정리.

이 문서는 인스펙션(현황 점검) 문서가 아니라 *모듈·환경 설계 시 같이 보는* 문서. 자원이 늘면서 단계적으로 채워감.

## 범위

- 1차 프레임워크: **SOC 2 Type II** (Trust Services Criteria 중 Security)
- 추후 확장: Availability, Confidentiality (Phase 3)
- Privacy: 본 레포 범위 밖 (앱 레이어 책임)
- ISMS-P 매핑은 [isms-mapping.md](isms-mapping.md)

## SOC 2가 자동 보장하지 않는 것

IaC만으로 충족 불가. 운영 절차·증거가 필요:

- 통제가 *감사 기간 동안* 작동했다는 증거
- 접근 검토 실제 수행 기록
- 사고 대응 실제 수행 기록
- 백업 복원 시연 기록
- 직원 정책 준수 기록

eks-bootstrap은 *기술 baseline*만 제공. 위는 별도 운영 단계에서 채움.

## Trust Services Criteria 매핑 (Security 우선)

각 통제별로: *대응 baseline 항목* + *현재 상태* + *목표 Phase*.

상태 값:
- **적용**: 해당 Phase에 baseline으로 채택됨
- **부분**: 일부 통제만 적용, 나머지는 후속 Phase
- **미적용**: 아직 baseline에 없음

### CC1~CC3 — 조직 통제

CC1(Control Environment), CC2(Communication), CC3(Risk Assessment)은 **IaC 범위 밖** (인사·조직 영역). 본 레포 미적용.

### CC4 — Monitoring Activities

| 통제 | Baseline | 상태 | Phase |
|---|---|---|---|
| CC4.1 통제 평가 | drift detection (`terraform plan -detailed-exitcode`) | 미적용 | Phase 2 |

### CC5 — Control Activities

대부분 CC6/CC7과 함께 처리. 별도 행 없음.

### CC6 — Logical and Physical Access

| 통제 | Baseline | 상태 | Phase |
|---|---|---|---|
| CC6.1 논리적 접근 제어 | EKS `authentication_mode=API`, IRSA per pod, IAM least privilege | 부분 | Phase 1~2 |
| CC6.1 암호화 | EBS·RDS·EKS Secret 암호화 (AWS-managed key) | 부분 (Phase 1) | Phase 1~2 (CMK는 Phase 2) |
| CC6.2 사용자 등록·인증 | ArgoCD OAuth, AWS IAM, Root MFA (계정 사전조건) | 부분 | Phase 1~2 |
| CC6.3 인증 정보 관리 | IAM access key 미사용 (IRSA), SSM/Secrets Manager | 부분 | Phase 1~2 |
| CC6.6 외부 위협 차단 | EKS API private, SG ingress 제한, S3 account-level public block | 부분 | Phase 1~3 (WAF는 Phase 3) |
| CC6.7 데이터 전송 보호 | RDS TLS 강제, ALB ACM | 부분 (Phase 1) | Phase 1~2 (mTLS는 Phase 2) |
| CC6.8 비인가 코드 차단 | Pod Security Standards, Kyverno | 미적용 | Phase 3 |

### CC7 — System Operations

| 통제 | Baseline | 상태 | Phase |
|---|---|---|---|
| CC7.1 보안 모니터링 | EKS control plane logs 5종, region default CloudTrail | 적용 (Phase 1) | Phase 1 |
| CC7.2 시스템 모니터링 | Log retention 90일(Phase 1) -> 365일(Phase 3), VPC Flow Logs, ALB access logs, CloudTrail centralized | 부분 (Phase 1) | Phase 2~3 |
| CC7.3 보안 사건 탐지 | GuardDuty, Security Hub | 미적용 | Phase 3 |
| CC7.4 보안 사건 대응 | 런북 + 자동 알람 | 미적용 | Phase 3 |
| CC7.5 복구 | 백업·복원·DR | 미적용 | Phase 3 |

### CC8 — Change Management

| 통제 | Baseline | 상태 | Phase |
|---|---|---|---|
| CC8.1 변경 관리 | `docs/plans/` + git history + ADR | 적용 (Phase 1) | Phase 1 |
| CC8.1 코드 품질 게이트 | [commit-gates.md](../conventions/commit-gates.md) (gitleaks, tfsec, fmt, validate, tflint) | 적용 (Phase 1) | Phase 1 |
| CC8.1 CI 백업 게이트 | GitHub Actions에서 pre-commit 재실행 | 미적용 | Phase 2 |

### CC9 — Risk Mitigation

| 통제 | Baseline | 상태 | Phase |
|---|---|---|---|
| CC9.1 벤더 위험 | provider/chart 버전 핀, IAM policy vendor | 부분 | Phase 1~2 |
| CC9.2 비즈니스 영향 | 환경 분리 (dev/staging/prod), tfstate 환경별 bucket | 부분 (Phase 2부터) | Phase 2 |

## Availability (Phase 3 진입 시 추가)

| 통제 | Baseline | Phase |
|---|---|---|
| A1.1 용량 관리 | Karpenter dynamic provisioning | Phase 3 |
| A1.2 백업·복원 | Aurora PITR 7일+, AWS Backup, restore test | Phase 3 |
| A1.3 복구 절차 | DR runbook | Phase 3 |

## 단계별 진척

각 모듈·환경 변경 plan을 적용한 뒤 위 표의 *상태* 컬럼 갱신. plans/에서 baseline 항목을 건드린 변경이 있을 때마다 업데이트.

## References

- [security-baseline.md](security-baseline.md) - 기술 baseline
- [isms-mapping.md](isms-mapping.md) - ISMS-P 매핑
- [commit-gates.md](../conventions/commit-gates.md) - 코드 품질·시크릿 게이트
- AWS SOC Compliance: https://aws.amazon.com/compliance/soc-faqs/
- AICPA TSC: https://www.aicpa-cima.com/topic/audit-assurance/audit-and-assurance-greater-than-soc-2

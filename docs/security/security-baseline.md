# Security Baseline

eks-bootstrap 자원이 지켜야 할 최소 보안 기준. 모든 환경(dev/staging/prod)에 적용.

목표: [SOC 2 Type II](soc2-compliance.md) 기술 통제 대부분을 자동으로 채우는 것. ISMS-P 매핑은 [isms-mapping.md](isms-mapping.md) 참조.

## 원칙

1. **최소 권한** — IAM·RBAC·SG·NetworkPolicy 모두 deny-by-default.
2. **암호화 기본 on** — 저장·전송·키 envelope 전부.
3. **감사 가능** — 변경·접근 모두 로그에 남음.
4. **재현 가능** — 손으로 만든 자원 없음. Terraform 외부 변경 = 드리프트.

## 사전 조건 (AWS 계정 수준)

Terraform 작업 전에 AWS 계정에 박혀 있어야 하는 setting. 1회성.

| 항목 | 적용 방법 | 이유 |
|---|---|---|
| EBS default encryption ON (region) | `aws ec2 enable-ebs-encryption-by-default` | 신규 볼륨 자동 암호화 |
| S3 public access block (account-level) | `aws s3control put-public-access-block` | 실수로 만든 bucket도 자동 차단 |
| Root account MFA | console에서 설정 | SOC 2 CC6.2 기본 |
| CloudTrail (region default trail) | 기본 활성 확인 | API 호출 감사 |

## Phase 1 Baseline (PoC)

| 영역 | 항목 | 적용 위치 |
|---|---|---|
| **Commit 게이트** | pre-commit 훅 (gitleaks, tfsec, fmt, validate, tflint) | [commit-gates.md](../conventions/commit-gates.md) |
| **EKS API** | Public endpoint 비활성 또는 CIDR 제한 | `modules/eks-cluster` |
| **EKS auth** | `authentication_mode = API` | `modules/eks-cluster` |
| **Control plane logs** | 5종 활성 (api/audit/authenticator/controllerManager/scheduler) | `modules/eks-cluster` |
| **Log retention** | 90일 (Phase 3에 365일 상향) | env var |
| **Node EBS** | gp3 + 암호화 (default AWS-managed key) | `modules/eks-node-group` |
| **IMDSv2** | 강제 (MNG·Karpenter 노드 모두) | `modules/eks-node-group` |
| **EKS Secret 암호화** | 기본 envelope (Phase 2에 CMK로 상향) | `modules/eks-cluster` |
| **tfstate 보호** | S3 버저닝 + SSE-S3 + public access block + `prevent_destroy` + noncurrent 90일 만료 + S3 native lock (`use_lockfile`) | `infra/tf-backend` |
| **RDS 저장 암호화** | on (AWS-managed key, Phase 3에 CMK) | `modules/rds-aurora` |
| **RDS TLS 강제** | `rds.force_ssl = 1` | `modules/rds-aurora` |
| **RDS public access** | `publicly_accessible = false` | `modules/rds-aurora` |
| **IRSA** | Temporal pod용 role 분리 | `modules/irsa` + `environments/dev` |
| **필수 태그** | Project, Environment, ManagedBy, Owner | provider `default_tags` |

## Phase 2 추가

| 항목 | SOC 2 매핑 |
|---|---|
| EKS Secret KMS CMK envelope | CC6.1 (접근 제어·암호화) |
| ESO (External Secrets Operator) | 시크릿 평문 분리 |
| ALB access logs S3 | CC7.2 (모니터링) |
| VPC Flow Logs S3 | CC7.2 |
| mTLS (Temporal frontend) | CC6.7 (전송 보호) |
| ArgoCD GitHub OAuth + local admin 비활성 | CC6.2 |
| CI 백업 게이트 (GitHub Actions에서 pre-commit 재실행) | CC8.1 |

## Phase 3 추가

| 항목 | SOC 2 매핑 |
|---|---|
| GuardDuty + Security Hub + Config | CC7.3 (탐지) |
| WAF (public ALB) | CC6.6 |
| CloudTrail centralized + CMK + log file validation | CC7.2 |
| Log retention 365일로 상향 | CC7.2 |
| Pod Security Standards `restricted` | CC6.8 |
| Kyverno/Gatekeeper | CC6.1 |
| AWS Backup plans | A1.2 (Availability) |
| Aurora Multi-AZ + PITR 7일+ | A1.2 |
| EBS·RDS·tfstate에 CMK 적용 | CC6.1 강화 |

## 운영 invariants

- 모듈 신규 자원 추가 시 위 baseline 자동 적용 여부 점검.
- baseline을 일부러 깨야 하는 경우(예: 임시 디버깅용 public access) `docs/plans/`에 명시 + 만료일 박음.
- baseline 변경(상향/하향)은 ADR 필수.

## References

- [soc2-compliance.md](soc2-compliance.md) - SOC 2 TSC와 baseline 매핑
- [isms-mapping.md](isms-mapping.md) - ISMS-P 차이점
- [commit-gates.md](../conventions/commit-gates.md) - pre-commit 훅

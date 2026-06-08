# Security Baseline

eks-bootstrap 자원이 지켜야 할 최소 보안 기준. 모든 환경(dev/staging/prod)에 적용. 본 디렉토리 진입점은 [README.md](README.md).

목표: [SOC 2 Type II](soc2-compliance.md) 기술 통제 대부분을 자동으로 채우는 것. 글로벌 사업 시 [iso27001-mapping.md](iso27001-mapping.md), 한국 시장은 [isms-mapping.md](isms-mapping.md) 보조.

## 리뷰 포커스

- **Tier 1 immutable 항목 11개** — 첫 plan(`20260513-tf-backend.md`) 작성 시 모두 반영되는지.
- **Tier 1 <-> Tier 2 경계** — EKS Secret CMK / Aurora storage_encrypted / S3 Object Lock은 정말 immutable인가 (AWS docs 기준).
- **Phase 1 baseline 표의 Tier 컬럼** — Tier 표와 일치하는지. 최근 4건(EKS API public / RDS public access / IRSA / 필수 태그) T1 -> T2 정정 적용됨.
- **Tier 3 "S3 Object Lock on other audit log buckets" 캐비엇** — 해당 bucket 생성 시점에 enable 필수.

## 원칙

1. **최소 권한** — IAM·RBAC·SG·NetworkPolicy 모두 deny-by-default.
2. **암호화 기본 on** — 저장·전송·키 envelope 전부.
3. **감사 가능** — 변경·접근 모두 로그에 남음.
4. **재현 가능** — 손으로 만든 자원 없음. Terraform 외부 변경 = 드리프트.
5. **실행 시 검증** — `terraform apply` 후 plan S4(Success Criteria) 명령으로 결과 확인 -> S7(Verification Result)에 기록. 미충족 시 S5/S6 rollback 또는 baseline 갱신. `terraform plan`이 못 잡는 위험은 실행 후 검증으로만 잡힘 ([versions.md "Apply/Runtime 함정 노트"](../conventions/versions.md#applyruntime-함정-노트) 참조).

## 우선순위 분류 — 구축 시 박을 것 vs 후속 추가

세 단계로 분류. **Tier 1은 day 1에 박지 않으면 변경이 매우 비싸거나 불가능**. Tier 2/3는 운영 중 추가 가능.

### Tier 1 — 첫 Terraform apply에 반드시 (immutable·재생성 비용 매우 큼)

| 항목 | 적용 시점 | 왜 day 1인가 |
|---|---|---|
| AWS 계정 EBS default encryption ON (region) | 사전 조건 | 안 박으면 그 시점 이후 만든 모든 볼륨이 미암호화로 시작. retroactive 적용 불가 |
| Root account MFA | 사전 조건 | day 1이 가장 안전 |
| S3 tfstate bucket Object Lock | infra/tf-backend (Phase 1 step 1) | **bucket 생성 시에만 enable 가능. 나중에 켤 수 없음 (AWS 제약)** |
| S3 tfstate bucket versioning + SSE + public access block + `prevent_destroy` | infra/tf-backend (Phase 1 step 1) | 생성 시 박는 게 표준 |
| VPC CIDR + subnet 구조 (private/public 분리, 여유 IP) | modules/vpc (Phase 1 step 3) | 사실상 immutable. 변경 = VPC 재생성 |
| EKS cluster KMS encryption_config (Secret envelope CMK) | modules/eks-cluster (Phase 1 step 4) | **cluster 생성 시에만 설정. 나중에 켜려면 cluster 재생성** |
| EKS authentication_mode = `API` | modules/eks-cluster (Phase 1 step 4) | 변경 가능하나 aws-auth ConfigMap 이전 비용 큼 |
| EKS control plane logs 5종 활성 | modules/eks-cluster (Phase 1 step 4) | 토글 가능하지만 evidence 일관성 위해 day 1 |
| Aurora `storage_encrypted = true` + CMK | modules/rds-aurora (Phase 1 step 7) | **변경 불가. 생성 후 storage encryption toggle 불가** |
| Aurora cluster identifier 명명 규칙 | step 7 | 변경 시 사실상 신규 cluster |
| IMDSv2 강제 (MNG·Karpenter 노드) | modules/eks-node-group (Phase 1 step 5) | 변경 가능하나 launch template 재생성 |

### Tier 2 — Phase 1 후반 / Phase 2 (운영 중 추가 가능, evidence 일관성 위해 빨리)

| 항목 | 적용 시점 | 비고 |
|---|---|---|
| commit-gates (gitleaks, tfsec, fmt, validate, tflint) | Phase 1 step 2~ | 코드 작성 시작 시점에 박을 것 ([commit-gates.md](../conventions/commit-gates.md)) |
| CloudTrail multi-region trail + log file validation | Phase 1 후반 | toggle 가능. evidence 일관성 위해 day 1 권장 (region default trail로는 부족) |
| Log retention 365일 상향 (CloudWatch·S3) | Phase 2 | 변경 가능. SOC 2 auditor 권장 최소 1년 |
| ESO (External Secrets Operator) | Phase 2 | helm release 추가. K8s Secret 평문 분리 |
| KMS CMK rotation 활성 (annual) | Phase 2 | 변경 가능 (`enable_key_rotation = true`) |
| EBS·RDS·tfstate에 CMK 적용 (AWS-managed -> customer-managed) | Phase 2 | 변경 가능하나 일부 자원은 재생성 (tfstate bucket 등 — 새 bucket 만들어 migration) |
| ALB access logs S3 | Phase 2 (Ingress 도입 시) | 자원 추가, downtime 없음 |
| VPC Flow Logs S3 | Phase 2 | 자원 추가, downtime 없음 |
| mTLS (Temporal frontend) | Phase 2 | helm values 변경 |
| ArgoCD GitHub OAuth + local admin 비활성 | Phase 2 | ([ADR 0006](../decisions/0006-argocd-package-only.md)) |
| RDS pgAudit (parameter group + `shared_preload_libraries`) | Phase 2 | 변경 가능하나 cluster restart 필요 (downtime) |
| Aurora `force_ssl = 1` | Phase 1~2 | parameter group change |
| Secrets Manager rotation Lambda (DB credential 자동 회전) | Phase 2 | 자원 추가 |

### Tier 3 — Phase 3+ (운영 시작 후 자유롭게 추가)

| 항목 | 적용 시점 | 비고 |
|---|---|---|
| GuardDuty / Security Hub / Config / Inspector | Phase 3 | enable/disable 자유 |
| WAF on public ALB | Phase 3 | ALB 변경 없이 attach 가능 |
| Pod Security Standards `restricted` | Phase 3 | namespace label |
| Kyverno / Gatekeeper | Phase 3 | helm release |
| NACL (defense-in-depth, SG와 별도) | Phase 3 | 자원 추가 |
| CloudTrail centralized account 분리 | Phase 3 | 마이그레이션 비용 있음, multi-account 필요 |
| AWS Backup plans | Phase 3 | 자원 추가 |
| Aurora Multi-AZ provisioned + PITR 7일+ | Phase 3 | Aurora Serverless -> provisioned 전환, downtime 가능 |
| S3 Object Lock on other audit log buckets (CloudTrail, ALB logs, VPC Flow) | Phase 3 | **각 bucket 생성 시 enable 필수**. Phase 2에 해당 bucket 만들 때 미리 박을 것 |
| Confidentiality 통제 (데이터 분류·파기 정책) | Phase 3 | C1.1/C1.2 ([soc2-compliance.md](soc2-compliance.md#confidentiality-tsc)) |

## 사전 조건 (AWS 계정 수준)

Terraform 작업 전에 AWS 계정에 박혀 있어야 하는 setting. 1회성. **Tier 1 항목 포함**.

| 항목 | 적용 방법 | 이유 |
|---|---|---|
| EBS default encryption ON (region) | `aws ec2 enable-ebs-encryption-by-default` | Tier 1: retroactive 불가 |
| S3 public access block (account-level) | `aws s3control put-public-access-block` | 실수로 만든 bucket도 자동 차단 |
| Root account MFA | console 설정 | Tier 1: SOC 2 CC6.2 기본 |
| CloudTrail multi-region trail + LFV | Terraform 또는 console | Tier 2 (region default trail로는 부족) |
| 시간 동기화 | (AWS 기본 — Amazon Time Sync) | 추가 작업 불필요. 단 audit 시점에 명시 |

## Phase 1 Baseline (PoC)

Tier 1 + 일부 Tier 2 항목이 여기 포함. 첫 plan(`20260513-tf-backend.md`)부터 강제 확인.

| 영역 | 항목 | 적용 위치 | Tier |
|---|---|---|---|
| **Commit 게이트** | pre-commit 훅 ([commit-gates.md](../conventions/commit-gates.md)) | Phase 1 step 2~ | T2 |
| **EKS API** | Public endpoint 비활성 또는 CIDR 제한 | `modules/eks-cluster` | T2 |
| **EKS auth** | `authentication_mode = API` | `modules/eks-cluster` | T1 |
| **Control plane logs** | 5종 활성 (api/audit/authenticator/controllerManager/scheduler) | `modules/eks-cluster` | T1 |
| **Log retention** | 90일 (Phase 2에 365일로 상향) | env var | T2 (상향) |
| **Node EBS** | gp3 + 암호화 (AWS-managed default key) | `modules/eks-node-group` | T1 |
| **IMDSv2** | 강제 (MNG·Karpenter 노드 모두) | `modules/eks-node-group` | T1 |
| **EKS Secret 암호화 (CMK envelope)** | KMS CMK envelope | `modules/eks-cluster` | **T1 (생성 시에만)** |
| **tfstate 보호** | S3 versioning + SSE-S3 + public access block + `prevent_destroy` + Object Lock + noncurrent 90일 만료 + S3 native lock (`use_lockfile`) | `infra/tf-backend` | T1 |
| **RDS 저장 암호화** | on (CMK) | `modules/rds-aurora` | **T1 (생성 시에만)** |
| **RDS TLS 강제** | `rds.force_ssl = 1` | `modules/rds-aurora` | T2 |
| **RDS public access** | `publicly_accessible = false` | `modules/rds-aurora` | T2 |
| **IRSA** | Temporal pod용 role 분리 | `modules/irsa` + `environments/dev` | T2 |
| **필수 태그** | Project, Environment, ManagedBy, Owner | provider `default_tags` | T2 |

## Phase 2 추가

| 항목 | SOC 2 매핑 | Tier |
|---|---|---|
| ESO (External Secrets Operator) | 시크릿 평문 분리 | T2 |
| ALB access logs S3 | CC7.2 | T2 |
| VPC Flow Logs S3 | CC7.2 | T2 |
| mTLS (Temporal frontend) | CC6.7 | T2 |
| ArgoCD GitHub OAuth + local admin 비활성 | CC6.2 | T2 |
| CI 백업 게이트 (GitHub Actions에서 pre-commit 재실행) | CC8.1 | T2 |
| KMS CMK rotation 활성 | CC6.1 | T2 |
| RDS pgAudit | CC7.1 | T2 |
| Log retention 365일 | CC7.2 | T2 |
| Secrets Manager rotation Lambda | CC6.3 | T2 |

## Phase 3 추가

| 항목 | SOC 2 매핑 | Tier |
|---|---|---|
| GuardDuty + Security Hub + Config + Inspector | CC7.3 | T3 |
| WAF (public ALB) | CC6.6 | T3 |
| CloudTrail centralized account 분리 + log file validation 강화 | CC7.2 | T3 |
| Pod Security Standards `restricted` | CC6.8 | T3 |
| Kyverno/Gatekeeper | CC6.1 | T3 |
| AWS Backup plans | A1.2 | T3 |
| Aurora Multi-AZ provisioned + PITR 7일+ | A1.2 | T3 |
| EBS·RDS·tfstate CMK 강화 | CC6.1 | T3 |
| NACL (defense-in-depth) | CC6.6 | T3 |
| Confidentiality 통제 (데이터 분류·파기) | C1.1, C1.2 | T3 |

## 운영 invariants

- **Tier 1 항목을 day 1에 빼먹으면 Phase 2/3에서 재생성·downtime 또는 evidence gap 발생**. 첫 plan부터 Tier 1 강제 점검.
- baseline을 일부러 깨야 하는 경우(예: 임시 디버깅용 public access) `docs/plans/`에 명시 + 만료일 박음.
- baseline 변경(상향/하향)은 ADR 필수.
- 모듈 신규 자원 추가 시 위 baseline 자동 적용 여부 점검.

## References

- [soc2-compliance.md](soc2-compliance.md) — SOC 2 TSC와 baseline 매핑 + audit timeline
- [iso27001-mapping.md](iso27001-mapping.md) — ISO 27001:2022 매핑 (글로벌 사업 보조)
- [isms-mapping.md](isms-mapping.md) — 한국 ISMS-P 매핑 (보조)
- [commit-gates.md](../conventions/commit-gates.md) — pre-commit 훅

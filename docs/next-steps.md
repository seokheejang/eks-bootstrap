# Next Steps

다음 세션에서 이어서 할 작업. 누적 변경은 git log 참조.

## 다음 세션 진입점 (이 순서로 읽기)

1. [CLAUDE.md](../CLAUDE.md) — 정체성·구조·invariants
2. [docs/plans/README.md](plans/README.md) — Phase 1 빌드 순서 8단계
3. [docs/security/README.md](security/README.md) — 보안 docs 진입점 + Quick Map (37 항목)
4. [docs/conventions/versions.md](conventions/versions.md) — 버전 핀 + 변경 검증 절차
5. 본 파일 (next-steps.md)

## 우선 작업 (Phase 1 build order)

각 단계 = 별도 plan 문서 (`docs/plans/YYYYMMDD-<slug>.md`). 빌드 순서 상세는 [plans/README.md](plans/README.md).

| # | 작업 | 비고 |
|---|---|---|
| 0 | **AWS 계정 사전 조건 1회 실행** (코드 X, console/CLI) | EBS default encryption ON, S3 account-level public access block, Root MFA, region default CloudTrail 활성 확인 — Tier 1 사전 조건 |
| 0.5 | `.gitignore` 작성 | `*.tfstate*`, `.terraform/`, `*.tfvars` (local override만) |
| 0.5 | `.pre-commit-config.yaml` 작성 | gitleaks, tfsec, terraform_fmt/validate/tflint, detect-private-key ([commit-gates.md](conventions/commit-gates.md)) |
| 1 | `infra/tf-backend/` Terraform 코드 | plan [`20260513-tf-backend.md`](plans/20260513-tf-backend.md) 따름. S3 bucket + `use_lockfile` + Object Lock |
| 2 | `environments/dev/` skeleton | provider.tf, backend.tf (partial config), variables.tf, terraform.tfvars |
| 3 | `modules/vpc/` + dev 호출 | VPC + subnets + NAT. T1: CIDR + subnet 구조 |
| 4 | `modules/eks-cluster/` | T1 immutable 박기: KMS encryption_config, `authentication_mode=API`, control plane logs 5종 |
| 5 | `modules/eks-node-group/` | T1: IMDSv2, EBS 암호화 |
| 6 | `modules/irsa/` | Temporal pod용 IRSA helper |
| 7 | `modules/rds-aurora/` | T1: `storage_encrypted` + CMK + cluster identifier. T2: `force_ssl = 1` |
| 8 | Temporal helm install | `environments/dev/charts/temporal/values.yaml` + Makefile. helm chart 버전 확정 필요 (현재 TBD) |

8단계까지 완료 = Phase 1 PoC 완료.

## 미해결 결정 (next 세션에 결정 필요)

- **Temporal helm chart 버전** — 현재 TBD ([versions.md "Helm Chart"](conventions/versions.md#helm-chart)). Phase 1 step 8 직전 확정.
- **도메인·DNS** — Temporal frontend 노출 시점에 결정 (Phase 2일 가능성).
- **VPC CIDR + subnet 구조** — `modules/vpc/` 작성 직전 확정. 향후 staging/prod·peering 고려한 IP 공간 설계.
- **AWS region** — 현재 가정 `ap-northeast-2`. 확정 또는 다중 region 결정.

## 향후 고려 (Phase 2~3)

- **Phase 1 후반**: CloudTrail multi-region + LFV ([security-baseline Tier 2](security/security-baseline.md#tier-2--phase-1-후반--phase-2-운영-중-추가-가능-evidence-일관성-위해-빨리))
- **Phase 2**: state 분리 (단일 -> 환경별), drift detection (CC4.1), ArgoCD 패키지 모듈, ESO, mTLS, log retention 365일
- **Phase 3**: Multi-AZ Aurora provisioned, GuardDuty/Security Hub, Pod Security, NACL, Confidentiality 통제
- **Audit milestone**: Phase 2 baseline 완료 -> Type I 후보. Phase 2 + 6~12개월 운영 -> Type II ([soc2-compliance.md Audit Timeline](security/soc2-compliance.md#audit-timeline-type-i-vs-type-ii))

## 보류 항목 (의식적 미작성)

- **Tier 통합 상세표** — Quick Map([security/README.md](security/README.md#quick-map-항목--tier--phase))으로 대체. 상세는 [security-baseline.md](security/security-baseline.md) Tier 표 그대로 유지.
- **soc2-checklist에 운영 절차 매뉴얼** — Type II observation 시점에 [runbooks/](runbooks/)로 작성.
- **GDPR 별도 문서** — 본 레포 범위 밖 (앱 + 법무). [iso27001-mapping.md "GDPR과의 관계"](security/iso27001-mapping.md)에 짧은 노트만.

## 세션 종료 시 점검

다음 세션 진입 시 본 파일 갱신:
- 완료된 step 체크
- 새로 발견된 미해결 결정 추가
- Phase 진척에 따라 "향후 고려" 항목 이동

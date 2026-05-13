# Version Pinning

## Terraform

- `required_version = ">= 1.11"` — S3 backend native locking(`use_lockfile`) 사용. 1.10 미만은 DynamoDB lock 의존이라 baseline 위반.
- 권장: 최신 stable.

## Provider

각 모듈 `versions.tf`에 핀.

| Provider | 핀 | Phase | Migration trap (silent breakage 주의) |
|---|---|---|---|
| `hashicorp/aws` | `~> 6.0` | Phase 1 | OpsWorks/SimpleDB 제거. `aws_region.name` deprecated. v5에서 silent drift 사례 보고. [v6 upgrade guide](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/guides/version-6-upgrade) |
| `hashicorp/tls` | `~> 4.0` | Phase 1 | 안정. EKS OIDC thumbprint·TLS 자원용 |
| `hashicorp/kubernetes` | `~> 3.0` | Phase 1~2 | `kubernetes_manifest` credential resolution 변경 (env var가 config 못 덮어씀). unversioned resource deprecated |
| `hashicorp/helm` | `~> 3.0` | Phase 2+ | **block→attribute syntax 전면 변경** (`kubernetes = {...}`, `set = [{...}]`). v2→v3 state migration 실패 보고 다수. 처음부터 v3로 작성. Phase 1 미사용 ([ADR 0005](../decisions/0005-helm-outside-terraform.md)) |
| `alekc/kubectl` | `~> 2.0` | Phase 2+ | `gavinbunney/kubectl` 비활성(2022-03~) → alekc fork. CRD-의존 리소스(Gateway API, ESO CR)용. ArgoCD 도입 시 함께 ([ADR 0006](../decisions/0006-argocd-package-only.md)) |

## EKS

- 최소 1.28 ([temporal-on-eks.md](../temporal-on-eks.md)).
- Phase 1 target: **1.35** (적용 직전 latest stable 재확인).

## EKS / Karpenter / Cilium 호환성 anchor

| EKS K8s | Karpenter | Cilium | 검증 상태 |
|---|---|---|---|
| 1.35 | 1.12.0 | 1.19.3 | Karpenter ✓ ([공식 매트릭스](https://karpenter.sh/docs/upgrading/compatibility/): K8s 1.35는 Karpenter >= 1.9). Cilium ✓ (참조 환경 실제 deploy 검증 — `helm_release.version` + 운영 흔적). 단 [공식 compat doc](https://docs.cilium.io/en/stable/network/kubernetes/compatibility/)에 1.19↔1.35 명시 부재 ⚠ — 다음 K8s/Cilium minor 업그레이드 시 재검증 필수 |

본 레포는 Phase 1에 VPC CNI + MNG로 시작. Karpenter/Cilium은 Phase 3+ ADR 선행.

## Helm Chart

chart 버전은 `environments/<env>/terraform.tfvars`로 외부 주입. 모듈 hardcoded 금지.

| Chart | 버전 | Phase | 비고 |
|---|---|---|---|
| `temporalio/temporal` | TBD | Phase 1 | 적용 직전 확정 |
| `argo/argo-cd` | `9.5.4` | Phase 2 | [ADR 0006](../decisions/0006-argocd-package-only.md): 패키지만 |
| `external-secrets/external-secrets` | `2.4.1` | Phase 2 | ESO |
| `aws/eks-charts/aws-load-balancer-controller` | `3.2.2` | Phase 2 | Gateway API GA |
| `kubernetes-sigs/metrics-server` | `3.13.0` | Phase 3 | HPA |
| `karpenter/karpenter` | `1.12.0` | Phase 3+ | 호환성 ADR 선행 |
| `cilium/cilium` | `1.19.3` | Phase 3+ | 호환성 ADR 선행 |

## Apply/Runtime 함정 노트

`terraform plan`이 안 잡는 항목. 모듈/plan 작성 시 직접 점검.

1. **Aurora IAM auth: cluster ID 함정** — IAM 정책 `Resource` ARN에 **rds cluster ID** 사용 필수. instance ID로 쓰면 `rds-db:connect` 있어도 연결 거부. `modules/rds-aurora/` IRSA 예시에 명시 + 코멘트.
2. **`use_lockfile` + bucket policy encryption mismatch** — lock file은 state file과 같은 SSE 설정으로 PUT됨. bucket policy가 encryption header 강제 시 lock file도 동일 정책 만족해야 함. `infra/tf-backend/`에서 lock file 경로(`*.tflock`) 명시적 허용.
3. **Helm v3 state migration 함정** — v2→v3 마이그레이션 실패 보고 다수. 우리는 Phase 2부터 v3 신규 작성으로 회피.
4. **Cilium + K8s 매트릭스 공식 명시 부재** — Cilium 도입/업그레이드 시 release note + e2e test 매트릭스 직접 재검증.

## 버전 변경 시 검증 절차

신규 provider/chart 추가, 메이저 업그레이드, EKS K8s version 변경, 호환성 anchor 항목 변경 시 아래 5단계를 변경 plan의 S3.5(Security Review)에 박는다. `terraform plan`은 silent breakage를 못 잡으므로 사전 검증이 유일한 방어선.

1. **공식 1차 소스 확인** — 변경 대상의 release note / migration guide / breaking change 문서 직접 fetch. 2차 소스(블로그)는 보조.
2. **Silent breakage 후보 식별** — `terraform plan` 통과지만 apply/runtime에서 깨지는 패턴 (provider major bump의 deprecated attribute, helm syntax 변경, IAM resource ID 형식 등). 위 "Migration trap" 컬럼 갱신.
3. **호환성 정합 점검** — 위 호환성 anchor 표 + 영향 받는 provider/chart 간 매트릭스 확인. anchor 변경 시 모든 의존 컴포넌트 재검증.
4. **Apply/Runtime 함정 점검** — 위 "Apply/Runtime 함정 노트" 항목 + 신규 발견 함정 추가.
5. **결과 반영** — plan S3.5 작성 + 영향 받는 anchor/표/함정 노트가 있으면 본 문서 갱신 PR.

권장 도구 (강도 순):

1. **참조 구현 cross-check** — 신뢰할 수 있는 working repo의 `.terraform.lock.hcl`, `tfvars`, `helm_release` 코멘트 직접 읽기. *실제 잠긴 버전과 운영 흔적* — 가장 강한 증거.
2. **공식 primary source 직접 fetch** — `WebFetch`로 release-note / migration-guide / CHANGELOG.md URL 직접 읽기. SEO 최적화된 blog summary 우회.
3. **Empirical apply in throwaway env** — 개인 계정에 짧게 띄웠다 destroy (Phase 경계에서만). 진짜 "동작 검증"의 유일한 길.
4. `/best-practice <topic>` — 외부 1차 소스 + 커뮤니티 자동 수집 (위 1~3을 못 할 때).
5. `/ralph docs/conventions/versions.md` — 문서 일관성·완전성 자체 검증.

## 갱신 정책

- 마이너: 단일 PR + plan. 메이저: ADR + plan + 위 5단계 검증 필수.
- EKS K8s 업그레이드: 호환성 anchor 5항목 + 위 5단계 검증 동시 수행.

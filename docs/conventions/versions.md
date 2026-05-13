# Version Pinning

## Terraform

- 최소: **1.11+** (S3 backend native locking - `use_lockfile`)
- 권장: 최신 stable
- `versions.tf`에 `required_version = ">= 1.11"`
- 1.10 이하 사용 금지 (DynamoDB lock 의존 - 본 레포 baseline 위반)

## Provider

| Provider | 핀 | 이유 |
|---|---|---|
| hashicorp/aws | `~> 5.x` | EKS 1.28+, IRSA, Aurora Serverless v2 |
| hashicorp/kubernetes | `~> 2.x` | EKS access entries |
| hashicorp/helm | `~> 2.x` | helm release (Phase 2+) |
| hashicorp/tls | `~> 4.x` | TLS 인증서·키 |

## EKS

- 최소: 1.28
- Phase 1 적용 시점에 latest stable 선택 (현재 가정: 1.30)
- 업그레이드 정책: Phase 2 진입 시 latest stable로 갱신

## Helm Chart

| Chart | 버전 | 노트 |
|---|---|---|
| temporalio/temporal | TBD | Phase 1 적용 직전 확정 |
| argo/argo-cd | TBD | Phase 2 |

## 갱신 정책

- 각 모듈의 `versions.tf`에 핀 박음
- 마이너 업그레이드: 단일 PR + plan 문서
- 메이저 업그레이드: ADR + plan 문서 필수

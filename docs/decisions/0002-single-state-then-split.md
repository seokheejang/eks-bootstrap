# 0002: 단일 state로 시작, Phase 2에 분리

- Status: Accepted
- Date: 2026-05-13
- Tags: terraform, state, phase-1

## Context

state 격리 전략 결정 필요:
- 단일 state (environments/dev/ 안의 모든 자원이 한 state)
- 레이어드 state (foundation/platform/app 3계층, cross reference via `terraform_remote_state`)
- terragrunt로 레이어드 자동화

1인 학습 단계 + 환경 1개(dev)만 있는 시점에 어느 게 합리적인가.

## Decision

Phase 1은 **단일 state**. environments/dev/ 하나의 backend = 하나의 tfstate.

Phase 2에 staging/prod 환경이 추가되는 시점에 환경별 분리 (`terraform state mv` 마이그레이션). 레이어드 분리(foundation/platform/app)는 Phase 3 진입 시 재평가.

## Alternatives Considered

- **A. 단일 state (채택)**: 가장 단순. plan/apply 한 곳, destroy도 한 명령. 단점: helm/temporal만 재배포해도 vpc·rds plan이 같이 돔. 사이클 무거움.
- **B. 레이어드 state from start**: foundation(vpc) + platform(eks+rds) + app(temporal) 세 디렉토리, 각자 state, `terraform_remote_state` data source. Phase 1엔 잠재 이득 대비 학습 부담 큼.
- **C. terragrunt**: B를 자동화. 새 도구 학습 곡선, 1인 학습 단계엔 over-engineering.

## Consequences

- Phase 1 사이클: vpc~temporal 모두 destroy/recreate. PoC 빈도 낮으므로(Phase 경계에서만) 수용 가능.
- Phase 2 마이그레이션: `terraform state mv -state-out=...`. 사전 조건 — 모듈 wrapping 최소화 + 명시적 input/output ([terraform-variables.md](../conventions/terraform-variables.md)). 두 invariant가 conventions에 박혀있어 자연 충족.
- Phase 2에 어차피 디렉토리 구조 손볼 시점이라 마이그레이션 비용 작음.

### Security Implications

- 단일 state는 blast radius가 크다 (apply 실수 한 번에 vpc까지 영향). 1인 운영에서 plan-driven workflow + commit-gates로 완화.
- state 자체의 보호는 `infra/tf-backend` baseline(SSE-S3 + versioning + public access block + prevent_destroy)으로 처리.
- Phase 2 분리는 SOC 2 CC9.1(사업 중단 위험 완화) 충족과 일치.

## References

- [security-baseline.md](../security/security-baseline.md)
- HashiCorp - Backend type s3: https://developer.hashicorp.com/terraform/language/backend/s3
- (작성 예정) state-split runbook

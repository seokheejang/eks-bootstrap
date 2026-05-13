# 0001: modules/ + environments/<env>/ 분리 패턴

- Status: Accepted
- Date: 2026-05-13
- Tags: terraform, repo-structure

## Context

eks-bootstrap는 두 역할을 한 레포에서 수행한다:
1. 외부 fork 대상이 되는 generic Terraform 모듈
2. 본인이 실제로 띄워보며 학습하는 sandbox stack (첫 use-case는 Temporal)

이 둘을 어떻게 구조적으로 분리하느냐를 첫 코드 한 줄 쓰기 전에 결정.

## Decision

`modules/`(재사용 primitive) + `environments/<env>/`(실제 배포 단위)로 분리. 환경이 1급 시민이고, modules는 환경에서 호출하는 building block.

```
modules/             # 단일 책임 primitive, 비즈니스 컨텍스트 없음 (fork 대상)
environments/        # tfvars + module 호출, 환경별 디렉토리
  └── dev/           # Phase 1 PoC가 여기서 apply됨
infra/tf-backend/    # state 부트스트랩 (별도 stack)
```

## Alternatives Considered

- **A. modules-only 레포**: Terraform 모듈만 두고 실제 배포는 별도 private 레포에서. 가장 깨끗하지만 본인 sandbox 사용처가 없어져 검증 어려움.
- **B. stacks/<use-case>/ 분리**: `stacks/temporal/` 처럼 use-case 단위. 외부 fork 친화적이지만 환경 추가 시 stacks 안에 환경 갈래가 또 생겨야 함.
- **C. modules/ + environments/<env>/ (채택)**: 환경이 1급 시민. Temporal은 environments/dev/ 안에서 modules/* 호출하는 한 컴포넌트. 환경 추가 = 디렉토리 복제.
- **D. 브랜치로 분리** (main=reusable, temporal-poc=실배포): 1인 운영에서 동기화 비용 큼.
- **E. sibling repo 분리**: 처음부터 모듈 레포와 사용 레포 분리. 부트스트랩 단계 마찰 큼.

## Consequences

- 외부 fork 소비자: `modules/`만 vendor. `environments/`, `infra/`, `docs/temporal-on-eks.md`는 무시.
- 본인: `cd environments/dev && terraform apply`로 실제 배포.
- 환경 추가 = `environments/<new-env>/` 복제 + tfvars 수정.
- 단점: `modules/`와 `environments/` 사이 디렉토리 경로(`../../modules/vpc`) 의존. 외부 fork가 실제 발생하면 git ref + semver tag로 전환 고려.

### Security Implications

- `modules/`에 시크릿·환경값 박는 것 자체가 baseline 위반 ([terraform-variables.md](../conventions/terraform-variables.md)). 분리 구조가 이 invariant를 자연 강제.
- `environments/<env>/terraform.tfvars`는 git 추적되지만 시크릿 박지 않음 (SSM Parameter Store / ESO 경유).

## References

- [terraform-variables.md](../conventions/terraform-variables.md)
- Spacelift - Terraform Monorepo: https://spacelift.io/blog/terraform-monorepo
- HashiCorp - Monorepo vs Multi-repo: https://www.hashicorp.com/en/blog/terraform-mono-repo-vs-multi-repo-the-great-debate

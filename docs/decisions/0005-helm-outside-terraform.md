# 0005: Helm 적용은 Terraform 외부 (Makefile -> 추후 GitOps)

- Status: Accepted
- Date: 2026-05-13
- Tags: helm, terraform, separation-of-concerns

## Context

Temporal Helm chart를 어디서 적용할지 결정 필요. 옵션:

- Terraform `helm_release` 리소스로 직접 (TF state에 helm release 포함)
- Terraform 외부에서 별도 적용 (Makefile, GitOps)

ArgoCD/AWS LB Controller 같은 platform 컴포넌트는 `helm_release`로 TF 안에서 처리하는 패턴이 흔하지만, Temporal은 application 성격이라 GitOps repo로 분리하는 게 일반적이다.

## Decision

**Terraform은 AWS 인프라까지. K8s workload(helm release)는 외부.**

- Phase 1: `environments/dev/Makefile` + `environments/dev/charts/temporal/values.yaml`로 helm CLI 적용.
- Phase 2: Temporal은 별도 GitOps repo로 이전, ArgoCD Application으로 관리.
- ArgoCD 자체(Phase 2 도입)는 패키지 설치(helm release)까지만 본 레포에서. Applications는 외부 GitOps repo (cf. [0006](0006-argocd-package-only.md)).

## Alternatives Considered

- **A. Terraform `helm_release` 리소스 직접**: 편하지만 state에 helm release 포함 → values 변경 시 큰 plan. provider "helm"이 EKS auth 타이밍 문제로 일시적 실패 가능. Phase 2 ArgoCD 전환 시 `helm_release` 제거가 TF 코드 변경 강제.
- **B. Makefile + Phase 2 GitOps 전환 (채택)**: TF와 helm 책임 명확. Phase 2 전환 시 TF 무손상.
- **C. Phase 1부터 ArgoCD 도입**: Phase 1 범위 늘어남, PoC 검증 속도 느림.
- **D. TF는 ArgoCD만, Temporal은 Argo Application**: 가장 GitOps적. Phase 1에 비용 큼.

## Consequences

- Phase 1: `terraform apply` 후 별도 `make helm-install`. 두 단계지만 책임 분리 명확.
- Phase 2 전환: TF 코드 변경 없음. Makefile 타겟 제거 + GitOps repo에 Argo Application 추가.
- state 가벼움 (helm release 미포함).
- helm provider 인증 타이밍 문제 회피.

### Security Implications

- helm values.yaml에 시크릿 박지 않음. Phase 1: 환경변수/SSM 참조, Phase 2: ESO ExternalSecret로 K8s Secret 생성.
- Makefile은 로컬 실행 환경에 의존. 1인 학습 단계 수용 가능. 팀 환경에선 GitOps로 빠르게 전환 필요.

## References

- [security-baseline.md](../security/security-baseline.md)
- [0006-argocd-package-only.md](0006-argocd-package-only.md)
- [docs/temporal-on-eks.md](../temporal-on-eks.md)

# 0006: ArgoCD는 Phase 2부터, 패키지 설치만

- Status: Accepted
- Date: 2026-05-13
- Tags: argocd, gitops, phase-2

## Context

GitOps 도입 시점과 범위 결정. ArgoCD를 어디서 어떻게 관리하느냐.

## Decision

- **시점**: Phase 2 진입 시 도입.
- **범위**: `modules/argocd/`에 ArgoCD 본체(helm release) 설치까지. ArgoCD Application 리소스(워크로드 정의)는 **별도 GitOps repo**에서 관리.
- 이 레포는 GitOps repo가 아니다.

## Alternatives Considered

- **A. Phase 1부터 ArgoCD**: PoC 검증 비용 증가. Temporal 띄우기 전에 ArgoCD를 먼저 띄워야 함.
- **B. Phase 2에 ArgoCD + Applications 모두 본 레포**: TF가 Application 리소스까지 관리하면 TF state에 Application들이 들어감. GitOps 본질(Git이 source of truth)과 충돌.
- **C. Phase 2부터 ArgoCD 패키지만, Applications는 GitOps repo (채택)**: 책임 분리 명확. 본 레포는 인프라까지, GitOps repo는 워크로드.

## Consequences

- Phase 2 진입 시점에 별도 GitOps repo 필요 (`eks-bootstrap-gitops` 또는 use-case별).
- `modules/argocd/`는 helm release + IRSA + OAuth 설정까지. Application은 미포함.
- Phase 1 Temporal helm 적용 방식([0005](0005-helm-outside-terraform.md))은 Phase 2 진입과 함께 GitOps Application으로 마이그레이션.

### Security Implications

- ArgoCD OAuth (GitHub/SSO) 필수, local admin 비활성 (baseline Phase 2 항목).
- Application 리소스가 GitOps repo에 있으므로 그 repo의 접근 통제(branch protection, CODEOWNERS)가 SOC 2 CC8.1 (변경 관리) 일부.
- ArgoCD에 부여되는 K8s RBAC은 namespace-scope 권장 (cluster-admin 회피).

## References

- [security-baseline.md](../security/security-baseline.md) Phase 2 항목
- [0005-helm-outside-terraform.md](0005-helm-outside-terraform.md)
- ArgoCD docs: https://argo-cd.readthedocs.io/

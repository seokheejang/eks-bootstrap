# Architecture Decision Records (ADR)

비자명한 아키텍처·도구 선택을 기록. "왜 이렇게 했는가"가 시간이 지나면 잊히므로.

## 파일 명명

`NNNN-<kebab-slug>.md` — 4자리 일련번호 + 슬러그.

## ADR 작성 시점

- 모듈 구조·환경 분리 등 *전체에 영향 주는* 결정
- 도구 선택 (예: Aurora Serverless vs provisioned)
- 기존 ADR을 뒤집는 결정 (Supersedes 표기)

작은 변경(변수 이름 바꾸기, 모듈 입자 조정)은 ADR 안 씀. plans/에 기록.

## 작성 방법

[_template.md](_template.md) 복사 후 채움.

## 인덱스

| # | 제목 | Status |
|---|---|---|
| [0001](0001-modules-environments-split.md) | modules/ + environments/<env>/ 분리 패턴 | Accepted |
| [0002](0002-single-state-then-split.md) | 단일 state로 시작, Phase 2에 분리 | Accepted |
| [0003](0003-backend-bootstrap-local-state.md) | backend bootstrap을 local state로 | Accepted |
| [0004](0004-db-aurora-serverless-v2.md) | DB는 Aurora PostgreSQL Serverless v2 (Phase 1부터) | Accepted |
| [0005](0005-helm-outside-terraform.md) | Helm 적용은 Terraform 외부 (Makefile -> GitOps) | Accepted |
| [0006](0006-argocd-package-only.md) | ArgoCD는 Phase 2부터, 패키지 설치만 | Accepted |
| [0007](0007-soc2-primary-isms-reference.md) | 보안 1차 프레임워크는 SOC 2, ISMS-P는 매핑 참고 | Accepted |
| [0008](0008-aws-access-account-strategy.md) | AWS 자격증명·계정 전략 (Phase 1 access key, SSO/multi-account 연기) | Accepted |

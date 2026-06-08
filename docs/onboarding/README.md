# Onboarding

이 레포를 제로에서 빌드하면서 두 가지를 동시에 익히는 학습 동반 문서 시리즈.

1. **Terraform 을 제대로** - 문법(HCL) + 아키텍처(모듈 경계, 생성 순서, state) + 설계 결정.
2. **SOC 적용 bootstrap** - SOC 2 통제를 Terraform 코드 줄로 번역, Tier(immutable) 판단.

운영용 문서(`docs/conventions/`, `docs/security/` 등)를 대체하지 않는다. 그 문서들을 읽고 코드를 짤 수 있도록 *왜 / 언제 / 어떤 순서로* 를 먼저 깐다.

## 포맷

`NNN-<slug>.html` (HTML). 사이드바 TOC + Mermaid + 콜아웃이 학습에 유리해 `docs/onboarding/` 만 예외적으로 HTML. 나머지 docs 는 Markdown ([documentation-style.md](../conventions/documentation-style.md)). 본문은 ASCII + 한글, 이모지 / 유니코드 화살표 금지, 화살표는 `->`.

## 읽는 순서

000(Terraform 기초)이 바탕, 001(이 레포의 지도)이 그 위에 선다 - 코드가 없어도 지금 읽는다. 003 부터는 해당 빌드 step 직전에 같이 쓰며 읽는다.

## 시리즈 (빌드 순서와 1:1)

| 문서 | 제목 | 빌드 step | 상태 |
|---|---|---|---|
| [000](000-terraform-foundation.html) | Terraform 기초 (repo-무관 foundation) | (사전) | 작성됨 |
| [001](001-orientation.html) | 오리엔테이션과 지도 | (전체) | 작성됨 |
| 002 | 컨벤션 + HCL 적용 + 계정 사전조건 + commit-gates | 0, 0.5 | 예정 |
| 003 | state & backend bootstrap (`infra/tf-backend`) | 1 | 예정 |
| 004 | `environments/dev` skeleton + backend partial config | 2 | 예정 |
| 005 | `modules/vpc` | 3 | 예정 |
| 006 | `modules/eks-cluster` (Tier 1 집중) | 4 | 예정 |
| 007 | `modules/eks-node-group` | 5 | 예정 |
| 008 | `modules/irsa` | 6 | 예정 |
| 009 | `modules/rds-aurora` | 7 | 예정 |
| 010 | Temporal helm install | 8 | 예정 |

문서 번호는 가이드다. 빌드 단계가 합쳐지거나 갈라지면 조정될 수 있다. live 진척은 [next-steps.md](../next-steps.md), 빌드 순서 상세는 [plans/README.md](../plans/README.md).

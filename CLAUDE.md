# eks-bootstrap

개인 샌드박스 + 재사용 가능한 AWS EKS Terraform 베이스.

## 정체성

- `modules/` — 단일 책임 primitive. 비즈니스 컨텍스트·시크릿·조직 네이밍 박지 않음. 외부 fork 대상.
- `environments/<env>/` — 실제 배포 단위. tfvars + module 호출로 환경 조립.
- `infra/tf-backend/` — state 저장용 S3 1회성 부트스트랩 (S3 native lock; DynamoDB 미사용).

## 디렉토리

```
eks-bootstrap/
├── modules/             # 재사용 모듈 (vpc, eks-cluster, eks-node-group, irsa, rds-aurora)
├── environments/        # 환경별 조립 (dev → staging → prod)
├── infra/tf-backend/    # state 부트스트랩 (1회성)
└── docs/                # 규칙·결정·계획·런북·보안 문서
```

## 운영 invariants

- `modules/`에 환경값·시크릿·조직 네이밍 박지 않음. inputs로만 받음.
- `terraform apply` 전 `docs/plans/`에 plan 문서 있어야 함.
- 모든 commit은 `docs/conventions/commit-gates.md`의 pre-commit 훅 통과 (시크릿·포맷·tfsec).
- ArgoCD 등장 시점에도 Applications는 별도 GitOps repo. 이 레포는 패키지 설치까지만.
- 보안 baseline은 `docs/security/security-baseline.md` 따름.
- 문서·코드 스타일은 `docs/conventions/documentation-style.md`.

## 문서 인덱스

| 카테고리 | 위치 | 용도 |
|---|---|---|
| 컨벤션 | [docs/conventions/](docs/conventions/) | 네이밍, 태깅, 변수, 문서 스타일, 버전 핀 |
| 의사결정 | [docs/decisions/](docs/decisions/) | ADR (Architecture Decision Records) |
| 변경 계획 | [docs/plans/](docs/plans/) | apply 전 plan 문서, `YYYYMMDD-<slug>.md` |
| 운영 절차 | [docs/runbooks/](docs/runbooks/) | state migration, drift, break-glass 등 |
| 보안 | [docs/security/](docs/security/) | baseline + SOC 2 (compliance·checklist) + ISO 27001 + ISMS-P 매핑 |
| 첫 사용 케이스 | [docs/temporal-on-eks.md](docs/temporal-on-eks.md) | Temporal 요구사항·결정 |

## Phase 로드맵

1. **Phase 1 (PoC)** — VPC + EKS + RDS Aurora Serverless v2 + Temporal (PG visibility, mTLS·인증 X). Tier 1 immutable baseline 박힘.
2. **Phase 2 (Staging)** — state 분리, mTLS, ESO, ArgoCD(패키지만), 관측성, log retention 365일, CMK rotation. **Type I audit 후보 시점**.
3. **Phase 3 (Prod)** — Multi-AZ, DR, NetworkPolicy, Pod Security, GuardDuty/Security Hub. Phase 2 + 6~12개월 운영 후 **Type II audit 후보**.

세부 진척은 [docs/plans/](docs/plans/) 참조. 보안 baseline·audit timeline은 [docs/security/](docs/security/) 참조.

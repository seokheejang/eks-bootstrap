# Change Plans

`terraform apply` 전에 작성하는 변경 계획서. 의도·범위·rollback을 명시.

## 파일 명명

`YYYYMMDD-<kebab-slug>.md` — 날짜 prefix + 슬러그.

예: `20260514-tf-backend.md`, `20260516-modules-vpc.md`

## 작성 시점

- 새 모듈 추가
- 기존 모듈 변경 (자원 추가/삭제·input 변경)
- backend·state 구조 변경
- 환경 추가

읽기 전용 변경(README, comment, conventions 문서)은 plan 안 씀.

## 작성 방법

[_template.md](_template.md) 복사 후 채움.

## 빌드 순서 (Phase 1)

| # | Plan slug | 산출물 |
|---|---|---|
| 1 | `tf-backend` | S3 bucket (`use_lockfile`로 S3 native lock) |
| 2 | `environments-dev-skeleton` | environments/dev/ 초기 구조 |
| 3 | `modules-vpc` | VPC + subnets + NAT |
| 4 | `modules-eks-cluster` | EKS control plane + addons |
| 5 | `modules-eks-node-group` | MNG |
| 6 | `modules-irsa` | IRSA helper |
| 7 | `modules-rds-aurora` | Aurora Serverless v2 |
| 8 | `temporal-helm-install` | Makefile + values.yaml |

각 단계는 별도 plan 파일.

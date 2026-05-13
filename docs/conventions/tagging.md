# Tagging

모든 AWS 자원에 아래 태그 적용. provider 레벨 `default_tags`로 한 번에 박음.

## 필수 태그

| 키 | 값 예시 | 의미 |
|---|---|---|
| `Project` | `eks-bootstrap` | 레포 식별 (fork 시 변경) |
| `Environment` | `dev`, `staging`, `prod` | 환경 |
| `ManagedBy` | `terraform` | 수동 자원과 구분 |
| `Owner` | `<your-team>` | 책임자 (개인이면 GitHub 핸들, 팀이면 팀명) |

## 자원별 추가 태그 (선택)

| 키 | 값 예시 | 적용 자원 |
|---|---|---|
| `Component` | `eks`, `rds`, `temporal` | 자원이 속한 컴포넌트 |
| `CostCenter` | `learning`, `platform` | 비용 분류 |

## 적용 방법

- `environments/<env>/provider.tf`의 `default_tags` 블록에 필수 4종
- 자원별 추가 태그는 모듈 안에서 `merge(var.tags, { Component = "eks" })`

## 금지

- 시크릿·개인정보를 태그에 박음 (태그는 IAM 외 광범위하게 노출)

# Resource Naming

## AWS 자원 이름

포맷: `eksbs-<env>-<component>[-<suffix>]`

- `eksbs` = eks-bootstrap 식별 prefix (다운스트림 fork는 자기 prefix로 교체)
- `<env>` = `dev`, `staging`, `prod`
- `<component>` = `vpc`, `eks`, `rds`, `temporal` 등 단어 1개
- `<suffix>` = 같은 component가 여러 개 있을 때만 (예: `-a`, `-writer`)

예시:
- `eksbs-dev-vpc`
- `eksbs-dev-eks` (cluster name)
- `eksbs-dev-rds-temporal` (Aurora cluster for Temporal)

## Terraform identifier

- 리소스 라벨: 모듈 안에서 단일 인스턴스면 `this`, 그 외엔 의미 있는 이름
- 모듈 호출 이름은 *역할* 기준: `module "vpc"`, `module "temporal_irsa"`
- snake_case (Terraform 관례)

## 금지

- 대문자, 공백, 한글, 특수문자 (DNS-1035 위반 가능)
- 64자 초과 (RDS 등 자원 제한)
- 환경명 없는 이름 (다중 환경에서 충돌)

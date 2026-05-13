# Terraform Variables / File Layout

## 모듈 (`modules/<name>/`) 파일 구성

```
modules/<name>/
├── main.tf          # 주요 리소스
├── variables.tf     # 모듈 입력
├── outputs.tf       # 모듈 출력
├── versions.tf      # required_version, required_providers
└── README.md        # 용도·input/output 표·예시 호출
```

자원이 많아지면 `iam.tf`, `security_group.tf`, `addons.tf` 등으로 분리. 한 파일 200~300줄 넘기 전에 분리 고려.

## 환경 (`environments/<env>/`) 파일 구성

```
environments/<env>/
├── backend.tf       # S3 backend partial config
├── provider.tf      # AWS/Kubernetes/Helm providers + default_tags
├── data.tf          # 기존 자원 참조 (선택)
├── variables.tf     # 환경 변수 선언
├── terraform.tfvars # 환경별 값 (git 추적)
├── main.tf          # modules/* 호출
└── outputs.tf       # 환경 출력
```

`terraform.tfvars`엔 시크릿 박지 않음. 시크릿은 Phase 1: SSM Parameter Store, Phase 2: ESO 경유.

## 변수 명명

- snake_case
- bool은 `enable_*` 또는 `*_enabled`
- 리스트는 복수형 (`subnet_ids`)
- AWS 자원 ID 변수는 `<resource>_id` (예: `vpc_id`)

## 모듈/환경 경계

- 환경 → 모듈: AWS 식별자(`vpc_id`, `cluster_name`), 환경 이름, 태그, 환경별 설정값
- 모듈 → 환경: 후속 모듈이 필요로 하는 ID·endpoint·ARN
- 모듈 내부 결정(예: subnet CIDR 계산)은 모듈 안에서 끝냄. 환경은 결과만 받음.

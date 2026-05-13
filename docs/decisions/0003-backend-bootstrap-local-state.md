# 0003: backend bootstrap을 local state로

- Status: Accepted
- Date: 2026-05-13
- Tags: terraform, backend, bootstrap

## Context

state를 S3에 두기로 했지만, 그 S3 bucket 자체는 어떻게 만드나? Terraform으로 만들려면 state가 어디 있어야 하나? S3에 두려면 그 S3는? 순환 의존.

## Decision

`infra/tf-backend/` 라는 작은 Terraform stack을 만들고 **local state**로 1회 apply.

- 이 stack은 S3 bucket(state 저장소) + 부수 자원(versioning, encryption, public access block, lifecycle, `prevent_destroy`)만 만듦
- local state 파일(`infra/tf-backend/terraform.tfstate`)은 `.gitignore`로 git 제외
- 이후 `environments/<env>/`는 partial backend config로 S3 backend 사용

```hcl
terraform {
  backend "s3" {}
}
```

```bash
terraform init \
  -backend-config="bucket=eksbs-tfstate" \
  -backend-config="key=environments/dev/terraform.tfstate" \
  -backend-config="use_lockfile=true"
```

## Alternatives Considered

- **A. AWS CLI/console 수동 생성**: `aws s3 mb` + 정책 명령어를 README에 박음. 가장 단순. Terraform 일관성 깨짐 ("everything as code" 위반).
- **B. infra/tf-backend (local state)로 Terraform 작성 (채택)**: bucket 생성도 Terraform. 1회성, local state는 git ignore.
- **C. terraform-aws-modules 기성 모듈**: 의존성 추가. 학습 가치 작고 외부 의존만 늘어남.
- **D. CDK/CloudFormation**: 도구 이중화. 본 레포가 Terraform 중심이라 결이 안 맞음.

## Consequences

- Terraform 일관성 유지 ("모든 자원은 코드").
- `infra/tf-backend/`는 한 번 apply 후 거의 손대지 않음. `prevent_destroy = true`로 실수 보호.
- fork 소비자는 자기 backend로 재초기화 가능 (partial config 패턴 덕분).
- DynamoDB lock 테이블 미사용 — Terraform 1.11+ `use_lockfile = true` 채택 ([versions.md](../conventions/versions.md)).

### Security Implications

- bucket baseline: SSE-S3 + versioning + public access block + `prevent_destroy` + noncurrent 90일 만료 ([security-baseline.md](../security/security-baseline.md)).
- local state 파일이 git에 들어가지 않게 `.gitignore` 항목 필수. commit-gates의 gitleaks가 보조 차단.
- bucket policy: state 접근 주체 최소화 (Phase 2에서 IAM 정책 정교화).

## References

- [security-baseline.md](../security/security-baseline.md) - tfstate 보호 항목
- [versions.md](../conventions/versions.md) - Terraform 1.11+ 요구사항
- HashiCorp - S3 backend: https://developer.hashicorp.com/terraform/language/backend/s3

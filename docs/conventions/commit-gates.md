# Commit-time Gates (Pre-commit Hooks)

모든 commit은 아래 훅을 통과해야 함. 목적은 (1) 시크릿이 git history에 들어가는 것 차단, (2) 포맷·문법·보안 정책 위반 사전 차단.

## 필수 훅

| 카테고리 | 훅 | 차단 대상 |
|---|---|---|
| **시크릿 탐지** | `gitleaks` | AWS key, GitHub PAT, private key, generic API token |
| **시크릿 탐지** | `detect-private-key` | RSA/SSH/PGP private key 파일 |
| **Terraform 포맷** | `terraform_fmt` | 비포맷 코드 |
| **Terraform 문법** | `terraform_validate` | invalid HCL |
| **Terraform lint** | `terraform_tflint` | 비추천 패턴·deprecated 인자 |
| **Terraform 보안** | `terraform_trivy` (config scan) | tfsec rule 위반 (public S3, 0.0.0.0/0 SG, 평문 시크릿 등) |
| **일반 위생** | `end-of-file-fixer` | 줄바꿈 없이 끝나는 파일 |
| **일반 위생** | `trailing-whitespace` | 줄 끝 공백 |
| **일반 위생** | `check-merge-conflict` | merge 마커 남은 파일 |
| **일반 위생** | `check-yaml` | 깨진 YAML |

## 설정 위치

- `.pre-commit-config.yaml` (레포 루트, 빌드 순서 1단계 후 도입)
- 각 개발자 로컬: `pre-commit install` 1회

## Bypass 정책

- 원칙: bypass 금지 (`--no-verify` 사용 안 함).
- 예외: 훅 자체에 버그가 있는 경우만. `docs/plans/`에 사유·범위·복구 절차 명시한 plan을 먼저 작성.

## CI 백업

pre-commit 로컬 누락 대비:
- GitHub Actions 워크플로(`.github/workflows/pre-commit.yml`)에서 동일 훅 실행 (Phase 1 후반 도입).
- 실패 시 PR merge 차단.

## SOC 2 / ISMS 매핑

- SOC 2 **CC8.1** (변경 관리): 코드 품질·시크릿 게이트가 적용됐다는 증거.
- ISMS-P **2.8** (정보시스템 도입 및 개발 보안): 자동 충족.

## References

- [security-baseline.md](../security/security-baseline.md) - 전체 보안 baseline
- gitleaks: https://github.com/gitleaks/gitleaks
- pre-commit-terraform: https://github.com/antonbabenko/pre-commit-terraform

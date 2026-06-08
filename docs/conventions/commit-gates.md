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

- `.pre-commit-config.yaml` (레포 루트) — 훅 정의 + 버전 핀. 핀의 single source of truth ([versions.md "Commit-gate 훅"](versions.md#commit-gate-훅-dev-tooling)).
- `.tflint.hcl` (레포 루트) — 번들 terraform ruleset만 활성. AWS ruleset(`tflint-ruleset-aws`)은 첫 AWS 모듈 작성 시 추가.
- 도입 시점: 빌드 순서 **step 0.5** (tf-backend step 1보다 먼저 — 첫 커밋부터 게이트 적용).

## 로컬 설치 (개발자 1회)

훅이 호출하는 도구(gitleaks, tflint, trivy, terraform)는 pre-commit이 자동 설치하지 않음 — system PATH 의존. 직접 설치:

```bash
# macOS (Homebrew). terraform 은 이미 설치돼 있다고 가정.
brew install pre-commit gitleaks trivy
brew install terraform-linters/tap/tflint   # tflint 는 homebrew-core 에 없음 -> 공식 tap

pre-commit install            # git hook 등록 (1회)
pre-commit run --all-files    # 전체 1회 실행 (.tf 없으면 terraform_* 훅은 skip)
```

함정: `brew install tflint` 단독은 실패 (homebrew-core 미존재). 반드시 `terraform-linters/tap/tflint` 사용. 또한 `brew install A B tflint` 처럼 묶으면 잘못된 formula 하나가 batch 전체를 중단시키므로 tflint 는 줄을 분리.

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

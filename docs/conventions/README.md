# Conventions

eks-bootstrap의 코드·문서·자원 일관성 규칙. modules/와 environments/ 양쪽에 적용.

## 파일 목록

| 파일 | 다루는 내용 |
|---|---|
| [resource-naming.md](resource-naming.md) | AWS 자원·Terraform identifier 명명 규칙 |
| [tagging.md](tagging.md) | 필수 태그·태깅 정책 |
| [terraform-variables.md](terraform-variables.md) | 변수 명명·파일 레이아웃·모듈 경계 |
| [documentation-style.md](documentation-style.md) | docs·코드 코멘트 스타일 |
| [versions.md](versions.md) | Terraform·provider·EKS·chart 버전 핀 |
| [commit-gates.md](commit-gates.md) | pre-commit 훅 (시크릿 탐지·포맷·tfsec) |

새 규칙이 반복되어 등장하면 별도 파일로 추가하기 전에 기존 파일에 한 섹션으로 들어가는지 먼저 확인.

# Documentation Style

## 언어

- 한국어 + 영어 혼용 OK. 기술용어·AWS/K8s 리소스명·코드 식별자는 영어 유지.
- 본문은 한국어 우선.

## 이모지·유니코드

- 이모지 사용하지 않음 (검색·diff 가독성 저해).
- 화살표 등 유니코드는 `->`, `=>` 같은 ASCII로 대체.
- 한글은 본문 한정. AWS Security Group description은 **ASCII만** 허용 (한글 안 됨).

## Markdown

- 헤더 `#`~`####` 까지. `#####` 이상 안 씀 (구조 깊으면 파일 분리).
- 표는 자유롭게. 너무 넓으면 컬럼 분리.
- 코드 블록은 언어 태그 (`hcl`, `bash`, `yaml`).
- 링크는 상대 경로 (`../plans/...md`).

## 코드 코멘트

- 기본: 안 씀. 코드가 스스로 설명되면 그게 우선.
- 예외: WHY가 비자명할 때만 (워크어라운드, 미묘한 invariant, 미래 reader가 놀랄 결정).
- WHAT 설명은 금지 (`# create vpc` 같은 거).

## 파일·디렉토리 명명

- kebab-case (`security-baseline.md`)
- ADR은 `NNNN-<slug>.md` (4자리 일련번호)
- plan은 `YYYYMMDD-<slug>.md` (날짜 prefix)
- 임시·실험 파일은 `WIP-` prefix + `.gitignore`

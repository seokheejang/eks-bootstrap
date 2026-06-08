# tflint config. 번들 terraform ruleset만 활성 (별도 plugin 버전 핀 불필요).
# AWS ruleset(tflint-ruleset-aws)은 첫 AWS 모듈 작성 시(빌드 step 3) 추가 +
# versions.md "버전 변경 시 검증 절차"로 버전 확정. (2026-06 현재 latest 태그 미확정 — 추정 핀 회피)
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

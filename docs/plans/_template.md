# <Plan Title>

- Date: YYYY-MM-DD
- Status: Draft | Approved | Applied | Rolled Back
- Related: (선택) ADR 번호·이전 plan·이슈 링크

## S1. Background

왜 이 변경이 필요한가. 어떤 요구사항·gap·이슈로부터 시작됐나.

## S2. Target Resources

영향받는 AWS·K8s 자원 목록. (자원 ID는 생성 후 채움)

## S3. Expected Changes

- 추가/변경/삭제될 자원
- `terraform plan` 요약 (핵심 부분 발췌 또는 별도 파일 링크)

## S3.5. Security Review

- **Baseline 영향**: 이 plan이 건드리는 [security-baseline.md](../security/security-baseline.md) 항목 나열. baseline 위반 또는 일시 예외가 있으면 만료일과 복구 절차 명시.
- **SOC 2 TSC 매핑**: 이 plan으로 상태 변경되는 통제 (예: CC6.1 부분 -> 적용). [soc2-compliance.md](../security/soc2-compliance.md) 표 갱신 필요 여부.
- **신규 외부 노출**: public endpoint, public S3, 0.0.0.0/0 SG, 인터넷 노출 ALB 등.
- **IAM 변경**: 신규/변경 role·policy 요약, wildcard(`*`) 사용 여부, AssumeRole 신뢰관계.
- **시크릿 취급**: 신규 시크릿이 있다면 저장소(SSM Parameter Store / Secrets Manager / ESO)와 접근 방식.

해당 없으면 "N/A"로 명시. 빈칸 금지.

## S4. Success Criteria

apply 후 확인할 명령어와 기대 출력. 구체적으로.

## S5. Rollback Trigger

무엇이 보이면 rollback할지. (예: apply 실패, 헬스체크 실패, baseline 위반)

## S6. Rollback Procedure

순서대로 적힌 명령어. 데이터 손실 가능성 명시.

## S7. Verification Result

(apply 후 채움) S4의 명령어 실행 결과.

## S8. Related Commit/PR

(apply 후 채움) 적용된 commit hash·PR 링크.

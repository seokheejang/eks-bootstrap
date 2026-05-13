# 0007: 보안 1차 프레임워크는 SOC 2 Type II, ISMS-P는 매핑 참고

- Status: Accepted
- Date: 2026-05-13
- Tags: security, soc2, isms

## Context

어느 보안 컴플라이언스 프레임워크를 1차 기준으로 삼을지 결정 필요. 후보:

- SOC 2 Type II (글로벌 표준, 기술 통제 중심)
- ISMS/ISMS-P (한국 표준, 조직·관리체계 포함)
- 둘 다 동일 비중

## Decision

**SOC 2 Type II Security Trust Services Criteria를 1차 프레임워크**로 채택. baseline·plan·ADR 모두 SOC 2 매핑 명시.

ISMS-P는 **보조 참고**로만 사용. [isms-mapping.md](../security/isms-mapping.md)에서:
1. SOC 2 충족 시 ISMS-P가 자동 충족되는 항목 표
2. SOC 2로 안 채워지는 ISMS-P 갭 표 (대부분 조직/앱 레이어)

## Alternatives Considered

- **A. ISMS-P를 1차**: 한국 기업 대상이면 적합하지만, 1.x 관리체계·2.1~2.4 조직/인적/물리·3.x 개인정보 라이프사이클이 본 레포 범위 밖이라 baseline 정의가 모호.
- **B. 둘 다 동일 비중**: 모든 통제를 양쪽 매핑. 문서 비용 큼, 결정 시점에 어느 쪽 따라야 할지 모호.
- **C. SOC 2 Security TSC 1차, ISMS-P 매핑 참고 (채택)**: SOC 2가 IaC 기술 통제 중심이라 본 레포에 자연 매핑. ISMS-P는 표로 갭만 정리.

## Consequences

- [baseline](../security/security-baseline.md) · [soc2-compliance](../security/soc2-compliance.md) · [isms-mapping](../security/isms-mapping.md) 3종 문서로 분리. 변경 시 SOC 2 매핑은 필수 갱신, ISMS-P는 자동 충족 여부만 점검.
- ISMS-P 인증이 실제 필요해지면 갭 표를 출발점으로 별도 organization-level 작업 시작.
- Availability/Confidentiality TSC는 Phase 3 진입 시 추가 매핑.

### Security Implications

- ISMS-P 인증 갭 (1.x 관리체계, 3.x 개인정보)은 본 레포에서 해결 불가. 인증 추진 시 별도 조직·앱팀 작업 필요.
- SOC 2 자체도 IaC만으로 자동 보장되지 않음 (감사 기간 동안 통제 작동 증거 필요). 본 레포는 *기술 baseline*만 제공.

## References

- [security-baseline.md](../security/security-baseline.md)
- [soc2-compliance.md](../security/soc2-compliance.md)
- [isms-mapping.md](../security/isms-mapping.md)

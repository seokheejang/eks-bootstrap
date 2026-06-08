# 0004: DB는 Aurora PostgreSQL Serverless v2 (Phase 1부터)

- Status: Accepted
- Date: 2026-05-13
- Tags: rds, aurora, phase-1, cost

## Context

Temporal Server는 PostgreSQL 메타데이터 DB 필요. Phase 1 PoC에서 어떤 DB 형태로 시작할지 결정 필요. [docs/temporal-on-eks.md](../temporal-on-eks.md)의 표 2(Aurora)와 표 4(vanilla RDS PG)가 모순되어 있어 명시 결정 필요.

후보:
- Aurora provisioned (Multi-AZ, db.r6g.large × 2 ≈ $420/월): prod에 가까운 형태
- Vanilla RDS PG 단일 인스턴스 (db.t3.micro ≈ $15/월): 비용 최소
- Aurora Serverless v2 (0.5 ACU min ≈ $45/월): Aurora 구조 + PoC 비용

## Decision

**Aurora PostgreSQL Serverless v2 (0.5~1 ACU min/max) Single-AZ로 Phase 1 시작.**

Phase 3에 Multi-AZ provisioned (`engine_mode = "provisioned"` + `instance_class = "db.r6g.large"`)로 input만 교체. 모듈 자체는 동일.

## Alternatives Considered

- **A. Aurora provisioned 다운사이징 (db.t4g.medium × 2 ≈ $120/월)**: Phase 1부터 provisioned. Serverless 대비 비싸고 idle scaling 불가.
- **B. Vanilla RDS PG 단일 인스턴스**: docs 표 4와 일치. ~$15/월. 단점 — Phase 3에서 Aurora로 마이그레이션 시 dump/restore 또는 DMS 필요. 모듈 작명(`rds-aurora`)과 불일치.
- **C. Aurora Serverless v2 0.5 ACU (채택)**: Aurora 구조 유지 + 비용 ~$45/월. Phase 3 provisioned로 input만 교체. 모듈 일관성.

## Consequences

- Phase 1 ~$45/월 (Single-AZ, 0.5 ACU idle).
- 모듈 작명·구조가 Phase 1~3 일관 (`modules/rds-aurora`).
- Phase 3 마이그레이션은 모듈 input 변경뿐 (`engine_mode`, `instance_class`).
- Phase 1 Single-AZ -> Phase 3 Multi-AZ 전환 시 일시 다운타임 가능 (snapshot + restore 또는 reader 추가).
- Aurora Serverless v2 cold-start 지연 가능 (idle -> 활성). PoC 수용 가능.

### Security Implications

- baseline 항목 그대로 적용: 저장 암호화(AWS-managed key, Phase 3에 CMK), TLS 강제, public access false, IRSA 접근.
- Aurora backtrack/PITR은 Phase 3 (A1.2 Availability).

## References

- [security-baseline.md](../security/security-baseline.md)
- [docs/temporal-on-eks.md](../temporal-on-eks.md)
- AWS Aurora Serverless v2 pricing: https://aws.amazon.com/rds/aurora/pricing/

# Runbooks

비자명한 운영 절차를 단계별로 적은 문서.

## 작성 시점

- 한 번 이상 실수했거나 헷갈렸던 작업
- 시간 압박 상황에서 참조해야 할 절차 (예: break-glass)
- 자동화하기 전에 임시로 박아두는 절차

## 예정 (Phase에 따라 작성)

| 파일 | 작성 시점 | 내용 |
|---|---|---|
| `backend-migration-s3.md` | Phase 1 1단계 직후 | local state -> S3 backend 이전 |
| `state-split.md` | Phase 2 진입 | 단일 state -> 환경/레이어 분리 (`terraform state mv`) |
| `break-glass-eks.md` | Phase 3 | prod EKS 비상 접근 |
| `db-restore.md` | Phase 3 | Aurora PITR 복원 시연 |

지금은 비어있음. 필요해질 때 작성.

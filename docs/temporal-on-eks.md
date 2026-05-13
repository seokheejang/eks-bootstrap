# Temporal on EKS — Requirements & Decisions

AWS EKS 위에 [Temporal](https://temporal.io) 플랫폼을 자체 구축할 때의 선택지와 요구사항을 정리한 문서.

---

## 1. 핵심 배포 모델 선택

| 구분 | 셀프호스팅 (OSS) | Temporal Cloud |
|---|---|---|
| **선택 여부** | 선택 | 미사용 |
| 라이센스 | MIT (무료) | 상용 SaaS |
| Server 운영 주체 | 자체 (EKS) | Temporal |
| DB 운영 주체 | 자체 (RDS) | Temporal |
| Worker 운영 주체 | 자체 | 자체 (동일) |
| 비용 모델 | 인프라 비용 | 액션 기반 과금 |
| 운영 부담 | 높음 | 낮음 |

---

## 2. 필수 컴포넌트 (Required)

| 영역 | 컴포넌트 | 필수 여부 | 비고 |
|---|---|---|---|
| 클러스터 | AWS EKS 1.28+ | 필수 | 노드그룹은 Temporal/Worker 분리 권장 |
| DB (메인) | RDS Aurora PostgreSQL 15+ | 필수 | `temporal` DB |
| DB (visibility) | RDS Aurora PostgreSQL | 필수 | `temporal_visibility` DB (같은 클러스터 OK) |
| 서버 배포 | Helm chart (`temporalio/helm-charts`) | 필수 | Kustomize로 wrap |
| GitOps | ArgoCD Application | 필수 | 기존 GitOps 환경 활용 |
| Secrets | AWS Secrets Manager + External Secrets Operator | 필수 | DB 크리덴셜·인증서 |
| 네트워킹 | Internal NLB (gRPC) | 필수 | Temporal frontend 7233 |
| 보안 | mTLS (cert-manager) | 필수 | 프로덕션 |
| IAM | IRSA | 필수 | Pod별 AWS 권한 |
| 관측성 | Prometheus + Grafana | 필수 | 기존 스택 활용 |
| 로깅 | Fluent Bit → CloudWatch/Loki | 필수 | |
| 백업 | Aurora 자동 백업 + PITR | 필수 | 7일+ |
| 인증 (UI) | OIDC (Cognito/SSO) | 필수 | Web UI 노출 시 |

---

## 3. 선택 컴포넌트 (Optional)

| 영역 | 컴포넌트 | 상태 | 도입 조건 |
|---|---|---|---|
| Advanced Visibility | AWS OpenSearch | 보류 | 검색·필터 많을 때 (Phase 3) |
| Archival | S3 | 보류 | 장기 보관 필요 시 |
| Worker 오토스케일 | KEDA + temporal scaler | 권장 | task queue backlog 기반 |
| 정책 엔진 | OPA / Kyverno | 권장 | 멀티팀 환경 |
| Cross-region DR | Aurora Global Database | 보류 | RPO 요구사항 발생 시 |

---

## 4. Phase별 우선순위

| Phase | 기간 | 범위 | DB | Visibility |
|---|---|---|---|---|
| **Phase 1 (PoC)** | ~1주 | Server + Sample Worker + UI (인증 X) | RDS PG 단일 인스턴스 | PG visibility |
| **Phase 2 (Staging)** | ~3주 | mTLS, Secrets, ArgoCD 전환, 관측성 | RDS PG Multi-AZ | PG visibility |
| **Phase 3 (Prod)** | ~1개월 | DR, NetworkPolicy, Pod Security, 런북 | Aurora PG Multi-AZ | OpenSearch 검토 |

---

## 5. 비용 추정 (us-east-1, 소규모)

| 항목 | 스펙 | 월 비용 |
|---|---|---|
| EKS 컨트롤플레인 | - | $73 |
| EKS 노드 | m6i.large × 3 | ~$220 |
| Aurora PostgreSQL | db.r6g.large × 2 (Multi-AZ) | ~$420 |
| OpenSearch (옵션) | t3.medium.search × 3 | ~$210 |
| NLB | 1대 | ~$20 |
| **합계 (PG visibility)** | | **~$733/월** |
| **합계 (OpenSearch 포함)** | | **~$943/월** |

---

## 6. 운영 책임 매트릭스

| 항목 | 담당 |
|---|---|
| Temporal Server 패치/업그레이드 | 인프라팀 |
| DB 패치/백업 | 인프라팀 (AWS 매니지드 활용) |
| Worker 코드 배포 | 앱팀 |
| Workflow/Activity 코드 | 앱팀 |
| Namespace 생성/권한 | 인프라팀 |
| 모니터링/알람 | 인프라팀 |
| Retention 정책 | 인프라팀 + 앱팀 협의 |

---

## 7. 의사결정 요약

| 결정 사항 | 선택 | 근거 |
|---|---|---|
| 배포 모델 | 셀프호스팅 (EKS) | GitOps·IaC 학습/운영 내재화 |
| DB 엔진 | PostgreSQL (Aurora) | 운영 친숙도, Cassandra 운영 회피 |
| 초기 Visibility | PG (OpenSearch 미도입) | 운영 복잡도·비용 최소화 |
| 배포 도구 | Helm + Kustomize + ArgoCD | 기존 GitOps 스택 정합 |
| Secrets | AWS Secrets Manager + ESO | AWS 네이티브 통합 |
| 인증 | OIDC (사내 SSO 또는 Cognito) | Web UI 보안 필수 |

---

## 참고

- [Temporal 공식 문서](https://docs.temporal.io)
- [temporalio/helm-charts](https://github.com/temporalio/helm-charts)
- [Temporal Server self-hosting guide](https://docs.temporal.io/self-hosted-guide)

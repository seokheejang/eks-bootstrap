# ISO 27001:2022 Mapping

글로벌 사업 (EU·아시아 enterprise 고객) 대응 시 보조 매핑. 본 디렉토리 진입점은 [README.md](README.md). 1차 프레임워크는 [SOC 2 Type II](soc2-compliance.md).

ISO/IEC 27001:2022는 Annex A를 **4 theme · 93 controls**로 재구성 (이전 2013 대비 114 -> 93 통합). AICPA 공식 매핑상 SOC 2 TSC와 약 **80% 통제 중복** — dual cert 시 단일 audit firm으로 20~35% 비용 절감 가능.

두 가지 표:
1. SOC 2 충족 시 ISO 27001 Annex A의 어느 항목이 *자동 충족*되는가
2. SOC 2로는 *안 채워지는* ISO 27001 갭 (대부분 조직·인적·물리 영역)

## 리뷰 포커스

- **Annex A 번호 정확성** — A.5.x, A.8.x 등이 실제 ISO/IEC 27001:2022 standard와 일치 (4 theme 합계 37+8+14+34=93 controls).
- **A.5 일부 + A.6 전체 + A.7 전체는 범위 밖** — 정책·인적·물리는 본 레포에서 다루지 않음.
- **80% overlap / 20~35% 비용 절감 수치** — AICPA 공식 매핑 기준. [soc2-checklist.md global market section](soc2-checklist.md#5-global-market-확장-iso-27001-dual)과 동일 출처.
- **Phase 컬럼 정합성** — 자동 충족 매핑의 "충족 Phase"가 [soc2-compliance.md TSC 매핑](soc2-compliance.md#trust-services-criteria-매핑-security-우선)과 일치.

## 1. 자동 충족 매핑 (SOC 2 -> ISO 27001:2022 Annex A)

ISO 27001:2022 Annex A 4 theme:
- **A.5 Organizational** (37 controls)
- **A.6 People** (8 controls)
- **A.7 Physical** (14 controls)
- **A.8 Technological** (34 controls)

### A.5 Organizational — IaC relevant

| Annex A | 내용 | 대응 SOC 2 | 충족 Phase |
|---|---|---|---|
| A.5.15 접근통제 | 접근 정책 | CC6.1 | Phase 1~2 |
| A.5.16 신원관리 | identity lifecycle | CC6.2, CC6.3 | Phase 1~2 (IRSA, ArgoCD OAuth) |
| A.5.17 인증정보 | password·token 관리 | CC6.3 | Phase 1~2 (IRSA, ESO) |
| A.5.18 접근권한 | provisioning·deprovisioning | CC6.1 | Phase 1~2 |
| A.5.19 공급자 관계 | 벤더 위험 | CC9.2 | Phase 1~2 (version pin + 검증 절차) |
| A.5.22 공급자 모니터링 | 서비스 변경 평가 | CC9.2 | Phase 1~2 |
| A.5.23 클라우드 보안 | 클라우드 서비스 사용 | CC6.6, CC6.7 | Phase 1~2 |
| A.5.30 ICT 준비성 | 운영 지속 | A1.x | Phase 3 |
| A.5.33 기록 보호 | 기록 무결성 | CC7.2 | Phase 2 (CloudTrail LFV, S3 Object Lock) |

### A.6 People — 대부분 범위 밖

채용·교육·비밀유지·종료 절차 등 HR 영역. SOC 2 CC1 (Control Environment)과 동일하게 조직 차원. **범위 밖**.

### A.7 Physical — AWS Shared Responsibility

데이터센터·사무실 보안. AWS가 책임. **범위 밖**.

### A.8 Technological — IaC core

| Annex A | 내용 | 대응 SOC 2 | 충족 Phase |
|---|---|---|---|
| A.8.2 특권 접근 | privileged access | CC6.1 | Phase 1~2 (IAM least privilege) |
| A.8.3 정보 접근 제한 | 접근 제어 구현 | CC6.1, CC6.3 | Phase 1~2 |
| A.8.5 보안 인증 | MFA·인증서 | CC6.2 | Phase 1~2 (Root MFA, ArgoCD OAuth, mTLS) |
| A.8.7 멀웨어 보호 | 노드·container scan | CC6.8 | Phase 3 (Inspector, Kyverno) |
| A.8.9 형상 관리 | IaC·configuration | CC8.1 | Phase 1 (plans/, git, ADR) |
| A.8.10 정보 삭제 | 데이터 파기 | C1.2 | Phase 3 |
| A.8.13 백업 | 정보 백업 | A1.2 | Phase 3 (AWS Backup, Aurora PITR) |
| A.8.15 로깅 | 활동 로그 | CC7.1, CC7.2 | Phase 1~2 (EKS logs, CloudTrail, VPC Flow) |
| A.8.16 모니터링 | 시스템 모니터링 | CC7.2, CC7.3 | Phase 2~3 (GuardDuty, Security Hub) |
| A.8.17 시간 동기화 | NTP | CC7.1 | 사전 조건 (Amazon Time Sync) |
| A.8.20 네트워크 보안 | 네트워크 통제 | CC6.6 | Phase 1~2 (SG, VPC) |
| A.8.21 네트워크 서비스 보안 | 네트워크 서비스 메커니즘 | CC6.6, CC6.7 | Phase 1~2 (TLS, mTLS) |
| A.8.22 네트워크 분리 | segmentation | CC6.6 | Phase 1 (VPC, subnet) |
| A.8.23 웹 필터링 | 웹 접근 통제 | CC6.6 | Phase 3 (WAF) |
| A.8.24 암호 사용 | 암호화 | CC6.1 | Phase 1~2 (KMS) |
| A.8.25 보안 SDLC | secure development | CC8.1 | Phase 1 (commit-gates) |
| A.8.27 보안 아키텍처 | 아키텍처 원칙 | CC8.1 | Phase 1 (ADR) |
| A.8.28 보안 코딩 | 코딩 표준 | CC8.1 | Phase 1 (conventions/) |
| A.8.29 보안 테스트 | 보안 시험 | CC8.1 | Phase 1~2 (tfsec, trivy) |
| A.8.31 환경 분리 | dev/staging/prod | CC9.1 | Phase 2 |
| A.8.32 변경 관리 | 변경 통제 | CC8.1 | Phase 1 (plan, ADR) |
| A.8.33 테스트 정보 | 테스트 데이터 보호 | C1.1 | Phase 3 |

## 2. SOC 2로 안 채워지는 ISO 27001 갭

ISO 27001 특화 항목. SOC 2 baseline 외에 추가 작업 필요.

| Annex A | 내용 | 본 레포 다룰지 |
|---|---|---|
| A.5.1 정보보안 정책 | 정책 문서·승인·검토 | **범위 밖** (조직) |
| A.5.2 역할·책임 | 정보보호 책임 분장 | **범위 밖** (조직) |
| A.5.3 직무 분리 | SoD | 부분 (CODEOWNERS·git 추후) |
| A.5.4 경영진 책임 | 경영진 commitment | **범위 밖** (조직) |
| A.5.5 외부 기관 연락 | regulator·CERT 연락 | **범위 밖** (조직) |
| A.5.7 위협 정보 | threat intelligence | **범위 밖** (운영) |
| A.5.8 프로젝트 보안 | 프로젝트 단계 보안 | **범위 밖** (PM) |
| A.5.24~5.28 사건 관리 | 사건 절차 | **범위 밖** (runbook + 운영) |
| A.5.31 법적·계약 요구사항 | 컴플라이언스 매핑 | **범위 밖** (법무) |
| A.5.32 지적재산 | IP 보호 | **범위 밖** (법무) |
| A.5.34 개인정보 보호 | privacy program | **범위 밖** (앱 + 법무) |
| A.5.36 정책 준수 | 준수 검토 | **범위 밖** (조직) |
| A.5.37 문서화된 절차 | 운영 절차서 | 부분 (runbooks/, 추가 필요) |
| A.6.x 인적 보안 전체 | 채용·교육·종료 | **범위 밖** (HR) |
| A.7.x 물리 보안 전체 | 데이터센터·사무실 | AWS Shared Responsibility |
| A.8.1 사용자 단말 | 엔드포인트 | **범위 밖** (조직 IT) |
| A.8.4 소스 코드 접근 | 소스 접근 통제 | **범위 밖** (GitHub 권한) |
| A.8.6 용량 관리 | capacity | 부분 (Karpenter — Phase 3) |
| A.8.8 취약점 관리 | vulnerability management | 부분 (trivy — Phase 1~2) |
| A.8.18 특권 유틸리티 | admin tool 통제 | 부분 (IAM least privilege) |
| A.8.19 운영 시스템 소프트웨어 설치 | 변경 통제 | 부분 (CC8.1) |
| A.8.26 애플리케이션 보안 | 앱 보안 요구사항 | **범위 밖** (앱) |
| A.8.30 외주 개발 | outsourced dev | **범위 밖** (조직) |

## 3. 글로벌 사업 컨텍스트

| 시장 | 표준 | 우선순위 |
|---|---|---|
| 미국 enterprise | SOC 2 Type II | **1순위** — procurement 사실상 mandatory |
| EU enterprise | ISO 27001 + GDPR | **2순위** — 동시에 SOC 2도 인정 |
| 영국 enterprise | ISO 27001 + UK GDPR + Cyber Essentials | 케이스별 |
| 일본·싱가포르·호주 enterprise | ISO 27001 우선 | SOC 2 보조 |
| 한국 enterprise | ISMS-P | 별도 ([isms-mapping.md](isms-mapping.md)) |

**dual cert 권장 시나리오**:
- 미국 + EU 동시 진출 -> SOC 2 + ISO 27001 dual
- 단일 audit firm에서 두 audit 동시 진행 시 controls 80% 재사용
- 비용 절감 20~35%, 운영 부담은 거의 단일 cert과 동일

## 4. GDPR과의 관계 (글로벌 사업 시 추가 고려)

GDPR은 *법규* (regulation), ISO 27001은 *표준* (standard). 다른 layer.

- GDPR 핵심: 데이터 주체 권리 (열람·수정·삭제·이동), 처리 근거, DPIA, breach notification
- ISO 27001: 정보보호 management system (ISMS)
- 교집합: A.5.34 (개인정보 보호), A.8.10 (정보 삭제), A.8.11 (데이터 마스킹), A.8.12 (DLP)
- 본 레포는 **GDPR 직접 다루지 않음** (앱 + 법무 영역). 단 IaC baseline이 GDPR Article 32 (technical and organizational measures)의 일부 evidence로 사용 가능.

## 5. 결론

- eks-bootstrap이 SOC 2 Type II Security baseline을 단계적으로 충족하면 **ISO 27001 Annex A의 IaC relevant 통제 대부분 동일 Phase에 자동 충족** (A.5 일부 조직 통제·A.6 People·A.7 Physical 제외).
- 글로벌 사업 진출 시점에 SOC 2 + ISO 27001 **dual cert을 같은 audit firm에서 동시 진행** 권장 — 본 레포는 그 기술 baseline 제공.
- ISO 27001 인증을 위해서는 조직 차원 작업 (A.5.1~5.5 정책, A.6 인적, A.5.24 사건 관리, A.5.37 절차서 등) 별도 필요.

## References

- [security-baseline.md](security-baseline.md) — Tier 1/2/3 우선순위
- [soc2-compliance.md](soc2-compliance.md) — SOC 2 TSC 매핑 + audit timeline
- [isms-mapping.md](isms-mapping.md) — 한국 ISMS-P (보조)
- ISO/IEC 27001:2022 (공식 구매): https://www.iso.org/standard/27001
- ISO/IEC 27001:2022 Annex A 변경 요약: https://www.iso.org/news/ref2820.html
- AICPA SOC 2 <-> ISO 27001 매핑 (공식): https://www.aicpa-cima.com/topic/audit-assurance/audit-and-assurance-greater-than-soc-2

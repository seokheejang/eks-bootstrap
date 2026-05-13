# SOC 2 Audit-Ready Checklist

audit 직전 self-assessment + evidence 위치 매핑. Type I/II 양쪽에 사용. 본 디렉토리 진입점은 [README.md](README.md).

상위 문서:
- 통제 매핑: [soc2-compliance.md](soc2-compliance.md)
- 기술 baseline: [security-baseline.md](security-baseline.md)
- 우선순위 (Tier 1/2/3): [security-baseline.md "우선순위 분류"](security-baseline.md#우선순위-분류--구축-시-박을-것-vs-후속-추가)

## 리뷰 포커스

- **Type I yes/no 항목**이 [security-baseline.md Tier 표](security-baseline.md#tier-1--첫-terraform-apply에-반드시-immutable재생성-비용-매우-큼)의 Tier 1 + Tier 2 항목과 양방향 일치하는지.
- **Evidence Map 12행** — 각 TSC 통제의 evidence 위치가 실제 파일/AWS 리소스 경로와 매칭하는지.
- **"Audit firm 사전 협의" 4건** — [soc2-compliance.md disclaimer](soc2-compliance.md#trust-services-criteria-매핑-security-우선)와 같은 5건 + CC1.5 빠진 게 의도인지 확인 (현재 4건만 박힘).
- **Global market 확장 섹션** — ISO 27001 dual 권장 시점 + 비용 절감 수치가 [iso27001-mapping.md](iso27001-mapping.md)와 일치.

## 1. Type I Readiness (point-in-time)

각 항목 yes/no. 모두 yes면 Type I audit 진입 후보.

### 인프라 baseline (Tier 1·2 필수)

- [ ] AWS account-level EBS default encryption ON
- [ ] Root account MFA 활성
- [ ] tfstate S3 bucket: versioning + SSE + public access block + Object Lock + `prevent_destroy`
- [ ] CloudTrail multi-region trail + log file validation (LFV) 활성
- [ ] EKS authentication_mode = `API` (aws-auth ConfigMap 미사용)
- [ ] EKS control plane logs 5종 활성 (api/audit/authenticator/controllerManager/scheduler)
- [ ] EKS Secret KMS CMK envelope encryption (cluster 생성 시 설정)
- [ ] Aurora storage_encrypted + CMK + TLS 강제 (`rds.force_ssl=1`) + public access false
- [ ] IMDSv2 강제 (MNG·Karpenter 노드 모두)
- [ ] IRSA per pod (static IAM access key 미사용)
- [ ] commit-gates 활성 (gitleaks, tfsec, fmt, validate, tflint)

### Phase 2 baseline 항목

- [ ] KMS CMK annual rotation 활성
- [ ] Log retention >= 365일 (CloudWatch + S3)
- [ ] VPC Flow Logs S3 destination
- [ ] ALB access logs S3 destination
- [ ] mTLS (Temporal frontend)
- [ ] ArgoCD GitHub OAuth + local admin 비활성
- [ ] ESO (External Secrets Operator) 도입
- [ ] RDS pgAudit (parameter group + `shared_preload_libraries`)
- [ ] Secrets Manager rotation Lambda (DB credential)

### 변경 관리 evidence

- [ ] 최근 6개월 모든 변경에 plan 문서 (`docs/plans/YYYYMMDD-*.md`) 존재
- [ ] 각 plan에 S3.5 Security Review 채워짐
- [ ] 모든 자원 변경이 git history에 추적됨
- [ ] ADR (`docs/decisions/*.md`) 작성됨 (의사결정 기록)

## 2. Type II Readiness (operating effectiveness)

Type I 항목 + 다음 운영 evidence **6~12개월 누적**.

### 운영 절차 evidence

- [ ] Drift detection 정기 실행 기록 (`terraform plan -detailed-exitcode`)
- [ ] Access review 분기별 수행 기록 (IAM, EKS RBAC, ArgoCD, GitHub, SSM)
- [ ] Vulnerability scan 결과 + remediation tracking (trivy, Inspector)
- [ ] Backup restore 시연 기록 (Aurora PITR, AWS Backup) — annual 권장
- [ ] Incident response 사례 + post-mortem (있을 시)
- [ ] 변경 PR review 흐름 (CODEOWNERS, 승인 기록)

### 모니터링 evidence

- [ ] GuardDuty 발견 + triage 기록
- [ ] Security Hub 통제 평가 기록
- [ ] CloudTrail 로그가 audit 기간 동안 연속 수집됨 (gap 없음)
- [ ] VPC Flow Logs / ALB access logs 누락 없음
- [ ] alert + on-call 응답 기록

## 3. Evidence Map (통제 → 어디서 보여줄지)

audit firm이 *"어디를 보여달라"*고 할 때 빠르게 안내.

| TSC 통제 | Evidence 위치 |
|---|---|
| CC6.1 접근통제 | AWS Console: IAM Roles, EKS Access Entries / `modules/irsa/`, `modules/eks-cluster/access.tf` |
| CC6.1 암호화 | `modules/rds-aurora/main.tf` (`storage_encrypted`), `modules/eks-cluster/cluster.tf` (`encryption_config`), AWS Console KMS |
| CC6.2 인증 | AWS Console: Root MFA / IAM Identity Center / ArgoCD UI (OAuth) |
| CC6.3 시크릿 | AWS Secrets Manager, SSM Parameter Store, ESO ClusterSecretStore |
| CC6.6 외부 위협 차단 | `modules/vpc/`, `modules/eks-cluster/security_group.tf`, AWS WAF |
| CC6.7 전송 보호 | ACM 인증서, RDS parameter group (`rds.force_ssl=1`), Temporal mTLS config |
| CC7.1 control plane logs | CloudWatch Logs: `/aws/eks/<cluster>/cluster` 5 log streams |
| CC7.2 audit trail | CloudTrail (multi-region + LFV), S3 bucket (Object Lock), VPC Flow Logs, ALB access logs |
| CC7.3 탐지 | GuardDuty findings, Security Hub findings, Inspector findings |
| CC8.1 변경 관리 | `docs/plans/*.md`, git log, ADR (`docs/decisions/*.md`), GitHub PR history |
| CC9.1 벤더 위험 | `docs/conventions/versions.md` (provider/chart pinning + 변경 검증 절차) |
| A1.2 백업 | Aurora automated backup, AWS Backup vaults |
| C1.2 기밀정보 파기 | Aurora PITR retention, S3 lifecycle, secrets rotation Lambda |

## 4. Audit firm 사전 협의 권장 항목

본 baseline에 *industry-common interpretation*으로 박힌 항목은 firm마다 해석 차이 가능 ([soc2-compliance.md disclaimer](soc2-compliance.md#trust-services-criteria-매핑-security-우선)):

- **CC1.5 Accountability** — git commit author + CODEOWNERS as accountability evidence
- **CC3.4 변경 위험 평가** — plan S5/S6 (Rollback Trigger/Procedure) as change risk assessment
- **CC4.2 결함 communication** — ADR + post-incident docs as deficiency communication
- **CC5.1~5.3 통제 선택** — commit-gates (gitleaks/tfsec 등) as control selection evidence

audit kickoff 시 위 항목 evidence가 firm 기준에 맞는지 사전 확인.

## 5. Global market 확장 (ISO 27001 dual)

EU·아시아 enterprise 시장 진출 시 SOC 2 + ISO 27001 dual cert 권장:

- [ ] [iso27001-mapping.md](iso27001-mapping.md)의 Annex A 자동 충족 매핑 검토
- [ ] ISO 27001 특화 갭 (A.5 정책, A.6 People, A.5.24~28 사건 관리) 별도 작업
- [ ] 단일 audit firm으로 SOC 2 + ISO 27001 동시 engagement (controls 80% overlap, 비용 20~35% 절감)

## References

- [soc2-compliance.md](soc2-compliance.md) — TSC 매핑
- [security-baseline.md](security-baseline.md) — 기술 baseline + Tier 분류
- [iso27001-mapping.md](iso27001-mapping.md) — ISO 27001 매핑
- [isms-mapping.md](isms-mapping.md) — ISMS-P 매핑
- [docs/plans/](../plans/) — 변경 plan template + 누적 기록
- [docs/decisions/](../decisions/) — ADR

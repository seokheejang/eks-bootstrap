# ISMS-P Mapping (Reference Only)

eks-bootstrap의 1차 프레임워크는 **SOC 2 Type II**. ISMS/ISMS-P는 보조 참고용.

두 가지를 표로 정리:

1. SOC 2 통제 충족 시 ISMS-P의 어느 항목이 *자동 충족*되는가
2. SOC 2로는 *안 채워지는* ISMS-P 갭이 무엇인가

## 1. 자동 충족 (SOC 2 -> ISMS-P)

ISMS-P 기술 통제 대부분은 SOC 2 baseline 충족 시 자동으로 채워짐. 충족 시점은 SOC 2 매핑된 통제의 Phase와 동일.

| ISMS-P 도메인 | 대응 SOC 2 TSC | 충족 경로 | Phase |
|---|---|---|---|
| 2.5 인증 및 권한관리 | CC6.1, CC6.2, CC6.3 | EKS API auth + IRSA + IAM + Root MFA | Phase 1 부분, Phase 2 강화 |
| 2.6 접근통제 | CC6.1, CC6.6 | RBAC, SG, NetworkPolicy | Phase 1 부분, Phase 3 강화 (Pod Security) |
| 2.7 암호화 적용 | CC6.1, CC6.7 | EBS/RDS/EKS Secret + RDS TLS | Phase 1 부분 (AWS-managed key), Phase 2 강화 (CMK + mTLS) |
| 2.8 정보시스템 도입 및 개발 보안 | CC8.1 | plans/ + git + commit-gates (gitleaks, tfsec) | **Phase 1 자동 충족** |
| 2.9 시스템 및 서비스 운영관리 | CC7.1, CC7.2 | EKS control plane logs (Phase 1), CloudTrail centralized + VPC Flow + ALB access (Phase 2) | Phase 1 부분, Phase 2 자동 충족 |
| 2.10 시스템 및 서비스 보안관리 | CC6.6, CC6.8 | SG/NetworkPolicy (Phase 1), WAF (Phase 3), Pod Security (Phase 3) | Phase 1 부분, Phase 3 자동 충족 |
| 2.11 사고 예방 및 대응 | CC7.3, CC7.4 | GuardDuty, Security Hub, runbook | Phase 3 자동 충족 |
| 2.12 재해복구 | A1.2, A1.3 | AWS Backup, Aurora PITR, DR runbook | Phase 3 자동 충족 |

## 2. SOC 2로 안 채워지는 ISMS-P 갭

ISMS-P 특화 항목. SOC 2 baseline 외에 추가 작업 필요.

| ISMS-P 도메인 | 갭 내용 | eks-bootstrap 다룰지 |
|---|---|---|
| 1.1 관리체계 수립 | 정보보호위원회, 책임자 지정, 정책 수립 | **레포 범위 밖** (조직) |
| 1.2 관리체계 운영 | 자산식별·위험분석·위험처리 절차 | **레포 범위 밖** (프로세스) |
| 1.3 관리체계 점검 및 개선 | 내부감사, 경영진 검토 | **레포 범위 밖** (프로세스) |
| 2.1 정책, 조직, 자산 관리 | 인적·물리적 자산 관리 | **레포 범위 밖** (조직) |
| 2.2 인적 보안 | 채용·교육·퇴직자 관리 | **레포 범위 밖** (HR) |
| 2.3 외부자 보안 | 외주·위탁 관리 | **레포 범위 밖** (계약) |
| 2.4 물리 보안 | 데이터센터·사무실 보안 | AWS Shared Responsibility |
| 3.1 개인정보 수집 시 보호 | 수집 동의·고지 | **레포 범위 밖** (앱) |
| 3.2 개인정보 보유·이용 시 보호 | 처리방침·보관 | **레포 범위 밖** (앱) |
| 3.3 개인정보 제공 시 보호 | 제3자 제공·국외 이전 | **레포 범위 밖** (앱) |
| 3.4 개인정보 파기 시 보호 | 파기 절차·증거 | **레포 범위 밖** (앱) |
| 3.5 정보주체 권리보장 | 열람·정정·삭제 요구 처리 | **레포 범위 밖** (앱) |

## 결론

- eks-bootstrap이 SOC 2 Type II Security baseline을 단계적으로 충족하면 **ISMS-P 2.x 기술 통제는 동일 Phase에 자동 충족**.
- ISMS-P 1.x 관리체계, 2.1~2.4 조직·인적·물리, 3.x 개인정보 라이프사이클은 **이 레포 미처리**. 조직 또는 앱 레이어에서 다룸.
- ISMS-P 인증이 실제 필요해지면, 위 갭 표를 출발점으로 별도 organization-level 작업 수행.

## References

- [security-baseline.md](security-baseline.md)
- [soc2-compliance.md](soc2-compliance.md)
- KISA ISMS-P Overview: https://isms.kisa.or.kr/main/ispims/intro

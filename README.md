# eks-bootstrap

> Personal sandbox + reusable AWS EKS Terraform base.

This repository serves two roles in one place:

1. **Reusable modules** (`modules/`) — single-responsibility Terraform primitives for AWS EKS. Designed to be forked, copied, or vendored into private/company repos. No business context, no organization-specific naming, no secrets.

2. **Sandbox stacks** (`environments/<env>/`) — my own learning ground. The first use case is Temporal on EKS, where I exercise the modules end-to-end. Other platform tools will join the same pattern.

If you're here to grab modules, ignore `environments/` and `infra/`. If you're here for design notes, read `docs/`.

## Layout

```
eks-bootstrap/
├── modules/                # Reusable Terraform modules (the forkable part)
├── environments/           # Sandbox stacks (my own use cases)
│   └── dev/                #   Phase 1: VPC + EKS + Aurora Serverless v2 + Temporal
├── infra/tf-backend/       # One-time S3 backend bootstrap (S3 native lock)
└── docs/                   # Conventions, decisions, plans, runbooks, security
```

## Modules

Designed as small primitives with clear input/output contracts. Granularity intentionally similar to `terraform-aws-modules/*` (cohesive primitives, not micro-modules).

Planned for Phase 1:

| Module | Responsibility |
|---|---|
| `modules/vpc` | VPC + subnets + NAT |
| `modules/eks-cluster` | EKS control plane + addons + IRSA base + SG |
| `modules/eks-node-group` | Managed node group + launch template |
| `modules/irsa` | Reusable IRSA helper |
| `modules/rds-aurora` | Aurora cluster + instances + parameter/subnet group |

## Stack

- **IaC**: Terraform **1.11+** (S3 native locking; DynamoDB not used)
- **Cluster**: AWS EKS 1.28+ (Phase 1 target: 1.30)
- **DB**: Aurora PostgreSQL Serverless v2
- **State backend**: S3 with `use_lockfile = true`
- **First workload**: [Temporal](docs/temporal-on-eks.md) via Helm (later GitOps)

## Security posture

Primary framework: **SOC 2 Type II** (Security TSC), targeting global SaaS audit-readiness. ISO 27001:2022 mapped for EU/Asia enterprise markets. ISMS-P mapped for Korean market.

- [Baseline](docs/security/security-baseline.md) — minimum security bar by Phase, with Tier 1/2/3 priority (immutable vs. addable later)
- [SOC 2 compliance design](docs/security/soc2-compliance.md) — TSC-by-TSC + Type I/II audit timeline
- [SOC 2 audit checklist](docs/security/soc2-checklist.md) — pre-audit readiness + evidence map
- [ISO 27001 mapping](docs/security/iso27001-mapping.md) — global market secondary
- [ISMS-P mapping](docs/security/isms-mapping.md) — Korean market reference

## Docs

- [CLAUDE.md](CLAUDE.md) — assistant-facing summary
- [docs/conventions/](docs/conventions/) — naming, tagging, variables, style, versions, commit gates
- [docs/decisions/](docs/decisions/) — Architecture Decision Records (ADRs)
- [docs/plans/](docs/plans/) — change plans per apply
- [docs/runbooks/](docs/runbooks/) — operational procedures (sparse during Phase 1)
- [docs/security/](docs/security/) — baseline, SOC 2, ISMS-P mapping
- [docs/temporal-on-eks.md](docs/temporal-on-eks.md) — first use case requirements

## Status

Personal sandbox. Not battle-tested. Phase 1 (PoC) in progress; structure and docs first, Terraform code follows.

## License

MIT

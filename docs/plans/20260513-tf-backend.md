# tf-backend: S3 bucket for Terraform state

- Date: 2026-05-13
- Status: Draft
- Related: [0003-backend-bootstrap-local-state](../decisions/0003-backend-bootstrap-local-state.md)

## S1. Background

빌드 순서 1단계 ([plans/README.md](README.md)). `environments/dev/`의 terraform state를 저장할 S3 bucket을 만든다.

순환 의존(state를 만들 state)을 피하기 위해 `infra/tf-backend/`라는 독립 stack을 local state로 1회 apply한다. Terraform 1.10+의 S3 native locking(`use_lockfile`)을 사용하므로 DynamoDB 테이블은 만들지 않는다.

## S2. Target Resources

신규 생성 (region: ap-northeast-2 가정, env 변경 시 tfvars로 override):

- `aws_s3_bucket.state` (예상 이름: `eksbs-dev-tfstate` 등; bucket 이름은 글로벌 유니크라 tfvars에서 결정)
- `aws_s3_bucket_versioning.state`
- `aws_s3_bucket_server_side_encryption_configuration.state` (SSE-S3 / AES256)
- `aws_s3_bucket_public_access_block.state`
- `aws_s3_bucket_lifecycle_configuration.state` (noncurrent 90일 만료 + 7일 미완 multipart 정리)

기존 자원 변경: 없음
DynamoDB lock 테이블: **만들지 않음** (S3 native lock 사용)

## S3. Expected Changes

```
infra/tf-backend/
├── main.tf          # 위 5개 resource
├── variables.tf     # bucket_name, tags
├── outputs.tf       # bucket_name, bucket_arn, region
├── versions.tf      # required_version >= 1.11, aws ~> 5
├── terraform.tfvars # bucket_name = "eksbs-dev-tfstate" 등 (env별로 갱신)
└── README.md        # 사용법 (init/apply/teardown 주의)
```

`terraform plan` 출력 첨부 위치: (코드 작성 후 채움)

backend block은 이 stack에 **없음** (local state로 동작). `terraform.tfstate`는 `.gitignore` 대상.

## S3.5. Security Review

- **Baseline 영향**: [security-baseline.md "tfstate 보호" 항목](../security/security-baseline.md) 적용 — SSE-S3, versioning, public access block, `prevent_destroy = true`, noncurrent 90일 만료.
- **SOC 2 TSC 매핑**:
  - CC6.1 암호화: tfstate at-rest 암호화 (AWS-managed key).
  - CC6.6 외부 위협 차단: public access block 4종 모두 활성.
  - CC8.1 변경 관리: 본 plan 자체 + git history.
- **신규 외부 노출**: 없음 (bucket은 비공개, ACL/Policy 명시적 deny).
- **IAM 변경**: 없음 (bucket policy는 추후 plan에서 정교화). 본 plan에선 default bucket owner(account root) 외 접근자 없음.
- **시크릿 취급**: 없음 (bucket 이름과 region만 tfvars에 있음, 둘 다 비밀 아님).
- **Apply/Runtime 함정 점검** ([versions.md](../conventions/versions.md#applyruntime-함정-노트)):
  - **#2 `use_lockfile` + encryption mismatch**: 이 plan은 SSE-S3 (`AES256`)를 적용. lock file(`*.tflock`)도 같은 PUT 경로로 자동 동일 암호화 적용됨. bucket policy로 `s3:x-amz-server-side-encryption` 헤더 강제 시 lock file 경로도 동일 정책 만족해야 함 → 본 plan은 bucket policy 미설정이라 현재는 영향 없음. Phase 2에서 bucket policy 도입 시 재점검 필수.

## S4. Success Criteria

```bash
# 1. apply 후 bucket 존재 확인
aws s3api head-bucket --bucket "$BUCKET_NAME"
# expected: exit code 0

# 2. versioning 활성
aws s3api get-bucket-versioning --bucket "$BUCKET_NAME"
# expected: { "Status": "Enabled" }

# 3. public access block 4종 모두 true
aws s3api get-public-access-block --bucket "$BUCKET_NAME"
# expected: BlockPublicAcls=true, BlockPublicPolicy=true,
#           IgnorePublicAcls=true, RestrictPublicBuckets=true

# 4. SSE-S3 encryption
aws s3api get-bucket-encryption --bucket "$BUCKET_NAME"
# expected: SSEAlgorithm=AES256

# 5. lifecycle rule
aws s3api get-bucket-lifecycle-configuration --bucket "$BUCKET_NAME"
# expected: rule "expire-noncurrent-versions" Status=Enabled
```

## S5. Rollback Trigger

다음 중 하나면 rollback:
- `terraform apply` 실패
- S4 5개 명령어 중 하나라도 기대 출력과 다름
- bucket 이름이 글로벌 충돌 (unique name 재선택 후 재apply)

## S6. Rollback Procedure

S3 bucket은 `prevent_destroy = true`로 보호 → Terraform 명령으로는 삭제 불가 (의도). 정말 제거해야 한다면:

```bash
# 1. 모든 객체 + 버전 제거 (주의: 다른 stack의 state가 들어가있지 않은지 먼저 확인)
aws s3api list-object-versions --bucket "$BUCKET_NAME" --output json \
  | jq '.Versions + .DeleteMarkers | map(select(.Key != null)) | {Objects: map({Key, VersionId})}' \
  | aws s3api delete-objects --bucket "$BUCKET_NAME" --delete file:///dev/stdin

# 2. Terraform 코드에서 lifecycle.prevent_destroy 제거 후 commit
# 3. terraform destroy
# 4. local state 파일 제거
rm infra/tf-backend/terraform.tfstate*
```

apply 실패 시점이면 보통 bucket이 아예 안 만들어졌거나 일부 자원만 생성된 상태. `terraform destroy` 또는 `terraform state rm` 후 재시도.

## S7. Verification Result

(apply 후 채움) S4 5개 명령어 출력.

## S8. Related Commit/PR

(apply 후 채움) commit hash·PR 링크.

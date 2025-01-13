data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "test_bucket" {
  bucket = "aft-global-hub-${data.aws_caller_identity.current.account_id}"
  acl    = "private"
}

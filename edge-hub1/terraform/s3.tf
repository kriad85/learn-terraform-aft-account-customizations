data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "test_bucket" {
  bucket = "aft-edge-hub1-${data.aws_caller_identity.current.account_id}"
  acl    = "private"
}

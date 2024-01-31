terraform {
  required_version = "~> 1.4.0"
  required_providers {
    aws = {
      version = "= 5.0.1"
      source  = "hashicorp/aws"
    }
  }
  backend "s3" {
    profile        = "terraform"
    bucket         = "matvil-freelance-tests-tf-state"
    key            = "terraform.tfstate"
    dynamodb_table = "matvil-tf-lock"
  }
}

provider "aws" {
  region              = "us-east-1"
  allowed_account_ids = ["747160515002"]
  default_tags { tags = local.tags }
}

# NOTE: normally, MFA delete and KMS encryption would be enabled
resource "aws_s3_bucket" "state" {
  bucket = "matvil-freelance-tests-tf-state"
  lifecycle { prevent_destroy = true }
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id
  versioning_configuration { status = "Enabled" }
  lifecycle { prevent_destroy = true }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket                  = aws_s3_bucket.state.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  lifecycle { prevent_destroy = true }
}

output "terraform_state_bucket_name" { value = aws_s3_bucket.state.bucket }

resource "aws_dynamodb_table" "lock" {
  name         = "matvil-tf-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  lifecycle { prevent_destroy = true }
}

output "lock_dynamodb_table" { value = aws_dynamodb_table.lock.name }

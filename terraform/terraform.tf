terraform {
  backend "s3" {
    bucket = "terra-state-bucket-alm-woc"
    key    = "terraform/terraform.tfstate"
    region = "eu-west-2"
    dynamodb_table = "terraform-locks"
    encrypt = true
  }
}
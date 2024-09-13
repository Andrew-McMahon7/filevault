resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-${local.environment}"
  }

  depends_on = [null_resource.enforce_workspace]
}
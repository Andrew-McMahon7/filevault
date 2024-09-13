resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw-${local.environment}"
  }

  depends_on = [null_resource.enforce_workspace]
}
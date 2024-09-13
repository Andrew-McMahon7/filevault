resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "nat-${local.environment}"
  }

  depends_on = [null_resource.enforce_workspace]
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-eu-west-2a.id

  tags = {
    Name = "nat-${local.environment}"
  }

  depends_on = [aws_internet_gateway.igw]
}
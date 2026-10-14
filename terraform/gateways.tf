# Internet Gateway for Public Subnet Traffic
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.default_tags,
    {
      Name = "${local.name_prefix}-igw"
    }
  )
}

# Elastic IP for Single NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(
    local.default_tags,
    {
      Name = "${local.name_prefix}-nat-eip"
    }
  )
}

# Single NAT Gateway deployed in the first public subnet
# COST & AVAILABILITY NOTE:
# A single NAT Gateway is deployed to balance cost and operational simplicity for this
# portfolio project (~$32+/month per NAT GW plus data processing charges).
# Because this NAT Gateway resides in one AZ, all private-subnet egress traffic across
# both AZs depends on this single instance. This is not highly available across AZs:
# an AZ-level incident impacting this subnet will disrupt outbound internet connectivity
# for private workloads. For production-grade resilience, deploy one NAT Gateway per AZ.
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    local.default_tags,
    {
      Name = "${local.name_prefix}-nat"
    }
  )

  depends_on = [aws_internet_gateway.main]
}


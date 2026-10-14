# Public Subnets (one per AZ)
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    local.default_tags,
    {
      Name                                          = "${local.name_prefix}-public-${local.azs[count.index]}"
      "kubernetes.io/role/elb"                      = "1"
      "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    }
  )
}

# Private Subnets reserved for EKS worker nodes (one per AZ)
resource "aws_subnet" "private" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = false

  tags = merge(
    local.default_tags,
    {
      Name                                          = "${local.name_prefix}-private-${local.azs[count.index]}"
      "kubernetes.io/role/internal-elb"             = "1"
      "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    }
  )
}


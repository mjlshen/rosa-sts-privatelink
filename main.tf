resource "aws_iam_service_linked_role" "elasticbeanstalk" {
  aws_service_name = "elasticloadbalancing.amazonaws.com"
}

resource "aws_vpc" "rosa" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name}-vpc"
  }
}

resource "aws_subnet" "rosa_private" {
  for_each          = { for idx, az in local.azs : az => idx }
  availability_zone = each.key
  vpc_id            = aws_vpc.rosa.id
  cidr_block        = cidrsubnet(var.cidr, length(local.azs), each.value)

  tags = {
    Name = "${var.name}-private-${each.key}"
    "kubernetes.io/role/internal-elb" = ""
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_subnet" "rosa_public" {
  for_each          = { for idx, az in local.azs : az => idx }
  availability_zone = each.key
  vpc_id            = aws_vpc.rosa.id
  cidr_block        = cidrsubnet(var.cidr, length(local.azs), length(local.azs) + each.value)

  tags = {
    Name = "${var.name}-public-${each.key}"
    "kubernetes.io/role/elb" = ""
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_internet_gateway" "rosa" {
  tags = {
    Name = "${var.name}-igw"
  }
}

resource "aws_internet_gateway_attachment" "rosa" {
  internet_gateway_id = aws_internet_gateway.rosa.id
  vpc_id              = aws_vpc.rosa.id
}

resource "aws_route_table" "rosa_public" {
  vpc_id = aws_vpc.rosa.id

  tags = {
    Name = "${var.name}-public"
  }
}

resource "aws_route_table_association" "rosa_public" {
  for_each       = aws_subnet.rosa_public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.rosa_public.id
}

resource "aws_route" "internet_egress" {
  route_table_id         = aws_route_table.rosa_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.rosa.id
}

resource "aws_eip" "nat_gw" {
  for_each = aws_subnet.rosa_public

  vpc = true

  tags = {
    Name = "${var.name}-eip-${each.key}"
  }

  // EIP may require IGW to exist prior to association.
  // https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip
  depends_on = [aws_internet_gateway_attachment.rosa]
}

resource "aws_nat_gateway" "rosa" {
  for_each          = aws_subnet.rosa_public
  allocation_id     = aws_eip.nat_gw[each.key].allocation_id
  connectivity_type = "public"
  subnet_id         = each.value.id

  tags = {
    Name = "${var.name}-nat-${each.key}"
  }
}

resource "aws_route_table" "rosa_private" {
  for_each = aws_subnet.rosa_private
  vpc_id   = aws_vpc.rosa.id

  tags = {
    Name = "${var.name}-private-${each.key}"
  }
}

resource "aws_route_table_association" "rosa_private" {
  for_each       = aws_subnet.rosa_private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.rosa_private[each.key].id
}

resource "aws_route" "nat_gateway" {
  for_each               = aws_subnet.rosa_private
  route_table_id         = aws_route_table.rosa_private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.rosa[each.key].id
}

resource "aws_vpc" "demovpc" {
  cidr_block           = var.vpccidr
  instance_tenancy     = "default"
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = "true"

  tags = merge(var.commontags, {
    "Name" = "demovpc"
  })
}

resource "aws_subnet" "demovpcpublicsubnets" {
  vpc_id                  = aws_vpc.demovpc.id
  count                   = length(var.publicsubnetscidrs)
  cidr_block              = element(var.publicsubnetscidrs, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = merge(var.commontags, {
    "Name" = "demovpc-publicsubnet-${count.index + 1}"
  })
}

resource "aws_subnet" "demovpcprivatesubnets" {
  vpc_id            = aws_vpc.demovpc.id
  count             = length(var.privatesubnetscidrs)
  cidr_block        = element(var.privatesubnetscidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = merge(var.commontags, {
    "Name" = "demovpc-privatesubnet-${count.index + 1}"
  })
}

resource "aws_internet_gateway" "demovpcigw" {
  vpc_id = aws_vpc.demovpc.id

  tags = merge(var.commontags, {
    "Name" = "demovpc-igw"
  })
}


resource "aws_route_table" "demovpcpublicrt" {
  vpc_id = aws_vpc.demovpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demovpcigw.id
  }

  tags = merge(var.commontags, {
    "Name" = "demovpc-publicrt"
  })
}

resource "aws_route_table_association" "demovpcigwpublicrtassociation" {
  count = length(var.publicsubnetscidrs)
  # subnet_id      = element(aws_subnet.demovpcpublicsubnets[*].id, count.index)  # or
  subnet_id      = aws_subnet.demovpcpublicsubnets[count.index].id
  route_table_id = aws_route_table.demovpcpublicrt.id
}

resource "aws_eip" "nateips" {
  count = length(var.publicsubnetscidrs)

  tags = merge(var.commontags, {
    "Name" = "Elastic-IP-${count.index + 1}"
  })
}

resource "aws_nat_gateway" "demovpcnatgateways" {
  count         = length(var.publicsubnetscidrs)
  allocation_id = aws_eip.nateips[count.index].id
  subnet_id     = aws_subnet.demovpcpublicsubnets[count.index].id
  depends_on    = [aws_internet_gateway.demovpcigw]

  tags = merge(var.commontags, {
    "Name" = "demovpc-NAT-${count.index + 1}"
  })
}

resource "aws_route_table" "demovpcprivaterts" {
  vpc_id = aws_vpc.demovpc.id
  count  = length(var.privatesubnetscidrs)

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.demovpcnatgateways[count.index].id
  }

  tags = merge(var.commontags, {
    "Name" = "demovpc-privatert-${count.index + 1}"
  })
}

resource "aws_route_table_association" "demovpcnatrtassociation" {
  count          = length(var.privatesubnetscidrs)
  subnet_id      = aws_subnet.demovpcprivatesubnets[count.index].id
  route_table_id = aws_route_table.demovpcprivaterts[count.index].id
}

resource "aws_security_group" "sg" {
    name = var.security_group_name
    vpc_id =  aws_vpc.demovpc.id
    description = var.security_group_description

    dynamic "ingress" {
      for_each = var.security_group_inbound_rules
      content {
        from_port = ingress.value.from_port
        to_port = ingress.value.to_port
        protocol = ingress.value.protocol
        cidr_blocks = ingress.value.cidr_blocks
        description = ingress.value.description
      }
    }

    egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = var.sg_tags
}
variable "vpc_id" {}

data "aws_vpc" "selected" {
  id = var.vpc_id
}
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "subnet" {
  count             = 2
  availability_zone = data.aws_availability_zones.available.names[count.index]
  #cidr_block = cidrsubnet(data.aws_vpc.selected.cidr_block, 8, count.index)
  #cidr_block = cidrsubnet(data.aws_vpc.selected.cidr_block, 4, 10)
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = data.aws_vpc.selected.id
  tags = map(
    "Name", "terraform-eks-demo-node",
    "kubernetes.io/cluster/${var.cluster_name}", "shared",
  )

}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = data.aws_vpc.selected.id

  tags = {
    Name = "terraform-eks-demo"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = data.aws_vpc.selected.id

#  route {
#    cidr_block = "0.0.0.0/0"
#    gateway_id = aws_internet_gateway.internet_gateway.id
#  }
}

resource "aws_route_table_association" "demo" {
  count = 2

#  subnet_id      = aws_subnet.subnet[count.index].id
  subnet_id      = aws_subnet.subnet.*.id[count.index]
  route_table_id = aws_route_table.route_table.id
}

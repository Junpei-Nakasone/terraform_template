provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    "Name" = "terraform-sandbox"
  }
}

resource "aws_subnet" "public_1a" {
  vpc_id = "${aws_vpc.main.id}"

  availability_zone = "ap-northeast-1a"

  cidr_block = "10.0.1.0/24"

  tags = {
    "Name" = "sandbox-public-1a"
  }
}

resource "aws_subnet" "private_1a" {
  vpc_id = "${aws_vpc.main.id}"

  availability_zone = "ap-northeast-1a"

  cidr_block = "10.0.2.0/24"

  tags = {
    "Name" = "sandbox-private-1a"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    "Name" = "sandbox-igw"
  }
}

resource "aws_eip" "nat_1a" {
  vpc = true
  tags = {
    "Name" = "sandbox-natgw-1a"
  }
}

resource "aws_nat_gateway" "nat_1a" {
  subnet_id = "${aws_subnet.public_1a.id}"
  allocation_id = "${aws_eip.nat_1a.id}"
  tags = {
    "Name" = "sandbox-1a"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"
  tags = {
    "Name" = "sandbox-public"
  }
}

resource "aws_route" "public" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id = "${aws_route_table.public.id}"
  gateway_id = "${aws_internet_gateway.main.id}"
}

resource "aws_route_table_association" "public_1a" {
  subnet_id = "${aws_subnet.public_1a.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table" "private_1a" {
  vpc_id = "${aws_vpc.main.id}"
  tags = {
    "Name" = "sandbox-private-1a"
  }
}

resource "aws_route" "private_1a" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id = "${aws_route_table.private_1a.id}"
  nat_gateway_id = "${aws_nat_gateway.nat_1a.id}"
}

resource "aws_route_table_association" "private_1a" {
  subnet_id = "${aws_subnet.private_1a.id}"
  route_table_id = "${aws_route_table.private_1a.id}"
}

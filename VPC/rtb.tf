resource "aws_route_table" "wsi-public-rt" {
  vpc_id = aws_vpc.wsi-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wsi-igw.id
  }

  tags = {
    Name = "wsi-public-rt"
  }
}

resource "aws_route_table" "wsi-private-a-rt" {
  vpc_id = aws_vpc.wsi-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.wsi-natgw-a.id
  }

  tags = {
    Name = "wsi-private-a-rt"
  }
}

resource "aws_route_table" "wsi-private-b-rt" {
  vpc_id = aws_vpc.wsi-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.wsi-natgw-b.id
  }

  tags = {
    Name = "wsi-private-b-rt"
  }
}

resource "aws_route_table" "wsi-data-rt" {
  vpc_id = aws_vpc.wsi-vpc.id
  tags = {
    Name = "wsi-data-rt"
  }
}

resource "aws_route_table_association" "wsi-public-rt-association-a" {
  subnet_id      = aws_subnet.wsi-public-a.id
  route_table_id = aws_route_table.wsi-public-rt.id
}

resource "aws_route_table_association" "wsi-public-rt-association-b" {
  subnet_id      = aws_subnet.wsi-public-b.id
  route_table_id = aws_route_table.wsi-public-rt.id
}

resource "aws_route_table_association" "wsi-private-a-rt-association" {
  subnet_id      = aws_subnet.wsi-private-a.id
  route_table_id = aws_route_table.wsi-private-a-rt.id
}

resource "aws_route_table_association" "wsi-private-b-rt-association" {
  subnet_id      = aws_subnet.wsi-private-b.id
  route_table_id = aws_route_table.wsi-private-b-rt.id
}

resource "aws_route_table_association" "wsi-private-protected-a" {
  subnet_id      = aws_subnet.wsi-private-protected-a.id
  route_table_id = aws_route_table.wsi-data-rt.id
}

resource "aws_route_table_association" "wsi-private-protected-b" {
  subnet_id      = aws_subnet.wsi-private-protected-b.id
  route_table_id = aws_route_table.wsi-data-rt.id
}
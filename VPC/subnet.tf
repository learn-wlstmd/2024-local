resource "aws_subnet" "wsi-public-a" {
  vpc_id = aws_vpc.wsi-vpc.id
  cidr_block = "10.1.2.0/24"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "wsi-public-a"
  }
}

resource "aws_subnet" "wsi-public-b" {
  vpc_id = aws_vpc.wsi-vpc.id
  cidr_block = "10.1.3.0/24"
  availability_zone = "ap-northeast-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "wsi-public-b"
  }
}

resource "aws_subnet" "wsi-private-a" {
  vpc_id = aws_vpc.wsi-vpc.id
  cidr_block = "10.1.0.0/24"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "wsi-private-a"
  }
}

resource "aws_subnet" "wsi-private-b" {
  vpc_id = aws_vpc.wsi-vpc.id
  cidr_block = "10.1.1.0/24"
  availability_zone = "ap-northeast-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "wsi-private-b"
  }
}

resource "aws_subnet" "wsi-private-protected-a" {
  vpc_id            = aws_vpc.wsi-vpc.id
  cidr_block        = "10.1.4.0/24"
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "wsi-private-protected-a"
  }
}

resource "aws_subnet" "wsi-private-protected-b" {
  vpc_id            = aws_vpc.wsi-vpc.id
  cidr_block        = "10.1.5.0/24"
  availability_zone = "ap-northeast-2b"
  tags = {
    Name = "wsi-private-protected-b"
  }
}
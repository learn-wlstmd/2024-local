resource "aws_internet_gateway" "wsi-igw" {
  vpc_id = aws_vpc.wsi-vpc.id

  tags = {
    Name = "wsi-igw"
  }
}
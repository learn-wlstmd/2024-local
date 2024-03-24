resource "aws_nat_gateway" "wsi-natgw-a" {
  allocation_id = aws_eip.wsi-nat-eip.id
  subnet_id = aws_subnet.wsi-public-a.id
  
  tags = {
    Name = "wsi-natgw-a"
  }
}

resource "aws_nat_gateway" "wsi-natgw-b" {
  allocation_id = aws_eip.wsi-nat-eip2.id
  subnet_id = aws_subnet.wsi-public-b.id
  
  tags = {
    Name = "wsi-natgw-b"
  }
}
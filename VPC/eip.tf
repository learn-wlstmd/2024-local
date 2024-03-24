resource "aws_eip" "wsi-nat-eip" {
  domain = "vpc"
  tags = {
    Name = "-"
  }
}

resource "aws_eip" "wsi-nat-eip2" {
  domain = "vpc"
  tags = {
    Name = "-"
  }
}
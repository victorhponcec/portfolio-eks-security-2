#SG DB 
resource "aws_security_group" "db" {
  name        = "db-sg"
  description = "allow db access from EKS private subnets"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow MySQL from EKS private subnets"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [
      aws_subnet.private_a_az1.cidr_block,
      aws_subnet.private_b_az2.cidr_block
    ]
  }
}
#creating vpc
resource "aws_vpc" "set5-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "set5-vpc"
  }
}

#creating subnet
resource "aws_subnet" "set5-subnet" {
  vpc_id     = aws_vpc.set5-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "set5-subnet"
  }
}

#creating internet gateway
resource "aws_internet_gateway" "set5-igw" {
  vpc_id = aws_vpc.set5-vpc.id

  tags = {
    Name = "set5-igw"
  }
}

#Creating route table
resource "aws_route_table" "set5-route-table" {
  vpc_id = aws_vpc.set5-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.set5-igw.id
  }
}

#Creating route table association
resource "aws_route_table_association" "set5-route-table-association" {
  subnet_id      = aws_subnet.set5-subnet.id
  route_table_id = aws_route_table.set5-route-table.id
}

#creating security group
resource "aws_security_group" "set5-sg" {
  name        = "set5-sg"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = aws_vpc.set5-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#creating tls key pair
resource "tls_private_key" "set5-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

#creating local file for private key
resource "local_file" "set5-private-key" {
  content         = tls_private_key.set5-key.private_key_pem
  filename        = "./set5-key.pem"
  file_permission = "400"
}

#creating public key
resource "aws_key_pair" "set5-key-pair" {
  key_name   = "set5-key-pair"
  public_key = tls_private_key.set5-key.public_key_openssh
}

#creating EC2 instance
resource "aws_instance" "set5-instance" {
  ami                         = "ami-0884bba1ac5619645" # Redhat AMI (HVM), SSD Volume Type
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.set5-subnet.id
  key_name                    = aws_key_pair.set5-key-pair.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.set5-sg.id]
  user_data                   = file("./user_data.sh")
  tags = {
    Name = "set5-instance"
  }
}


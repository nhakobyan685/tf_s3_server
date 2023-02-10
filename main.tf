#----------------------------------

# Make s3 bucket  aws save tfstate 

#----------------------------------


# terraform {
#   backend "s3" {
#     bucket = "nhakobyan685"
#     key    = "dev/terraform.tfstate"
#     region = "us-east-1"
#   }
# }


#-------------------------------------

# Make vpc, subnet, ni, sg

#-------------------------------------


resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_network_interface" "main" {
  subnet_id   = aws_subnet.my_subnet.id
  private_ips = ["10.0.10.100"]


  attachment {
    instance     = aws_instance.webserver.id
    device_index = 1
  }
  tags = {
    Name = "primary_network_interface"
  }
  depends_on = [aws_instance.webserver]
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "TLS from VPC"
    from_port   = 08
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}


#-----------------------

# Make internet gateway

#-----------------------

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}


#--------------------------

# Make rt and rt assosetion

#--------------------------


resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/24"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "example"
  }
}


resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.rt.id
}


#-------------------

# Make EC2 instance

#-------------------


resource "aws_instance" "webserver" {
  ami                    = data.aws_ami.ubuntu.id #Ubuntu 20.04
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  subnet_id              = aws_subnet.my_subnet.id
  tags = {
    Name = "${var.instance_name}"
  }
}

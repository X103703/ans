provider "aws" {

    region = "us-east-1"

   // access_key = var.cg_acces_key

    // secret_key = var.cg_secret_key

}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "171.31.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["171.31.6.0/24", "171.31.4.0/24","171.31.5.0/24"]
  public_subnets  = ["171.31.1.0/24", "171.31.2.0/24","171.31.3.0/24"]
  enable_dns_hostnames = true
  enable_dns_support = true
  enable_nat_gateway = true
  //enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
     Name = "test_vpc"
  }
}
/*
resource "aws_vpc" "myvpc" {
  cidr_block = "171.31.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true


  tags = {
    "Name" = "test_vpc"
  }




}

#Declaration du subnet front
resource "aws_subnet" "front"{
   availability_zone = "us-east-1a"

   cidr_block = "171.31.1.0/24"
   vpc_id = aws_vpc.myvpc.id
   tags = {
     "Name" = "subnet-front"
   }

}
/*
#Declaration du subnet privée dans l'AZ 1a
resource "aws_subnet" "back1a"{

   availability_zone = "us-east-1a"
   cidr_block = "171.31.2.0/24"
   vpc_id = aws_vpc.myvpc.id
   map_public_ip_on_launch = true
   tags = {
     "Name" = "subnet-back-1a"
   }


}

resource "aws_subnet" "back1b"{
   availability_zone = "us-east-1b"
   cidr_block = "171.31.3.0/24"
   vpc_id = aws_vpc.myvpc.id
   map_public_ip_on_launch = true
   tags = {
     "Name" = "subnet-back-1b"
   }


}

#declaration de la gateway internet dans le VPC
resource "aws_internet_gateway" "igw"{

vpc_id = aws_vpc.myvpc.id
 tags = {
     "Name" = "igw-test"
   }
}

#Table de routage internet
resource "aws_route_table" "internet_route" {
  vpc_id = aws_vpc.myvpc.id
  route  {

    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id

  }

}

#Association de la table de routage internet avec le subnet front
resource "aws_route_table_association" "igw_ass"{
     route_table_id = aws_route_table.internet_route.id
     subnet_id = aws_subnet.front.id
}

resource "aws_route_table_association" "igw_ass_bck1"{
     route_table_id = aws_route_table.internet_route.id
     subnet_id = aws_subnet.back1a.id
}
resource "aws_route_table_association" "igw_ass_bck2"{
     route_table_id = aws_route_table.internet_route.id
     subnet_id = aws_subnet.back1b.id
}

/*
resource "aws_key_pair" "mykey" {
  key_name   = "mykey"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCN5rI5gPkV4mMZBC/9tIDyzMly4SzYyLwJw/Spea87YcBeE2XvN6+z0T/knl+uyyQr9SsytSYlL7atnfzl5FhP2bRjCOiOpMYhGCvRStO9wcEwXJFeoz2dsRlCRaEbW+mI8WbGhNRJZvjC2fKivO/k/suDP/zSVp0sZiD2JBATzZQdQi95zgFwDfh2Lz68LXMGPHhffBE4/T2OGF+4zm5JC"
}*/

/*
resource "aws_instance" "bastion" {
  associate_public_ip_address = true
  instance_type = "t2.micro"
  //key_name = "mykey"
  subnet_id = aws_subnet.front.id
  ami = "ami-0b5eea76982371e91"
  tags  = {
     "Name" = "bastion"
   }

}*/

/*
resource "aws_instance" "backend" {
  associate_public_ip_address = false
  instance_type = "t2.micro"
  key_name = "last"
  subnet_id = aws_subnet.back.id
  ami = "ami-0b5eea76982371e91"
  tags  = {
     "Name" = "backend"
   }

*/


resource "aws_vpc_endpoint" "secmgr" {

  private_dns_enabled = true
  subnet_ids = module.vpc.private_subnets

  vpc_endpoint_type = "Interface"
  service_name = "com.amazonaws.us-east-1.secretsmanager"
 #vpc_id = aws_vpc.myvpc.id
  vpc_id = module.vpc.vpc_id
 #vpc_id = aws_default_vpc.defaultvpc.id
  tags  = {
     "Name" = "secmgr-endpoint"
   }
}

resource "aws_vpc_endpoint" "ebs" {

  private_dns_enabled = true
  subnet_ids = module.vpc.private_subnets

  vpc_endpoint_type = "Interface"
  service_name = "com.amazonaws.us-east-1.ebs"
 #vpc_id = aws_vpc.myvpc.id
 vpc_id = module.vpc.vpc_id
 #vpc_id = aws_default_vpc.defaultvpc.id
  tags  = {
     "Name" = "ebs-endpoint"
   }
}

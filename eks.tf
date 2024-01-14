resource "aws_security_group" "eks_sg" {

  name = "eks_sg_in"
  ingress   {
    cidr_blocks = [ "0.0.0.0/0" ]

    from_port = 0
    ipv6_cidr_blocks = [ "::/0" ]
    protocol = "-1"
    to_port = 0
  }

  egress   {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    ipv6_cidr_blocks = [ "::/0" ]
    protocol = "-1"
    to_port = 0
  }

   tags = {
    Name = "eks-sg"
  }

  vpc_id = module.vpc.vpc_id
}



resource "aws_eks_cluster" "test"{
  name = "test"
  version = 1.24
  vpc_config {


    public_access_cidrs = [ "0.0.0.0/0" ]
    endpoint_public_access = true
    endpoint_private_access = true

    subnet_ids = module.vpc.private_subnets
   # subnet_ids = ["subnet-01448519058ff0b41", "subnet-09159d4fbc2342c72", "subnet-06ec8b38bfb69ac39" ]
   # security_group_ids = [aws_security_group.eks_sg.id]


  }

  role_arn = "arn:aws:iam::${var.cg_account}:role/Myeksclusterrole"

}

  output "identity_oidc_issuer" {
  value = replace(aws_eks_cluster.test.identity[0].oidc[0].issuer,"https://","")
}






output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.test.certificate_authority[0].data
}

###################################
#  Node group creation            #
###################################


resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.test.name

  node_group_name = "nodegroup"
  node_role_arn   = "arn:aws:iam::${var.cg_account}:role/Mynodegrouprole"
  subnet_ids      = module.vpc.private_subnets

#  subnet_ids = ["subnet-01448519058ff0b41", "subnet-09159d4fbc2342c72", "subnet-06ec8b38bfb69ac39" ]
  #instance_types = "t3.medium"
  scaling_config {
    desired_size = 3
    max_size     = 5
    min_size     = 1

  }




  update_config {
    max_unavailable = 1
  }

}

 output "subnet_ids" {
  value = aws_eks_node_group.node_group.subnet_ids
}



/*
resource "aws_secretsmanager_secret" "example" {
  name = "toto"

}

resource "aws_secretsmanager_secret_version" "sversion" {
  secret_id = aws_secretsmanager_secret.example.id
  secret_string = <<EOF
   {
    "secret": ${replace(aws_eks_cluster.test.identity[0].oidc[0].issuer,"https://","")},
   }
EOF
}

*/

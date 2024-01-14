/*============================================================================================#
*
*                                       EKS
*
*
*==============================================================================================*/
resource "aws_iam_role" "cluster_role" {
  name = "Myeksclusterrole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "myeksclusterrole"
  }
}

resource "aws_iam_role_policy_attachment" "attach-clusterrole" {
  role       = aws_iam_role.cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


resource "aws_iam_role" "nodegroup_role" {
  name = "Mynodegrouprole"


  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "myeksclusterrole"
  }

}

resource "aws_iam_role_policy_attachment" "attach-workernodepolicy" {
  role       = aws_iam_role.nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}
resource "aws_iam_role_policy_attachment" "attach-workercnipolicy" {
  role       = aws_iam_role.nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
resource "aws_iam_role_policy_attachment" "attach-workerregistrypolicy" {
  role       = aws_iam_role.nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"

}

/*============================================================================================#
*
*                                       EBS
*
*
*==============================================================================================*/

resource "aws_iam_policy" "policy_ebs" {
  name        = "AmazonEKS_EBS_CSI_Driver_Policy"
  description = "EKS_EBS_CSI_Driver_Policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect": "Allow",
      "Action": [
        "ec2:AttachVolume",
        "ec2:CreateSnapshot",
        "ec2:CreateTags",
        "ec2:CreateVolume",
        "ec2:DeleteSnapshot",
        "ec2:DeleteTags",
        "ec2:DeleteVolume",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeInstances",
        "ec2:DescribeSnapshots",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes",
        "ec2:DescribeVolumesModifications",
        "ec2:DetachVolume",
        "ec2:ModifyVolume"
      ],
      "Resource": "*"
      }
    ]
  })
}

resource "aws_iam_role" "ebs_role" {

  name = "EBSRole_For_CSI"


  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${var.cg_account}:oidc-provider/${replace(aws_eks_cluster.test.identity[0].oidc[0].issuer,"https://","")}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${replace(aws_eks_cluster.test.identity[0].oidc[0].issuer,"https://","")}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }
  ]
})

  tags = {
    tag-key = "EBSRole_For_CSI"
  }
depends_on = [
  aws_eks_cluster.test
]
}

resource "aws_iam_role_policy_attachment" "attach-ebs_policy" {
  role       = aws_iam_role.ebs_role.name
  policy_arn = "arn:aws:iam::${var.cg_account}:policy/AmazonEKS_EBS_CSI_Driver_Policy"

}

/*============================================================================================#
*
*                                       SECRET MANAGER
*
*
*==============================================================================================*/
resource "aws_iam_policy" "policy_secret" {
  name        = "Secret_Policy"
  description = "Secret_Policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource": "arn:aws:secretsmanager:${var.cg_region}:${var.cg_account}:secret:*"
      }
    ]
  })
}

resource "aws_iam_role" "secret_role" {

  name = "SecretRole"


  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${var.cg_account}:oidc-provider/${replace(aws_eks_cluster.test.identity[0].oidc[0].issuer,"https://","")}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${replace(aws_eks_cluster.test.identity[0].oidc[0].issuer,"https://","")}:aud": "sts.amazonaws.com",
          "${replace(aws_eks_cluster.test.identity[0].oidc[0].issuer,"https://","")}:sub": "system:serviceaccount:kube-system:test-sa"
        }
      }
    }
  ]
})

  tags = {
    tag-key = "SecretRole"
  }
depends_on = [
  aws_eks_cluster.test
]
}

resource "aws_iam_role_policy_attachment" "attach-secret_policy" {
  role       = aws_iam_role.secret_role.name
  policy_arn = "arn:aws:iam::${var.cg_account}:policy/Secret_Policy"

}

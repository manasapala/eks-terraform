resource "aws_iam_role" "vgd-cluster-iam" {
  name = "terraform-eks-vgd-cluster-iam"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "vgd-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.vgd-cluster-iam.name
}
resource "aws_iam_role_policy_attachment" "vgd-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.vgd-cluster-iam.name
}



resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.vgd-cluster-iam.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.vgd-cluster-iam.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.vgd-cluster-iam.name
}



resource "aws_security_group" "vgd-cluster-sg" {
  name        = "terraform-eks-vgd-cluster-sg"
  description = "Security group for communication with worker nodes"
  vpc_id      = data.aws_vpc.selected.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  #  cidr_blocks = ["10.0.1.0/24","10.0.2.0/24"] # recent change
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-eks-vgd-sg"
  }
}

resource "aws_security_group_rule" "vgd-cluster-ingress-workstation-https" {
  #cidr_blocks       = cidrsubnets(data.aws_vpc.selected.cidr_block, 4, 1)
  count = 2
  cidr_blocks       = ["10.0.${count.index}.0/24"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.vgd-cluster-sg.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_eks_cluster" "vgd-cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.vgd-cluster-iam.arn
  enabled_cluster_log_types = ["api", "audit"]
  vpc_config {
    security_group_ids = [aws_security_group.vgd-cluster-sg.id]
    subnet_ids         = aws_subnet.subnet[*].id
    endpoint_private_access = true
    endpoint_public_access = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.vgd-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.vgd-cluster-AmazonEKSServicePolicy
  ]
}


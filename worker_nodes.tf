resource "aws_iam_role" "vgd-node" {
  name = "terraform-eks-vgd-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}
resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = aws_iam_role.vgd-node.name
}
resource "aws_iam_role_policy_attachment" "vgd-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.vgd-node.name
}

resource "aws_iam_role_policy_attachment" "vgd-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.vgd-node.name
}

resource "aws_iam_role_policy_attachment" "vgd-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.vgd-node.name
}

resource "aws_security_group" "vgd-node-sg" {
  name        = "terraform-eks-vgd-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = data.aws_vpc.selected.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"                                      = "terraform-eks-demo-node"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_security_group_rule" "vgd-node-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.vgd-node-sg.id
  source_security_group_id = aws_security_group.vgd-node-sg.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "vgd-node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.vgd-node-sg.id
  source_security_group_id = aws_security_group.vgd-cluster-sg.id
  to_port                  = 65535
  type                     = "ingress"
 }

resource "aws_security_group_rule" "vgd-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.vgd-cluster-sg.id
  source_security_group_id = aws_security_group.vgd-node-sg.id
  to_port                  = 443
  type                     = "ingress"
}
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/eZnJdbS6DRYDl7Q0P9QhNlLju+77wFEq7Nvxc/kutQWItMmXLWqpjMGIojl25QWX3abfmXd05JnkSlVMZZDz0Jg236Ricx5JxE+8xnizMSOciboJqTOPuUV9Gfsi/hmyMuQllc2K4x44r/VeQwn8oJDfy0DySQv/F2ps1cUBTkAiJhiOJDT8038E/+P+mF1iGnyaPHYpVFrjiFwJxHlzgq0SZYMemDq93QWKBFz7RJYvXhdeO+yKjFu8MLQyqj7pNoXOt1Td2DOyf3MjvHK7a1ptLdsrDtQRJJ1mhf9ieCT+0MzNhUy0rHFFrH77QzP6jhcqMNbVLZ18z6f+p70n manasa.pala@Manasas-MBP.hsd1.ca.comcast.net"
}





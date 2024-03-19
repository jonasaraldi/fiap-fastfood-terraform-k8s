resource "aws_iam_role" "cluster-role" {
  name               = "${var.app}-cluster-role"
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
  tags = {
    org       = var.org
    app       = var.app
    env       = var.env
    terraform = true
  }
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSVPCResourceController" {
  role       = aws_iam_role.cluster-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSClusterPolicy" {
  role       = aws_iam_role.cluster-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_cloudwatch_log_group" "cluster-log" {
  name              = "/aws/eks/${var.prefix}-${var.app}/cluster"
  retention_in_days = var.retention_in_days
}

resource "aws_security_group" "cluster-sg" {
  vpc_id = var.vpc_id
  depends_on = [
    aws_cloudwatch_log_group.cluster-log,
    aws_iam_role_policy_attachment.cluster-AmazonEKSVPCResourceController,
    aws_iam_role_policy_attachment.cluster-AmazonEKSClusterPolicy
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.prefix}-sg"
    org       = var.org
    app       = var.app
    env       = var.env
    terraform = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "cluster-sg-ingress-rule" {
  security_group_id = aws_security_group.cluster-sg.id
  cidr_ipv4         = var.vpc_cidr_block
  from_port         = 0
  ip_protocol       = "TCP"
  to_port           = 0
}

resource "aws_eks_cluster" "cluster-eks" {
  name                      = var.cluster_name
  role_arn                  = aws_iam_role.cluster-role.arn
  enabled_cluster_log_types = ["api", "audit"]
  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.cluster-sg.id]
  }
  depends_on = [
    aws_cloudwatch_log_group.cluster-log,
    aws_iam_role_policy_attachment.cluster-AmazonEKSVPCResourceController,
    aws_iam_role_policy_attachment.cluster-AmazonEKSClusterPolicy
  ]
  tags = {
    org       = var.org
    app       = var.app
    env       = var.env
    terraform = true
  }
}

resource "aws_iam_role" "node-role" {
  name               = "${var.app}-role-node"
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
  tags = {
    org       = var.org
    app       = var.app
    env       = var.env
    terraform = true
  }
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node-role.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node-role.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node-role.name
}

resource "aws_eks_node_group" "cluster-node" {
  cluster_name    = aws_eks_cluster.cluster-eks.name
  node_group_name = "${var.app}-nodes"
  node_role_arn   = aws_iam_role.node-role.arn
  subnet_ids      = var.subnet_ids
  instance_types  = [var.instance_type]
  capacity_type   = "ON_DEMAND"

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }
  depends_on = [
    aws_iam_role_policy_attachment.node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node-AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.node-AmazonEKS_CNI_Policy
  ]
  tags = {
    org       = var.org
    app       = var.app
    env       = var.env
    terraform = true
  }
}

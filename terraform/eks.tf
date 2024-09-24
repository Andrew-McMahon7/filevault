resource "aws_iam_role" "cluster-role" {
  name = "eks-cluster-cluster-role-${local.environment}"

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

  depends_on = [null_resource.enforce_workspace]
}

resource "aws_iam_role_policy_attachment" "filevault-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster-role.name

  depends_on = [null_resource.enforce_workspace]
}

resource "aws_iam_role_policy_attachment" "cluster-AdministratorAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.cluster-role.name

  depends_on = [null_resource.enforce_workspace]
}

resource "aws_iam_role_policy_attachment" "cluster-CloudWatchLogsFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  role       = aws_iam_role.cluster-role.name

  depends_on = [null_resource.enforce_workspace]
}

resource "aws_eks_cluster" "filevault-eks" {
  name     = "filevault-eks-${local.environment}"
  role_arn = aws_iam_role.cluster-role.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.private-eu-west-2a.id,
      aws_subnet.private-eu-west-2b.id,
      aws_subnet.public-eu-west-2a.id,
      aws_subnet.public-eu-west-2b.id
    ]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.filevault-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster-AdministratorAccess,
    aws_iam_role_policy_attachment.cluster-CloudWatchLogsFullAccess
  ]
}

resource "aws_cloudwatch_log_group" "eks_log_group" {
  name              = "/aws/eks/cluster/filevault-eks-${local.environment}"
  retention_in_days = 7

  depends_on = [null_resource.enforce_workspace]
}
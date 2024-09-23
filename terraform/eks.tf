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

  depends_on = [
    aws_iam_role_policy_attachment.filevault-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster-AdministratorAccess
  ]
}

resource "aws_eks_addon" "cloudwatch_observability" {
  cluster_name = aws_eks_cluster.filevault-eks.name
  addon_name   = "vpc-cni"
  addon_version = "v1.18.3-eksbuild.3"

  resolve_conflicts = "OVERWRITE"

  service_account_role_arn = aws_iam_role.cloudwatch_observability_role.arn

  depends_on = [aws_eks_cluster.filevault-eks]
}
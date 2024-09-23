data "tls_certificate" "eks" {
  url = aws_eks_cluster.filevault-eks.identity[0].oidc[0].issuer

  depends_on = [null_resource.enforce_workspace]
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.filevault-eks.identity[0].oidc[0].issuer

  depends_on = [null_resource.enforce_workspace]
}

resource "aws_iam_role" "cloudwatch_agent_role" {
  name = "eks-cloudwatch-agent-role-${local.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  depends_on = [null_resource.enforce_workspace]
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.cloudwatch_agent_role.name

  depends_on = [null_resource.enforce_workspace]
}

resource "aws_iam_role" "cloudwatch_observability_role" {
  name = "eks-cloudwatch-observability-role-${local.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  depends_on = [null_resource.enforce_workspace]
}

resource "aws_iam_role_policy_attachment" "cloudwatch_observability_policy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.cloudwatch_observability_role.name

  depends_on = [null_resource.enforce_workspace]
}
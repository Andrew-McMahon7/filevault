resource "aws_ecr_repository" "woc_image_repo_alm" {
  name = "woc_image_repo_alm-${local.environment}"

  depends_on = [null_resource.enforce_workspace]
}

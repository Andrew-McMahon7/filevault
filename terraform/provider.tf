provider "aws" {
  region = "eu-west-2"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

resource "null_resource" "enforce_workspace" {
  provisioner "local-exec" {
    command = "sh ./enforce_workspace.sh"
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}
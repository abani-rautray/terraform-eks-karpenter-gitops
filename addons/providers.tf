terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
  }
}

############################################
# AWS PROVIDER
############################################
provider "aws" {
  region = var.aws_region
  profile = "devops"
}

############################################
# READ INFRA STATE (EKS MUST ALREADY EXIST)
############################################
data "terraform_remote_state" "infra" {
  backend = "local"

  config = {
    path = "../infra/terraform.tfstate"
  }
}

############################################
# KUBERNETES PROVIDER
############################################
provider "kubernetes" {
  host                   = data.terraform_remote_state.infra.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(
    data.terraform_remote_state.infra.outputs.cluster_ca_certificate
  )
  token = data.aws_eks_cluster_auth.this.token
}

############################################
# EKS AUTH TOKEN (SHORT-LIVED)
############################################
data "aws_eks_cluster_auth" "this" {
  name = data.terraform_remote_state.infra.outputs.cluster_name
}

############################################
# HELM PROVIDER
############################################
provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.infra.outputs.cluster_endpoint
    cluster_ca_certificate = base64decode(
      data.terraform_remote_state.infra.outputs.cluster_ca_certificate
    )
    token = data.aws_eks_cluster_auth.this.token
  }
}


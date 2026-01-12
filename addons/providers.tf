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
  region  = var.aws_region
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
# LOCALS FOR SAFE PROVIDER CONFIGURATION
############################################
locals {
  # Use try() to safely handle missing state/outputs
  cluster_endpoint = try(
    data.terraform_remote_state.infra.outputs.cluster_endpoint,
    ""
  )
  
  cluster_ca_certificate = try(
    base64decode(data.terraform_remote_state.infra.outputs.cluster_ca_certificate),
    ""
  )
  
  cluster_name = try(
    data.terraform_remote_state.infra.outputs.cluster_name,
    ""
  )
}

############################################
# KUBERNETES PROVIDER (USE EXEC AUTH)
############################################
provider "kubernetes" {
  host                   = local.cluster_endpoint
  cluster_ca_certificate = local.cluster_ca_certificate

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      local.cluster_name,
      "--region",
      var.aws_region,
      "--profile",
      "devops"
    ]
  }
}

############################################
# HELM PROVIDER (USE SAME EXEC AUTH)
############################################
provider "helm" {
  kubernetes {
    host                   = local.cluster_endpoint
    cluster_ca_certificate = local.cluster_ca_certificate

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        local.cluster_name,
        "--region",
        var.aws_region,
        "--profile",
        "devops"
      ]
    }
  }
}
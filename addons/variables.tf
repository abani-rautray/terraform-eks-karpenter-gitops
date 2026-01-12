############################################
# GLOBAL
############################################
variable "aws_region" {
  description = "AWS region where the EKS cluster is running"
  type        = string
}

############################################
# OPTIONAL OVERRIDES (SAFE DEFAULTS)
############################################
variable "argocd_namespace" {
  description = "Namespace for Argo CD"
  type        = string
  default     = "argocd"
}

variable "karpenter_namespace" {
  description = "Namespace for Karpenter"
  type        = string
  default     = "karpenter"
}

############################################
# EKS / KARPENTER INPUTS
############################################

# variable "cluster_name" {
#   description = "EKS cluster name"
#   type        = string
# }

# variable "cluster_endpoint" {
#   description = "EKS cluster API server endpoint"
#   type        = string
# }

# variable "karpenter_controller_role_arn" {
#   description = "IAM role ARN for Karpenter controller (IRSA)"
#   type        = string
# }

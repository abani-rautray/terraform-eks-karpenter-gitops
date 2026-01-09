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

############################################
# EKS
############################################
output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_ca_certificate" {
  description = "Base64 encoded EKS cluster CA certificate"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

############################################
# KARPENTER
############################################
output "karpenter_iam_role_arn" {
  description = "IAM role ARN used by Karpenter controller (IRSA)"
  value       = aws_iam_role.karpenter_controller.arn
}

output "karpenter_node_role_arn" {
  description = "IAM role ARN for Karpenter-managed nodes"
  value       = aws_iam_role.karpenter_node.arn
}

output "karpenter_instance_profile_name" {
  description = "Instance profile name for Karpenter-managed nodes"
  value       = aws_iam_instance_profile.karpenter.name
}

output "karpenter_interruption_queue_name" {
  description = "SQS queue name for Karpenter interruption handling"
  value       = aws_sqs_queue.karpenter.name
}

############################################
# NETWORKING (OPTIONAL, BUT USEFUL)
############################################
output "private_subnet_ids" {
  description = "Private subnet IDs for Karpenter discovery"
  value       = aws_subnet.private[*].id
}


output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}
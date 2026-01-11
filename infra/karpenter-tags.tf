############################################
# KARPENTER DISCOVERY TAGS
############################################

locals {
  karpenter_discovery_tag = var.cluster_name
}

############################################
# TAG PRIVATE SUBNETS
############################################
resource "aws_ec2_tag" "karpenter_private_subnets" {
  for_each = toset(aws_subnet.private[*].id)

  resource_id = each.value
  key         = "karpenter.sh/discovery"
  value       = var.cluster_name
}


############################################
# TAG PUBLIC SUBNETS (OPTIONAL BUT SAFE)
############################################
resource "aws_ec2_tag" "karpenter_public_subnets" {
  for_each = toset(aws_subnet.public[*].id)

  resource_id = each.value
  key         = "karpenter.sh/discovery"
  value       = local.karpenter_discovery_tag
}

############################################
# TAG NODE SECURITY GROUP
############################################
resource "aws_ec2_tag" "karpenter_node_sg" {
  resource_id = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  key         = "karpenter.sh/discovery"
  value       = local.karpenter_discovery_tag
}

resource "aws_sqs_queue" "karpenter_interruption" {
  name                      = "karpenter-interruption-${data.terraform_remote_state.infra.outputs.cluster_name}"
  message_retention_seconds = 300
}

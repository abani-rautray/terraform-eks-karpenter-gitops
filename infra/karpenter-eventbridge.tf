############################################
# EVENTBRIDGE RULES FOR INTERRUPTION HANDLING
############################################

resource "aws_cloudwatch_event_rule" "spot_interruption" {
  name        = "karpenter-spot-interruption-${var.cluster_name}"
  description = "Karpenter - Spot Instance Interruption Warning"

  event_pattern = jsonencode({
  source      = ["aws.ec2"]
  detail-type = ["EC2 Spot Instance Interruption Warning"]
  detail = {
    instance-id = [{
      exists = true
    }]
  }
})
}
resource "aws_cloudwatch_event_target" "spot_interruption" {
  rule      = aws_cloudwatch_event_rule.spot_interruption.name
  target_id = "KarpenterInterruptionQueue"
  arn       = aws_sqs_queue.karpenter.arn
}

resource "aws_cloudwatch_event_rule" "rebalance" {
  name        = "karpenter-rebalance-${var.cluster_name}"
  description = "Karpenter - EC2 Instance Rebalance Recommendation"

  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["EC2 Instance Rebalance Recommendation"]
  })
}

resource "aws_cloudwatch_event_target" "rebalance" {
  rule      = aws_cloudwatch_event_rule.rebalance.name
  target_id = "KarpenterInterruptionQueue"
  arn       = aws_sqs_queue.karpenter.arn
}

resource "aws_cloudwatch_event_rule" "instance_state_change" {
  name        = "karpenter-instance-state-change-${var.cluster_name}"
  description = "Karpenter - EC2 Instance State-change Notification"

  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["EC2 Instance State-change Notification"]
  })
}

resource "aws_cloudwatch_event_target" "instance_state_change" {
  rule      = aws_cloudwatch_event_rule.instance_state_change.name
  target_id = "KarpenterInterruptionQueue"
  arn       = aws_sqs_queue.karpenter.arn
}

resource "aws_cloudwatch_event_rule" "scheduled_change" {
  name        = "karpenter-scheduled-change-${var.cluster_name}"
  description = "Karpenter - AWS Health Event"

  event_pattern = jsonencode({
    source      = ["aws.health"]
    detail-type = ["AWS Health Event"]
  })
}

resource "aws_cloudwatch_event_target" "scheduled_change" {
  rule      = aws_cloudwatch_event_rule.scheduled_change.name
  target_id = "KarpenterInterruptionQueue"
  arn       = aws_sqs_queue.karpenter.arn
}

############################################
# SQS QUEUE POLICY (ALLOW EVENTBRIDGE)
############################################

resource "aws_sqs_queue_policy" "karpenter_events" {
  queue_url = aws_sqs_queue.karpenter.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowEventBridgeToSendMessages"
      Effect    = "Allow"
      Principal = { Service = "events.amazonaws.com" }
      Action    = "sqs:SendMessage"
      Resource  = aws_sqs_queue.karpenter.arn
    }]
  })
}
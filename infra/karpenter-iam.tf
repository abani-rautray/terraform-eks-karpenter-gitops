############################################
# GET CURRENT AWS ACCOUNT ID
############################################
data "aws_caller_identity" "current" {}

############################################
# KARPENTER CONTROLLER IAM ROLE (IRSA)
############################################

resource "aws_iam_role" "karpenter_controller" {
  name = "${var.cluster_name}-karpenter-controller"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.this.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
  StringEquals = {
    "${replace(
      aws_iam_openid_connect_provider.this.url,
      "https://",
      ""
    )}:aud" = "sts.amazonaws.com"

    "${replace(
      aws_iam_openid_connect_provider.this.url,
      "https://",
      ""
    )}:sub" = "system:serviceaccount:kube-system:karpenter"
        }
    }

    }]
  })
}

############################################
# KARPENTER CONTROLLER POLICY (FIXED)
############################################

data "aws_iam_policy_document" "karpenter_policy" {

  ############################################
  # SQS INTERRUPTION QUEUE
  ############################################
  statement {
    sid    = "AllowKarpenterInterruptionQueueRead"
    effect = "Allow"
    actions = [
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage"
    ]
    resources = [aws_sqs_queue.karpenter.arn]
  }

  ############################################
  # EC2 INSTANCE & FLEET CREATION
  ############################################
  statement {
    sid = "AllowEC2RunAndFleet"
    actions = [
      "ec2:RunInstances",
      "ec2:CreateFleet"
    ]
    resources = ["*"]
  }

  ############################################
  # REQUIRED: LAUNCH TEMPLATE PERMISSIONS
  ############################################
  statement {
    sid = "AllowLaunchTemplateManagement"
    actions = [
      "ec2:CreateLaunchTemplate",
      "ec2:CreateLaunchTemplateVersion",
      "ec2:DeleteLaunchTemplate",
      "ec2:DeleteLaunchTemplateVersions",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:ModifyLaunchTemplate"
    ]
    resources = ["*"]
  }

  ############################################
  # EC2 TAGGING (REQUIRED)
  ############################################
  statement {
    sid = "AllowEC2Tagging"
    actions = ["ec2:CreateTags"]
    resources = [
      "arn:aws:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:instance/*",
      "arn:aws:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:volume/*",
      "arn:aws:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:network-interface/*",
      "arn:aws:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:launch-template/*"
    ]
  }

  ############################################
  # EC2 TERMINATION
  ############################################
  statement {
    sid = "AllowEC2Termination"
    actions = ["ec2:TerminateInstances"]
    resources = ["*"]
  }

  ############################################
  # EC2 READ-ONLY (REGIONAL)
  ############################################
  statement {
    sid = "AllowEC2Read"
    actions = [
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeImages",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeInstanceTypeOfferings",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSpotPriceHistory",
      "ec2:DescribeSubnets"
    ]
    resources = ["*"]
  }

  ############################################
  # PRICING + SSM
  ############################################
  statement {
    sid       = "AllowPricing"
    actions   = ["pricing:GetProducts"]
    resources = ["*"]
  }

  statement {
    sid     = "AllowSSM"
    actions = ["ssm:GetParameter"]
    resources = [
      "arn:aws:ssm:${var.aws_region}::parameter/aws/service/*"
    ]
  }

  ############################################
  # PASS NODE ROLE (CRITICAL)
  ############################################
  statement {
    sid = "AllowPassNodeRole"
    actions = ["iam:PassRole"]
    resources = [
      aws_iam_role.karpenter_node.arn
    ]
  }

  ############################################
  # INSTANCE PROFILE MANAGEMENT
  ############################################
  statement {
    sid = "AllowInstanceProfileManagement"
    actions = [
      "iam:CreateInstanceProfile",
      "iam:DeleteInstanceProfile",
      "iam:AddRoleToInstanceProfile",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:GetInstanceProfile",
      "iam:TagInstanceProfile"
    ]
    resources = ["*"]
  }

  ############################################
  # EKS CLUSTER DISCOVERY
  ############################################
  statement {
    sid = "AllowEKSDescribe"
    actions = ["eks:DescribeCluster"]
    resources = [
      "arn:aws:eks:${var.aws_region}:${data.aws_caller_identity.current.account_id}:cluster/${var.cluster_name}"
    ]
  }
}

############################################
# ATTACH POLICY TO CONTROLLER ROLE
############################################

resource "aws_iam_policy" "karpenter" {
  name   = "karpenter-policy-${var.cluster_name}"
  policy = data.aws_iam_policy_document.karpenter_policy.json
}

resource "aws_iam_role_policy_attachment" "karpenter_attach" {
  role       = aws_iam_role.karpenter_controller.name
  policy_arn = aws_iam_policy.karpenter.arn
}

############################################
# KARPENTER NODE ROLE (EC2)
############################################

resource "aws_iam_role" "karpenter_node" {
  name = "karpenter-node-${var.cluster_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "karpenter_node_worker" {
  role       = aws_iam_role.karpenter_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "karpenter_node_cni" {
  role       = aws_iam_role.karpenter_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "karpenter_node_ecr" {
  role       = aws_iam_role.karpenter_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "karpenter_node_ssm" {
  role       = aws_iam_role.karpenter_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

############################################
# INSTANCE PROFILE
############################################

resource "aws_iam_instance_profile" "karpenter" {
  name = "karpenter-node-${var.cluster_name}"
  role = aws_iam_role.karpenter_node.name
}

############################################
# SQS QUEUE FOR INTERRUPTION HANDLING
############################################

resource "aws_sqs_queue" "karpenter" {
  name                      = "karpenter-${var.cluster_name}"
  message_retention_seconds = 300
  sqs_managed_sse_enabled   = true
}


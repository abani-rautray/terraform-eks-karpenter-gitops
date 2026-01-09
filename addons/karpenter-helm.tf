############################################
# KARPENTER HELM RELEASE (CRDs + Controller)
############################################
resource "helm_release" "karpenter" {
  name       = "karpenter"
  namespace  = "karpenter"

  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "0.37.7"

  create_namespace = true
  skip_crds = false   # <-- let Helm install CRDs
  wait      = true
  timeout   = 900     # CRDs + webhooks need time

  ##########################################
  # SERVICE ACCOUNT (IRSA)
  ##########################################
  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "karpenter"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.karpenter_controller_role_arn
  }

  ##########################################
  # REQUIRED ENV VARS (0.37.x)
  ##########################################
  set {
    name  = "controller.env[0].name"
    value = "CLUSTER_NAME"
  }

  set {
    name  = "controller.env[0].value"
    value = var.cluster_name
  }

  set {
    name  = "controller.env[1].name"
    value = "CLUSTER_ENDPOINT"
  }

  set {
    name  = "controller.env[1].value"
    value = var.cluster_endpoint
  }

  ##########################################
  # OPTIONAL BUT SAFE DEFAULTS
  ##########################################
  
  set {
    name  = "logLevel"
    value = "info"
  }

  set {
  name  = "settings.aws.interruptionQueue"
  value = aws_sqs_queue.karpenter_interruption.name
}


  ##########################################
  # ORDERING
  ##########################################
  depends_on = [
    
    aws_sqs_queue.karpenter_interruption,
    helm_release.argocd
  ]
}

  
# echo "kubectl get pods -n karpenter"
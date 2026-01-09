############################################
# KARPENTER HELM RELEASE
# (Karpenter v0.16.3 - with proper env vars)
############################################
resource "helm_release" "karpenter" {
  name             = "karpenter"
  namespace        = var.karpenter_namespace
  chart            = "karpenter"
  repository       = "https://charts.karpenter.sh"
  version          = "0.16.3"
  create_namespace = true
  
  skip_crds        = false
  wait             = false
  timeout          = 300
  
  dependency_update = true

  ##########################################
  # CLUSTER SETTINGS (AS ENV VARS)
  ##########################################
  set {
    name  = "controller.env[0].name"
    value = "CLUSTER_NAME"
  }

  set {
    name  = "controller.env[0].value"
    value = data.terraform_remote_state.infra.outputs.cluster_name
  }

  set {
    name  = "controller.env[1].name"
    value = "CLUSTER_ENDPOINT"
  }

  set {
    name  = "controller.env[1].value"
    value = data.terraform_remote_state.infra.outputs.cluster_endpoint
  }

  set {
    name  = "controller.env[2].name"
    value = "AWS_DEFAULT_INSTANCE_PROFILE"
  }

  set {
    name  = "controller.env[2].value"
    value = data.terraform_remote_state.infra.outputs.karpenter_instance_profile_name
  }

  ##########################################
  # IRSA (IAM ROLE FOR SERVICE ACCOUNT)
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
    value = data.terraform_remote_state.infra.outputs.karpenter_iam_role_arn
  }

  ##########################################
  # CONTROLLER RESOURCES (SAFE DEFAULTS)
  ##########################################
  set {
    name  = "controller.resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "controller.resources.requests.memory"
    value = "256Mi"
  }

  set {
    name  = "controller.resources.limits.cpu"
    value = "1"
  }

  set {
    name  = "controller.resources.limits.memory"
    value = "1Gi"
  }

  ##########################################
  # LOGGING
  ##########################################
  set {
    name  = "logLevel"
    value = "debug"
  }
  
  # Add dependencies to ensure proper order
  depends_on = [
    data.terraform_remote_state.infra,
    helm_release.argocd
  ]
}
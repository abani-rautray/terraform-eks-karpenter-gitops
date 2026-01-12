resource "helm_release" "karpenter" {
  name       = "karpenter"
  namespace  = "kube-system"

  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "0.37.7"

  create_namespace = true
  wait             = true
  timeout          = 900
  skip_crds        = false

  # Dynamic values from remote state
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = data.terraform_remote_state.infra.outputs.karpenter_iam_role_arn
  }

  set {
    name  = "settings.clusterName"
    value = data.terraform_remote_state.infra.outputs.cluster_name
  }

  set {
    name  = "settings.clusterEndpoint"
    value = data.terraform_remote_state.infra.outputs.cluster_endpoint
  }

  set {
    name  = "settings.interruptionQueue"
    value = data.terraform_remote_state.infra.outputs.karpenter_interruption_queue_name
  }

  depends_on = [
    data.terraform_remote_state.infra
  ]
}
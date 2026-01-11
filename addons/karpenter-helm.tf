resource "helm_release" "karpenter" {
  name       = "karpenter"
  namespace  = "karpenter"

  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "0.37.7"

  create_namespace = true
  wait             = true
  timeout          = 900
  skip_crds        = false

  values = [
    file("${path.module}/karpenter-values.yaml")
  ]
}

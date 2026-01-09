############################################
# ARGO CD HELM RELEASE
############################################
resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = var.argocd_namespace
  chart            = "argo-cd"
  create_namespace = true
  
  # Use OCI repository URL - more reliable than chart repository
  repository       = "https://argoproj.github.io/argo-helm"
  
  # Force Helm to skip cache and download fresh
  skip_crds        = false
  wait             = true
  timeout          = 600
  
  # Disable cache-related features that cause issues on Windows
  dependency_update = true

  ##########################################
  # BASIC SETTINGS
  ##########################################
  set {
    name  = "configs.params.server.insecure"
    value = "true"
  }

  ##########################################
  # SERVICE CONFIG (CLUSTERIP)
  ##########################################
  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }
  
  # Add dependencies to ensure proper order
  depends_on = [
    data.terraform_remote_state.infra
  ]
}

# echo "kubectl port-forward svc/argocd-server -n argocd 8080:443"

# echo 'kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode'

# echo "https://localhost:8080  Username: admin"
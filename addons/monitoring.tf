resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "kubernetes_secret" "grafana_admin" {
  metadata {
    name      = "grafana-admin"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  data = {
    admin-user     = "admin"
    admin-password = var.grafana_admin_password

  }

  type = "Opaque"
}

resource "helm_release" "kube_prometheus_stack" {
  name      = "kube-prometheus-stack"
  namespace = kubernetes_namespace.monitoring.metadata[0].name

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version   = "58.6.0"

  create_namespace = false
  wait             = false
  timeout          = 1800

  values = [<<EOF
grafana:
  admin:
    existingSecret: grafana-admin
    passwordKey: admin-password
  service:
    type: ClusterIP

prometheus:
  prometheusSpec:
    retention: 7d
    serviceMonitorSelectorNilUsesHelmValues: false

# prometheusOperator:
#   admissionWebhooks:
#     enabled: false

nodeExporter:
  tolerations:
    - operator: Exists

kubeStateMetrics:
  tolerations:
    - operator: Exists
EOF
  ]

  depends_on = [
    kubernetes_namespace.monitoring,
    kubernetes_secret.grafana_admin
  ]
}

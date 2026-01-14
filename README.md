# 🚀 Production-Grade EKS Platform with GitOps, Karpenter & Observability

This repository demonstrates a **production-ready Kubernetes platform on AWS EKS**, provisioned using **Terraform**, managed via **GitOps (ArgoCD)**, dynamically scaled using **Karpenter**, and monitored with **Prometheus & Grafana**.

---

## 🧩 Architecture Overview

**Core Stack**

- **Terraform** – Infrastructure as Code
- **Amazon EKS** – Managed Kubernetes
- **Karpenter** – Dynamic node provisioning (Spot + On-Demand)
- **ArgoCD** – GitOps continuous delivery
- **Prometheus Operator** – Metrics & alerting
- **Grafana** – Dashboards & visualization

---

# 🏗️ Infrastructure Components

## 1️⃣ AWS Infrastructure (Terraform)
- Custom VPC with public & private subnets
- Amazon EKS cluster with OIDC provider
- IAM roles & policies using IRSA
- Karpenter controller and node IAM roles
- Spot interruption handling with SQS

## 2️⃣ Node Autoscaling (Karpenter)
- **NodePools**
  - `ondemand` – stable workloads
  - `spot` – cost-optimized workloads
- **EC2NodeClass**
  - Amazon Linux 2023 AMI
  - Auto-discovery using cluster tags
- Fast scale-up / scale-down based on pod demand

## 3️⃣ GitOps Deployment (ArgoCD)
- Declarative Kubernetes manifests
- Auto-sync enabled
- Drift detection & self-healing
- Separation of infrastructure & application configs

## 4️⃣ Observability Stack
- `kube-prometheus-stack` Helm chart
- Prometheus, Alertmanager
- Node Exporter & kube-state-metrics
- Grafana dashboards for:
  - Nodes
  - Cluster resources
  - Namespaces
  - Network & storage metrics

## ✨ Key Features

- Fully automated EKS provisioning using Terraform
- GitOps-based Kubernetes configuration with ArgoCD
- Dynamic autoscaling using Karpenter (Spot & On-Demand)
- Cost optimization via Spot instances
- Production-grade observability with Prometheus & Grafana
- Secure IAM access using IRSA


---

## 📁 Repository Structure

```text
.
├── infra/                  # Terraform: VPC, EKS, IAM, IRSA
├── gitops/
│   ├── argocd/              # ArgoCD applications
│   └── karpenter/           # NodePool & EC2NodeClass manifests
├── addons/
│   └── monitoring.tf        # Prometheus & Grafana Helm install
├── README.md
└── LICENSE
```

##  💡 Why This Project Matters

  This project reflects real-world DevOps practices used in production environments—combining IaC, GitOps, autoscaling, and observability to build a scalable, cost-efficient Kubernetes platform on AWS.

## 🔮 Future Improvements

- Add multi-environment support (dev/stage/prod)
- Integrate AWS Load Balancer Controller
- Enable alerting rules with Alertmanager
- Add workload-level HPA testing
- Implement cost monitoring with Kubecost

## 📸 Screenshots shared on LinkedIn

linkdin : https://github.com/abani-rautray/terraform-eks-karpenter-gitops.git

## 📜 License

This project is licensed under the

MIT License





# Demo CRM Helm Chart

> **Production-ready Helm chart** for deploying the Demo CRM application on Kubernetes

[![Helm](https://img.shields.io/badge/Helm-3.8+-0F1689?logo=helm)](https://helm.sh/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.24+-326CE5?logo=kubernetes)](https://kubernetes.io/)
[![Chart Version](https://img.shields.io/badge/Chart-0.1.0-blue)](Chart.yaml)

## 🎯 Overview

A comprehensive Helm chart for deploying the **Demo CRM application** with all necessary components including MongoDB, ingress configuration, and TLS certificates.

### Key Features

- ✅ **Production-ready** deployment configuration
- ✅ **High availability** with configurable replicas
- ✅ **Automatic TLS** via cert-manager integration
- ✅ **MongoDB integration** with connection management
- ✅ **Configurable resources** and scaling
- ✅ **GitOps-ready** for ArgoCD deployment

## 📦 What's Included

| Component | Description |
|-----------|-------------|
| **Application** | Demo CRM containerized application |
| **Service** | ClusterIP service for internal communication |
| **Ingress** | Ingress resource with TLS support |
| **ConfigMap** | Application configuration |
| **Secrets** | MongoDB credentials and sensitive data |
| **Deployment** | Kubernetes deployment with resource limits |

## 🚀 Quick Start

### Prerequisites

- Kubernetes cluster (1.24+)
- Helm 3.8.0+
- Ingress controller (ingress-nginx-classic)
- cert-manager (for TLS certificates)
- MongoDB (managed separately via GitOps)

### Installation via Helm

```bash
# Add repository (if using Helm repo)
helm repo add demo-crm https://charts.example.com
helm repo update

# Install with default values
helm install demo-crm ./demo-crm-helm

# Install with custom values
helm install demo-crm ./demo-crm-helm -f custom-values.yaml

# Upgrade existing release
helm upgrade demo-crm ./demo-crm-helm
```

### Installation via ArgoCD

This chart is designed to be deployed via ArgoCD from the [demo-crm-gitops](https://github.com/tziyon31/demo-crm-gitops) repository.

The ArgoCD Application is defined in:
```yaml
apps/demo-crm-helm.yaml
```

## ⚙️ Configuration

### Key Values

| Parameter | Description | Default |
|-----------|-------------|---------|
| `app.replicas` | Number of application replicas | `3` |
| `app.image.repository` | Container image repository | `pwstaging/demo-crm` |
| `app.image.tag` | Container image tag | `latest` |
| `ingress.enabled` | Enable ingress | `true` |
| `ingress.host` | Ingress hostname | `tziyon-crm.ddns.net` |
| `ingress.className` | Ingress class name | `ingress-nginx` |
| `ingress.tls.enabled` | Enable TLS | `true` |
| `service.port` | Service port | `80` |
| `resources.requests.cpu` | CPU request | `200m` |
| `resources.requests.memory` | Memory request | `256Mi` |

### Example: Custom Values

```yaml
app:
  replicas: 5
  image:
    repository: myregistry/demo-crm
    tag: v1.2.3

ingress:
  host: crm.example.com
  className: ingress-nginx

resources:
  requests:
    cpu: "500m"
    memory: "512Mi"
  limits:
    cpu: "1000m"
    memory: "1Gi"
```

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│         Ingress (TLS/HTTPS)              │
│    ingressClassName: ingress-nginx       │
└──────────────────┬──────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────┐
│         Service (ClusterIP)             │
│         Port: 80 → 3000                 │
└──────────────────┬──────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────┐
│      Demo CRM Application Pods         │
│  ┌──────┐  ┌──────┐  ┌──────┐         │
│  │ Pod1 │  │ Pod2 │  │ Pod3 │         │
│  └──┬───┘  └──┬───┘  └──┬───┘         │
└─────┼─────────┼─────────┼──────────────┘
      │         │         │
      └─────────┼─────────┘
                │ MongoDB Connection
                ▼
┌─────────────────────────────────────────┐
│      MongoDB Replica Set               │
│  (Managed via GitOps separately)       │
└─────────────────────────────────────────┘
```

## 🔐 Security

### TLS/HTTPS

- **Automatic certificate** provisioning via cert-manager
- **ClusterIssuer**: `letsencrypt-prod`
- **Certificate renewal**: Automatic via cert-manager

### Secrets Management

- MongoDB credentials stored in Kubernetes Secrets
- Base64 encoding handled automatically
- Secrets referenced via environment variables

## 📊 Monitoring & Health Checks

### Application Health

```bash
# Check pod status
kubectl get pods -n demo-crm

# View application logs
kubectl logs -n demo-crm -l app.kubernetes.io/name=democrm

# Check service endpoints
kubectl get endpoints -n demo-crm
```

### Ingress Status

```bash
# Check ingress configuration
kubectl get ingress -n demo-crm

# Verify TLS certificate
kubectl get certificate -n demo-crm
```

## 🔄 Upgrades & Rollbacks

```bash
# Upgrade to new version
helm upgrade demo-crm ./demo-crm-helm

# Rollback to previous version
helm rollback demo-crm

# View release history
helm history demo-crm
```

## 🛠️ Troubleshooting

### Pods Not Starting

```bash
# Check pod events
kubectl describe pod <pod-name> -n demo-crm

# Check pod logs
kubectl logs <pod-name> -n demo-crm
```

### Ingress Issues

```bash
# Verify ingress controller
kubectl get pods -n ingress-nginx-classic

# Check ingress status
kubectl describe ingress -n demo-crm
```

### MongoDB Connection Issues

```bash
# Verify MongoDB service
kubectl get svc -n demo-crm | grep mongodb

# Check MongoDB pods
kubectl get pods -n demo-crm | grep mongodb
```

## 📁 Chart Structure

```
demo-crm-helm/
├── Chart.yaml              # Chart metadata
├── values.yaml             # Default configuration values
├── templates/              # Kubernetes manifests
│   ├── deployment.yaml     # Application deployment
│   ├── service.yaml        # Service definition
│   ├── ingress.yaml        # Ingress configuration
│   ├── configmap.yaml      # Application config
│   └── secret.yaml         # Secrets template
└── README.md               # This file
```

## 🔗 Dependencies

This chart expects the following infrastructure (managed via GitOps):

- **ingress-nginx-classic** - Ingress controller
- **cert-manager** - TLS certificate management
- **MongoDB Community Operator** - MongoDB management
- **MongoDB Replica Set** - Database backend

## 📚 Related Resources

- **[GitOps Repository](https://github.com/tziyon31/demo-crm-gitops)** - Infrastructure and ArgoCD configuration
- **[MongoDB Operator](https://github.com/mongodb/mongodb-kubernetes-operator)** - MongoDB Community Operator

## 📝 License

This project is part of a learning course and is provided as-is.

---

**Maintained by**: [tziyon31](https://github.com/tziyon31)  
**Repository**: [demo-crm-helm](https://github.com/tziyon31/demo-crm-helm)  
**Chart Version**: 0.1.0

# Demo CRM v4 - Helm Chart

A production-ready Helm chart for deploying the Demo CRM application with MongoDB, F5 NGINX Ingress Controller, and TLS certificates managed by cert-manager.

## Table of Contents

- [Project Description](#project-description)
- [Prerequisites](#prerequisites)
- [Architecture Overview](#architecture-overview)
- [Installation](#installation)
- [Configuration](#configuration)
- [Testing Procedures](#testing-procedures)
- [Troubleshooting](#troubleshooting)

## Project Description

This Helm chart deploys a complete Demo CRM application stack on Kubernetes, including:

- **Demo CRM Application**: A containerized CRM application with configurable replicas
- **MongoDB**: MongoDB Community Operator with replica set configuration
- **F5 NGINX Ingress Controller**: Production-ready ingress controller (replacing deprecated community ingress-nginx)
- **cert-manager**: Automated TLS certificate management with Let's Encrypt
- **TLS/HTTPS**: Automatic SSL/TLS certificate provisioning and renewal

### Purpose

This chart provides a complete, production-ready deployment solution that:
- Simplifies the deployment process through Helm dependencies
- Ensures high availability with MongoDB replica sets
- Provides secure HTTPS access with automatic certificate management
- Follows Kubernetes and Helm best practices

## Prerequisites

### Required

- **Kubernetes Cluster**: Version 1.24+ (tested on 1.24-1.28)
- **Helm**: Version 3.8.0 or higher
- **kubectl**: Configured to access your Kubernetes cluster
- **Network Access**: 
  - Outbound access to download container images
  - Inbound access for ingress (if using LoadBalancer)
  - DNS access for Let's Encrypt ACME challenges

### Optional

- **kubectl**: For manual verification and troubleshooting
- **Helm repositories**: Will be automatically added via chart dependencies

### Verify Prerequisites

```bash
# Check Kubernetes version
kubectl version --client --short

# Check Helm version
helm version

# Verify cluster access
kubectl cluster-info
```

## Architecture Overview

The following diagram illustrates the architecture of the Demo CRM v4 deployment:

```
┌─────────────────────────────────────────────────────────────┐
│                        User/Client                           │
└──────────────────────────┬──────────────────────────────────┘
                           │ HTTPS (TLS)
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              F5 NGINX Ingress Controller                     │
│              (nginx-ingress 2.4.1)                          │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    Ingress Resource                         │
│              (TLS: Let's Encrypt)                          │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    Service (ClusterIP)                      │
│              Port: 80 → Target: 3000                        │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              Demo CRM Application Pods                      │
│              (Replicas: 3)                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Pod 1      │  │   Pod 2      │  │   Pod 3      │      │
│  │  Container   │  │  Container   │  │  Container   │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
└─────────┼──────────────────┼──────────────────┼────────────┘
          │                  │                  │
          └──────────────────┼──────────────────┘
                             │ MongoDB Connection
                             ▼
┌─────────────────────────────────────────────────────────────┐
│              MongoDB Replica Set                            │
│  ┌──────────────┐  ┌──────────────┐                        │
│  │ MongoDB-0     │  │ MongoDB-1     │                        │
│  │ (Primary)    │  │ (Secondary)  │                        │
│  └──────────────┘  └──────────────┘                        │
│         │                  │                                │
│         └──────────────────┘                                │
│              Replica Set: rs0                               │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    cert-manager                             │
│              (ClusterIssuer: Let's Encrypt)                │
│         ┌──────────────────────────────────┐                │
│         │  ClusterIssuer                  │                │
│         │  - ACME Server                  │                │
│         │  - HTTP-01 Challenge            │                │
│         └──────────────────────────────────┘                │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│              Configuration & Secrets                       │
│  ┌──────────────┐  ┌──────────────┐                      │
│  │  ConfigMap   │  │   Secrets    │                      │
│  │  - LOG_LEVEL │  │  - MongoDB   │                      │
│  │  - MongoDB   │  │    URI        │                      │
│  │    Config    │  │  - Password   │                      │
│  └──────────────┘  └──────────────┘                      │
└─────────────────────────────────────────────────────────────┘
```

### Components

1. **Application Layer**
   - Demo CRM pods with configurable replicas
   - Resource limits and requests
   - Environment variables from ConfigMap and Secrets

2. **Network Layer**
   - ClusterIP Service for internal communication
   - Ingress resource with TLS termination
   - F5 NGINX Ingress Controller for routing

3. **Data Layer**
   - MongoDB Community Operator
   - MongoDB Replica Set (2 members)
   - Persistent storage for MongoDB

4. **Security Layer**
   - cert-manager for TLS certificate management
   - ClusterIssuer for Let's Encrypt
   - Kubernetes Secrets for sensitive data

5. **Configuration Layer**
   - ConfigMap for application settings
   - Secrets for MongoDB credentials

## Installation

### Quick Start

The simplest way to install the chart:

```bash
# Add required Helm repositories (if not already added)
helm repo add mongodb https://mongodb.github.io/helm-charts
helm repo add jetstack https://charts.jetstack.io
helm repo add nginx-stable https://helm.nginx.com/stable
helm repo update

# Install the chart
helm install democrm-v4 ./democrm-v4

# Or install in a specific namespace
helm install democrm-v4 ./democrm-v4 --namespace democrm --create-namespace
```

### Custom Installation

Install with custom values:

```bash
# Create a custom values file
cat > custom-values.yaml <<EOF
app:
  replicas: 5
  image:
    tag: v1.2.3

ingress:
  host: my-crm.example.com

resources:
  limits:
    cpu: "1000m"
    memory: "1Gi"
EOF

# Install with custom values
helm install democrm-v4 ./democrm-v4 -f custom-values.yaml
```

### Installation with Multiple Value Files

```bash
helm install democrm-v4 ./democrm-v4 \
  -f values.yaml \
  -f production-values.yaml \
  -f secrets-values.yaml
```

### Upgrade Existing Installation

```bash
# Upgrade with new values
helm upgrade democrm-v4 ./democrm-v4 -f custom-values.yaml

# Upgrade and wait for rollout
helm upgrade democrm-v4 ./democrm-v4 --wait --timeout 5m
```

### Uninstall

```bash
# Uninstall the release
helm uninstall democrm-v4

# Uninstall and remove dependencies
helm uninstall democrm-v4
# Note: Dependencies (MongoDB, cert-manager, nginx-ingress) will remain installed
# To remove them, uninstall separately:
helm uninstall <dependency-release-name>
```

## Configuration

The following table lists the configurable parameters and their default values:

### Application Configuration

| Parameter | Description | Default | Example |
|-----------|-------------|---------|---------|
| `global.appName` | Global application name | `democrm` | `myapp` |
| `app.name` | Application instance name | `crm1` | `crm-prod` |
| `app.image.repository` | Container image repository | `pwstaging/demo-crm` | `myregistry/demo-crm` |
| `app.image.tag` | Container image tag | `latest` | `v1.2.3` |
| `app.image.pullPolicy` | Image pull policy | `IfNotPresent` | `Always` |
| `app.replicas` | Number of application replicas | `3` | `5` |
| `app.container.name` | Container name | `crm1` | `app` |
| `app.container.port` | Container port | `3000` | `8080` |

### Resource Configuration

| Parameter | Description | Default | Example |
|-----------|-------------|---------|---------|
| `resources.requests.cpu` | CPU request | `200m` | `500m` |
| `resources.requests.memory` | Memory request | `256Mi` | `512Mi` |
| `resources.limits.cpu` | CPU limit | `500m` | `1000m` |
| `resources.limits.memory` | Memory limit | `512Mi` | `1Gi` |

### Service Configuration

| Parameter | Description | Default | Example |
|-----------|-------------|---------|---------|
| `service.name` | Service name suffix | `cluster-ip` | `lb` |
| `service.type` | Service type | `ClusterIP` | `LoadBalancer` |
| `service.port` | Service port | `80` | `443` |
| `service.targetPort` | Target container port | `3000` | `8080` |

### Ingress Configuration

| Parameter | Description | Default | Example |
|-----------|-------------|---------|---------|
| `ingress.enabled` | Enable ingress | `true` | `false` |
| `ingress.name` | Ingress name suffix | `ingress` | `web` |
| `ingress.className` | Ingress class name | `nginx` | `nginx-plus` |
| `ingress.host` | Ingress hostname | `tziyon-crm.ddns.net` | `crm.example.com` |
| `ingress.annotations` | Ingress annotations | See values.yaml | Custom annotations |
| `ingress.tls.enabled` | Enable TLS | `true` | `false` |
| `ingress.tls.secretName` | TLS secret name | `crm1-tls-secret` | `my-tls-secret` |

### ConfigMap Configuration

| Parameter | Description | Default | Example |
|-----------|-------------|---------|---------|
| `config.name` | ConfigMap name | `demo-crm-conf` | `app-config` |
| `config.logLevel` | Log level | `info` | `debug` |
| `config.persistence` | Enable persistence | `true` | `false` |
| `config.mongodb.hosts` | MongoDB hosts | `mongodb-0.mongo-service:27017,mongodb-1.mongo-service:27017` | Custom hosts |
| `config.mongodb.replicaSet` | MongoDB replica set name | `rs0` | `my-replica-set` |
| `config.mongodb.authSource` | MongoDB auth source | `admin` | `democrm` |

### Secrets Configuration

| Parameter | Description | Default | Example |
|-----------|-------------|---------|---------|
| `secrets.mongodb.username` | MongoDB username | `crmuser` | `admin` |
| `secrets.mongodb.password` | MongoDB password | `crmpassword` | `secure-password` |
| `secrets.mongodb.uriSecretName` | MongoDB URI secret name | `mongodb-credentials` | `db-uri` |
| `secrets.mongodb.passwordSecretName` | MongoDB password secret name | `mongodb-crmuser-password` | `db-password` |

### ClusterIssuer Configuration

| Parameter | Description | Default | Example |
|-----------|-------------|---------|---------|
| `clusterIssuer.enabled` | Enable ClusterIssuer | `true` | `false` |
| `clusterIssuer.name` | ClusterIssuer name | `letsencrypt-prod` | `my-issuer` |
| `clusterIssuer.email` | Email for Let's Encrypt | `tziyon31@hotmail.com` | `admin@example.com` |
| `clusterIssuer.server` | ACME server URL | `https://acme-v02.api.letsencrypt.org/directory` | Staging URL |
| `clusterIssuer.solver.type` | Challenge solver type | `http01` | `dns01` |
| `clusterIssuer.solver.ingress.class` | Ingress class for solver | `nginx` | `nginx-plus` |

### Dependencies Configuration

| Parameter | Description | Default | Example |
|-----------|-------------|---------|---------|
| `mongodb-community-operator-crds.enabled` | Enable MongoDB CRDs | `true` | `false` |
| `mongodb-community-operator.enabled` | Enable MongoDB Operator | `true` | `false` |
| `cert-manager.enabled` | Enable cert-manager | `true` | `false` |
| `nginx-ingress.enabled` | Enable nginx-ingress | `true` | `false` |

### Example: Production Configuration

```yaml
app:
  replicas: 5
  image:
    repository: myregistry/demo-crm
    tag: v1.2.3
    pullPolicy: Always

resources:
  requests:
    cpu: "500m"
    memory: "512Mi"
  limits:
    cpu: "2000m"
    memory: "2Gi"

ingress:
  host: crm.production.example.com
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    ingress.kubernetes.io/ssl-redirect: "true"

clusterIssuer:
  email: admin@production.example.com
```

## Testing Procedures

### Pre-Installation Checks

```bash
# Verify cluster access
kubectl cluster-info

# Check available nodes
kubectl get nodes

# Verify Helm is installed
helm version

# Check if required repositories are available
helm repo list
```

### Installation Verification

```bash
# Check Helm release status
helm status democrm-v4

# List all releases
helm list -A

# Check if all pods are running
kubectl get pods -l app=crm1

# Check deployment status
kubectl get deployment

# Check service
kubectl get service

# Check ingress
kubectl get ingress
```

### Application Health Checks

```bash
# Check application pods
kubectl get pods -l app=crm1

# View pod logs
kubectl logs -l app=crm1 --tail=50

# Check pod events
kubectl describe pod -l app=crm1

# Test service connectivity (from within cluster)
kubectl run -it --rm debug --image=curlimages/curl --restart=Never -- curl http://<service-name>:80
```

### MongoDB Verification

```bash
# Check MongoDB pods
kubectl get pods -l app=mongodb

# Check MongoDB replica set status
kubectl get mongodbcommunity

# Check MongoDB service
kubectl get svc | grep mongo

# Test MongoDB connection (if MongoDB client pod available)
kubectl exec -it <mongodb-pod> -- mongosh --eval "rs.status()"
```

### TLS Certificate Verification

```bash
# Check certificate status
kubectl get certificate

# Check certificate details
kubectl describe certificate crm1-tls-secret

# Check certificate request
kubectl get certificaterequest

# Verify cert-manager pods
kubectl get pods -n cert-manager

# Check ClusterIssuer
kubectl get clusterissuer
```

### Ingress Verification

```bash
# Check ingress status
kubectl get ingress

# Check ingress details
kubectl describe ingress <ingress-name>

# Verify F5 NGINX Ingress Controller
kubectl get pods -l app=nginx-ingress

# Test ingress from outside (if LoadBalancer or NodePort)
curl -I https://<your-host>
```

### End-to-End Testing

```bash
# 1. Verify all components are ready
kubectl get all

# 2. Check application is accessible
curl -k https://<your-host>

# 3. Verify TLS certificate
openssl s_client -connect <your-host>:443 -servername <your-host>

# 4. Test application functionality
# (Perform application-specific tests)
```

### Load Testing (Optional)

```bash
# Install hey (HTTP load testing tool)
# Test with 100 requests, 10 concurrent
hey -n 100 -c 10 https://<your-host>
```

## Troubleshooting

### Common Issues

#### 1. Pods Not Starting

**Symptoms:**
- Pods in `Pending` or `CrashLoopBackOff` state
- `kubectl get pods` shows unhealthy pods

**Diagnosis:**
```bash
# Check pod status
kubectl get pods

# Check pod events
kubectl describe pod <pod-name>

# Check pod logs
kubectl logs <pod-name>
```

**Solutions:**
- **Insufficient resources**: Check node resources with `kubectl top nodes`
- **Image pull errors**: Verify image exists and credentials are correct
- **ConfigMap/Secret missing**: Verify ConfigMap and Secrets exist
- **Resource limits too low**: Increase resources in values.yaml

#### 2. MongoDB Connection Issues

**Symptoms:**
- Application cannot connect to MongoDB
- MongoDB pods not ready

**Diagnosis:**
```bash
# Check MongoDB pods
kubectl get pods -l app=mongodb

# Check MongoDB operator logs
kubectl logs -l app=mongodb-community-operator

# Check MongoDB service
kubectl get svc | grep mongo

# Verify MongoDB URI in secret
kubectl get secret mongodb-credentials -o jsonpath='{.data.uri}' | base64 -d
```

**Solutions:**
- **MongoDB not ready**: Wait for MongoDB replica set to initialize
- **Wrong connection string**: Verify MongoDB hosts in ConfigMap
- **Authentication failure**: Check MongoDB username/password in Secrets
- **Network issues**: Verify service and endpoints exist

#### 3. TLS Certificate Not Issued

**Symptoms:**
- Certificate in `Pending` state
- HTTPS not working
- Certificate request failing

**Diagnosis:**
```bash
# Check certificate status
kubectl get certificate

# Check certificate request
kubectl get certificaterequest

# Check cert-manager logs
kubectl logs -n cert-manager -l app=cert-manager

# Check ClusterIssuer
kubectl get clusterissuer letsencrypt-prod -o yaml
```

**Solutions:**
- **DNS not configured**: Ensure DNS points to ingress IP
- **HTTP-01 challenge failing**: Verify ingress is accessible on port 80
- **Rate limiting**: Let's Encrypt has rate limits, wait or use staging server
- **cert-manager not ready**: Check cert-manager pods are running
- **Wrong email**: Verify email in ClusterIssuer configuration

#### 4. Ingress Not Working

**Symptoms:**
- Cannot access application via ingress
- 404 or 502 errors
- Ingress shows no address

**Diagnosis:**
```bash
# Check ingress status
kubectl get ingress

# Check ingress details
kubectl describe ingress <ingress-name>

# Check F5 NGINX Ingress Controller
kubectl get pods -l app=nginx-ingress

# Check ingress controller logs
kubectl logs -l app=nginx-ingress --tail=50
```

**Solutions:**
- **Ingress controller not installed**: Verify nginx-ingress dependency is enabled
- **Wrong ingress class**: Verify ingressClassName matches controller
- **Service not found**: Check service name in ingress matches actual service
- **DNS not configured**: Ensure DNS points to ingress controller IP
- **TLS certificate issue**: See TLS certificate troubleshooting above

#### 5. High Resource Usage

**Symptoms:**
- Pods being evicted
- Slow application performance
- OOMKilled errors

**Diagnosis:**
```bash
# Check resource usage
kubectl top pods
kubectl top nodes

# Check pod resource limits
kubectl describe pod <pod-name> | grep -A 5 "Limits\|Requests"
```

**Solutions:**
- **Increase resource limits**: Update resources in values.yaml
- **Scale horizontally**: Increase replica count
- **Optimize application**: Review application resource usage
- **Add more nodes**: Scale cluster if needed

#### 6. Helm Dependency Issues

**Symptoms:**
- `helm dependency update` fails
- Charts not downloading
- Version conflicts

**Diagnosis:**
```bash
# Check Chart.lock
cat Chart.lock

# Try updating dependencies
helm dependency update ./democrm-v4

# Check repository connectivity
helm repo list
helm repo update
```

**Solutions:**
- **Repository not accessible**: Check network connectivity
- **Version not found**: Verify chart version exists in repository
- **Repository not added**: Add required repositories manually
- **Clear cache**: Delete `charts/` directory and run `helm dependency update`

### Debugging Commands

```bash
# Get all resources
kubectl get all

# Get events
kubectl get events --sort-by='.lastTimestamp'

# Check resource quotas
kubectl describe quota

# Check persistent volumes
kubectl get pv,pvc

# Check network policies
kubectl get networkpolicies

# Describe any resource
kubectl describe <resource-type> <resource-name>
```

### Getting Help

If you encounter issues not covered here:

1. **Check logs**: Review pod and component logs
2. **Review values**: Verify your values.yaml configuration
3. **Check documentation**: Review component-specific documentation
4. **Community support**: Check GitHub issues and community forums

### Useful Links

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)
- [MongoDB Community Operator](https://github.com/mongodb/mongodb-kubernetes-operator)
- [F5 NGINX Ingress Controller](https://docs.nginx.com/nginx-ingress-controller/)
- [cert-manager Documentation](https://cert-manager.io/docs/)

---

## License

This Helm chart is provided as-is for educational and demonstration purposes.

## Contributing

Contributions, issues, and feature requests are welcome!

## Version History

- **0.1.0**: Initial release with MongoDB, F5 NGINX Ingress, and cert-manager support

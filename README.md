# Multi-Site Platform (Professional Edition)

This repository contains a professional multi-site, multi-service platform.

## 🏗️ Architecture

- **Cargo Workspace**: Unified management for all Rust microservices and shared libraries.
- **Microservices**: Each site has its own `apps/` directory for multiple backend services.
- **Shared Libraries**: Located in `libs/`, providing common functionality (DB, Utils, Logging).
- **Frontend**: Next.js (App Router) located in `web/` for each site.
- **Infrastructure**: Kubernetes (Kustomize) with isolated namespaces and monitoring.
- **Monitoring**: Integrated Prometheus & Grafana for per-site observation.
- **CI/CD**: GitHub Actions for automated testing and builds.

## 📁 Structure

- `services/`: Site-specific code.
  - `<site>/apps/`: Microservices (Rust/Actix).
  - `<site>/web/`: Frontend (Next.js).
- `libs/`: Shared Rust crates.
- `k8s/`: Kubernetes manifests.
- `docker/`: Base Dockerfiles for services.

## 🚀 Getting Started

1. **Build all services**:
   ```bash
   make build
   ```
2. **Initialize Cluster**:
   ```bash
   make init
   ```
3. **Deploy**:
   ```bash
   make deploy
   ```

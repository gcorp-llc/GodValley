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

## 🛠️ Technical Details

### Backend (Rust)
- **Framework**: Actix-web 4.x
- **Logging**: Tracing with JSON formatting for production.
- **Metrics**: Prometheus integration via `/metrics` endpoint.
- **Workspaces**: Common logic is shared through local crates in `libs/`.

### Frontend (Next.js)
- **Framework**: Next.js 14 (App Router)
- **Styling**: Tailwind CSS
- **Deployment**: Standalone build mode for minimal Docker image size.

### Infrastructure
- **Ingress**: Nginx Ingress Controller routing based on hostnames.
- **Monitoring**: Prometheus scrapes all pods annotated with `prometheus.io/scrape`. Grafana is available for visualization.
- **Database**: Dedicated ScyllaDB and Redis instances per site for maximum isolation.

## 🤝 Contributing

1. Create a feature branch.
2. Ensure `cargo check --workspace` passes.
3. Ensure all Next.js apps build successfully.
4. Submit a Pull Request.

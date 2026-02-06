# GodValley Project Wiki

Welcome to the GodValley Mother Project documentation. This wiki provides a comprehensive overview of the architecture, deployment processes, and development workflows.

## 🏗️ Architecture Overview

GodValley follows a highly decoupled microservices architecture designed for extreme scalability and multi-tenancy.

### Core Components
- **Frontend**: Independent Next.js applications per site, managed via Turborepo.
- **Backend**: High-performance Rust services built with Actix-web.
- **Inter-service Communication**: gRPC (via `tonic`) for low-latency internal communication.
- **Database Layer**:
  - **ScyllaDB**: High-throughput NoSQL storage.
  - **Redis**: Distributed caching and real-time data.
- **API Gateway**: Traefik handles dynamic routing, TLS termination, and ingress management.

## 🚀 Kubernetes Deployment Flow

The project uses a unified Kubernetes structure with Kustomize for environment-specific patches.

### Initializing the Cluster
```bash
make init
```
This command:
1. Creates namespaces (`godvalley`, `gcorp`, etc.).
2. Deploys the Monitoring stack (Prometheus & Grafana).
3. Installs the Traefik Ingress Controller.

### Building Images
```bash
make build
```
Builds Docker images for all sites and services defined in the `SITES` variable.

### Deploying Services
```bash
make deploy
```
Applies Kustomize manifests for all sites. Each site is deployed in its own isolated namespace with dedicated ScyllaDB and Redis clusters.

## 🗄️ ScyllaDB Schema Management

GodValley uses a database-per-service pattern. Each service is responsible for its own keyspace.

### Reference Schema (Core Service)
- **Keyspace**: `godvalley_core`
- **Replication**: `{'class': 'SimpleStrategy', 'replication_factor': 3}`

Recommended practice is to use a migration tool (e.g., `scylla-migrate` or custom Rust logic) during service startup or as a CI/CD job.

## 📡 gRPC Service Map

All internal communication is defined in the `protos/` directory and compiled into the `common-proto` library.

### Services Defined:
1. **CoreService** (`protos/core.proto`)
   - `HealthCheck`: System health monitoring.
   - `GetData`: Sample data retrieval.

### Using gRPC in Rust
Add `common-proto` as a dependency and use the generated modules:
```rust
use common_proto::core::core_service_client::CoreServiceClient;
```

## 🛠️ Development Workflow

### Adding a New Site
1. Create a new directory under `services/<site_name>`.
2. Add `web/` (Next.js) and `apps/api/` (Rust) directories.
3. Update the root `package.json` and `Cargo.toml`.
4. Create K8s manifests in `k8s/sites/<site_name>`.
5. Add the site to `SITES` in the `Makefile`.

### Adding a New gRPC Method
1. Update the relevant `.proto` file in `protos/`.
2. Recompile `common-proto` using `cargo check -p common-proto`.
3. Implement the new method in the target service.

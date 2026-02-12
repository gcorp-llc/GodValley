# Multi-Site Platform (Professional Edition)

This repository contains a professional multi-site, multi-service platform.

## 🏗️ Architecture

- **Cargo Workspace**: Unified management for all Rust microservices and shared libraries.
- **Microservices**: Each site has its own `apps/` directory for backend services.
- **Shared Libraries**: Located in `libs/`, providing common functionality (DB, Utils, Logging).
- **Frontend**: Next.js (App Router) located in `web/` for each site.
- **Infrastructure**: Kubernetes (Kustomize) with isolated namespaces and monitoring.
- **Monitoring**: Integrated Prometheus & Grafana for per-site observation.

## 📁 Structure

- `services/`: Site-specific code.
  - `<site>/apps/`: Microservices (Rust/Actix).
  - `<site>/web/`: Frontend (Next.js).
- `libs/`: Shared Rust crates.
- `k8s/`: Kubernetes manifests.
- `docker/`: Base Dockerfiles for services.
- `local/docker-compose.dev.yml`: Local all-in-one development stack.

## ✅ Integrity checks performed

- Workspace compile check: `cargo check --workspace`.
- Docker orchestration consistency:
  - fixed mismatched service paths in `local/docker-compose.dev.yml`.
  - aligned backend image build paths in `Makefile` (`godvalley` uses `apps/core`, other sites use `apps/api`).
  - normalized Dockerfiles so backend and frontend images are buildable from current repository layout.

## 🚀 Getting Started

### Local (Docker Compose)

```bash
cd local
docker compose -f docker-compose.dev.yml up --build
```

Useful URLs (default):
- GodValley web: `http://localhost:3000`
- GodValley API: `http://localhost:8080`
- gcorp web/api: `http://localhost:3001` / `http://localhost:8081`
- journa web/api: `http://localhost:3002` / `http://localhost:8082`
- cardiani web/api: `http://localhost:3003` / `http://localhost:8083`
- zeteb web/api: `http://localhost:3004` / `http://localhost:8084`

### Kubernetes flow

1. Build all images:
   ```bash
   make build
   ```
2. Initialize cluster:
   ```bash
   make init
   ```
3. Deploy all sites:
   ```bash
   make deploy
   ```

## 🐳 Run on Docker Desktop (Windows)

1. Install Docker Desktop and enable **WSL2 backend**.
2. Clone the repository inside WSL2 filesystem (recommended) for best performance.
3. From project root:
   ```bash
   cd local
   docker compose -f docker-compose.dev.yml up --build
   ```
4. Add hostnames (optional) in Windows `hosts` file if you use domain-based routing.
5. For clean restart:
   ```bash
   docker compose -f docker-compose.dev.yml down -v
   docker compose -f docker-compose.dev.yml up --build
   ```

## 🐳 Run on VPS (Docker Engine)

1. Install Docker Engine + Compose plugin on VPS.
2. Clone repo on server.
3. Build and run:
   ```bash
   cd local
   docker compose -f docker-compose.dev.yml up -d --build
   ```
4. Open firewall ports you need (for example `3000-3004`, `8080-8084`, `50051`, `9042`, `6379`).
5. For production hardening:
   - use reverse proxy (Traefik/Nginx) with TLS.
   - store secrets in `.env` or secret manager (not plain compose files).
   - pin image tags and set restart policies.
   - move persistent volumes to managed block storage.

## 🤝 Contributing

1. Create a feature branch.
2. Ensure `cargo check --workspace` passes.
3. Ensure targeted Docker builds succeed.
4. Submit a Pull Request.

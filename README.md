# Multi-Site Platform (Docker + Kubernetes)

This repository contains a production-ready multi-site platform designed to run
on **Docker Desktop (Windows)** with **Kubernetes enabled**, and transferable
without architectural changes to a **VPS or dedicated server**.

## 🚀 Supported Sites

- gcorp.cc
- journa.ir
- cardiani.ir
- zeteb.ir

Each site is fully isolated and includes:
- Frontend: Next.js
- Backend: Rust + Actix Web
- Cache: Redis (dedicated)
- Database: ScyllaDB (dedicated)

---

## 🧱 Architecture Overview

- Kubernetes (local via Docker Desktop, prod via VPS)
- NGINX Ingress Controller
- One namespace per site
- No shared runtime dependencies between sites
- Production-grade container images
- Kustomize-based Kubernetes manifests

---

## 📁 Repository Structure (High Level)

multi-site-platform/
│
├── README.md
├── .env.example
├── Makefile
│
├── docker/
│   ├── frontend-nextjs/
│   │   └── Dockerfile
│   │
│   ├── backend-actix/
│   │   └── Dockerfile
│   │
│   ├── redis/
│   │   └── redis.conf
│   │
│   └── scylladb/
│       └── scylla.yaml
│
├── k8s/
│   ├── ingress/
│   │   ├── ingress-nginx-install.yaml
│   │   └── ingress-routes.yaml
│   │
│   ├── namespaces/
│   │   ├── gcorp.yaml
│   │   ├── journa.yaml
│   │   ├── cardiani.yaml
│   │   └── zeteb.yaml
│   │
│   ├── base/
│   │   ├── frontend.yaml
│   │   ├── backend.yaml
│   │   ├── redis.yaml
│   │   ├── scylladb.yaml
│   │   ├── configmap.yaml
│   │   └── secrets.yaml
│   │
│   └── sites/
│       ├── gcorp/
│       │   ├── kustomization.yaml
│       │   ├── frontend-patch.yaml
│       │   ├── backend-patch.yaml
│       │   ├── redis-patch.yaml
│       │   ├── scylladb-patch.yaml
│       │   └── ingress.yaml
│       │
│       ├── journa/
│       │   └── (same structure)
│       │
│       ├── cardiani/
│       │   └── (same structure)
│       │
│       └── zeteb/
│           └── (same structure)
│
├── services/
│   ├── gcorp.cc/
│   │   ├── frontend/
│   │   │   ├── package.json
│   │   │   ├── next.config.js
│   │   │   ├── tsconfig.json
│   │   │   ├── public/
│   │   │   ├── app/
│   │   │   └── Dockerfile
│   │   │
│   │   └── backend/
│   │       ├── Cargo.toml
│   │       ├── Cargo.lock
│   │       ├── src/
│   │       │   ├── main.rs
│   │       │   ├── config.rs
│   │       │   ├── routes/
│   │       │   ├── services/
│   │       │   ├── db/
│   │       │   │   ├── scylla.rs
│   │       │   │   └── redis.rs
│   │       │   └── middleware/
│   │       └── Dockerfile
│   │
│   ├── journa.ir/
│   │   └── (frontend + backend)
│   │
│   ├── cardiani.ir/
│   │   └── (frontend + backend)
│   │
│   └── zeteb.ir/
│       └── (frontend + backend)
│
├── databases/
│   ├── gcorp/
│   │   ├── redis-data/
│   │   └── scylla-data/
│   │
│   ├── journa/
│   │   ├── redis-data/
│   │   └── scylla-data/
│   │
│   ├── cardiani/
│   │   ├── redis-data/
│   │   └── scylla-data/
│   │
│   └── zeteb/
│       ├── redis-data/
│       └── scylla-data/
│
├── tools/
│   ├── redis-commander/
│   │   └── deployment.yaml
│   │
│   └── scylla-manager/
│       └── deployment.yaml
│
└── local/
    ├── docker-compose.dev.yml
    ├── hosts.example
    └── bootstrap.ps1


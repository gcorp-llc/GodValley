SHELL := /bin/bash

.DEFAULT_GOAL := help

SITES := godvalley gcorp cardiani journa zeteb

## -----------------------------
## Core
## -----------------------------

help:
	@echo "Available commands:"
	@echo "  make init           Initialize cluster (ingress, namespaces, monitoring)"
	@echo "  make build          Build all Docker images for all sites"
	@echo "  make deploy         Deploy all sites to Kubernetes"
	@echo "  make destroy        Remove all deployments and namespaces"
	@echo "  make status         Show cluster status"

## -----------------------------
## Init
## -----------------------------

init:
	kubectl apply -f k8s/namespaces/
	kubectl apply -f k8s/monitoring/
	kubectl apply -f k8s/ingress/traefik-install.yaml
	@echo "Waiting for Traefik ingress controller..."
	kubectl wait --namespace kube-system \
		--for=condition=ready pod \
		--selector=app=traefik \
		--timeout=120s

## -----------------------------
## Build Images
## -----------------------------

build: build-backend build-frontend

build-backend:
	@for site in $(SITES); do \
		echo "Building $$site-api..."; \
		path="services/$$site"; \
		[ "$$site" == "gcorp" ] && path="services/gcorp.cc"; \
		docker build --build-arg APP_PATH=$$path/apps/api --build-arg APP_NAME=$$site-api -t multi/$$site-api:latest -f docker/backend-actix/Dockerfile . ; \
	done

build-frontend:
	@for site in $(SITES); do \
		echo "Building $$site-web..."; \
		path="services/$$site"; \
		[ "$$site" == "gcorp" ] && path="services/gcorp.cc"; \
		docker build -t multi/$$site-web:latest $$path/web -f docker/frontend-nextjs/Dockerfile ; \
	done

## -----------------------------
## Deploy
## -----------------------------

deploy:
	@for site in $(SITES); do \
		echo "Deploying $$site..."; \
		kubectl apply -k k8s/sites/$$site; \
	done

## -----------------------------
## Destroy
## -----------------------------

destroy:
	@for site in $(SITES); do \
		kubectl delete -k k8s/sites/$$site --ignore-not-found=true; \
	done
	kubectl delete -f k8s/monitoring/ --ignore-not-found=true
	kubectl delete -f k8s/namespaces/ --ignore-not-found=true

## -----------------------------
## Status
## -----------------------------

status:
	@echo "--- Nodes ---"
	kubectl get nodes
	@echo "--- Pods ---"
	kubectl get pods -A
	@echo "--- Services ---"
	kubectl get svc -A
	@echo "--- Ingress ---"
	kubectl get ingress -A

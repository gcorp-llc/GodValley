SHELL := /bin/bash

.DEFAULT_GOAL := help

## -----------------------------
## Core
## -----------------------------

help:
	@echo "Available commands:"
	@echo "  make init           Initialize cluster (ingress, namespaces)"
	@echo "  make build          Build all Docker images"
	@echo "  make deploy         Deploy all sites to Kubernetes"
	@echo "  make destroy        Remove all deployments"
	@echo "  make status         Show cluster status"

## -----------------------------
## Init
## -----------------------------

init:
	kubectl apply -f k8s/namespaces/
	kubectl apply -f k8s/ingress/ingress-nginx-install.yaml
	kubectl wait --namespace ingress-nginx \
		--for=condition=ready pod \
		--selector=app.kubernetes.io/component=controller \
		--timeout=120s

## -----------------------------
## Build Images
## -----------------------------

build:
	docker build -t multi/frontend-nextjs:latest docker/frontend-nextjs
	docker build -t multi/backend-actix:latest docker/backend-actix

## -----------------------------
## Deploy
## -----------------------------

deploy:
	kubectl apply -k k8s/sites/gcorp
	kubectl apply -k k8s/sites/journa
	kubectl apply -k k8s/sites/cardiani
	kubectl apply -k k8s/sites/zeteb

## -----------------------------
## Destroy
## -----------------------------

destroy:
	kubectl delete -k k8s/sites/gcorp || true
	kubectl delete -k k8s/sites/journa || true
	kubectl delete -k k8s/sites/cardiani || true
	kubectl delete -k k8s/sites/zeteb || true

## -----------------------------
## Status
## -----------------------------

status:
	kubectl get nodes
	kubectl get pods -A
	kubectl get svc -A
	kubectl get ingress -A

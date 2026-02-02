# 🏗️ ساختار بهبود یافته پروژه Multi-Site Platform

## 📊 افزودن Observability Stack

```
k8s/
├── observability/
│   ├── namespace.yaml
│   ├── elasticsearch/
│   │   ├── statefulset.yaml
│   │   ├── service.yaml
│   │   └── configmap.yaml
│   ├── kibana/
│   │   ├── deployment.yaml
│   │   └── service.yaml
│   ├── grafana/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── configmap-datasources.yaml
│   │   └── configmap-dashboards.yaml
│   ├── prometheus/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── configmap.yaml
│   ├── loki/
│   │   ├── statefulset.yaml
│   │   └── service.yaml
│   └── fluent-bit/
│       ├── daemonset.yaml
│       ├── configmap.yaml
│       └── serviceaccount.yaml
│
├── automation/
│   ├── namespace.yaml
│   └── n8n/
│       ├── deployment.yaml
│       ├── service.yaml
│       ├── pvc.yaml
│       └── ingress.yaml
│
└── monitoring/
    ├── servicemonitors/
    │   ├── scylla-monitor.yaml
    │   ├── redis-monitor.yaml
    │   └── app-monitor.yaml
    └── alerts/
        ├── scylla-alerts.yaml
        └── app-alerts.yaml
```

## 🔧 بهبودهای ساختاری

### 1. Namespace Isolation صحیح
- هر سایت namespace مستقل خود را دارد
- Observability stack در namespace جداگانه
- n8n در namespace automation

### 2. Centralized Monitoring
- Elasticsearch برای log aggregation از تمام سایت‌ها
- Grafana برای visualization
- Prometheus برای metrics
- Loki برای log streaming

### 3. ScyllaDB Monitoring
- ScyllaDB Monitoring Stack جداگانه
- Prometheus exporter برای ScyllaDB
- Grafana dashboards اختصاصی

### 4. Automation با n8n
- Workflow automation
- دسترسی به تمام سایت‌ها
- Webhook endpoints

## 🎯 مزایای ساختار جدید

1. **مانیتورینگ متمرکز**: همه لاگ‌ها و متریک‌ها در یک مکان
2. **جداسازی کامل**: هر سایت مستقل است
3. **مقیاس‌پذیری**: آسان برای افزودن سایت جدید
4. **قابلیت debug**: لاگ‌ها و متریک‌های جامع
5. **اتوماسیون**: n8n برای workflow ها

## 📈 Resource Requirements

### Development (Docker Desktop)
- CPU: 8 cores minimum
- RAM: 16GB minimum
- Disk: 50GB minimum

### Production (VPS)
- CPU: 16 cores recommended
- RAM: 32GB recommended
- Disk: 200GB SSD recommended
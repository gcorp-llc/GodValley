# 🚀 راهنمای جامع دیپلوی پروژه Multi-Site Platform

## 📋 فهرست مطالب
1. [نصب و راه‌اندازی اولیه](#نصب-و-راهاندازی-اولیه)
2. [دیپلوی Stack های مختلف](#دیپلوی-stackهای-مختلف)
3. [مانیتورینگ و Observability](#مانیتورینگ-و-observability)
4. [اتوماسیون با n8n](#اتوماسیون-با-n8n)
5. [عیب‌یابی](#عیبیابی)

---

## 🛠️ نصب و راه‌اندازی اولیه

### پیش‌نیازها

#### Windows (Docker Desktop)
```powershell
# نصب Docker Desktop
winget install Docker.DockerDesktop

# فعال کردن Kubernetes در Docker Desktop
# Settings → Kubernetes → Enable Kubernetes
```

#### نیازمندی‌های سخت‌افزاری
- **CPU**: حداقل 8 هسته (16 هسته توصیه می‌شود)
- **RAM**: حداقل 16GB (32GB توصیه می‌شود)
- **Storage**: حداقل 50GB فضای خالی SSD

### مرحله 1: آماده‌سازی پروژه

```bash
# کلون پروژه
git clone <repository-url>
cd multi-site-platform

# کپی فایل .env
cp .env.example .env

# ویرایش .env و تنظیم مقادیر
nano .env
```

### مرحله 2: تنظیم فایل hosts

#### Windows
```powershell
# اجرا با دسترسی Administrator
notepad C:\Windows\System32\drivers\etc\hosts
```

#### Linux/Mac
```bash
sudo nano /etc/hosts
```

افزودن این خطوط:
```
127.0.0.1   gcorp.local
127.0.0.1   journa.local
127.0.0.1   cardiani.local
127.0.0.1   zeteb.local
127.0.0.1   grafana.local
127.0.0.1   kibana.local
127.0.0.1   n8n.local
```

### مرحله 3: راه‌اندازی سریع

```bash
# نصب و دیپلوی همه چیز با یک دستور
make setup-all
```

این دستور به ترتیب انجام می‌دهد:
1. ✅ ایجاد namespace ها
2. ✅ نصب Ingress Controller
3. ✅ Build کردن Docker Images
4. ✅ دیپلوی تمام سایت‌ها
5. ✅ دیپلوی Observability Stack
6. ✅ دیپلوی n8n Automation

---

## 🌐 دیپلوی Stack های مختلف

### دیپلوی جداگانه سایت‌ها

```bash
# دیپلوی تک‌تک سایت‌ها
make deploy-gcorp
make deploy-journa
make deploy-cardiani
make deploy-zeteb

# یا همه با هم
make deploy
```

### دیپلوی Observability Stack

```bash
# نصب کامل Monitoring & Logging
make observability
```

این شامل:
- **Elasticsearch**: ذخیره و جستجوی لاگ‌ها
- **Kibana**: Visualization لاگ‌ها
- **Prometheus**: جمع‌آوری Metrics
- **Grafana**: Dashboard ها و نمایش Metrics
- **Loki**: Log Aggregation
- **Fluent Bit**: جمع‌آوری لاگ از تمام Pods

### دیپلوی Automation

```bash
# نصب n8n
make automation
```

---

## 📊 مانیتورینگ و Observability

### دسترسی به Dashboard ها

#### Grafana
```
URL: http://grafana.local
Username: admin
Password: admin
```

**Dashboard های پیش‌فرض**:
1. Kubernetes Cluster Overview
2. ScyllaDB Monitoring
3. Redis Monitoring
4. Application Metrics

#### Kibana
```
URL: http://kibana.local
```

**قابلیت‌ها**:
- جستجوی لاگ‌ها با Elasticsearch Query
- فیلتر بر اساس namespace, pod, container
- ایجاد Visualization و Dashboard

### مانیتورینگ ScyllaDB

#### Metrics مهم:
```
# Query در Prometheus/Grafana
scylla_database_total_writes_rate
scylla_database_total_reads_rate
scylla_storage_load_bytes
scylla_transport_requests_served
```

#### Dashboard ScyllaDB:
1. Read/Write Throughput
2. Latency Percentiles (p50, p95, p99)
3. Storage Usage
4. Compaction Stats

### مانیتورینگ Redis

#### Metrics مهم:
```
redis_connected_clients
redis_memory_used_bytes
redis_commands_processed_total
redis_keyspace_hits_total
redis_keyspace_misses_total
```

---

## 🤖 اتوماسیون با n8n

### دسترسی به n8n
```
URL: http://n8n.local
```

### Workflow های پیشنهادی

#### 1. Cache Invalidation Workflow
```yaml
Trigger: Webhook از Backend
↓
Check Site Name
↓
Connect to Site Redis
↓
Clear Cache Keys
↓
Send Notification
```

#### 2. Database Backup Workflow
```yaml
Trigger: Schedule (روزانه 3 صبح)
↓
Loop Through Sites
↓
ScyllaDB Snapshot
↓
Upload to Storage
↓
Send Success Report
```

#### 3. Log Alert Workflow
```yaml
Trigger: Elasticsearch Query
↓
Check Error Count
↓
If > Threshold
↓
Send Alert (Slack/Email)
```

### Environment Variables در n8n

تمام URL های سرویس‌ها به صورت خودکار در n8n تنظیم شده:

```javascript
// در Workflow ها می‌توانید استفاده کنید:
{{$env.GCORP_BACKEND_URL}}
{{$env.JOURNA_REDIS_URL}}
{{$env.ELASTICSEARCH_URL}}
{{$env.GRAFANA_URL}}
```

---

## 🔍 عیب‌یابی

### بررسی وضعیت کلی

```bash
# نمای کلی
make status

# لاگ‌های اخیر
make logs

# مصرف منابع
make metrics
```

### مشکلات رایج

#### 1. Pod در حالت Pending
```bash
# بررسی Events
kubectl describe pod <pod-name> -n <namespace>

# بررسی PVC
kubectl get pvc -A
```

**راه‌حل**: معمولاً مشکل Storage است. در Docker Desktop باید StorageClass را بررسی کنید.

#### 2. Ingress کار نمی‌کند
```bash
# بررسی Ingress Controller
kubectl get pods -n ingress-nginx
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller

# بررسی Ingress Rules
kubectl get ingress -A
```

**راه‌حل**: 
- مطمئن شوید فایل hosts تنظیم شده
- Port 80 و 443 آزاد باشند

#### 3. ScyllaDB Ready نمی‌شود
```bash
# لاگ ScyllaDB
kubectl logs -n <namespace> statefulset/scylla

# بررسی Resources
kubectl describe statefulset scylla -n <namespace>
```

**راه‌حل**:
- ScyllaDB نیاز به RAM زیاد دارد (حداقل 2GB per pod)
- زمان startup طولانی است (2-3 دقیقه)

#### 4. Elasticsearch CrashLoopBackOff
```bash
# لاگ Elasticsearch
kubectl logs -n observability statefulset/elasticsearch
```

**راه‌حل رایج**:
```bash
# در Linux/Mac نیاز به تنظیم vm.max_map_count
# روی Docker Desktop معمولاً نیاز نیست
sysctl -w vm.max_map_count=262144
```

### Debug کردن یک Site خاص

```bash
# مثال: journa
kubectl get all -n journa
kubectl describe pod <pod-name> -n journa
kubectl logs <pod-name> -n journa --tail=100 -f
```

### Restart کردن Services

```bash
# Restart همه pods یک site
kubectl rollout restart deployment -n journa

# یا با Makefile
make restart-site
# سپس نام site را وارد کنید: journa
```

---

## 🔐 امنیت (Production)

### تغییر Secrets

```bash
# ویرایش secrets
kubectl edit secret backend-secret -n <namespace>
kubectl edit secret frontend-secret -n <namespace>
```

### مقادیر مهم برای Production:
```yaml
# k8s/base/secrets.yaml
JWT_SECRET: "<generated-secret-256bit>"
SCYLLA_PASSWORD: "<strong-password>"
N8N_ENCRYPTION_KEY: "<generated-key>"
```

### TLS/SSL

برای production باید Cert-Manager و Let's Encrypt اضافه شود:

```bash
# نصب cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml
```

---

## 📈 Scaling

### Horizontal Scaling

```bash
# Scale کردن Frontend
kubectl scale deployment frontend --replicas=3 -n gcorp

# Scale کردن Backend
kubectl scale deployment backend --replicas=3 -n gcorp
```

### Vertical Scaling

ویرایش resource limits در patch files:

```yaml
resources:
  requests:
    memory: "1Gi"
    cpu: "1000m"
  limits:
    memory: "2Gi"
    cpu: "2000m"
```

---

## 🚀 انتقال به VPS/Production

### تفاوت‌های کلیدی:

1. **Storage**: تغییر از local به distributed storage (Ceph, Longhorn)
2. **Ingress**: استفاده از Load Balancer واقعی
3. **TLS**: فعال کردن cert-manager
4. **Backup**: تنظیم backup خودکار
5. **Monitoring**: اضافه کردن Alertmanager

### Checklist انتقال:

- [ ] تنظیم DNS records
- [ ] نصب cluster با kubeadm/k3s
- [ ] نصب storage provisioner
- [ ] تنظیم TLS certificates
- [ ] تغییر image registry (DockerHub/Harbor)
- [ ] تنظیم backup و disaster recovery
- [ ] تست load testing

---

## 📞 پشتیبانی

برای مشکلات و سوالات:
1. بررسی logs با `make logs`
2. بررسی status با `make status`
3. مشاهده documentation Kubernetes
4. بررسی logs مربوط به هر service

---

## 🎯 بهترین Practice ها

1. **همیشه از namespace های جدا استفاده کنید**
2. **Resource limits را تنظیم کنید**
3. **Monitoring را از ابتدا فعال کنید**
4. **Backup منظم بگیرید**
5. **Secrets را ایمن نگه دارید**
6. **Logging را centralized کنید**
7. **Health checks تنظیم کنید**

---

تاریخ به‌روزرسانی: {{ DATE }}
نسخه: 2.0
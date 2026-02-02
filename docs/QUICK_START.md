# 🚀 راهنمای سریع - Multi-Site Platform

## 📦 نصب سریع (Quick Start)

### گام 1: پیش‌نیازها
```bash
# بررسی Docker
docker --version
docker-compose --version

# بررسی Kubernetes (برای production)
kubectl version --client
```

### گام 2: کلون پروژه
```bash
git clone <repository-url>
cd multi-site-platform
```

### گام 3: تنظیم محیط توسعه

#### با Docker Compose (توصیه می‌شود برای Development)
```bash
# کپی فایل docker-compose بهبود یافته
cp docker-compose-complete.yml local/docker-compose.yml

# کپی فایل‌های configuration
cp local/*.yml local/
cp local/*.yaml local/

# راه‌اندازی
cd local
docker-compose up -d

# بررسی وضعیت
docker-compose ps
```

#### با Kubernetes (برای Production)
```bash
# استفاده از Makefile بهبود یافته
cp Makefile-improved Makefile

# راه‌اندازی کامل
make setup-all

# یا قدم به قدم
make init          # Initialize cluster
make build         # Build images
make deploy        # Deploy sites
make observability # Deploy monitoring
make automation    # Deploy n8n
```

---

## 🌐 دسترسی به سرویس‌ها

### تنظیم فایل hosts

#### Windows
```powershell
# اجرا با Administrator
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

### URL های دسترسی

#### سایت‌ها (با Kubernetes):
- 🌐 http://gcorp.local - سایت gcorp
- 🌐 http://journa.local - سایت journa
- 🌐 http://cardiani.local - سایت cardiani
- 🌐 http://zeteb.local - سایت zeteb

#### سایت‌ها (با Docker Compose):
- 🌐 http://localhost:3001 - gcorp frontend
- 🌐 http://localhost:3002 - journa frontend
- 🌐 http://localhost:3003 - cardiani frontend
- 🌐 http://localhost:3004 - zeteb frontend

#### مانیتورینگ:
- 📊 http://grafana.local:3000 (admin/admin)
- 📈 http://localhost:9090 - Prometheus
- 🔍 http://kibana.local:5601 - Kibana
- 🗃️ http://localhost:9200 - Elasticsearch

#### اتوماسیون:
- 🤖 http://n8n.local:5678 - n8n Workflows

#### ابزارها:
- 💾 http://localhost:8081 - Redis Commander

---

## 🔧 دستورات مفید

### با Makefile

```bash
# نمایش راهنما
make help

# دیپلوی
make deploy              # همه سایت‌ها
make deploy-gcorp        # فقط gcorp
make deploy-journa       # فقط journa

# مانیتورینگ
make observability       # نصب stack مانیتورینگ
make automation          # نصب n8n
make status              # وضعیت cluster
make logs                # نمایش لاگ‌ها
make metrics             # مصرف منابع

# حذف
make destroy             # حذف سایت‌ها
make destroy-observability  # حذف مانیتورینگ
make destroy-all         # حذف همه چیز

# Development
make dev-up              # شروع محیط development
make dev-down            # توقف محیط development
make dev-logs            # لاگ‌های development
```

### با Docker Compose

```bash
cd local

# شروع همه سرویس‌ها
docker-compose up -d

# شروع سرویس خاص
docker-compose up -d gcorp-frontend gcorp-backend

# توقف
docker-compose stop

# حذف
docker-compose down

# حذف با volumes
docker-compose down -v

# لاگ‌ها
docker-compose logs -f
docker-compose logs -f gcorp-backend

# Restart سرویس
docker-compose restart gcorp-backend

# Rebuild
docker-compose build
docker-compose up -d --build
```

### با Kubectl

```bash
# نمایش pods
kubectl get pods -A
kubectl get pods -n gcorp

# نمایش services
kubectl get svc -A

# نمایش ingress
kubectl get ingress -A

# لاگ‌ها
kubectl logs -n gcorp deployment/frontend
kubectl logs -n gcorp deployment/backend -f

# توضیحات pod
kubectl describe pod <pod-name> -n gcorp

# اجرای دستور در pod
kubectl exec -it <pod-name> -n gcorp -- /bin/sh

# Port forwarding
kubectl port-forward -n gcorp svc/frontend 3000:3000

# Scale کردن
kubectl scale deployment frontend --replicas=3 -n gcorp

# Restart
kubectl rollout restart deployment frontend -n gcorp
```

---

## 🐛 عیب‌یابی سریع

### مشکل: Pod در حالت Pending

```bash
# بررسی Events
kubectl describe pod <pod-name> -n <namespace>

# بررسی node resources
kubectl describe nodes

# بررسی PVC
kubectl get pvc -A
```

### مشکل: Container Crash

```bash
# دیدن لاگ‌های قبلی
kubectl logs <pod-name> -n <namespace> --previous

# بررسی وضعیت
kubectl describe pod <pod-name> -n <namespace>
```

### مشکل: Ingress کار نمی‌کند

```bash
# بررسی ingress controller
kubectl get pods -n ingress-nginx
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller

# بررسی ingress rules
kubectl get ingress -A
kubectl describe ingress <ingress-name> -n <namespace>
```

### مشکل: Database Connection

```bash
# تست اتصال Redis
kubectl exec -it <pod-name> -n <namespace> -- redis-cli -h redis ping

# تست اتصال ScyllaDB
kubectl exec -it <pod-name> -n <namespace> -- cqlsh scylla

# یا با Docker Compose
docker-compose exec gcorp-redis redis-cli ping
docker-compose exec gcorp-scylla cqlsh
```

### مشکل: Out of Memory

```bash
# بررسی مصرف منابع
kubectl top nodes
kubectl top pods -A

# با Docker
docker stats

# افزایش resource limits در deployment
```

---

## 📊 Grafana Dashboards

### Dashboard های آماده

1. **Kubernetes Overview**
   - CPU/Memory usage
   - Pod status
   - Network I/O

2. **ScyllaDB Monitoring**
   - Read/Write throughput
   - Latency percentiles
   - Storage usage
   - Compaction stats

3. **Redis Monitoring**
   - Connected clients
   - Memory usage
   - Commands/sec
   - Hit rate

4. **Application Metrics**
   - Request rate
   - Error rate
   - Response time
   - Active connections

### ایجاد Custom Dashboard

1. ورود به Grafana: http://grafana.local:3000
2. Username: `admin`, Password: `admin`
3. کلیک روی `+` → `Dashboard`
4. Add Panel
5. انتخاب Data Source (Prometheus/Loki)
6. Query:
   ```promql
   # مثال: Request rate
   rate(http_requests_total[5m])
   
   # مثال: CPU usage
   container_cpu_usage_seconds_total
   
   # مثال: Memory usage
   container_memory_usage_bytes
   ```

---

## 🤖 n8n Workflows

### Workflow های پیشنهادی

#### 1. Auto Backup
```
Trigger: Schedule (هر شب 3 صبح)
↓
Loop: برای هر سایت
↓
ScyllaDB: ایجاد snapshot
↓
Upload: به S3/MinIO
↓
Notification: ارسال گزارش
```

#### 2. Cache Clear on Deploy
```
Trigger: Webhook از CI/CD
↓
Parse: شناسایی site name
↓
Redis: اتصال به Redis سایت مربوطه
↓
Command: FLUSHALL
↓
Response: تایید موفقیت
```

#### 3. Error Alert
```
Trigger: Schedule (هر 5 دقیقه)
↓
Elasticsearch: Query برای errors
↓
If: تعداد error > threshold
↓
Send: پیام به Slack/Email
```

### دسترسی به Environment Variables در n8n

```javascript
// در Function nodes:
const gcorpBackend = $env.GCORP_BACKEND_URL;
const elasticsearch = $env.ELASTICSEARCH_URL;

// HTTP Request به backend
return {
  url: `${gcorpBackend}/api/health`,
  method: 'GET'
};
```

---

## 📈 Performance Tuning

### ScyllaDB

```yaml
# افزایش SMP
command: --smp 4

# افزایش Memory
command: --memory 4G

# Tuning برای SSD
--io-properties-file=/etc/scylla.d/io_properties.yaml
```

### Redis

```conf
# در redis.conf
maxmemory 512mb
maxmemory-policy allkeys-lru
save ""  # Disable RDB
appendonly yes  # Enable AOF
```

### Next.js

```javascript
// next.config.js
module.exports = {
  compress: true,
  poweredByHeader: false,
  reactStrictMode: true,
  swcMinify: true,
}
```

---

## 🔐 Security Checklist

- [ ] تغییر passwords پیش‌فرض
- [ ] تنظیم JWT secrets
- [ ] فعال کردن HTTPS (cert-manager)
- [ ] محدود کردن Network Policies
- [ ] تنظیم RBAC
- [ ] فعال کردن Pod Security Standards
- [ ] Scan کردن images برای vulnerabilities
- [ ] Backup منظم
- [ ] Log retention policy
- [ ] Monitoring alerts

---

## 📚 مستندات بیشتر

- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) - راهنمای کامل دیپلوی
- [ISSUES_AND_FIXES.md](ISSUES_AND_FIXES.md) - مشکلات و راه‌حل‌ها
- [IMPROVED_STRUCTURE.md](IMPROVED_STRUCTURE.md) - معماری جدید

---

## 💡 نکات مهم

1. **همیشه از namespace های جداگانه استفاده کنید**
2. **Resource limits را تنظیم کنید**
3. **Health checks را پیاده‌سازی کنید**
4. **Monitoring را از ابتدا فعال کنید**
5. **Backup منظم بگیرید**
6. **Documentation را به‌روز نگه دارید**

---

تاریخ به‌روزرسانی: {{ DATE }}
نسخه: 2.0
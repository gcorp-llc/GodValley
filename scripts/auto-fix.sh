#!/bin/bash

# ========================================
# اسکریپت اعمال خودکار تغییرات
# ========================================

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "======================================"
echo "Multi-Site Platform - Auto Fix Script"
echo "======================================"
echo ""

# رنگ‌ها برای output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# تابع برای نمایش پیام‌ها
info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# بررسی وجود kubectl
if ! command -v kubectl &> /dev/null; then
    error "kubectl not found. Please install kubectl first."
    exit 1
fi

# بررسی وجود دایرکتوری k8s
if [ ! -d "$PROJECT_ROOT/k8s" ]; then
    error "k8s directory not found in $PROJECT_ROOT"
    exit 1
fi

echo "Project root: $PROJECT_ROOT"
echo ""

# ========================================
# مرحله 1: پشتیبان‌گیری
# ========================================

info "Step 1: Creating backup..."

BACKUP_DIR="$PROJECT_ROOT/backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

if [ -d "$PROJECT_ROOT/k8s" ]; then
    cp -r "$PROJECT_ROOT/k8s" "$BACKUP_DIR/"
    info "✓ k8s directory backed up to $BACKUP_DIR"
fi

if [ -f "$PROJECT_ROOT/Makefile" ]; then
    cp "$PROJECT_ROOT/Makefile" "$BACKUP_DIR/"
    info "✓ Makefile backed up"
fi

echo ""

# ========================================
# مرحله 2: اصلاح namespace ها
# ========================================

info "Step 2: Fixing namespaces..."

# journa
if [ -f "$PROJECT_ROOT/k8s/sites/journa/kustomization.yaml" ]; then
    sed -i 's/namespace: gcorp/namespace: journa/g' "$PROJECT_ROOT/k8s/sites/journa/kustomization.yaml"
    info "✓ Fixed journa namespace"
fi

# cardiani
if [ -f "$PROJECT_ROOT/k8s/sites/cardiani/kustomization.yaml" ]; then
    sed -i 's/namespace: gcorp/namespace: cardiani/g' "$PROJECT_ROOT/k8s/sites/cardiani/kustomization.yaml"
    info "✓ Fixed cardiani namespace"
fi

# zeteb
if [ -f "$PROJECT_ROOT/k8s/sites/zeteb/kustomization.yaml" ]; then
    sed -i 's/namespace: gcorp/namespace: zeteb/g' "$PROJECT_ROOT/k8s/sites/zeteb/kustomization.yaml"
    info "✓ Fixed zeteb namespace"
fi

echo ""

# ========================================
# مرحله 3: اصلاح Ingress ها
# ========================================

info "Step 3: Fixing ingress configurations..."

# Function to fix ingress
fix_ingress() {
    local site=$1
    local ingress_file="$PROJECT_ROOT/k8s/sites/$site/ingress.yaml"
    
    if [ -f "$ingress_file" ]; then
        cat > "$ingress_file" << EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ${site}-ingress
  namespace: ${site}
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  rules:
    - host: ${site}.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: frontend
                port:
                  number: 3000
EOF
        info "✓ Fixed $site ingress"
    fi
}

fix_ingress "journa"
fix_ingress "cardiani"
fix_ingress "zeteb"

echo ""

# ========================================
# مرحله 4: اصلاح Labels
# ========================================

info "Step 4: Fixing labels in patch files..."

# Function to fix labels
fix_labels() {
    local site=$1
    local patch_dir="$PROJECT_ROOT/k8s/sites/$site"
    
    for file in "$patch_dir"/*-patch.yaml; do
        if [ -f "$file" ]; then
            sed -i "s/site: gcorp/site: $site/g" "$file"
        fi
    done
    
    info "✓ Fixed $site labels"
}

fix_labels "journa"
fix_labels "cardiani"
fix_labels "zeteb"

echo ""

# ========================================
# مرحله 5: افزودن Health Checks
# ========================================

info "Step 5: Adding health checks..."

# Backend health checks
BACKEND_FILE="$PROJECT_ROOT/k8s/base/backend.yaml"
if [ -f "$BACKEND_FILE" ]; then
    # این باید manual اضافه شود چون structure پیچیده است
    warn "Backend health checks need manual addition - see ISSUES_AND_FIXES.md"
fi

# Frontend health checks
FRONTEND_FILE="$PROJECT_ROOT/k8s/base/frontend.yaml"
if [ -f "$FRONTEND_FILE" ]; then
    warn "Frontend health checks need manual addition - see ISSUES_AND_FIXES.md"
fi

echo ""

# ========================================
# مرحله 6: ایجاد دایرکتوری‌های جدید
# ========================================

info "Step 6: Creating new directories..."

mkdir -p "$PROJECT_ROOT/k8s/observability"
mkdir -p "$PROJECT_ROOT/k8s/automation"
mkdir -p "$PROJECT_ROOT/k8s/monitoring"

info "✓ Created observability directory"
info "✓ Created automation directory"
info "✓ Created monitoring directory"

echo ""

# ========================================
# مرحله 7: کپی فایل‌های جدید
# ========================================

info "Step 7: Copying new configuration files..."

# در اینجا باید فایل‌های جدید کپی شوند
# این قسمت بستگی به اینکه فایل‌ها کجا هستند دارد

warn "New configuration files should be copied manually from:"
echo "  - /home/claude/k8s/observability/"
echo "  - /home/claude/k8s/automation/"
echo "  - /home/claude/k8s/monitoring/"

echo ""

# ========================================
# مرحله 8: بررسی نهایی
# ========================================

info "Step 8: Running validation..."

# Validate kustomization files
for site in gcorp journa cardiani zeteb; do
    KUST_FILE="$PROJECT_ROOT/k8s/sites/$site/kustomization.yaml"
    if [ -f "$KUST_FILE" ]; then
        if kubectl kustomize "$PROJECT_ROOT/k8s/sites/$site" &> /dev/null; then
            info "✓ $site kustomization is valid"
        else
            error "✗ $site kustomization has errors"
        fi
    fi
done

echo ""

# ========================================
# خلاصه
# ========================================

echo "======================================"
echo "Fix Summary"
echo "======================================"
echo ""
echo "✅ Completed:"
echo "  - Backup created at: $BACKUP_DIR"
echo "  - Namespace configurations fixed"
echo "  - Ingress configurations fixed"
echo "  - Labels fixed"
echo "  - New directories created"
echo ""
echo "⚠️  Manual steps required:"
echo "  1. Add health checks to deployments (see ISSUES_AND_FIXES.md)"
echo "  2. Add resource limits (see ISSUES_AND_FIXES.md)"
echo "  3. Copy observability stack files"
echo "  4. Copy automation stack files"
echo "  5. Copy monitoring exporters"
echo "  6. Update Makefile"
echo ""
echo "📖 Documentation:"
echo "  - ISSUES_AND_FIXES.md - List of all issues and solutions"
echo "  - DEPLOYMENT_GUIDE.md - Complete deployment guide"
echo "  - IMPROVED_STRUCTURE.md - New architecture overview"
echo ""
echo "🚀 Next steps:"
echo "  1. Review changes: git diff"
echo "  2. Test deployment: make deploy"
echo "  3. Deploy observability: make observability"
echo "  4. Deploy automation: make automation"
echo ""

# ========================================
# تولید گزارش
# ========================================

REPORT_FILE="$PROJECT_ROOT/fix-report-$(date +%Y%m%d-%H%M%S).txt"

cat > "$REPORT_FILE" << EOF
Multi-Site Platform - Fix Report
Generated: $(date)
Backup Location: $BACKUP_DIR

Changes Applied:
================

1. Namespace Fixes:
   - journa: gcorp → journa
   - cardiani: gcorp → cardiani
   - zeteb: gcorp → zeteb

2. Ingress Fixes:
   - journa: gcorp-ingress → journa-ingress (host: journa.local)
   - cardiani: gcorp-ingress → cardiani-ingress (host: cardiani.local)
   - zeteb: gcorp-ingress → zeteb-ingress (host: zeteb.local)

3. Label Fixes:
   - All patches now use correct site labels

4. New Directories:
   - k8s/observability/ (Monitoring & Logging)
   - k8s/automation/ (n8n Workflows)
   - k8s/monitoring/ (Exporters)

Manual Steps Required:
======================
- Add health checks (liveness/readiness probes)
- Add resource limits (requests/limits)
- Configure ScyllaDB properly
- Setup persistent volumes for Redis
- Improve Ingress Controller configuration

Validation Results:
===================
EOF

# Add validation results to report
for site in gcorp journa cardiani zeteb; do
    if kubectl kustomize "$PROJECT_ROOT/k8s/sites/$site" &> /dev/null 2>&1; then
        echo "  ✓ $site: VALID" >> "$REPORT_FILE"
    else
        echo "  ✗ $site: ERRORS" >> "$REPORT_FILE"
    fi
done

info "Report saved to: $REPORT_FILE"

echo ""
info "Fix script completed successfully!"
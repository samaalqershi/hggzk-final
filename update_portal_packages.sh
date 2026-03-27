#!/bin/bash

# 🔄 سكريبت تحديث المكتبات للبورتالات
# Package Update Script for Portal Apps

set -e  # إيقاف عند أول خطأ

echo "🚀 بدء تحديث المكتبات في تطبيقات البورتال..."
echo "================================================"

# ألوان للطباعة
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# المسار الأساسي
BASE_DIR="/home/ameen/Desktop/BOOKIN/BOOKIN"

# دالة للطباعة الملونة
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

# دالة لتحديث مشروع واحد
update_project() {
    local project_name=$1
    local project_path="$BASE_DIR/$project_name"
    
    echo ""
    print_status "تحديث $project_name..."
    echo "----------------------------------------"
    
    if [ ! -d "$project_path" ]; then
        print_error "المشروع غير موجود: $project_path"
        return 1
    fi
    
    cd "$project_path"
    
    # 1. Flutter Clean
    print_status "تنظيف المشروع..."
    if flutter clean > /dev/null 2>&1; then
        print_success "تم تنظيف المشروع"
    else
        print_error "فشل تنظيف المشروع"
        return 1
    fi
    
    # 2. Flutter Pub Get
    print_status "تحميل المكتبات..."
    if flutter pub get; then
        print_success "تم تحميل المكتبات بنجاح"
    else
        print_error "فشل تحميل المكتبات"
        return 1
    fi
    
    # 3. Flutter Pub Upgrade (اختياري)
    read -p "$(echo -e ${YELLOW}هل تريد ترقية المكتبات إلى أحدث إصدار؟ [y/N]:${NC}) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "ترقية المكتبات..."
        if flutter pub upgrade; then
            print_success "تم ترقية المكتبات بنجاح"
        else
            print_warning "فشلت بعض الترقيات (قد يكون طبيعياً)"
        fi
    fi
    
    # 4. تنظيف Android
    if [ -d "android" ]; then
        print_status "تنظيف مشروع Android..."
        cd android
        if [ -f "gradlew" ]; then
            ./gradlew clean > /dev/null 2>&1 || print_warning "تحذير: مشكلة في تنظيف Gradle"
        fi
        cd ..
        print_success "تم تنظيف Android"
    fi
    
    # 5. تنظيف iOS
    if [ -d "ios" ]; then
        print_status "تنظيف مشروع iOS..."
        cd ios
        if [ -d "Pods" ]; then
            rm -rf Pods Podfile.lock
            print_success "تم حذف Pods القديمة"
        fi
        
        read -p "$(echo -e ${YELLOW}هل تريد إعادة تثبيت CocoaPods؟ [y/N]:${NC}) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_status "تثبيت CocoaPods..."
            if pod install; then
                print_success "تم تثبيت Pods بنجاح"
            else
                print_error "فشل تثبيت Pods"
            fi
        fi
        cd ..
    fi
    
    print_success "اكتمل تحديث $project_name ✅"
}

# البداية
echo ""
echo "📦 سيتم تحديث المشاريع التالية:"
echo "   1. hggzkportal_app"
echo "   2. rezmateportal_app"
echo ""

read -p "$(echo -e ${YELLOW}هل تريد المتابعة؟ [y/N]:${NC}) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "تم الإلغاء"
    exit 0
fi

# تحديث hggzkportal_app
update_project "hggzkportal_app"

# تحديث rezmateportal_app
update_project "rezmateportal_app"

# النهاية
echo ""
echo "================================================"
echo -e "${GREEN}🎉 تم الانتهاء من تحديث جميع المشاريع!${NC}"
echo ""
echo "📋 الخطوات التالية:"
echo "   1. اختبر التطبيقات للتأكد من عملها"
echo "   2. راجع التقرير: PACKAGES_UPDATE_REPORT.md"
echo "   3. تحقق من أي Breaking Changes في المكتبات"
echo ""
echo -e "${BLUE}للتشغيل:${NC}"
echo "   cd hggzkportal_app && flutter run"
echo "   cd rezmateportal_app && flutter run"
echo ""

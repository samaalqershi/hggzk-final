#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Script لتطبيق جميع تحسينات البحث والفلترة
# Apply All Search & Filter Optimizations
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -euo pipefail  # إيقاف عند أول خطأ مع ضبط المتغيرات والأنابيب

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
SQL_DIR="${ROOT_DIR}/hggzk.Infrastructure/SQL"

# الألوان
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# معلومات الاتصال بقاعدة البيانات
DB_USER="${DB_USER:-postgres}"
DB_NAME="${DB_NAME:-yemen_booking}"
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}   تطبيق تحسينات البحث والفلترة${NC}"
echo -e "${BLUE}   Applying Search & Filter Optimizations${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# التحقق من الاتصال
echo -e "${YELLOW}🔍 التحقق من الاتصال بقاعدة البيانات...${NC}"
if ! psql -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" -d "$DB_NAME" -c "SELECT 1" > /dev/null 2>&1; then
    echo -e "${RED}❌ فشل الاتصال بقاعدة البيانات${NC}"
    echo -e "${RED}   تأكد من: DB_USER, DB_NAME, DB_HOST, DB_PORT${NC}"
    exit 1
fi
echo -e "${GREEN}✅ الاتصال ناجح${NC}"
echo ""

# التحقق من PostGIS
echo -e "${YELLOW}🔍 التحقق من PostGIS Extension...${NC}"
psql -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" -d "$DB_NAME" <<SQL
    CREATE EXTENSION IF NOT EXISTS postgis;
    CREATE EXTENSION IF NOT EXISTS postgis_topology;
    CREATE EXTENSION IF NOT EXISTS pg_trgm;
SQL
echo -e "${GREEN}✅ PostGIS جاهز${NC}"
echo ""

# المرحلة 1: الدوال الأساسية
echo -e "${BLUE}━━━ المرحلة 1: تطبيق الدوال الأساسية ━━━${NC}"
echo -e "${YELLOW}📝 تطبيق Functions/01_SearchFunctions.sql...${NC}"
psql -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" -d "$DB_NAME" -f "${SQL_DIR}/Functions/01_SearchFunctions.sql"
echo -e "${GREEN}✅ تم تطبيق الدوال الأساسية${NC}"
echo ""

# المرحلة 2: الدوال المتقدمة
echo -e "${BLUE}━━━ المرحلة 2: تطبيق الدوال المتقدمة ━━━${NC}"
echo -e "${YELLOW}📝 تطبيق Functions/02_ComprehensiveSearchFunction.sql...${NC}"
psql -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" -d "$DB_NAME" -f "${SQL_DIR}/Functions/02_ComprehensiveSearchFunction.sql"
echo -e "${GREEN}✅ تم تطبيق دالة البحث الشاملة${NC}"
echo ""

echo -e "${YELLOW}📝 تطبيق Functions/03_AdvancedSearchFunctions.sql...${NC}"
psql -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" -d "$DB_NAME" -f "${SQL_DIR}/Functions/03_AdvancedSearchFunctions.sql"
echo -e "${GREEN}✅ تم تطبيق دوال البحث المتقدمة${NC}"
echo ""

# المرحلة 3: Indexes
echo -e "${BLUE}━━━ المرحلة 3: إنشاء Indexes محسّنة ━━━${NC}"
echo -e "${YELLOW}📝 تطبيق Indexes/01_SearchIndexes.sql...${NC}"
psql -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" -d "$DB_NAME" -f "${SQL_DIR}/Indexes/01_SearchIndexes.sql"
echo -e "${GREEN}✅ تم إنشاء جميع الـ Indexes${NC}"
echo ""

# المرحلة 4: Materialized Views
echo -e "${BLUE}━━━ المرحلة 4: إنشاء Materialized Views ━━━${NC}"
echo -e "${YELLOW}📝 تطبيق Views/01_SearchableUnitsView.sql...${NC}"
psql -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" -d "$DB_NAME" -f "${SQL_DIR}/Views/01_SearchableUnitsView.sql"
echo -e "${GREEN}✅ تم إنشاء Materialized View${NC}"
echo ""

# التحقق من النتائج
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ اكتمل تطبيق جميع التحسينات بنجاح!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# عرض ملخص
echo -e "${YELLOW}📊 ملخص التحسينات:${NC}"
echo ""

# عدد الدوال
FUNCTION_COUNT=$(psql -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" -d "$DB_NAME" -t -c "
    SELECT COUNT(*)
    FROM pg_proc p
    INNER JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public'
      AND (
        p.proname LIKE '%search%'
        OR p.proname LIKE '%unit%'
        OR p.proname LIKE '%available%'
      );
" | xargs)
echo -e "  ${GREEN}✓${NC} دوال PostgreSQL: ${FUNCTION_COUNT}"

# عدد الـ Indexes
INDEX_COUNT=$(psql -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" -d "$DB_NAME" -t -c "
    SELECT COUNT(*) 
    FROM pg_indexes 
    WHERE schemaname = 'public' 
      AND indexname LIKE 'idx_%';
" | xargs)
echo -e "  ${GREEN}✓${NC} Database Indexes: ${INDEX_COUNT}"

# عدد الـ Views
VIEW_COUNT=$(psql -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" -d "$DB_NAME" -t -c "
    SELECT COUNT(*) 
    FROM pg_matviews 
    WHERE schemaname = 'public';
" | xargs)
echo -e "  ${GREEN}✓${NC} Materialized Views: ${VIEW_COUNT}"

echo ""
echo -e "${YELLOW}🧪 اختبار سريع:${NC}"
psql -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" -d "$DB_NAME" <<SQL
    \timing on
    SELECT 
        unit_name, 
        property_name, 
        city, 
        min_price,
        total_count
    FROM search_units_comprehensive(
        p_city := 'صنعاء',
        p_adults := 2,
        p_page_size := 10
    )
    LIMIT 5;
SQL

echo ""
echo -e "${GREEN}✅ كل شيء جاهز! يمكنك الآن استخدام نظام البحث المحسّن.${NC}"
echo ""

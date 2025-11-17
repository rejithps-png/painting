#!/bin/bash

# Simple Database Export Script
# Exports your local PostgreSQL database for cloud hosting

echo "🗄️  Database Export Tool"
echo "================================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if PostgreSQL is running
if ! command -v pg_dump &> /dev/null; then
    echo -e "${RED}Error: pg_dump not found. Is PostgreSQL installed?${NC}"
    exit 1
fi

# Check if database exists
if ! psql -U postgres -lqt | cut -d \| -f 1 | grep -qw painting_auction; then
    echo -e "${RED}Error: painting_auction database not found${NC}"
    echo "Please create the database first."
    exit 1
fi

# Create exports directory
EXPORT_DIR="database_exports"
mkdir -p $EXPORT_DIR

TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "Choose export option:"
echo "1) Schema only (for fresh deployment)"
echo "2) Schema + Data (full backup)"
echo "3) Use existing schema.sql file"
echo "4) Export specific data (CSV)"
echo "5) Complete export package"
echo ""
read -p "Enter choice (1-5): " choice

case $choice in
    1)
        echo ""
        echo "📄 Exporting schema only..."
        pg_dump -U postgres \
            --schema-only \
            --no-owner \
            --no-privileges \
            painting_auction > "$EXPORT_DIR/schema_$TIMESTAMP.sql"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Schema exported successfully!${NC}"
            echo "File: $EXPORT_DIR/schema_$TIMESTAMP.sql"
        else
            echo -e "${RED}❌ Export failed${NC}"
            exit 1
        fi
        ;;
        
    2)
        echo ""
        echo "💾 Exporting schema + data..."
        pg_dump -U postgres \
            --clean \
            --if-exists \
            --no-owner \
            --no-privileges \
            painting_auction > "$EXPORT_DIR/full_backup_$TIMESTAMP.sql"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Full backup exported successfully!${NC}"
            echo "File: $EXPORT_DIR/full_backup_$TIMESTAMP.sql"
        else
            echo -e "${RED}❌ Export failed${NC}"
            exit 1
        fi
        ;;
        
    3)
        echo ""
        if [ -f "database/schema.sql" ]; then
            echo -e "${GREEN}✅ Using existing schema.sql${NC}"
            echo ""
            echo "File location: database/schema.sql"
            echo ""
            echo "To use in Supabase:"
            echo "1. Open Supabase SQL Editor"
            echo "2. Copy contents from: database/schema.sql"
            echo "3. Paste and click Run"
        else
            echo -e "${RED}❌ schema.sql not found in database/ directory${NC}"
            echo "Exporting fresh schema instead..."
            pg_dump -U postgres \
                --schema-only \
                --no-owner \
                --no-privileges \
                painting_auction > "$EXPORT_DIR/schema_$TIMESTAMP.sql"
            echo -e "${GREEN}✅ Schema exported to: $EXPORT_DIR/schema_$TIMESTAMP.sql${NC}"
        fi
        ;;
        
    4)
        echo ""
        echo "📊 Exporting data as CSV..."
        
        # Export each table
        tables=("users" "paintings" "bids" "admins" "auction_settings")
        
        for table in "${tables[@]}"; do
            echo "Exporting $table..."
            psql -U postgres -d painting_auction -c \
                "COPY $table TO STDOUT WITH CSV HEADER" > "$EXPORT_DIR/${table}_$TIMESTAMP.csv" 2>/dev/null
            
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✓${NC} $table exported"
            else
                echo -e "${YELLOW}⚠${NC} $table empty or not found"
            fi
        done
        
        echo ""
        echo -e "${GREEN}✅ CSV files exported to: $EXPORT_DIR/${NC}"
        ;;
        
    5)
        echo ""
        echo "📦 Creating complete export package..."
        
        # Schema
        echo "1/4 Exporting schema..."
        pg_dump -U postgres \
            --schema-only \
            --no-owner \
            --no-privileges \
            painting_auction > "$EXPORT_DIR/schema_$TIMESTAMP.sql"
        
        # Full backup
        echo "2/4 Exporting full backup..."
        pg_dump -U postgres \
            --clean \
            --if-exists \
            --no-owner \
            --no-privileges \
            painting_auction > "$EXPORT_DIR/full_backup_$TIMESTAMP.sql"
        
        # CSV exports
        echo "3/4 Exporting CSV files..."
        tables=("users" "paintings" "bids" "admins" "auction_settings")
        for table in "${tables[@]}"; do
            psql -U postgres -d painting_auction -c \
                "COPY $table TO STDOUT WITH CSV HEADER" > "$EXPORT_DIR/${table}_$TIMESTAMP.csv" 2>/dev/null
        done
        
        # Statistics
        echo "4/4 Creating statistics report..."
        psql -U postgres -d painting_auction > "$EXPORT_DIR/stats_$TIMESTAMP.txt" << 'EOF'
\echo '=== DATABASE STATISTICS ==='
\echo ''
\echo 'Tables:'
\dt
\echo ''
\echo 'Row Counts:'
SELECT 'users' as table, COUNT(*) as rows FROM users
UNION ALL SELECT 'paintings', COUNT(*) FROM paintings
UNION ALL SELECT 'bids', COUNT(*) FROM bids
UNION ALL SELECT 'admins', COUNT(*) FROM admins
UNION ALL SELECT 'auction_settings', COUNT(*) FROM auction_settings;
EOF
        
        echo ""
        echo -e "${GREEN}✅ Complete package exported!${NC}"
        echo ""
        echo "Files created:"
        ls -lh $EXPORT_DIR/*$TIMESTAMP*
        ;;
        
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
echo "================================"
echo -e "${GREEN}Export Complete!${NC}"
echo ""
echo "📂 Exported files location: $EXPORT_DIR/"
echo ""
echo "Next steps:"
echo "1. Go to Supabase Dashboard"
echo "2. Open SQL Editor"
echo "3. Upload your exported SQL file"
echo "4. Click 'Run'"
echo ""
echo "📖 See FREE_HOSTING_GUIDE.md for detailed deployment steps"

#!/bin/bash

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  Student Painting Auction - Setup Script  ${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js is not installed. Please install Node.js v18 or higher.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Node.js found: $(node --version)${NC}"

# Check if PostgreSQL is installed
if ! command -v psql &> /dev/null; then
    echo -e "${RED}❌ PostgreSQL is not installed. Please install PostgreSQL.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ PostgreSQL found${NC}"
echo ""

# Database Setup
echo -e "${YELLOW}Setting up database...${NC}"
read -p "Enter PostgreSQL username (default: postgres): " DB_USER
DB_USER=${DB_USER:-postgres}

read -p "Enter PostgreSQL password: " -s DB_PASSWORD
echo ""

read -p "Enter database name (default: painting_auction): " DB_NAME
DB_NAME=${DB_NAME:-painting_auction}

# Create database
echo -e "${YELLOW}Creating database...${NC}"
PGPASSWORD=$DB_PASSWORD psql -U $DB_USER -c "CREATE DATABASE $DB_NAME;" 2>/dev/null || echo "Database may already exist"

# Import schema
echo -e "${YELLOW}Importing database schema...${NC}"
PGPASSWORD=$DB_PASSWORD psql -U $DB_USER -d $DB_NAME -f database/schema.sql

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Database setup complete${NC}"
else
    echo -e "${RED}❌ Database setup failed${NC}"
    exit 1
fi

# Backend Setup
echo ""
echo -e "${YELLOW}Setting up backend...${NC}"
cd backend

# Install dependencies
echo -e "${YELLOW}Installing backend dependencies...${NC}"
npm install

# Create .env file
echo -e "${YELLOW}Creating backend .env file...${NC}"
cat > .env << EOF
DB_HOST=localhost
DB_PORT=5432
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD

PORT=5000
NODE_ENV=development

JWT_SECRET=$(openssl rand -base64 32)
JWT_EXPIRES_IN=7d

CORS_ORIGIN=http://localhost:3000
FRONTEND_URL=http://localhost:3000
EOF

echo -e "${GREEN}✓ Backend setup complete${NC}"

# Frontend Setup
cd ../frontend
echo ""
echo -e "${YELLOW}Setting up frontend...${NC}"

# Install dependencies
echo -e "${YELLOW}Installing frontend dependencies...${NC}"
npm install

# Create .env file
echo -e "${YELLOW}Creating frontend .env file...${NC}"
cat > .env << EOF
REACT_APP_API_URL=http://localhost:5000/api
REACT_APP_FRONTEND_URL=http://localhost:3000
EOF

echo -e "${GREEN}✓ Frontend setup complete${NC}"

cd ..

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  Setup Complete! 🎉${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo ""
echo "1. Start the backend:"
echo "   cd backend && npm start"
echo ""
echo "2. Start the frontend (in a new terminal):"
echo "   cd frontend && npm start"
echo ""
echo -e "${YELLOW}Access URLs:${NC}"
echo "   Frontend: http://localhost:3000"
echo "   Backend API: http://localhost:5000"
echo "   Admin Panel: http://localhost:3000/admin/login"
echo ""
echo -e "${YELLOW}Default Admin Credentials:${NC}"
echo "   Username: admin"
echo "   Password: Admin@123"
echo ""
echo -e "${RED}⚠️  IMPORTANT: Change the admin password after first login!${NC}"
echo ""

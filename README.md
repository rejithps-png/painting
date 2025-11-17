# 🎨 Student Painting Auction System

A secure, professional, mobile-first web application for conducting online auctions of student paintings at college events.

## ✨ Features

- **QR Code Integration** - Instant access to paintings via printed QR codes
- **User-Friendly Bidding** - Simple registration and real-time bidding
- **Admin Dashboard** - Complete painting and bid management
- **Mobile Responsive** - Optimized for smartphone scanning
- **Enterprise Security** - JWT authentication, bcrypt encryption, input validation
- **Professional UI** - Modern design with Tailwind CSS

## 🚀 Quick Start

### Automated Setup (Recommended)

```bash
chmod +x setup.sh
./setup.sh
```

Follow the prompts to configure database and install dependencies.

### Manual Setup

#### 1. Database Setup
```bash
# Create database
psql -U postgres -c "CREATE DATABASE painting_auction;"

# Import schema
psql -U postgres -d painting_auction -f database/schema.sql
```

#### 2. Backend Setup
```bash
cd backend
npm install
cp .env.example .env
# Edit .env with your configuration
npm start
```

#### 3. Frontend Setup
```bash
cd frontend
npm install
cp .env.example .env
# Edit .env with your configuration
npm start
```

## 📱 Access URLs

- **Frontend**: http://localhost:3000
- **API**: http://localhost:5000
- **Admin Panel**: http://localhost:3000/admin/login

## 🔐 Default Admin Credentials

```
Username: admin
Password: Admin@123
```

⚠️ **Change these immediately after first login!**

## 📋 Requirements

- Node.js v18+
- PostgreSQL 14+
- npm or yarn

## 📚 Documentation

Complete documentation available in `/docs/README.md` including:
- Installation guide
- API endpoints
- Security features
- Deployment instructions
- Troubleshooting

## 🏗️ Technology Stack

**Backend**: Node.js, Express.js, PostgreSQL, JWT, bcrypt
**Frontend**: React 18, Tailwind CSS, Axios, React Router

## 📊 Application Flow

### For Users
1. Scan QR code near painting
2. Sign up/Login
3. Place bid
4. Track bid status and ranking

### For Admins
1. Login to admin panel
2. Add paintings and generate QR codes
3. Monitor bids in real-time
4. Configure auction dates

## 🔒 Security Features

- ✅ Bcrypt password hashing
- ✅ JWT authentication
- ✅ SQL injection prevention
- ✅ XSS protection
- ✅ Rate limiting
- ✅ Input validation
- ✅ Secure HTTP headers

## 📁 Project Structure

```
painting-auction/
├── backend/          # Express.js API server
├── frontend/         # React application
├── database/         # PostgreSQL schema
├── docs/            # Complete documentation
└── setup.sh         # Automated setup script
```

## 🎯 Use Case

Perfect for college anniversaries, art exhibitions, and student fundraising events where visitors can:
- Browse paintings at the venue
- Scan QR codes with their phones
- Place bids instantly
- Track their bidding status
- Pay at venue (Cash/Card/UPI)

## 🤝 Support

For issues or questions:
1. Check `/docs/README.md` for detailed documentation
2. Review error logs
3. Verify environment variables
4. Ensure PostgreSQL is running

## 📄 License

Educational project for college use.

---

**Created with ❤️ for student development through art**

*Support talented student artists while raising funds for educational programs*

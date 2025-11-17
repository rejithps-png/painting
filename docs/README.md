# Student Painting Auction System - Complete Documentation

## 📋 Project Overview

A secure, professional web application for conducting online auctions of student paintings at college anniversary events. The system enables students to showcase their artwork, allows visitors to place bids via QR codes, and provides administrators with comprehensive management tools.

## ✨ Key Features

### User Features
- **QR Code Scanning**: Quick access to paintings via printed QR codes
- **Easy Registration**: Simple signup with name, mobile, and password
- **Real-time Bidding**: Place bids with instant feedback
- **Bid Tracking**: View all your bids and current rankings
- **Mobile-First Design**: Optimized for smartphone scanning and bidding
- **Secure Authentication**: Password hashing with bcrypt

### Admin Features
- **Painting Management**: Add, edit, delete paintings
- **QR Code Generation**: Automatic QR code creation for printing
- **Bid Monitoring**: Real-time view of all bids and rankings
- **Auction Control**: Set start and end dates
- **Dashboard Statistics**: Overview of paintings, users, bids, and revenue
- **Image Upload Support**: Optional painting images

### Security Features
- ✅ Bcrypt password hashing (10 rounds)
- ✅ JWT authentication with secure tokens
- ✅ SQL injection prevention (parameterized queries)
- ✅ XSS protection (input sanitization)
- ✅ Rate limiting (prevent spam)
- ✅ CORS configuration
- ✅ Secure HTTP headers (helmet.js)
- ✅ Password strength validation
- ✅ Mobile number format validation

## 🏗️ Technology Stack

### Backend
- **Runtime**: Node.js v18+
- **Framework**: Express.js
- **Database**: PostgreSQL 14+
- **Authentication**: JWT (jsonwebtoken)
- **Password Security**: bcrypt
- **Security**: helmet, express-rate-limit, express-validator
- **QR Generation**: qrcode

### Frontend
- **Framework**: React 18
- **Routing**: React Router v6
- **Styling**: Tailwind CSS
- **HTTP Client**: Axios
- **Notifications**: react-hot-toast
- **Icons**: lucide-react

## 📁 Project Structure

```
painting-auction/
├── backend/
│   ├── config/
│   │   └── database.js          # PostgreSQL connection
│   ├── middleware/
│   │   ├── auth.js              # JWT authentication
│   │   └── validation.js         # Input validation
│   ├── routes/
│   │   ├── auth.js              # User authentication
│   │   ├── admin.js             # Admin operations
│   │   └── paintings.js          # Painting & bidding
│   ├── .env.example             # Environment variables template
│   ├── package.json
│   └── server.js                # Main server file
│
├── frontend/
│   ├── public/
│   │   └── index.html
│   ├── src/
│   │   ├── components/
│   │   │   └── Navbar.js
│   │   ├── context/
│   │   │   └── AuthContext.js
│   │   ├── pages/
│   │   │   ├── HomePage.js
│   │   │   ├── PaintingDetailPage.js
│   │   │   ├── UserLoginPage.js
│   │   │   ├── UserRegisterPage.js
│   │   │   ├── UserBidsPage.js
│   │   │   ├── AdminLoginPage.js
│   │   │   ├── AdminDashboard.js
│   │   │   ├── AdminPaintings.js
│   │   │   ├── AdminBids.js
│   │   │   └── AdminSettings.js
│   │   ├── services/
│   │   │   └── api.js
│   │   ├── App.js
│   │   ├── index.js
│   │   └── index.css
│   ├── .env.example
│   ├── package.json
│   └── tailwind.config.js
│
├── database/
│   └── schema.sql               # Database schema
└── docs/
    └── README.md                # This file
```

## 🚀 Installation & Setup

### Prerequisites
- Node.js v18 or higher
- PostgreSQL 14 or higher
- npm or yarn package manager

### Step 1: Database Setup

1. Install PostgreSQL and create a database:
```sql
CREATE DATABASE painting_auction;
```

2. Run the schema file:
```bash
psql -U postgres -d painting_auction -f database/schema.sql
```

3. Verify tables created:
```sql
\dt  # Lists all tables
```

### Step 2: Backend Setup

1. Navigate to backend directory:
```bash
cd backend
```

2. Install dependencies:
```bash
npm install
```

3. Create environment file:
```bash
cp .env.example .env
```

4. Edit `.env` with your configuration:
```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=painting_auction
DB_USER=postgres
DB_PASSWORD=your_postgres_password

PORT=5000
NODE_ENV=development

JWT_SECRET=change_this_to_a_random_32_character_string
JWT_EXPIRES_IN=7d

CORS_ORIGIN=http://localhost:3000
FRONTEND_URL=http://localhost:3000
```

5. Start the backend server:
```bash
npm start
# For development with auto-reload:
npm run dev
```

Backend will run on `http://localhost:5000`

### Step 3: Frontend Setup

1. Navigate to frontend directory:
```bash
cd frontend
```

2. Install dependencies:
```bash
npm install
```

3. Install Tailwind CSS and dependencies:
```bash
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p
```

4. Create environment file:
```bash
cp .env.example .env
```

5. Edit `.env`:
```env
REACT_APP_API_URL=http://localhost:5000/api
REACT_APP_FRONTEND_URL=http://localhost:3000
```

6. Start the frontend server:
```bash
npm start
```

Frontend will run on `http://localhost:3000`

## 👤 Default Admin Credentials

```
Username: admin
Password: Admin@123
```

**⚠️ IMPORTANT**: Change these credentials after first login!

## 📱 User Flow

### For Visitors (Bidders)

1. **Scan QR Code** near painting at the venue
2. **Redirected to painting page** showing:
   - Artist name
   - Painting name
   - Current highest bid
   - Total number of bidders
   - Your current rank (if logged in)
3. **Click "Bid Now"**
4. **Sign Up** (if new user):
   - First name, last name
   - Mobile number (10 digits)
   - Password (min 6 chars, uppercase, lowercase, number)
5. **Place Bid**:
   - Enter amount higher than current price
   - Submit bid
   - See your new rank instantly
6. **Track Bids**:
   - Visit "My Bids" page
   - Enter mobile number
   - View all bids with rankings

### For Administrators

1. **Login** at `/admin/login`
2. **Dashboard** shows:
   - Total paintings, users, bids
   - Total bid value
   - Quick action buttons
3. **Manage Paintings**:
   - Add new painting (artist, name, base price, image URL)
   - Generate QR code
   - Download QR code for printing
   - Edit or delete paintings
4. **View Bids**:
   - See all bids across paintings
   - View user details and rankings
   - Monitor bidding activity
5. **Configure Auction**:
   - Set start date/time
   - Set end date/time
   - Activate/deactivate auction

## 🔐 API Endpoints

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `GET /api/auth/check-mobile/:mobile` - Check mobile availability

### Admin Authentication
- `POST /api/admin/login` - Admin login

### Paintings (Public)
- `GET /api/paintings` - Get all active paintings
- `GET /api/paintings/:id` - Get single painting details

### Bidding (Authenticated)
- `POST /api/paintings/bid` - Place a bid
- `GET /api/paintings/user-bids?mobile=` - Get user's all bids

### Admin Management (Admin Only)
- `GET /api/admin/dashboard-stats` - Dashboard statistics
- `GET /api/admin/paintings` - Get all paintings
- `POST /api/admin/paintings` - Create painting
- `PUT /api/admin/paintings/:id` - Update painting
- `DELETE /api/admin/paintings/:id` - Delete painting
- `GET /api/admin/paintings/:id/qrcode` - Get QR code
- `GET /api/admin/bids` - Get all bids
- `GET /api/admin/auction-settings` - Get auction settings
- `PUT /api/admin/auction-settings` - Update auction settings

## 🎨 Design Features

### Mobile-First
- Responsive grid layouts
- Touch-friendly buttons
- Mobile-optimized forms
- Fast loading times
- No horizontal scrolling

### Professional UI
- Modern gradient backgrounds
- Card-based layouts
- Smooth animations
- Consistent color scheme
- Clear visual hierarchy
- Intuitive navigation

### Accessibility
- Semantic HTML
- ARIA labels
- Keyboard navigation
- High contrast colors
- Clear error messages

## 🔒 Security Best Practices

1. **Never commit `.env` files**
2. **Change default admin password immediately**
3. **Use strong JWT secret** (min 32 characters)
4. **Enable HTTPS in production**
5. **Set up PostgreSQL user with limited privileges**
6. **Regularly update dependencies**
7. **Enable rate limiting in production**
8. **Sanitize all user inputs**
9. **Use environment variables for secrets**
10. **Implement backup strategy for database**

## 📦 Deployment

### Backend Deployment (Example: Heroku/Railway/Render)

1. Set environment variables
2. Configure PostgreSQL database
3. Build command: `npm install`
4. Start command: `npm start`
5. Set PORT from environment

### Frontend Deployment (Example: Netlify/Vercel)

1. Build command: `npm run build`
2. Publish directory: `build`
3. Set environment variables
4. Configure redirects for React Router

### Database Deployment

1. Use managed PostgreSQL (AWS RDS, DigitalOcean, etc.)
2. Run schema.sql on production database
3. Set up automated backups
4. Configure connection pooling

## 🧪 Testing

### Manual Testing Checklist

#### User Flow
- [ ] Scan QR code redirects correctly
- [ ] Registration works with valid data
- [ ] Login works with correct credentials
- [ ] Can place bid when authenticated
- [ ] Bid amount validation works
- [ ] Rank updates after bidding
- [ ] "My Bids" shows correct data
- [ ] Mobile number search works

#### Admin Flow
- [ ] Admin login works
- [ ] Dashboard shows correct stats
- [ ] Can add painting
- [ ] QR code generates correctly
- [ ] Can edit/delete painting
- [ ] Bids list shows all data
- [ ] Auction settings update correctly

#### Security
- [ ] Cannot access admin routes without token
- [ ] Cannot place bid without login
- [ ] Password validation enforces rules
- [ ] SQL injection attempts fail
- [ ] XSS attempts are blocked
- [ ] Rate limiting triggers on spam

## 🐛 Troubleshooting

### Database Connection Issues
```bash
# Check PostgreSQL is running
sudo systemctl status postgresql

# Test connection
psql -U postgres -d painting_auction
```

### Backend Port Already in Use
```bash
# Find process
lsof -i :5000

# Kill process
kill -9 [PID]
```

### Frontend Build Errors
```bash
# Clear node_modules
rm -rf node_modules package-lock.json

# Reinstall
npm install
```

### CORS Errors
- Check `CORS_ORIGIN` in backend `.env`
- Ensure frontend URL matches exactly
- Include protocol (http:// or https://)

## 📊 Database Schema Overview

### Tables
1. **users** - Bidder accounts
2. **admins** - Administrator accounts
3. **paintings** - Artwork listings
4. **bids** - Bid transactions
5. **auction_settings** - Auction dates

### Key Relationships
- Bids → Paintings (many-to-one)
- Bids → Users (many-to-one)
- Automatic ranking via views

## 🎯 Future Enhancements

- [ ] Email notifications for outbid
- [ ] SMS notifications via Twilio
- [ ] Auto-bid functionality
- [ ] Payment gateway integration
- [ ] Image upload to cloud storage (AWS S3/Cloudinary)
- [ ] Auction history and archives
- [ ] Winner announcement system
- [ ] Certificate generation for winners
- [ ] Mobile app (React Native)
- [ ] Real-time updates via WebSockets

## 📞 Support

For issues or questions:
1. Check this documentation
2. Review error logs
3. Verify environment variables
4. Check database connection
5. Ensure all dependencies installed

## 📄 License

This project is created for educational purposes for college use.

---

## Quick Start Commands

```bash
# Database
psql -U postgres -d painting_auction -f database/schema.sql

# Backend
cd backend
npm install
cp .env.example .env
# Edit .env
npm start

# Frontend
cd frontend
npm install
cp .env.example .env
# Edit .env
npm start
```

## URLs
- Frontend: http://localhost:3000
- Backend API: http://localhost:5000
- Admin Panel: http://localhost:3000/admin/login

**Default Admin**: admin / Admin@123

---

*Created with ❤️ for student development through art*

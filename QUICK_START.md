# ⚡ Quick Start Guide - Get Running in 5 Minutes!

## Prerequisites
- Node.js installed? Check with `node --version` (need v18+)
- PostgreSQL installed? Check with `psql --version` (need v14+)

## Step 1: Automated Setup (Easiest!) ✨

```bash
cd painting-auction
chmod +x setup.sh
./setup.sh
```

The script will:
- Create the database
- Set up tables
- Install all dependencies
- Create environment files
- Generate secure JWT secret

Just follow the prompts!

## Step 2: Start the Application 🚀

### Terminal 1 - Backend:
```bash
cd backend
npm start
```

You should see: "Server running on port 5000"

### Terminal 2 - Frontend:
```bash
cd frontend
npm start
```

Browser will auto-open at http://localhost:3000

## Step 3: Access the System 🎯

### User Side (Testing)
1. Go to http://localhost:3000
2. Click any painting
3. Click "Sign Up"
4. Register: Name, Mobile (10 digits), Password
5. Place a bid!

### Admin Panel
1. Go to http://localhost:3000/admin/login
2. Login with:
   - Username: `admin`
   - Password: `Admin@123`
3. Add paintings
4. Generate QR codes
5. Monitor bids

## Quick Test Flow 🧪

1. **As Admin**:
   - Login to admin panel
   - Add a test painting (Name: "Test Art", Artist: "Test Artist", Price: 1000)
   - Generate QR code
   - Keep this page open

2. **As User**:
   - Open http://localhost:3000 in a new tab
   - Sign up with test mobile number
   - Find the test painting
   - Place a bid (e.g., ₹1500)
   - Check your rank!

3. **Back to Admin**:
   - View "All Bids" page
   - See your test bid appear!

## Common Issues & Quick Fixes 🔧

### "Database connection failed"
```bash
# Check if PostgreSQL is running
sudo systemctl status postgresql

# Start it if not running
sudo systemctl start postgresql
```

### "Port 5000 already in use"
```bash
# Kill the process
lsof -i :5000
kill -9 [PID]
```

### "npm install fails"
```bash
# Clear cache and retry
npm cache clean --force
rm -rf node_modules package-lock.json
npm install
```

### "Cannot find module"
```bash
# Reinstall dependencies
cd backend && npm install
cd ../frontend && npm install
```

## Printing QR Codes 🖨️

1. Login to admin panel
2. Go to "Manage Paintings"
3. Click "QR" button for any painting
4. QR code downloads automatically
5. Print on A4 paper
6. Place near the painting

## Mobile Testing 📱

To test QR scanning on your phone:

1. Get your computer's local IP:
```bash
# On Mac/Linux
ifconfig | grep "inet "

# On Windows
ipconfig
```

2. Update frontend `.env`:
```env
REACT_APP_API_URL=http://YOUR_IP:5000/api
REACT_APP_FRONTEND_URL=http://YOUR_IP:3000
```

3. Restart frontend
4. Access http://YOUR_IP:3000 from phone
5. Scan QR code with phone camera

## File Structure (What's What) 📁

```
painting-auction/
├── backend/                # Node.js API server
│   ├── routes/            # API endpoints
│   ├── middleware/        # Security & validation
│   └── server.js          # Main server file
│
├── frontend/              # React web app
│   ├── src/pages/         # All pages
│   ├── src/components/    # Reusable components
│   └── src/services/      # API calls
│
├── database/
│   └── schema.sql         # Database structure
│
├── docs/
│   └── README.md          # Full documentation
│
└── setup.sh               # Automated setup
```

## Key URLs 🔗

| Service | URL | Purpose |
|---------|-----|---------|
| Frontend | http://localhost:3000 | User interface |
| API | http://localhost:5000 | Backend server |
| Admin | http://localhost:3000/admin/login | Admin panel |

## Default Credentials 🔐

**Admin Login:**
- Username: `admin`
- Password: `Admin@123`

⚠️ **IMPORTANT**: Change this password immediately after first login!

## What to Do Next? 🎯

### For Development
1. ✅ Familiarize yourself with admin panel
2. ✅ Add sample paintings
3. ✅ Test bidding flow
4. ✅ Customize colors/branding in frontend
5. ✅ Test on mobile devices

### For Production
1. ✅ Read `DEPLOYMENT_CHECKLIST.md`
2. ✅ Choose hosting providers
3. ✅ Change admin password
4. ✅ Generate new JWT secret
5. ✅ Set up database backups
6. ✅ Configure SSL certificates

## Need Help? 🆘

1. **Full Documentation**: See `/docs/README.md`
2. **Deployment Guide**: See `DEPLOYMENT_CHECKLIST.md`
3. **Error Logs**:
   - Backend: Check terminal running `npm start`
   - Frontend: Check browser console (F12)
   - Database: Check PostgreSQL logs

## Quick Commands Cheat Sheet 📝

```bash
# Start backend
cd backend && npm start

# Start frontend
cd frontend && npm start

# Database backup
pg_dump -U postgres painting_auction > backup.sql

# Database restore
psql -U postgres painting_auction < backup.sql

# View backend logs
tail -f backend/logs/*.log

# Clear node_modules and reinstall
rm -rf node_modules package-lock.json && npm install

# Check all services
ps aux | grep node
ps aux | grep postgres
```

## Performance Tips 🚀

1. **For faster development**:
   - Use `npm run dev` in backend (auto-restart on changes)
   - Keep both terminals visible to catch errors

2. **For better UX**:
   - Use fast internet connection
   - Test on actual mobile devices
   - Optimize images before uploading

3. **For production**:
   - Enable compression
   - Use CDN for static assets
   - Set up caching

## Security Reminders 🔒

Before going live:
- [ ] Change admin password
- [ ] Generate new JWT secret
- [ ] Enable HTTPS
- [ ] Update CORS settings
- [ ] Set up rate limiting
- [ ] Configure firewall

## That's It! 🎉

You now have a fully functional painting auction system running locally!

### Next Steps:
1. Explore the admin panel
2. Add real paintings
3. Generate QR codes
4. Test complete user flow
5. When ready, follow `DEPLOYMENT_CHECKLIST.md` for production

**Happy Auctioning! 🎨**

---

*For detailed documentation, see `/docs/README.md`*
*For deployment help, see `DEPLOYMENT_CHECKLIST.md`*

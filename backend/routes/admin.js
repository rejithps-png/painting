const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const QRCode = require('qrcode');
const { query } = require('../config/database');
const { authenticateAdmin } = require('../middleware/auth');
const {
  validateAdminLogin,
  validatePaintingCreation,
  validatePaintingUpdate,
  validateAuctionSettings,
  validateIdParam
} = require('../middleware/validation');

// Admin Login
router.post('/login', validateAdminLogin, async (req, res) => {
  try {
    const { username, password } = req.body;

    // Find admin by username
    const result = await query(
      'SELECT id, username, password_hash, email FROM admins WHERE username = $1',
      [username]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
      });
    }

    const admin = result.rows[0];

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, admin.password_hash);

    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
      });
    }

    // Update last login
    await query(
      'UPDATE admins SET last_login = CURRENT_TIMESTAMP WHERE id = $1',
      [admin.id]
    );

    // Generate JWT token
    const token = jwt.sign(
      {
        adminId: admin.id,
        username: admin.username,
        type: 'admin'
      },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );

    res.status(200).json({
      success: true,
      message: 'Login successful',
      data: {
        admin: {
          id: admin.id,
          username: admin.username,
          email: admin.email
        },
        token
      }
    });
  } catch (error) {
    console.error('Admin login error:', error);
    res.status(500).json({
      success: false,
      message: 'Login failed. Please try again.'
    });
  }
});

// Create Painting (Protected)
router.post('/paintings', authenticateAdmin, validatePaintingCreation, async (req, res) => {
  try {
    const { artistName, paintingName, basePrice, imageUrl } = req.body;

    // Generate unique QR code data
    const qrCodeData = `PAINT${Date.now()}${Math.random().toString(36).substr(2, 9)}`;

    // Insert painting
    const result = await query(
      `INSERT INTO paintings (artist_name, painting_name, base_price, image_url, qr_code_data, status) 
       VALUES ($1, $2, $3, $4, $5, 'active') 
       RETURNING *`,
      [artistName, paintingName, basePrice, imageUrl || null, qrCodeData]
    );

    const painting = result.rows[0];

    // Generate QR code as data URL
    const paintingUrl = `${process.env.FRONTEND_URL || 'http://localhost:3000'}/painting/${painting.id}`;
    const qrCodeDataUrl = await QRCode.toDataURL(paintingUrl);

    res.status(201).json({
      success: true,
      message: 'Painting created successfully',
      data: {
        painting: {
          id: painting.id,
          artistName: painting.artist_name,
          paintingName: painting.painting_name,
          basePrice: parseFloat(painting.base_price),
          imageUrl: painting.image_url,
          status: painting.status,
          qrCode: qrCodeDataUrl,
          paintingUrl
        }
      }
    });
  } catch (error) {
    console.error('Create painting error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create painting'
    });
  }
});

// Get All Paintings (Protected)
router.get('/paintings', authenticateAdmin, async (req, res) => {
  try {
    const result = await query(
      `SELECT 
        p.*,
        COALESCE(MAX(b.bid_amount), p.base_price) as current_price,
        COUNT(DISTINCT b.user_id) as total_bidders,
        COUNT(b.id) as total_bids
      FROM paintings p
      LEFT JOIN bids b ON p.id = b.painting_id AND b.status = 'active'
      GROUP BY p.id
      ORDER BY p.created_at DESC`
    );

    const paintings = result.rows.map(painting => ({
      id: painting.id,
      artistName: painting.artist_name,
      paintingName: painting.painting_name,
      basePrice: parseFloat(painting.base_price),
      currentPrice: parseFloat(painting.current_price),
      imageUrl: painting.image_url,
      status: painting.status,
      totalBidders: parseInt(painting.total_bidders),
      totalBids: parseInt(painting.total_bids),
      createdAt: painting.created_at
    }));

    res.status(200).json({
      success: true,
      data: { paintings }
    });
  } catch (error) {
    console.error('Get paintings error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch paintings'
    });
  }
});

// Get Single Painting with QR Code (Protected)
router.get('/paintings/:id/qrcode', authenticateAdmin, validateIdParam, async (req, res) => {
  try {
    const { id } = req.params;

    const result = await query(
      'SELECT * FROM paintings WHERE id = $1',
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Painting not found'
      });
    }

    const painting = result.rows[0];
    const paintingUrl = `${process.env.FRONTEND_URL || 'http://localhost:3000'}/painting/${painting.id}`;
    const qrCodeDataUrl = await QRCode.toDataURL(paintingUrl);

    res.status(200).json({
      success: true,
      data: {
        painting: {
          id: painting.id,
          artistName: painting.artist_name,
          paintingName: painting.painting_name,
          qrCode: qrCodeDataUrl,
          paintingUrl
        }
      }
    });
  } catch (error) {
    console.error('Get QR code error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to generate QR code'
    });
  }
});

// Update Painting (Protected)
router.put('/paintings/:id', authenticateAdmin, validatePaintingUpdate, async (req, res) => {
  try {
    const { id } = req.params;
    const { artistName, paintingName, basePrice, imageUrl, status } = req.body;

    // Build dynamic update query
    const updates = [];
    const values = [];
    let paramCount = 1;

    if (artistName !== undefined) {
      updates.push(`artist_name = $${paramCount++}`);
      values.push(artistName);
    }
    if (paintingName !== undefined) {
      updates.push(`painting_name = $${paramCount++}`);
      values.push(paintingName);
    }
    if (basePrice !== undefined) {
      updates.push(`base_price = $${paramCount++}`);
      values.push(basePrice);
    }
    if (imageUrl !== undefined) {
      updates.push(`image_url = $${paramCount++}`);
      values.push(imageUrl);
    }
    if (status !== undefined) {
      updates.push(`status = $${paramCount++}`);
      values.push(status);
    }

    if (updates.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'No fields to update'
      });
    }

    values.push(id);
    const result = await query(
      `UPDATE paintings SET ${updates.join(', ')} WHERE id = $${paramCount} RETURNING *`,
      values
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Painting not found'
      });
    }

    const painting = result.rows[0];

    res.status(200).json({
      success: true,
      message: 'Painting updated successfully',
      data: {
        painting: {
          id: painting.id,
          artistName: painting.artist_name,
          paintingName: painting.painting_name,
          basePrice: parseFloat(painting.base_price),
          imageUrl: painting.image_url,
          status: painting.status
        }
      }
    });
  } catch (error) {
    console.error('Update painting error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update painting'
    });
  }
});

// Delete Painting (Protected)
router.delete('/paintings/:id', authenticateAdmin, validateIdParam, async (req, res) => {
  try {
    const { id } = req.params;

    const result = await query(
      'DELETE FROM paintings WHERE id = $1 RETURNING id',
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Painting not found'
      });
    }

    res.status(200).json({
      success: true,
      message: 'Painting deleted successfully'
    });
  } catch (error) {
    console.error('Delete painting error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete painting'
    });
  }
});

// Get All Bids (Protected)
router.get('/bids', authenticateAdmin, async (req, res) => {
  try {
    const result = await query(
      `SELECT 
        b.id,
        b.bid_amount,
        b.bid_time,
        b.status,
        p.id as painting_id,
        p.painting_name,
        p.artist_name,
        u.first_name,
        u.last_name,
        u.mobile,
        RANK() OVER (PARTITION BY b.painting_id ORDER BY b.bid_amount DESC, b.bid_time ASC) as rank
      FROM bids b
      JOIN paintings p ON b.painting_id = p.id
      JOIN users u ON b.user_id = u.id
      WHERE b.status = 'active'
      ORDER BY p.painting_name, b.bid_amount DESC, b.bid_time ASC`
    );

    const bids = result.rows.map(bid => ({
      id: bid.id,
      bidAmount: parseFloat(bid.bid_amount),
      bidTime: bid.bid_time,
      rank: parseInt(bid.rank),
      painting: {
        id: bid.painting_id,
        name: bid.painting_name,
        artist: bid.artist_name
      },
      user: {
        firstName: bid.first_name,
        lastName: bid.last_name,
        mobile: bid.mobile
      }
    }));

    res.status(200).json({
      success: true,
      data: { bids }
    });
  } catch (error) {
    console.error('Get bids error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch bids'
    });
  }
});

// Get/Update Auction Settings (Protected)
router.get('/auction-settings', authenticateAdmin, async (req, res) => {
  try {
    const result = await query(
      'SELECT * FROM auction_settings WHERE is_active = true ORDER BY created_at DESC LIMIT 1'
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'No active auction settings found'
      });
    }

    const settings = result.rows[0];

    res.status(200).json({
      success: true,
      data: {
        settings: {
          id: settings.id,
          startDate: settings.start_date,
          endDate: settings.end_date,
          isActive: settings.is_active
        }
      }
    });
  } catch (error) {
    console.error('Get auction settings error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch auction settings'
    });
  }
});

router.put('/auction-settings', authenticateAdmin, validateAuctionSettings, async (req, res) => {
  try {
    const { startDate, endDate } = req.body;

    // Deactivate all existing settings
    await query('UPDATE auction_settings SET is_active = false');

    // Insert new settings
    const result = await query(
      `INSERT INTO auction_settings (start_date, end_date, is_active)
       VALUES ($1, $2, true)
       RETURNING *`,
      [startDate, endDate]
    );

    const settings = result.rows[0];

    res.status(200).json({
      success: true,
      message: 'Auction settings updated successfully',
      data: {
        settings: {
          id: settings.id,
          startDate: settings.start_date,
          endDate: settings.end_date,
          isActive: settings.is_active
        }
      }
    });
  } catch (error) {
    console.error('Update auction settings error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update auction settings'
    });
  }
});

// Dashboard Statistics (Protected)
router.get('/dashboard-stats', authenticateAdmin, async (req, res) => {
  try {
    const stats = await query(`
      SELECT 
        (SELECT COUNT(*) FROM paintings WHERE status = 'active') as total_paintings,
        (SELECT COUNT(*) FROM users) as total_users,
        (SELECT COUNT(*) FROM bids WHERE status = 'active') as total_bids,
        (SELECT COALESCE(SUM(bid_amount), 0) FROM (
          SELECT DISTINCT ON (painting_id) bid_amount 
          FROM bids 
          WHERE status = 'active' 
          ORDER BY painting_id, bid_amount DESC, bid_time ASC
        ) as highest_bids) as total_bid_value
    `);

    res.status(200).json({
      success: true,
      data: {
        totalPaintings: parseInt(stats.rows[0].total_paintings),
        totalUsers: parseInt(stats.rows[0].total_users),
        totalBids: parseInt(stats.rows[0].total_bids),
        totalBidValue: parseFloat(stats.rows[0].total_bid_value)
      }
    });
  } catch (error) {
    console.error('Get dashboard stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch dashboard statistics'
    });
  }
});

module.exports = router;

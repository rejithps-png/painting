-- Painting Auction Database Schema
-- Secure, normalized structure for student painting auction system

-- Drop tables if exists (for clean setup)
DROP TABLE IF EXISTS bids CASCADE;
DROP TABLE IF EXISTS paintings CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS admins CASCADE;

-- Users table (bidders)
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    mobile VARCHAR(15) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Admins table
CREATE TABLE admins (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

-- Paintings table
CREATE TABLE paintings (
    id SERIAL PRIMARY KEY,
    artist_name VARCHAR(200) NOT NULL,
    painting_name VARCHAR(200) NOT NULL,
    image_url TEXT,
    base_price DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'sold')),
    qr_code_data TEXT UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bids table
CREATE TABLE bids (
    id SERIAL PRIMARY KEY,
    painting_id INTEGER NOT NULL REFERENCES paintings(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    bid_amount DECIMAL(10, 2) NOT NULL,
    bid_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'cancelled', 'won')),
    CONSTRAINT bid_amount_positive CHECK (bid_amount > 0)
);

-- Auction settings table (for global auction dates)
CREATE TABLE auction_settings (
    id SERIAL PRIMARY KEY,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX idx_bids_painting_id ON bids(painting_id);
CREATE INDEX idx_bids_user_id ON bids(user_id);
CREATE INDEX idx_bids_amount ON bids(bid_amount DESC);
CREATE INDEX idx_paintings_status ON paintings(status);
CREATE INDEX idx_users_mobile ON users(mobile);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for auto-updating updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_paintings_updated_at BEFORE UPDATE ON paintings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_auction_settings_updated_at BEFORE UPDATE ON auction_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert default admin (username: admin, password: Admin@123)
-- Password hash for 'Admin@123' - CHANGE THIS IN PRODUCTION!
INSERT INTO admins (username, password_hash, email) VALUES 
('admin', '$2b$10$xQB4qF8KqzL8oF9MH3p5.eP0Zx7YnXGN5LxXzQRKJFhZJqUH6hS3y', 'admin@college.edu');

-- Insert default auction settings (adjust dates as needed)
INSERT INTO auction_settings (start_date, end_date, is_active) VALUES 
(CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '30 days', true);

-- Sample data for testing (optional - remove in production)
-- INSERT INTO paintings (artist_name, painting_name, base_price, qr_code_data) VALUES 
-- ('Rajesh Kumar', 'Sunset Dreams', 5000.00, 'PAINT001'),
-- ('Priya Sharma', 'Ocean Waves', 7500.00, 'PAINT002'),
-- ('Amit Patel', 'Mountain Glory', 6000.00, 'PAINT003');

-- View for getting current highest bid per painting
CREATE OR REPLACE VIEW painting_current_bids AS
SELECT 
    p.id as painting_id,
    p.artist_name,
    p.painting_name,
    p.base_price,
    p.image_url,
    p.status,
    COALESCE(MAX(b.bid_amount), p.base_price) as current_price,
    COUNT(b.id) as total_bids
FROM paintings p
LEFT JOIN bids b ON p.id = b.painting_id AND b.status = 'active'
GROUP BY p.id, p.artist_name, p.painting_name, p.base_price, p.image_url, p.status;

-- View for user bid rankings per painting
CREATE OR REPLACE VIEW user_bid_rankings AS
SELECT 
    b.id as bid_id,
    b.painting_id,
    b.user_id,
    b.bid_amount,
    b.bid_time,
    RANK() OVER (PARTITION BY b.painting_id ORDER BY b.bid_amount DESC, b.bid_time ASC) as rank
FROM bids b
WHERE b.status = 'active';

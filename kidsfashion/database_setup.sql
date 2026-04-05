-- ============================================
-- DATABASE: kidsfashion_db
-- Chạy script này trong MySQL Workbench
-- ============================================

CREATE DATABASE IF NOT EXISTS kidsfashion_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE kidsfashion_db;

-- ============================================
-- TABLE: categories (Danh mục quần áo)
-- ============================================
CREATE TABLE IF NOT EXISTS categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    image_url VARCHAR(255),
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================
-- TABLE: products (Quần áo trẻ em)
-- ============================================
CREATE TABLE IF NOT EXISTS products (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(15,2) NOT NULL,
    original_price DECIMAL(15,2),
    stock_quantity INT DEFAULT 0,
    image_url VARCHAR(255),
    category_id BIGINT,
    size VARCHAR(50),
    color VARCHAR(50),
    age_range VARCHAR(50),
    active BOOLEAN DEFAULT TRUE,
    featured BOOLEAN DEFAULT FALSE,
    sold_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
);

-- ============================================
-- TABLE: roles
-- ============================================
CREATE TABLE IF NOT EXISTS roles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

-- ============================================
-- TABLE: users (Người mua hàng)
-- ============================================
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(200),
    phone VARCHAR(20),
    address TEXT,
    avatar_url VARCHAR(255),
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================
-- TABLE: user_roles
-- ============================================
CREATE TABLE IF NOT EXISTS user_roles (
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
);

-- ============================================
-- TABLE: discount_codes (Mã giảm giá)
-- ============================================
CREATE TABLE IF NOT EXISTS discount_codes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    discount_type ENUM('PERCENTAGE', 'FIXED_AMOUNT') NOT NULL,
    discount_value DECIMAL(15,2) NOT NULL,
    minimum_order_amount DECIMAL(15,2) DEFAULT 0,
    max_usage_count INT DEFAULT NULL,
    current_usage_count INT DEFAULT 0,
    start_date DATE,
    end_date DATE,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLE: orders (Đơn đặt hàng)
-- ============================================
CREATE TABLE IF NOT EXISTS orders (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_code VARCHAR(50) NOT NULL UNIQUE,
    user_id BIGINT,
    customer_name VARCHAR(200) NOT NULL,
    customer_email VARCHAR(150) NOT NULL,
    customer_phone VARCHAR(20) NOT NULL,
    shipping_address TEXT NOT NULL,
    total_amount DECIMAL(15,2) NOT NULL,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    final_amount DECIMAL(15,2) NOT NULL,
    discount_code_id BIGINT,
    status ENUM('PENDING','CONFIRMED','SHIPPING','DELIVERED','CANCELLED') DEFAULT 'PENDING',
    payment_method ENUM('COD','BANK_TRANSFER','MOMO') DEFAULT 'COD',
    payment_status ENUM('UNPAID','PAID','REFUNDED') DEFAULT 'UNPAID',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (discount_code_id) REFERENCES discount_codes(id) ON DELETE SET NULL
);

-- ============================================
-- TABLE: order_items (Chi tiết đơn hàng)
-- ============================================
CREATE TABLE IF NOT EXISTS order_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    product_id BIGINT,
    product_name VARCHAR(200) NOT NULL,
    product_price DECIMAL(15,2) NOT NULL,
    quantity INT NOT NULL,
    subtotal DECIMAL(15,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL
);

-- ============================================
-- TABLE: cart_items (Giỏ hàng - session hoặc user)
-- ============================================
CREATE TABLE IF NOT EXISTS cart_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT,
    session_id VARCHAR(255),
    product_id BIGINT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- ============================================
-- INSERT: Default Data
-- ============================================

-- Roles
INSERT IGNORE INTO roles (name) VALUES ('ROLE_ADMIN'), ('ROLE_USER');

-- Admin account (password: admin123)
INSERT IGNORE INTO users (username, email, password, full_name, phone, active)
VALUES ('admin', 'admin@kidsfashion.com',
        '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
        'Quản Trị Viên', '0901234567', TRUE);

-- Assign admin role
INSERT IGNORE INTO user_roles (user_id, role_id)
SELECT u.id, r.id FROM users u, roles r
WHERE u.username = 'admin' AND r.name = 'ROLE_ADMIN';

-- Categories
INSERT IGNORE INTO categories (name, description, active) VALUES
('Áo thun trẻ em', 'Áo thun cotton mềm mại cho bé', TRUE),
('Quần jean trẻ em', 'Quần jean thời trang cho bé yêu', TRUE),
('Váy đầm bé gái', 'Váy đầm xinh xắn cho bé gái', TRUE),
('Bộ đồ liền thân', 'Bộ đồ tiện lợi cho bé nhỏ', TRUE),
('Áo khoác trẻ em', 'Áo khoác ấm áp cho mùa lạnh', TRUE);

-- Sample products
INSERT INTO products (name, description, price, original_price, stock_quantity, category_id, size, age_range, featured, sold_count) VALUES
('Áo thun hoạt hình Mickey', 'Áo thun cotton 100%, in hình Mickey dễ thương', 150000, 200000, 50, 1, 'S,M,L', '2-5 tuổi', TRUE, 120),
('Áo thun khủng long xanh', 'Áo thun cho bé trai, chất liệu thoáng mát', 130000, 180000, 45, 1, 'S,M,L,XL', '3-7 tuổi', FALSE, 85),
('Quần jean bé trai slim fit', 'Quần jean co giãn thoải mái', 250000, 320000, 30, 2, 'S,M,L', '4-8 tuổi', TRUE, 200),
('Váy hoa mùa hè', 'Váy hoa nhẹ nhàng, thoáng mát', 200000, 260000, 25, 3, 'S,M', '3-6 tuổi', TRUE, 150),
('Váy công chúa lace', 'Váy ren xinh xắn cho bé gái', 350000, 450000, 20, 3, 'S,M,L', '4-9 tuổi', TRUE, 90),
('Bộ liền thân gấu teddy', 'Bộ liền thân ấm áp hình gấu', 280000, 350000, 35, 4, 'XS,S,M', '6-24 tháng', FALSE, 60),
('Áo khoác hoodie cầu vồng', 'Áo khoác hoodie màu sắc tươi vui', 320000, 400000, 40, 5, 'S,M,L,XL', '5-10 tuổi', TRUE, 110),
('Áo thun bé gái hoa anh đào', 'Áo thun cotton họa tiết hoa', 140000, 190000, 55, 1, 'S,M,L', '3-8 tuổi', FALSE, 75);

-- Discount codes
INSERT INTO discount_codes (code, discount_type, discount_value, minimum_order_amount, max_usage_count, start_date, end_date, active) VALUES
('WELCOME10', 'PERCENTAGE', 10, 200000, 100, '2024-01-01', '2025-12-31', TRUE),
('SALE50K', 'FIXED_AMOUNT', 50000, 300000, 50, '2024-01-01', '2025-06-30', TRUE),
('KIDS20', 'PERCENTAGE', 20, 500000, 30, '2024-03-01', '2025-03-31', TRUE);

SELECT 'Database setup completed!' AS message;

-- JP IT Staffing Database Setup
-- This file contains SQL queries to set up the database for contact form submissions

-- Create database (if you have permission)
-- CREATE DATABASE IF NOT EXISTS jp_it_staffing;
-- USE jp_it_staffing;

-- Table for contact form submissions
CREATE TABLE IF NOT EXISTS contact_submissions (
    id INT(11) AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    service VARCHAR(50),
    message TEXT NOT NULL,
    ip_address VARCHAR(45),
    user_agent VARCHAR(255),
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_read BOOLEAN DEFAULT FALSE,
    INDEX idx_email (email),
    INDEX idx_submitted_at (submitted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table for newsletter subscriptions (optional)
CREATE TABLE IF NOT EXISTS newsletter_subscribers (
    id INT(11) AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(100),
    subscribed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table for job applications (optional - for future use)
CREATE TABLE IF NOT EXISTS job_applications (
    id INT(11) AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    position VARCHAR(100),
    experience_years INT,
    resume_path VARCHAR(255),
    cover_letter TEXT,
    skills TEXT,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending', 'reviewed', 'shortlisted', 'rejected', 'hired') DEFAULT 'pending',
    INDEX idx_email (email),
    INDEX idx_status (status),
    INDEX idx_applied_at (applied_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert some sample data for testing (optional)
-- INSERT INTO contact_submissions (name, email, phone, service, message) 
-- VALUES ('Test User', 'test@example.com', '+1234567890', 'permanent', 'This is a test message');

-- View to get recent submissions
CREATE OR REPLACE VIEW recent_submissions AS
SELECT 
    id,
    name,
    email,
    phone,
    service,
    LEFT(message, 100) as message_preview,
    submitted_at,
    is_read
FROM contact_submissions
ORDER BY submitted_at DESC
LIMIT 50;

-- Procedure to mark submission as read (optional)
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS mark_submission_read(IN submission_id INT)
BEGIN
    UPDATE contact_submissions 
    SET is_read = TRUE 
    WHERE id = submission_id;
END //
DELIMITER ;

-- Procedure to get submission statistics (optional)
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS get_submission_stats()
BEGIN
    SELECT 
        COUNT(*) as total_submissions,
        COUNT(CASE WHEN is_read = FALSE THEN 1 END) as unread_count,
        COUNT(CASE WHEN DATE(submitted_at) = CURDATE() THEN 1 END) as today_count,
        COUNT(CASE WHEN submitted_at >= DATE_SUB(NOW(), INTERVAL 7 DAY) THEN 1 END) as week_count,
        COUNT(CASE WHEN submitted_at >= DATE_SUB(NOW(), INTERVAL 30 DAY) THEN 1 END) as month_count
    FROM contact_submissions;
END //
DELIMITER ;

-- Table for admin users (optional - for admin panel)
CREATE TABLE IF NOT EXISTS admin_users (
    id INT(11) AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    role ENUM('admin', 'manager', 'viewer') DEFAULT 'viewer',
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create a default admin user (Change password after first login!)
-- Password: admin123 (hashed using PHP password_hash)
-- INSERT INTO admin_users (username, email, password_hash, full_name, role) 
-- VALUES ('admin', 'admin@jpitstaffing.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Admin User', 'admin');

-- Backup procedure (optional)
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS backup_old_submissions()
BEGIN
    -- Create backup table if not exists
    CREATE TABLE IF NOT EXISTS contact_submissions_archive LIKE contact_submissions;
    
    -- Move submissions older than 1 year to archive
    INSERT INTO contact_submissions_archive
    SELECT * FROM contact_submissions
    WHERE submitted_at < DATE_SUB(NOW(), INTERVAL 1 YEAR);
    
    -- Delete archived submissions from main table
    DELETE FROM contact_submissions
    WHERE submitted_at < DATE_SUB(NOW(), INTERVAL 1 YEAR);
    
    SELECT ROW_COUNT() as archived_count;
END //
DELIMITER ;

-- Indexes for better performance
CREATE INDEX idx_name ON contact_submissions(name);
CREATE INDEX idx_service ON contact_submissions(service);
CREATE INDEX idx_is_read ON contact_submissions(is_read);

-- Comments
ALTER TABLE contact_submissions 
COMMENT = 'Stores all contact form submissions from the website';

ALTER TABLE newsletter_subscribers 
COMMENT = 'Stores newsletter subscription data';

ALTER TABLE job_applications 
COMMENT = 'Stores job application submissions';

-- Grant permissions (uncomment and modify as needed)
-- GRANT ALL PRIVILEGES ON jp_it_staffing.* TO 'your_username'@'localhost';
-- FLUSH PRIVILEGES;

-- Success message
SELECT 'Database setup completed successfully!' as message;

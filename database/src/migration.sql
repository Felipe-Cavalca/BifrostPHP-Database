CREATE TABLE IF NOT EXISTS bfr_migration (
    id INT AUTO_INCREMENT PRIMARY KEY,
    file VARCHAR(500) NOT NULL,
    created TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

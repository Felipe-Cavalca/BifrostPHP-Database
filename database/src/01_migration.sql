CREATE TABLE IF NOT EXISTS bfr_migration (
    id SERIAL PRIMARY KEY,
    file VARCHAR(500) NOT NULL,
    created TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

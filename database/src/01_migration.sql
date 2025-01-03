CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS bfr_migration (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    file VARCHAR(500) UNIQUE NOT NULL,
    created TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

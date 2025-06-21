-- Initialize database for Crypto Airdrop Platform
-- This script runs when the PostgreSQL container starts for the first time

-- Create database if it doesn't exist (handled by POSTGRES_DB env var)
-- Grant additional privileges to the user
GRANT ALL PRIVILEGES ON DATABASE crypto_airdrop_db TO crypto_user;
ALTER USER crypto_user CREATEDB;

-- Set up extensions that might be needed
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create a health check function
CREATE OR REPLACE FUNCTION health_check() 
RETURNS TEXT AS $$
BEGIN
    RETURN 'Database is healthy at ' || NOW();
END;
$$ LANGUAGE plpgsql;
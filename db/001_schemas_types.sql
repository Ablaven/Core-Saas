CREATE SCHEMA IF NOT EXISTS core;
CREATE SCHEMA IF NOT EXISTS product_a;
CREATE SCHEMA IF NOT EXISTS product_b;
CREATE TYPE core.approval_status AS ENUM ('proposed', 'approved', 'rejected');
CREATE TYPE core.source_type AS ENUM ('manual', 'ai_generated');
CREATE TABLE types (
    type_category VARCHAR(50) NOT NULL,  -- 'amenity', 'listing_type', etc.
    type_code VARCHAR(50) NOT NULL,      -- 'wifi', 'pool', 'entire_home'
    type_name VARCHAR(100) NOT NULL,
    description TEXT,
    metadata JSONB,                      -- Extended properties
    is_active BOOLEAN DEFAULT TRUE,
    display_order INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (type_category, type_code)
);

-- Sample data
INSERT INTO types (type_category, type_code, type_name, metadata) VALUES
('amenity', 'wifi', 'WiFi', '{"icon":"wifi", "category":"basic"}'),
('amenity', 'pool', 'Pool', '{"icon":"pool", "category":"premium"}'),
('listing_type', 'entire_home', 'Entire Home', '{"private":true}');

CREATE TABLE entity_types (
    entity_id UUID NOT NULL,           -- References listings, users, etc.
    entity_kind VARCHAR(30) NOT NULL,  -- 'listing', 'user_preference', etc.
    type_category VARCHAR(50) NOT NULL,-- Matches types.type_category
    type_code VARCHAR(50) NOT NULL,    -- Matches types.type_code
    PRIMARY KEY (entity_id, entity_kind, type_category, type_code),
    FOREIGN KEY (type_category, type_code) REFERENCES types(type_category, type_code)
);

-- Indexes for fast lookup
CREATE INDEX idx_entity_types_entity ON entity_types(entity_id, entity_kind);
CREATE INDEX idx_entity_types_type ON entity_types(type_category, type_code);

-- Add amenities to a listing
INSERT INTO entity_types (entity_id, entity_kind, type_category, type_code)
VALUES 
('123e4567-e89b-12d3-a456-426614174000', 'listing', 'amenity', 'wifi'),
('123e4567-e89b-12d3-a456-426614174000', 'listing', 'amenity', 'pool');

-- Get all amenities for a listing
SELECT t.* FROM types t
JOIN entity_types et ON t.type_category = et.type_category 
                     AND t.type_code = et.type_code
WHERE et.entity_id = '123e4567-e89b-12d3-a456-426614174000'
AND et.entity_kind = 'listing'
AND t.type_category = 'amenity';

-- Set listing type (one-to-one)
INSERT INTO entity_types (entity_id, entity_kind, type_category, type_code)
VALUES ('123e4567-e89b-12d3-a456-426614174000', 'listing', 'listing_type', 'entire_home');

-- User preferences (many-to-many)
INSERT INTO entity_types (entity_id, entity_kind, type_category, type_code)
VALUES ('987e6543-e89b-12d3-a456-426614174000', 'user_preference', 'amenity', 'wifi');
=====================================

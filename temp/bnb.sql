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


CREATE OR REPLACE MATERIALIZED VIEW listing_amenities_clean AS
SELECT 
    et.entity_id AS listing_id,
    jsonb_agg(to_jsonb(t) - 'created_at' - 'updated_at' - 'is_active') AS amenities
FROM types t
JOIN entity_types et ON t.type_category = et.type_category 
                     AND t.type_code = et.type_code
WHERE et.entity_kind = 'listing'
AND t.type_category = 'amenity'
GROUP BY et.entity_id;

=====================================
-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Master type table
CREATE TABLE types (
    type_category VARCHAR(50) NOT NULL,
    type_code VARCHAR(50) NOT NULL,
    type_name VARCHAR(100) NOT NULL,
    description TEXT,
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (type_category, type_code)
);

-- Users table
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(50),
    profile_photo_url TEXT,
    is_host BOOLEAN NOT NULL DEFAULT FALSE,
    is_superhost BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    last_login_at TIMESTAMP WITH TIME ZONE,
    preferred_language VARCHAR(10),
    preferred_currency VARCHAR(3),
    verification_status_code VARCHAR(50),
    trust_score DECIMAL(3,2),
    government_id_hash TEXT,
    date_of_birth DATE,
    deactivated_at TIMESTAMP WITH TIME ZONE,
    FOREIGN KEY ('verification_status', verification_status_code) REFERENCES types(type_category, type_code)
);

-- Listings table
CREATE TABLE listings (
    listing_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    host_id UUID NOT NULL REFERENCES users(user_id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    listing_type_code VARCHAR(50) NOT NULL,
    property_type_code VARCHAR(50) NOT NULL,
    address JSONB NOT NULL,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    geohash VARCHAR(12),
    price_per_night DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) NOT NULL,
    min_nights INTEGER NOT NULL DEFAULT 1,
    max_nights INTEGER,
    max_guests INTEGER NOT NULL,
    bedrooms INTEGER,
    beds INTEGER,
    bathrooms DECIMAL(3,1),
    square_footage INTEGER,
    amenities JSONB NOT NULL DEFAULT '[]'::JSONB,
    house_rules TEXT,
    cancellation_policy_code VARCHAR(50) NOT NULL DEFAULT 'moderate',
    photos JSONB,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    instant_bookable BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    rating_average DECIMAL(2,1),
    review_count INTEGER DEFAULT 0,
    views_count INTEGER DEFAULT 0,
    version INTEGER DEFAULT 1,
    FOREIGN KEY ('listing_type', listing_type_code) REFERENCES types(type_category, type_code),
    FOREIGN KEY ('property_type', property_type_code) REFERENCES types(type_category, type_code),
    FOREIGN KEY ('cancellation_policy', cancellation_policy_code) REFERENCES types(type_category, type_code),
    CONSTRAINT valid_amenities CHECK (
        jsonb_array_elements_text(amenities) IN (
            SELECT type_code FROM types WHERE type_category = 'amenity' AND is_active = TRUE
        )
    )
);

-- Bookings table
CREATE TABLE bookings (
    booking_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    listing_id UUID NOT NULL REFERENCES listings(listing_id),
    guest_id UUID NOT NULL REFERENCES users(user_id),
    host_id UUID NOT NULL REFERENCES users(user_id),
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    num_guests INTEGER NOT NULL,
    base_price DECIMAL(10,2) NOT NULL,
    cleaning_fee DECIMAL(10,2) DEFAULT 0,
    service_fee DECIMAL(10,2) DEFAULT 0,
    taxes DECIMAL(10,2) DEFAULT 0,
    total_price DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) NOT NULL,
    status_code VARCHAR(50) NOT NULL DEFAULT 'pending',
    cancellation_reason TEXT,
    booked_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    security_deposit DECIMAL(10,2) DEFAULT 0,
    special_requests TEXT,
    payment_plan VARCHAR(20),
    confirmation_code VARCHAR(20) UNIQUE,
    FOREIGN KEY ('booking_status', status_code) REFERENCES types(type_category, type_code)
);

-- Payments table
CREATE TABLE payments (
    payment_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID NOT NULL REFERENCES bookings(booking_id),
    user_id UUID NOT NULL REFERENCES users(user_id),
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) NOT NULL,
    payment_method_code VARCHAR(50) NOT NULL,
    payment_method_id VARCHAR(255),
    status_code VARCHAR(50) NOT NULL DEFAULT 'pending',
    transaction_id VARCHAR(255),
    fee_amount DECIMAL(10,2) DEFAULT 0,
    payout_id VARCHAR(255),
    captured_at TIMESTAMP WITH TIME ZONE,
    refunded_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    receipt_url TEXT,
    FOREIGN KEY ('payment_method', payment_method_code) REFERENCES types(type_category, type_code),
    FOREIGN KEY ('payment_status', status_code) REFERENCES types(type_category, type_code)
);

-- Reviews table
CREATE TABLE reviews (
    review_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID NOT NULL REFERENCES bookings(booking_id),
    reviewer_id UUID NOT NULL REFERENCES users(user_id),
    target_type_code VARCHAR(50) NOT NULL,
    target_id UUID NOT NULL,
    rating DECIMAL(2,1) NOT NULL,
    cleanliness DECIMAL(2,1),
    accuracy DECIMAL(2,1),
    communication DECIMAL(2,1),
    location DECIMAL(2,1),
    check_in DECIMAL(2,1),
    value DECIMAL(2,1),
    comment TEXT,
    response TEXT,
    response_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY ('review_target_type', target_type_code) REFERENCES types(type_category, type_code)
);

-- Messages table
CREATE TABLE messages (
    message_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    thread_id UUID NOT NULL,
    sender_id UUID NOT NULL REFERENCES users(user_id),
    receiver_id UUID NOT NULL REFERENCES users(user_id),
    booking_id UUID REFERENCES bookings(booking_id),
    content TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    attachments JSONB
);

-- Availability table
CREATE TABLE availability (
    availability_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    listing_id UUID NOT NULL REFERENCES listings(listing_id),
    date DATE NOT NULL,
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    price DECIMAL(10,2),
    min_nights INTEGER,
    max_nights INTEGER,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_listing_date UNIQUE (listing_id, date)
);

-- Payouts table
CREATE TABLE payouts (
    payout_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    host_id UUID NOT NULL REFERENCES users(user_id),
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) NOT NULL,
    status_code VARCHAR(50) NOT NULL DEFAULT 'pending',
    method_code VARCHAR(50) NOT NULL,
    destination_id VARCHAR(255) NOT NULL,
    statement_period VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    processed_at TIMESTAMP WITH TIME ZONE,
    fee_amount DECIMAL(10,2) DEFAULT 0,
    net_amount DECIMAL(10,2) NOT NULL,
    transaction_ids JSONB,
    FOREIGN KEY ('payout_status', status_code) REFERENCES types(type_category, type_code),
    FOREIGN KEY ('payout_method', method_code) REFERENCES types(type_category, type_code)
);

-- Saved listings table
CREATE TABLE saved_listings (
    saved_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id),
    listing_id UUID NOT NULL REFERENCES listings(listing_id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_user_listing UNIQUE (user_id, listing_id)
);

-- Price history table
CREATE TABLE price_history (
    history_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    listing_id UUID NOT NULL REFERENCES listings(listing_id),
    date DATE NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Modified Materialized View (cleaned up version)
CREATE MATERIALIZED VIEW listing_amenities_clean AS
SELECT 
    l.listing_id,
    jsonb_agg(
        jsonb_build_object(
            'type_code', t.type_code,
            'type_name', t.type_name,
            'description', t.description,
            'display_order', t.display_order,
            'type_category', t.type_category,
            'metadata', t.metadata
        )
    ) AS amenities
FROM listings l
CROSS JOIN jsonb_array_elements_text(l.amenities) AS a(amenity_code)
JOIN types t ON t.type_category = 'amenity' AND t.type_code = a.amenity_code
GROUP BY l.listing_id;

-- Create indexes
CREATE INDEX idx_types_category ON types(type_category);
CREATE INDEX idx_types_active ON types(type_category, is_active) WHERE is_active = TRUE;
CREATE INDEX idx_listings_amenities ON listings USING GIN(amenities jsonb_path_ops);
CREATE INDEX idx_listings_geohash ON listings(geohash);
CREATE INDEX idx_availability_listing_date ON availability(listing_id, date) WHERE is_available = TRUE;
-- (Add other necessary indexes...)

-- Create trigger function for updated_at
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply triggers to all tables with updated_at
DO $$
DECLARE
    t record;
BEGIN
    FOR t IN 
        SELECT table_name 
        FROM information_schema.columns 
        WHERE column_name = 'updated_at' 
        AND table_schema = 'public'
    LOOP
        EXECUTE format('CREATE TRIGGER update_%s_modtime
            BEFORE UPDATE ON %I
            FOR EACH ROW EXECUTE FUNCTION update_modified_column()',
            t.table_name, t.table_name);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

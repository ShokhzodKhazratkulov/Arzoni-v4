-- SQL to update Supabase schema for Arzoni App

-- Create listings table if not exists
CREATE TABLE IF NOT EXISTS listings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('food', 'clothes')),
  address TEXT NOT NULL,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  working_hours TEXT,
  is_sponsored BOOLEAN DEFAULT false,
  is_verified BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  photo_url TEXT,
  photo_urls TEXT[] DEFAULT '{}',
  description TEXT,
  dishes TEXT[] DEFAULT '{}',
  avg_price NUMERIC DEFAULT 0,
  phone TEXT,
  social_link TEXT,
  google_maps_url TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Create reviews table if not exists
CREATE TABLE IF NOT EXISTS reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  listing_id UUID REFERENCES listings(id) ON DELETE CASCADE,
  dish_name TEXT NOT NULL,
  price_paid NUMERIC NOT NULL,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  visit_date DATE,
  price_feeling TEXT CHECK (price_feeling IN ('cheap', 'fair', 'expensive')),
  portion_size TEXT CHECK (portion_size IN ('small', 'normal', 'big')),
  title TEXT,
  text TEXT,
  tags TEXT[] DEFAULT '{}',
  submitter_name TEXT,
  photo_urls TEXT[] DEFAULT '{}',
  likes INTEGER DEFAULT 0,
  dislikes INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Create banners table if not exists
CREATE TABLE IF NOT EXISTS banners (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  restaurant_id UUID REFERENCES listings(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  languages TEXT[] DEFAULT '{"uz", "ru", "en"}',
  start_date TIMESTAMPTZ DEFAULT now(),
  end_date TIMESTAMPTZ,
  position INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  is_paused BOOLEAN DEFAULT false,
  category TEXT CHECK (category IN ('food', 'clothes')),
  image_url TEXT,
  image_url_uz TEXT,
  image_url_ru TEXT,
  image_url_en TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Add missing columns if tables already exist
DO $$ 
BEGIN 
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='listings' AND column_name='phone') THEN
    ALTER TABLE listings ADD COLUMN phone TEXT;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='listings' AND column_name='social_link') THEN
    ALTER TABLE listings ADD COLUMN social_link TEXT;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='listings' AND column_name='google_maps_url') THEN
    ALTER TABLE listings ADD COLUMN google_maps_url TEXT;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='listings' AND column_name='avg_price') THEN
    ALTER TABLE listings ADD COLUMN avg_price NUMERIC DEFAULT 0;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='listings' AND column_name='dishes') THEN
    ALTER TABLE listings ADD COLUMN dishes TEXT[] DEFAULT '{}';
  END IF;
END $$;

-- Enable Row Level Security
ALTER TABLE listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE banners ENABLE ROW LEVEL SECURITY;

-- Listings Policies
DROP POLICY IF EXISTS "Allow public read access on listings" ON listings;
CREATE POLICY "Allow public read access on listings" ON listings
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow authenticated users to insert listings" ON listings;
DROP POLICY IF EXISTS "Allow anyone to insert listings" ON listings;
CREATE POLICY "Allow anyone to insert listings" ON listings
  FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Allow admin to update listings" ON listings;
DROP POLICY IF EXISTS "Allow anyone to update listings" ON listings;
CREATE POLICY "Allow anyone to update listings" ON listings
  FOR UPDATE USING (true)
  WITH CHECK (
    (auth.jwt() ->> 'email' IN ('khazratkulovshokhzod@gmail.com', 'abdullayevamuborak548@gmail.com'))
    OR 
    (
      -- For non-admins, ensure sponsored/verified status is not changed
      is_sponsored = (SELECT l.is_sponsored FROM listings l WHERE l.id = listings.id) AND
      is_verified = (SELECT l.is_verified FROM listings l WHERE l.id = listings.id)
    )
  );

DROP POLICY IF EXISTS "Allow admin to delete listings" ON listings;
CREATE POLICY "Allow admin to delete listings" ON listings
  FOR DELETE USING (
    auth.jwt() ->> 'email' IN ('khazratkulovshokhzod@gmail.com', 'abdullayevamuborak548@gmail.com')
  );

-- Reviews Policies
DROP POLICY IF EXISTS "Allow public read access on reviews" ON reviews;
CREATE POLICY "Allow public read access on reviews" ON reviews
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow authenticated users to insert reviews" ON reviews;
DROP POLICY IF EXISTS "Allow anyone to insert reviews" ON reviews;
CREATE POLICY "Allow anyone to insert reviews" ON reviews
  FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Allow admin to update reviews" ON reviews;
DROP POLICY IF EXISTS "Allow anyone to update reviews" ON reviews;
CREATE POLICY "Allow anyone to update reviews" ON reviews
  FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Allow admin to delete reviews" ON reviews;
CREATE POLICY "Allow admin to delete reviews" ON reviews
  FOR DELETE USING (
    auth.jwt() ->> 'email' IN ('khazratkulovshokhzod@gmail.com', 'abdullayevamuborak548@gmail.com')
  );

-- Banners Policies
DROP POLICY IF EXISTS "Allow public read access on banners" ON banners;
CREATE POLICY "Allow public read access on banners" ON banners
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow admin to manage banners" ON banners;
CREATE POLICY "Allow admin to manage banners" ON banners
  FOR ALL USING (
    auth.jwt() ->> 'email' IN ('khazratkulovshokhzod@gmail.com', 'abdullayevamuborak548@gmail.com')
  );

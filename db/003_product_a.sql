-- Product A Tables
CREATE TABLE product_a.brand_profiles (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 workspace_id uuid NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
 brand_name text NOT NULL
);
CREATE TABLE product_a.marketing_requests (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 workspace_id uuid NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
 brand_id uuid NOT NULL REFERENCES product_a.brand_profiles(id) ON DELETE CASCADE,
 title text NOT NULL,
 status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'open', 'awarded', 'closed', 'cancelled'))
);
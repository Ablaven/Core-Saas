-- Product B Tables
CREATE TABLE product_b.campaigns (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 workspace_id uuid NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
 project_id uuid NOT NULL REFERENCES core.projects(id) ON DELETE CASCADE,
 campaign_name text NOT NULL,
 budget numeric(12,2) NOT NULL DEFAULT 0.00
);
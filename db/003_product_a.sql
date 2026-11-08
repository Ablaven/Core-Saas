-- Product A Tables (Team A - Marketing & Brand Management Platform)
-- Multi-tenant SaaS architecture with workspace isolation

-- ============================================================================
-- BRAND MANAGEMENT
-- ============================================================================

-- Brand Profiles - Core brand entities
CREATE TABLE product_a.brand_profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id uuid NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
  brand_name text NOT NULL,
  brand_description text,
  logo_url text,
  website_url text,
  industry text,
  target_audience text,
  brand_status text NOT NULL DEFAULT 'active' 
    CHECK (brand_status IN ('active', 'inactive', 'archived')),
  created_by uuid REFERENCES core.users(id),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT unique_workspace_brand UNIQUE (workspace_id, brand_name)
);

-- Brand Colors - Color palettes for each brand
CREATE TABLE product_a.brand_colors (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  brand_id uuid NOT NULL REFERENCES product_a.brand_profiles(id) ON DELETE CASCADE,
  color_name text NOT NULL,
  hex_value text NOT NULL,
  color_type text NOT NULL DEFAULT 'primary'
    CHECK (color_type IN ('primary', 'secondary', 'accent', 'background', 'text')),
  usage_notes text,
  created_at timestamptz NOT NULL DEFAULT now()
  workspace_id uuid NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
);

-- Brand Assets - Logo, images, fonts, and other brand assets
CREATE TABLE product_a.brand_assets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  brand_id uuid NOT NULL REFERENCES product_a.brand_profiles(id) ON DELETE CASCADE,
  asset_name text NOT NULL,
  asset_type text NOT NULL 
    CHECK (asset_type IN ('logo', 'image', 'font', 'document', 'video', 'other')),
  file_url text NOT NULL,
  file_size_bytes bigint,
  mime_type text,
  description text,
  uploaded_by uuid REFERENCES core.users(id),
  created_at timestamptz NOT NULL DEFAULT now(),
  workspace_id uuid NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
);

-- ============================================================================
-- CAMPAIGN MANAGEMENT
-- ============================================================================

-- Marketing Campaigns
CREATE TABLE product_a.campaigns (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id uuid NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
  brand_id uuid NOT NULL REFERENCES product_a.brand_profiles(id) ON DELETE CASCADE,
  project_id uuid REFERENCES core.projects(id) ON DELETE SET NULL,
  campaign_name text NOT NULL,
  campaign_description text,
  campaign_type text NOT NULL
    CHECK (campaign_type IN ('social_media', 'email', 'content', 'paid_ads', 'seo', 'influencer', 'event', 'other')),
  budget numeric(12,2) DEFAULT 0.00,
  currency text DEFAULT 'USD',
  start_date date,
  end_date date,
  status text NOT NULL DEFAULT 'draft'
    CHECK (status IN ('draft', 'planned', 'active', 'paused', 'completed', 'cancelled')),
  target_audience text,
  goals text,
  kpi_metrics jsonb,
  campaign_manager_id uuid REFERENCES core.users(id),
  created_by uuid REFERENCES core.users(id),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  workspace_id uuid NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
);

-- Campaign Channels - Platforms/channels used in campaigns
CREATE TABLE product_a.campaign_channels (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  campaign_id uuid NOT NULL REFERENCES product_a.campaigns(id) ON DELETE CASCADE,
  channel_name text NOT NULL
    CHECK (channel_name IN ('facebook', 'instagram', 'twitter', 'linkedin', 'tiktok', 'youtube', 
                            'google_ads', 'email', 'website', 'blog', 'other')),
  budget_allocation numeric(12,2) DEFAULT 0.00,
  performance_metrics jsonb,
  is_active boolean DEFAULT true,
  workspace_id uuid NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- ============================================================================
-- CONTENT MANAGEMENT
-- ============================================================================

-- Content Calendar - Content planning and scheduling
CREATE TABLE product_a.content_calendar (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id uuid NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
  campaign_id uuid REFERENCES product_a.campaigns(id) ON DELETE SET NULL,
  brand_id uuid NOT NULL REFERENCES product_a.brand_profiles(id) ON DELETE CASCADE,
  content_title text NOT NULL,
  content_type text NOT NULL
    CHECK (content_type IN ('blog_post', 'social_post', 'video', 'infographic', 'email', 'whitepaper', 'case_study', 'other')),
  content_description text,
  scheduled_date timestamptz NOT NULL,
  publish_date timestamptz,
  status text NOT NULL DEFAULT 'idea'
    CHECK (status IN ('idea', 'planned', 'in_progress', 'review', 'scheduled', 'published', 'cancelled')),
  assigned_to uuid REFERENCES core.users(id),
  source_type core.source_type NOT NULL DEFAULT 'manual',
  approval_status core.approval_status NOT NULL DEFAULT 'approved',
  approved_by uuid REFERENCES core.users(id),
  approved_at timestamptz,
  created_by uuid REFERENCES core.users(id),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT check_content_ai_approval CHECK (
    approval_status <> 'approved' OR (approved_by IS NOT NULL AND approved_at IS NOT NULL) OR source_type = 'manual'
  )
);

-- Content Pieces - Actual content items
CREATE TABLE product_a.content_pieces (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  content_calendar_id uuid NOT NULL REFERENCES product_a.content_calendar(id) ON DELETE CASCADE,
  content_body text,
  media_urls text[],
  tags text[],
  target_channels text[],
  performance_metrics jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  workspace_id uuid NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
  workspace_id uuid NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE
);

-- ============================================================================
-- MARKETING REQUESTS (RFP/RFQ System)
-- ============================================================================

-- Marketing Requests - Requests for proposals/quotes
CREATE TABLE product_a.marketing_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id uuid NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
  brand_id uuid NOT NULL REFERENCES product_a.brand_profiles(id) ON DELETE CASCADE,
  request_title text NOT NULL,
  request_description text,
  request_type text NOT NULL
    CHECK (request_type IN ('rfp', 'rfq', 'rfr', 'creative_brief', 'vendor_request')),
  budget_range_min numeric(12,2),
  budget_range_max numeric(12,2),
  deadline date,
  status text NOT NULL DEFAULT 'draft'
    CHECK (status IN ('draft', 'open', 'in_review', 'awarded', 'closed', 'cancelled')),
  priority text DEFAULT 'medium'
    CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
  requirements jsonb,
  created_by uuid REFERENCES core.users(id),
  assigned_to uuid REFERENCES core.users(id),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Request Responses - Vendor/agency responses to requests
CREATE TABLE product_a.request_responses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  request_id uuid NOT NULL REFERENCES product_a.marketing_requests(id) ON DELETE CASCADE,
  vendor_name text NOT NULL,
  vendor_contact_email text NOT NULL,
  vendor_contact_phone text,
  proposal_summary text,
  proposed_budget numeric(12,2),
  estimated_timeline text,
  attachments text[],
  status text NOT NULL DEFAULT 'submitted'
    CHECK (status IN ('submitted', 'under_review', 'shortlisted', 'accepted', 'rejected')),
  review_notes text,
  submitted_at timestamptz NOT NULL DEFAULT now(),
  reviewed_by uuid REFERENCES core.users(id),
  workspace_id uuid NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
  reviewed_at timestamptz
);

-- ============================================================================
-- ANALYTICS & REPORTING
-- ============================================================================

-- Campaign Analytics - Performance tracking
CREATE TABLE product_a.campaign_analytics (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  campaign_id uuid NOT NULL REFERENCES product_a.campaigns(id) ON DELETE CASCADE,
  metric_date date NOT NULL,
  impressions bigint DEFAULT 0,
  clicks bigint DEFAULT 0,
  conversions bigint DEFAULT 0,
  engagement_rate numeric(5,2),
  cost_per_click numeric(10,2),
  cost_per_conversion numeric(10,2),
  roi_percentage numeric(10,2),
  additional_metrics jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  workspace_id uuid NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
  CONSTRAINT unique_campaign_date_analytics UNIQUE (campaign_id, metric_date)
);

-- Brand Performance Metrics
CREATE TABLE product_a.brand_metrics (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  brand_id uuid NOT NULL REFERENCES product_a.brand_profiles(id) ON DELETE CASCADE,
  metric_date date NOT NULL,
  brand_awareness_score numeric(5,2),
  sentiment_score numeric(5,2),
  social_mentions bigint DEFAULT 0,
  website_traffic bigint DEFAULT 0,
  engagement_score numeric(5,2),
  additional_metrics jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  workspace_id uuid NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
  CONSTRAINT unique_brand_date_metrics UNIQUE (brand_id, metric_date)
);

-- ============================================================================
-- COLLABORATION & APPROVALS
-- ============================================================================

-- Review Comments - Comments on campaigns, content, etc.
CREATE TABLE product_a.review_comments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id uuid NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
  entity_type text NOT NULL
    CHECK (entity_type IN ('campaign', 'content', 'request', 'brand')),
  entity_id uuid NOT NULL,
  comment_text text NOT NULL,
  comment_type text DEFAULT 'general'
    CHECK (comment_type IN ('general', 'feedback', 'approval', 'revision_request')),
  parent_comment_id uuid REFERENCES product_a.review_comments(id) ON DELETE CASCADE,
  created_by uuid NOT NULL REFERENCES core.users(id),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================

-- Brand Profiles
CREATE INDEX idx_brand_profiles_workspace ON product_a.brand_profiles(workspace_id);
CREATE INDEX idx_brand_profiles_status ON product_a.brand_profiles(brand_status);

-- Campaigns
CREATE INDEX idx_campaigns_workspace ON product_a.campaigns(workspace_id);
CREATE INDEX idx_campaigns_brand ON product_a.campaigns(brand_id);
CREATE INDEX idx_campaigns_status ON product_a.campaigns(status);
CREATE INDEX idx_campaigns_dates ON product_a.campaigns(start_date, end_date);

-- Content Calendar
CREATE INDEX idx_content_calendar_workspace ON product_a.content_calendar(workspace_id);
CREATE INDEX idx_content_calendar_campaign ON product_a.content_calendar(campaign_id);
CREATE INDEX idx_content_calendar_scheduled ON product_a.content_calendar(scheduled_date);
CREATE INDEX idx_content_calendar_status ON product_a.content_calendar(status);

-- Marketing Requests
CREATE INDEX idx_marketing_requests_workspace ON product_a.marketing_requests(workspace_id);
CREATE INDEX idx_marketing_requests_brand ON product_a.marketing_requests(brand_id);
CREATE INDEX idx_marketing_requests_status ON product_a.marketing_requests(status);

-- Analytics
CREATE INDEX idx_campaign_analytics_campaign ON product_a.campaign_analytics(campaign_id);
CREATE INDEX idx_campaign_analytics_date ON product_a.campaign_analytics(metric_date);

-- Review Comments
CREATE INDEX idx_review_comments_workspace ON product_a.review_comments(workspace_id);
CREATE INDEX idx_review_comments_entity ON product_a.review_comments(entity_type, entity_id);
CREATE INDEX idx_review_comments_parent ON product_a.review_comments(parent_comment_id);

-- ============================================================================
-- VIEWS FOR REPORTING
-- ============================================================================

-- Campaign Performance Summary
CREATE VIEW product_a.campaign_performance_summary AS
SELECT
  c.id AS campaign_id,
  c.campaign_name,
  c.workspace_id,
  c.brand_id,
  b.brand_name,
  c.status,
  c.budget,
  COUNT(DISTINCT ca.id) AS total_analytics_records,
  SUM(ca.impressions) AS total_impressions,
  SUM(ca.clicks) AS total_clicks,
  SUM(ca.conversions) AS total_conversions,
  AVG(ca.engagement_rate) AS avg_engagement_rate,
  AVG(ca.roi_percentage) AS avg_roi
FROM product_a.campaigns c
LEFT JOIN product_a.brand_profiles b ON b.id = c.brand_id
LEFT JOIN product_a.campaign_analytics ca ON ca.campaign_id = c.id
GROUP BY c.id, c.campaign_name, c.workspace_id, c.brand_id, b.brand_name, c.status, c.budget;

-- Content Pipeline Overview
CREATE VIEW product_a.content_pipeline_overview AS
SELECT
  cc.workspace_id,
  cc.brand_id,
  b.brand_name,
  cc.status,
  cc.content_type,
  COUNT(*) AS content_count,
  COUNT(CASE WHEN cc.scheduled_date < now() THEN 1 END) AS overdue_count,
  COUNT(CASE WHEN cc.source_type = 'ai_generated' AND cc.approval_status = 'proposed' THEN 1 END) AS pending_approval_count
FROM product_a.content_calendar cc
LEFT JOIN product_a.brand_profiles b ON b.id = cc.brand_id
GROUP BY cc.workspace_id, cc.brand_id, b.brand_name, cc.status, cc.content_type;

-- Brand Activity Summary
CREATE VIEW product_a.brand_activity_summary AS
SELECT
  bp.id AS brand_id,
  bp.brand_name,
  bp.workspace_id,
  bp.brand_status,
  COUNT(DISTINCT c.id) AS total_campaigns,
  COUNT(DISTINCT CASE WHEN c.status = 'active' THEN c.id END) AS active_campaigns,
  COUNT(DISTINCT cc.id) AS total_content_items,
  COUNT(DISTINCT mr.id) AS total_marketing_requests,
  bp.created_at
FROM product_a.brand_profiles bp
LEFT JOIN product_a.campaigns c ON c.brand_id = bp.id
LEFT JOIN product_a.content_calendar cc ON cc.brand_id = bp.id
LEFT JOIN product_a.marketing_requests mr ON mr.brand_id = bp.id
GROUP BY bp.id, bp.brand_name, bp.workspace_id, bp.brand_status, bp.created_at;

-- ============================================================================
-- TRIGGERS FOR UPDATED_AT TIMESTAMPS
-- ============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION product_a.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to tables with updated_at column
CREATE TRIGGER update_brand_profiles_updated_at BEFORE UPDATE ON product_a.brand_profiles
  FOR EACH ROW EXECUTE FUNCTION product_a.update_updated_at_column();

CREATE TRIGGER update_campaigns_updated_at BEFORE UPDATE ON product_a.campaigns
  FOR EACH ROW EXECUTE FUNCTION product_a.update_updated_at_column();

CREATE TRIGGER update_content_calendar_updated_at BEFORE UPDATE ON product_a.content_calendar
  FOR EACH ROW EXECUTE FUNCTION product_a.update_updated_at_column();

CREATE TRIGGER update_content_pieces_updated_at BEFORE UPDATE ON product_a.content_pieces
  FOR EACH ROW EXECUTE FUNCTION product_a.update_updated_at_column();

CREATE TRIGGER update_marketing_requests_updated_at BEFORE UPDATE ON product_a.marketing_requests
  FOR EACH ROW EXECUTE FUNCTION product_a.update_updated_at_column();

CREATE TRIGGER update_review_comments_updated_at BEFORE UPDATE ON product_a.review_comments
  FOR EACH ROW EXECUTE FUNCTION product_a.update_updated_at_column();

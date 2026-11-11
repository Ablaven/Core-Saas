# Product A - Marketing & Brand Management Platform Schema

## 📋 Overview

Product A is a comprehensive **Marketing & Brand Management Platform** designed for marketing agencies, creative studios, and brand teams. It provides complete tools for:

- **Brand Management** - Manage multiple brands with assets, colors, and guidelines
- **Campaign Management** - Plan, execute, and track marketing campaigns
- **Content Calendar** - Schedule and manage content across channels
- **Marketing Requests** - Handle RFPs, RFQs, and creative briefs
- **Analytics & Reporting** - Track performance and ROI
- **Collaboration** - Review, comment, and approve content

---

## 🏗️ Schema Architecture

### Database Structure
```
product_a (schema)
├── Brand Management (4 tables)
│   ├── brand_profiles
│   ├── brand_colors
│   ├── brand_assets
│   └── brand_metrics
│
├── Campaign Management (3 tables)
│   ├── campaigns
│   ├── campaign_channels
│   └── campaign_analytics
│
├── Content Management (2 tables)
│   ├── content_calendar
│   └── content_pieces
│
├── Marketing Requests (2 tables)
│   ├── marketing_requests
│   └── request_responses
│
└── Collaboration (1 table)
    └── review_comments
```

**Total Tables:** 14
**Total Views:** 3
**Total Triggers:** 6

---

## 📊 Detailed Table Documentation

### 🎨 BRAND MANAGEMENT

#### 1. `brand_profiles`
Core brand entity containing all brand information.

**Columns:**
- `id` (uuid, PK) - Unique identifier
- `workspace_id` (uuid, FK) - Multi-tenant workspace
- `brand_name` (text) - Brand name (unique per workspace)
- `brand_description` (text) - Brand overview
- `logo_url` (text) - Brand logo URL
- `website_url` (text) - Brand website
- `industry` (text) - Industry/sector
- `target_audience` (text) - Target demographic
- `brand_status` (text) - active | inactive | archived
- `created_by` (uuid, FK) - User who created
- `created_at` (timestamptz) - Creation timestamp
- `updated_at` (timestamptz) - Last update timestamp

**Indexes:**
- `idx_brand_profiles_workspace` - Fast workspace queries
- `idx_brand_profiles_status` - Filter by status

**Unique Constraints:**
- `unique_workspace_brand` - Brand name unique per workspace

---

#### 2. `brand_colors`
Color palettes and brand colors for each brand.

**Columns:**
- `id` (uuid, PK) - Unique identifier
- `brand_id` (uuid, FK) - Reference to brand
- `color_name` (text) - Color name (e.g., "Primary Blue")
- `hex_value` (text) - Hex color code (e.g., "#0066CC")
- `color_type` (text) - primary | secondary | accent | background | text
- `usage_notes` (text) - Usage guidelines
- `created_at` (timestamptz) - Creation timestamp

**Use Cases:**
- Brand style guide enforcement
- Design consistency
- Template generation

---

#### 3. `brand_assets`
Store and manage brand assets (logos, images, fonts, documents).

**Columns:**
- `id` (uuid, PK) - Unique identifier
- `brand_id` (uuid, FK) - Reference to brand
- `asset_name` (text) - Asset name
- `asset_type` (text) - logo | image | font | document | video | other
- `file_url` (text) - S3/CDN URL to asset
- `file_size_bytes` (bigint) - File size
- `mime_type` (text) - MIME type
- `description` (text) - Asset description
- `uploaded_by` (uuid, FK) - User who uploaded
- `created_at` (timestamptz) - Upload timestamp

**Use Cases:**
- Centralized brand asset library
- Version control
- Easy sharing with teams/vendors

---

#### 4. `brand_metrics`
Track brand performance metrics over time.

**Columns:**
- `id` (uuid, PK) - Unique identifier
- `brand_id` (uuid, FK) - Reference to brand
- `metric_date` (date) - Date of metrics
- `brand_awareness_score` (numeric) - Awareness score (0-100)
- `sentiment_score` (numeric) - Sentiment analysis (-100 to 100)
- `social_mentions` (bigint) - Social media mentions
- `website_traffic` (bigint) - Website visits
- `engagement_score` (numeric) - Engagement rate (0-100)
- `additional_metrics` (jsonb) - Custom metrics
- `created_at` (timestamptz) - Creation timestamp

**Unique Constraints:**
- `unique_brand_date_metrics` - One record per brand per date

---

### 📢 CAMPAIGN MANAGEMENT

#### 5. `campaigns`
Marketing campaigns with budget, timeline, and goals.

**Columns:**
- `id` (uuid, PK) - Unique identifier
- `workspace_id` (uuid, FK) - Multi-tenant workspace
- `brand_id` (uuid, FK) - Reference to brand
- `project_id` (uuid, FK) - Optional project link
- `campaign_name` (text) - Campaign name
- `campaign_description` (text) - Campaign overview
- `campaign_type` (text) - social_media | email | content | paid_ads | seo | influencer | event | other
- `budget` (numeric) - Total budget
- `currency` (text) - Currency code (default: USD)
- `start_date` (date) - Campaign start
- `end_date` (date) - Campaign end
- `status` (text) - draft | planned | active | paused | completed | cancelled
- `target_audience` (text) - Target demographic
- `goals` (text) - Campaign objectives
- `kpi_metrics` (jsonb) - Key performance indicators
- `campaign_manager_id` (uuid, FK) - Campaign manager
- `created_by` (uuid, FK) - Creator
- `created_at` (timestamptz) - Creation timestamp
- `updated_at` (timestamptz) - Last update

**Indexes:**
- `idx_campaigns_workspace` - Fast workspace queries
- `idx_campaigns_brand` - Filter by brand
- `idx_campaigns_status` - Filter by status
- `idx_campaigns_dates` - Date range queries

---

#### 6. `campaign_channels`
Channels and platforms used in campaigns.

**Columns:**
- `id` (uuid, PK) - Unique identifier
- `campaign_id` (uuid, FK) - Reference to campaign
- `channel_name` (text) - facebook | instagram | twitter | linkedin | tiktok | youtube | google_ads | email | website | blog | other
- `budget_allocation` (numeric) - Budget for this channel
- `performance_metrics` (jsonb) - Channel-specific metrics
- `is_active` (boolean) - Channel active status
- `created_at` (timestamptz) - Creation timestamp

**Use Cases:**
- Multi-channel campaign management
- Budget allocation by channel
- Performance comparison

---

#### 7. `campaign_analytics`
Daily performance tracking for campaigns.

**Columns:**
- `id` (uuid, PK) - Unique identifier
- `campaign_id` (uuid, FK) - Reference to campaign
- `metric_date` (date) - Date of metrics
- `impressions` (bigint) - Total impressions
- `clicks` (bigint) - Total clicks
- `conversions` (bigint) - Total conversions
- `engagement_rate` (numeric) - Engagement percentage
- `cost_per_click` (numeric) - CPC
- `cost_per_conversion` (numeric) - Cost per conversion
- `roi_percentage` (numeric) - Return on investment %
- `additional_metrics` (jsonb) - Custom metrics
- `created_at` (timestamptz) - Creation timestamp

**Unique Constraints:**
- `unique_campaign_date_analytics` - One record per campaign per date

**Indexes:**
- `idx_campaign_analytics_campaign` - Fast campaign queries
- `idx_campaign_analytics_date` - Date filtering

---

### 📝 CONTENT MANAGEMENT

#### 8. `content_calendar`
Content planning and scheduling system.

**Columns:**
- `id` (uuid, PK) - Unique identifier
- `workspace_id` (uuid, FK) - Multi-tenant workspace
- `campaign_id` (uuid, FK) - Optional campaign link
- `brand_id` (uuid, FK) - Reference to brand
- `content_title` (text) - Content title
- `content_type` (text) - blog_post | social_post | video | infographic | email | whitepaper | case_study | other
- `content_description` (text) - Content brief
- `scheduled_date` (timestamptz) - Scheduled publish time
- `publish_date` (timestamptz) - Actual publish time
- `status` (text) - idea | planned | in_progress | review | scheduled | published | cancelled
- `assigned_to` (uuid, FK) - Assignee
- `source_type` (core.source_type) - manual | ai_generated
- `approval_status` (core.approval_status) - proposed | approved | rejected
- `approved_by` (uuid, FK) - Approver
- `approved_at` (timestamptz) - Approval timestamp
- `created_by` (uuid, FK) - Creator
- `created_at` (timestamptz) - Creation timestamp
- `updated_at` (timestamptz) - Last update

**AI Integration:**
- Supports AI-generated content ideas
- Approval workflow for AI content

**Indexes:**
- `idx_content_calendar_workspace` - Fast workspace queries
- `idx_content_calendar_campaign` - Filter by campaign
- `idx_content_calendar_scheduled` - Date filtering
- `idx_content_calendar_status` - Status filtering

---

#### 9. `content_pieces`
Actual content items with body, media, and performance.

**Columns:**
- `id` (uuid, PK) - Unique identifier
- `content_calendar_id` (uuid, FK) - Reference to calendar item
- `content_body` (text) - Content text/HTML
- `media_urls` (text[]) - Array of media URLs
- `tags` (text[]) - Content tags
- `target_channels` (text[]) - Target platforms
- `performance_metrics` (jsonb) - Post performance
- `created_at` (timestamptz) - Creation timestamp
- `updated_at` (timestamptz) - Last update

---

### 📋 MARKETING REQUESTS (RFP/RFQ System)

#### 10. `marketing_requests`
Request for proposals, quotes, and creative briefs.

**Columns:**
- `id` (uuid, PK) - Unique identifier
- `workspace_id` (uuid, FK) - Multi-tenant workspace
- `brand_id` (uuid, FK) - Reference to brand
- `request_title` (text) - Request title
- `request_description` (text) - Detailed requirements
- `request_type` (text) - rfp | rfq | rfr | creative_brief | vendor_request
- `budget_range_min` (numeric) - Minimum budget
- `budget_range_max` (numeric) - Maximum budget
- `deadline` (date) - Response deadline
- `status` (text) - draft | open | in_review | awarded | closed | cancelled
- `priority` (text) - low | medium | high | urgent
- `requirements` (jsonb) - Structured requirements
- `created_by` (uuid, FK) - Creator
- `assigned_to` (uuid, FK) - Reviewer
- `created_at` (timestamptz) - Creation timestamp
- `updated_at` (timestamptz) - Last update

**Indexes:**
- `idx_marketing_requests_workspace` - Fast workspace queries
- `idx_marketing_requests_brand` - Filter by brand
- `idx_marketing_requests_status` - Status filtering

---

#### 11. `request_responses`
Vendor/agency responses to marketing requests.

**Columns:**
- `id` (uuid, PK) - Unique identifier
- `request_id` (uuid, FK) - Reference to request
- `vendor_name` (text) - Vendor/agency name
- `vendor_contact_email` (text) - Contact email
- `vendor_contact_phone` (text) - Contact phone
- `proposal_summary` (text) - Proposal overview
- `proposed_budget` (numeric) - Quoted price
- `estimated_timeline` (text) - Timeline estimate
- `attachments` (text[]) - Proposal documents
- `status` (text) - submitted | under_review | shortlisted | accepted | rejected
- `review_notes` (text) - Internal notes
- `submitted_at` (timestamptz) - Submission timestamp
- `reviewed_by` (uuid, FK) - Reviewer
- `reviewed_at` (timestamptz) - Review timestamp

---

### 💬 COLLABORATION

#### 12. `review_comments`
Comments and feedback on campaigns, content, brands.

**Columns:**
- `id` (uuid, PK) - Unique identifier
- `workspace_id` (uuid, FK) - Multi-tenant workspace
- `entity_type` (text) - campaign | content | request | brand
- `entity_id` (uuid) - ID of the entity
- `comment_text` (text) - Comment content
- `comment_type` (text) - general | feedback | approval | revision_request
- `parent_comment_id` (uuid, FK) - For threaded comments
- `created_by` (uuid, FK) - Commenter
- `created_at` (timestamptz) - Creation timestamp
- `updated_at` (timestamptz) - Last update

**Features:**
- Threaded comments (replies)
- Multi-entity support
- Approval workflow

**Indexes:**
- `idx_review_comments_workspace` - Fast workspace queries
- `idx_review_comments_entity` - Filter by entity
- `idx_review_comments_parent` - Threaded comments

---

## 📊 Views & Reports

### 1. `campaign_performance_summary`
Aggregated campaign performance metrics.

**Columns:**
- `campaign_id` - Campaign UUID
- `campaign_name` - Campaign name
- `workspace_id` - Workspace UUID
- `brand_id` - Brand UUID
- `brand_name` - Brand name
- `status` - Campaign status
- `budget` - Total budget
- `total_analytics_records` - Number of daily records
- `total_impressions` - Sum of impressions
- `total_clicks` - Sum of clicks
- `total_conversions` - Sum of conversions
- `avg_engagement_rate` - Average engagement
- `avg_roi` - Average ROI percentage

**Use Cases:**
- Campaign dashboard
- Performance comparison
- Executive reporting

---

### 2. `content_pipeline_overview`
Content status and pipeline overview.

**Columns:**
- `workspace_id` - Workspace UUID
- `brand_id` - Brand UUID
- `brand_name` - Brand name
- `status` - Content status
- `content_type` - Content type
- `content_count` - Number of content items
- `overdue_count` - Past scheduled date
- `pending_approval_count` - AI content pending approval

**Use Cases:**
- Content planning
- Team workload management
- AI approval queue

---

### 3. `brand_activity_summary`
Brand-level activity overview.

**Columns:**
- `brand_id` - Brand UUID
- `brand_name` - Brand name
- `workspace_id` - Workspace UUID
- `brand_status` - Brand status
- `total_campaigns` - Count of all campaigns
- `active_campaigns` - Count of active campaigns
- `total_content_items` - Count of content items
- `total_marketing_requests` - Count of requests
- `created_at` - Brand creation date

**Use Cases:**
- Brand health check
- Resource allocation
- Executive dashboard

---

## 🔐 Security & Permissions

### Multi-Tenancy
All tables include `workspace_id` for complete tenant isolation:
- Users can only access data in their workspace(s)
- Workspace deletion cascades to all related data
- No cross-workspace data leakage

### Application Role: `team_a_app`
Permissions granted:
```sql
-- Core schema
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA core TO team_a_app;

-- Product A schema
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA product_a TO team_a_app;
```

### AI Content Approval
- **Manual content**: Auto-approved (`source_type = 'manual'`)
- **AI content**: Requires approval workflow
  - `approval_status = 'proposed'` (default)
  - Must be approved by a user before publication
  - Tracks `approved_by` and `approved_at`

---

## 🚀 Performance Optimizations

### Indexes
All critical foreign keys and query patterns are indexed:
- Workspace filtering (most common query)
- Brand filtering
- Status filtering
- Date range queries
- Entity relationships

### Triggers
Automatic `updated_at` timestamp management:
- `brand_profiles`
- `campaigns`
- `content_calendar`
- `content_pieces`
- `marketing_requests`
- `review_comments`

### JSONB Columns
Flexible data storage for:
- `kpi_metrics` - Campaign KPIs
- `performance_metrics` - Analytics data
- `requirements` - Request requirements
- `additional_metrics` - Custom metrics

**Benefits:**
- Schema flexibility
- No schema migrations for custom fields
- JSON query support in PostgreSQL

---

## 📈 Common Use Cases

### 1. Create a New Brand
```sql
INSERT INTO product_a.brand_profiles (
  workspace_id, brand_name, brand_description, industry, created_by
) VALUES (
  'workspace-uuid', 'Acme Corp', 'Tech startup', 'Technology', 'user-uuid'
) RETURNING *;
```

### 2. Launch a Campaign
```sql
INSERT INTO product_a.campaigns (
  workspace_id, brand_id, campaign_name, campaign_type, 
  budget, start_date, end_date, status
) VALUES (
  'workspace-uuid', 'brand-uuid', 'Summer Sale 2024', 'social_media',
  5000.00, '2024-06-01', '2024-08-31', 'planned'
) RETURNING *;
```

### 3. Schedule Content
```sql
INSERT INTO product_a.content_calendar (
  workspace_id, brand_id, campaign_id, content_title,
  content_type, scheduled_date, status, assigned_to
) VALUES (
  'workspace-uuid', 'brand-uuid', 'campaign-uuid',
  'Product Launch Post', 'social_post',
  '2024-06-15 10:00:00', 'planned', 'user-uuid'
) RETURNING *;
```

### 4. Track Campaign Performance
```sql
-- Get campaign summary
SELECT * FROM product_a.campaign_performance_summary
WHERE workspace_id = 'workspace-uuid'
ORDER BY avg_roi DESC;
```

### 5. Review Content Pipeline
```sql
-- Get content status overview
SELECT * FROM product_a.content_pipeline_overview
WHERE workspace_id = 'workspace-uuid'
AND status IN ('in_progress', 'review');
```

---

## 🧪 Sample Queries

### Get All Active Campaigns for a Brand
```sql
SELECT c.*, b.brand_name
FROM product_a.campaigns c
JOIN product_a.brand_profiles b ON b.id = c.brand_id
WHERE c.brand_id = 'brand-uuid'
  AND c.status = 'active'
ORDER BY c.start_date DESC;
```

### Get Overdue Content
```sql
SELECT cc.*, b.brand_name, u.first_name, u.last_name
FROM product_a.content_calendar cc
JOIN product_a.brand_profiles b ON b.id = cc.brand_id
LEFT JOIN core.users u ON u.id = cc.assigned_to
WHERE cc.workspace_id = 'workspace-uuid'
  AND cc.status NOT IN ('published', 'cancelled')
  AND cc.scheduled_date < now()
ORDER BY cc.scheduled_date ASC;
```

### Get AI Content Pending Approval
```sql
SELECT cc.*, b.brand_name
FROM product_a.content_calendar cc
JOIN product_a.brand_profiles b ON b.id = cc.brand_id
WHERE cc.workspace_id = 'workspace-uuid'
  AND cc.source_type = 'ai_generated'
  AND cc.approval_status = 'proposed'
ORDER BY cc.created_at ASC;
```

### Campaign ROI Ranking
```sql
SELECT 
  c.campaign_name,
  b.brand_name,
  c.budget,
  AVG(ca.roi_percentage) as avg_roi,
  SUM(ca.conversions) as total_conversions
FROM product_a.campaigns c
JOIN product_a.brand_profiles b ON b.id = c.brand_id
LEFT JOIN product_a.campaign_analytics ca ON ca.campaign_id = c.id
WHERE c.workspace_id = 'workspace-uuid'
  AND c.status IN ('active', 'completed')
GROUP BY c.id, c.campaign_name, b.brand_name, c.budget
ORDER BY avg_roi DESC NULLS LAST;
```

---

## 🔄 Migration Path

When deploying, migrations run in this order:
1. `001_schemas_types.sql` - Schemas and ENUMs
2. `002_core.sql` - Core tables
3. **`003_product_a.sql`** - Product A tables (this file)
4. `004_product_b.sql` - Product B tables
5. `005_roles.sql` - Roles and permissions
6. `006_seed.sql` - Seed data

---

## 📚 Additional Resources

- **Core Schema**: See `002_core.sql` for shared tables
- **Deployment**: See `DEPLOYMENT_CHECKLIST.md`
- **Validation**: See `COMPLETE_VALIDATION_REPORT.md`

---

**Built with ❤️ for Marketing Teams**
*Version: 1.0.0*
*Last Updated: 2024*

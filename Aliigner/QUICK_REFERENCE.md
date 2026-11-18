# Product A - Quick Reference Card

## 🚀 Quick Start Commands

### Deploy Database
```bash
cd Core_Project_Final
docker-compose up -d db
```

### Connect to Database
```bash
docker exec -it saas_postgres psql -U saas_admin -d saas_platform
```

### List Product A Tables
```sql
\dt product_a.*
```

---

## 📊 Table Summary

| Table | Purpose | Key Columns |
|-------|---------|-------------|
| `brand_profiles` | Brand management | brand_name, logo_url, status |
| `brand_colors` | Brand colors | color_name, hex_value, type |
| `brand_assets` | Media library | asset_name, file_url, type |
| `brand_metrics` | Brand performance | metric_date, awareness_score |
| `campaigns` | Campaign management | campaign_name, budget, status |
| `campaign_channels` | Multi-platform | channel_name, budget_allocation |
| `campaign_analytics` | Performance data | impressions, clicks, conversions |
| `content_calendar` | Content planning | title, scheduled_date, status |
| `content_pieces` | Content items | body, media_urls, tags |
| `marketing_requests` | RFP/RFQ system | title, type, status |
| `request_responses` | Vendor proposals | vendor_name, proposed_budget |
| `review_comments` | Collaboration | entity_type, comment_text |

---

## 🎯 Common Queries

### Get All Brands in Workspace
```sql
SELECT * FROM product_a.brand_profiles 
WHERE workspace_id = 'your-uuid' 
ORDER BY created_at DESC;
```

### Active Campaigns
```sql
SELECT c.*, b.brand_name 
FROM product_a.campaigns c
JOIN product_a.brand_profiles b ON b.id = c.brand_id
WHERE c.workspace_id = 'your-uuid' 
  AND c.status = 'active';
```

### Today's Scheduled Content
```sql
SELECT * FROM product_a.content_calendar
WHERE DATE(scheduled_date) = CURRENT_DATE
  AND status = 'scheduled';
```

### Campaign Performance
```sql
SELECT * FROM product_a.campaign_performance_summary
WHERE workspace_id = 'your-uuid'
ORDER BY avg_roi DESC;
```

### AI Content Pending Approval
```sql
SELECT * FROM product_a.content_calendar
WHERE source_type = 'ai_generated'
  AND approval_status = 'proposed';
```

---

## 🔐 Status Values

### Brand Status
- `active` - Active brand
- `inactive` - Temporarily inactive
- `archived` - Archived/deleted

### Campaign Status
- `draft` - Being planned
- `planned` - Ready to launch
- `active` - Currently running
- `paused` - Temporarily paused
- `completed` - Finished
- `cancelled` - Cancelled

### Content Status
- `idea` - Initial idea
- `planned` - Scheduled
- `in_progress` - Being created
- `review` - Under review
- `scheduled` - Scheduled for publish
- `published` - Published
- `cancelled` - Cancelled

### Request Status
- `draft` - Being created
- `open` - Accepting responses
- `in_review` - Reviewing proposals
- `awarded` - Vendor selected
- `closed` - Completed
- `cancelled` - Cancelled

---

## 🎨 Enum Types

### Campaign Types
`social_media`, `email`, `content`, `paid_ads`, `seo`, `influencer`, `event`, `other`

### Content Types
`blog_post`, `social_post`, `video`, `infographic`, `email`, `whitepaper`, `case_study`, `other`

### Channel Names
`facebook`, `instagram`, `twitter`, `linkedin`, `tiktok`, `youtube`, `google_ads`, `email`, `website`, `blog`, `other`

### Request Types
`rfp`, `rfq`, `rfr`, `creative_brief`, `vendor_request`

---

## 📈 Reporting Views

### Campaign Performance
```sql
SELECT * FROM product_a.campaign_performance_summary;
```

### Content Pipeline
```sql
SELECT * FROM product_a.content_pipeline_overview;
```

### Brand Activity
```sql
SELECT * FROM product_a.brand_activity_summary;
```

---

## 🔄 Insert Examples

### Create Brand
```sql
INSERT INTO product_a.brand_profiles (
  workspace_id, brand_name, industry, created_by
) VALUES (
  'workspace-uuid', 'Acme Corp', 'Technology', 'user-uuid'
) RETURNING *;
```

### Create Campaign
```sql
INSERT INTO product_a.campaigns (
  workspace_id, brand_id, campaign_name, 
  campaign_type, budget, status
) VALUES (
  'workspace-uuid', 'brand-uuid', 'Summer Sale',
  'social_media', 5000.00, 'planned'
) RETURNING *;
```

### Schedule Content
```sql
INSERT INTO product_a.content_calendar (
  workspace_id, brand_id, content_title,
  content_type, scheduled_date, status
) VALUES (
  'workspace-uuid', 'brand-uuid', 'Product Launch',
  'social_post', '2024-06-15 10:00:00', 'planned'
) RETURNING *;
```

---

## 🛠️ Maintenance

### Backup
```bash
docker exec saas_postgres pg_dump -U saas_admin saas_platform > backup.sql
```

### View Table Sizes
```sql
SELECT 
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'product_a'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

### Count Records
```sql
SELECT 
  'brand_profiles' as table, COUNT(*) FROM product_a.brand_profiles
UNION ALL
SELECT 'campaigns', COUNT(*) FROM product_a.campaigns
UNION ALL
SELECT 'content_calendar', COUNT(*) FROM product_a.content_calendar;
```

---

## 📚 Documentation Links

- Full Schema: `PRODUCT_A_SCHEMA_DOCUMENTATION.md`
- Creation Summary: `PRODUCT_A_CREATION_SUMMARY.md`
- Deployment: `../DEPLOYMENT_CHECKLIST.md`
- Validation: `../COMPLETE_VALIDATION_REPORT.md`

---

**Quick Reference v1.0** | *Keep this handy!*

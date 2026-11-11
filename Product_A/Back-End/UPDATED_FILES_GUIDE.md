# ✅ Updated Files - Quick Guide

## What Was Changed

I've updated **all existing files** to work with the Product A database schema (brands, campaigns, analytics). No new files were created - only the 5 existing files were enhanced.

---

## 📝 Files Updated (5)

### 1. ✅ **`.env`** - Configured
```env
DATABASE_URL, DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD
PORT, NODE_ENV, ALLOWED_ORIGINS
```

### 2. ✅ **`config/db.js`** - Enhanced
- Better connection pooling (max 20, timeouts)
- Connection error handling
- Test query on startup
- Export both `query` and `pool`

### 3. ✅ **`server.js`** - Complete Rewrite
- Better CORS configuration
- Request logging
- Enhanced health check with DB status
- Error handlers (404 + 500)
- Pretty startup banner with endpoints list

### 4. ✅ **`routes/orderRoutes.js`** - Now Multi-Purpose
- GET `/api/workspaces` - List workspaces
- GET `/api/brands` - List brands
- POST `/api/brands` - Create brand
- GET `/api/campaigns` - List campaigns
- POST `/api/campaigns` - Create campaign
- GET `/api/analytics/campaigns` - Campaign performance

### 5. ✅ **`controllers/orderController.js`** - Full Implementation
- `getWorkspaces()` - Fetch all workspaces
- `getBrands()` - Fetch brands by workspace
- `createBrand()` - Create new brand
- `getCampaigns()` - Fetch campaigns by workspace
- `createCampaign()` - Create new campaign
- `getCampaignPerformance()` - Get analytics view

---

## 🚀 How to Run

### Step 1: Install Dependencies (if needed)
```bash
cd Product_A/Back-End
npm install
```

### Step 2: Make Sure Database is Running
```bash
cd ../../..  # Back to Core_Project_Final root
docker-compose up -d db
```

### Step 3: Start the API
```bash
cd Product_A/Back-End
npm start
```

You should see:
```
╔════════════════════════════════════════════════════════════════╗
║  🚀 Product A - Marketing Platform API                        ║
║  📍 Server: http://localhost:5000                              ║
║  🗄️  Database: saas_platform                                   ║
║  🌍 Environment: development                                   ║
╚════════════════════════════════════════════════════════════════╝
```

---

## 📋 Available Endpoints

### Health Check
```
GET http://localhost:5000/
```
**Response:**
```json
{
  "message": "✅ Product A Marketing Platform API is running!",
  "timestamp": "2024-...",
  "database": "Connected",
  "endpoints": { ... }
}
```

### Get All Workspaces
```
GET http://localhost:5000/api/workspaces
```
**Response:**
```json
{
  "status": "success",
  "count": 2,
  "data": [
    {
      "id": "uuid...",
      "name": "Marketing Agency Demo",
      "product_code": "PROD_A",
      "created_at": "2024-..."
    }
  ]
}
```

### Get Brands
```
GET http://localhost:5000/api/brands?workspace_id={uuid}
```
**Required Query Parameter:** `workspace_id` (UUID from workspaces)

**Response:**
```json
{
  "status": "success",
  "count": 0,
  "data": []
}
```

### Create Brand
```
POST http://localhost:5000/api/brands
Content-Type: application/json

{
  "workspace_id": "uuid-from-workspaces",
  "brand_name": "Acme Corp",
  "brand_description": "Tech startup focused on innovation",
  "logo_url": "https://example.com/logo.png",
  "website_url": "https://acme.com",
  "industry": "Technology",
  "target_audience": "B2B SaaS companies"
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Brand created successfully",
  "data": {
    "id": "new-uuid...",
    "workspace_id": "...",
    "brand_name": "Acme Corp",
    ...
  }
}
```

### Get Campaigns
```
GET http://localhost:5000/api/campaigns?workspace_id={uuid}
```
**Required Query Parameter:** `workspace_id`

**Response:**
```json
{
  "status": "success",
  "count": 0,
  "data": []
}
```

### Create Campaign
```
POST http://localhost:5000/api/campaigns
Content-Type: application/json

{
  "workspace_id": "uuid-from-workspaces",
  "brand_id": "uuid-from-brands",
  "campaign_name": "Summer Sale 2024",
  "campaign_description": "Annual summer promotion",
  "campaign_type": "social_media",
  "budget": 5000.00,
  "start_date": "2024-06-01",
  "end_date": "2024-08-31",
  "status": "planned"
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Campaign created successfully",
  "data": {
    "id": "new-uuid...",
    "campaign_name": "Summer Sale 2024",
    ...
  }
}
```

### Get Campaign Performance
```
GET http://localhost:5000/api/analytics/campaigns?workspace_id={uuid}
```
**Required Query Parameter:** `workspace_id`

**Response:**
```json
{
  "status": "success",
  "count": 0,
  "data": []
}
```
*Note: Will show data once campaigns have analytics records*

---

## 🧪 Testing with cURL

### Get Workspaces
```bash
curl http://localhost:5000/api/workspaces
```

### Get Brands (replace UUID)
```bash
curl "http://localhost:5000/api/brands?workspace_id=YOUR-UUID-HERE"
```

### Create Brand
```bash
curl -X POST http://localhost:5000/api/brands \
  -H "Content-Type: application/json" \
  -d '{
    "workspace_id": "YOUR-UUID-HERE",
    "brand_name": "Test Brand",
    "brand_description": "This is a test brand",
    "industry": "Technology"
  }'
```

---

## 🔍 Workflow Example

### 1. Get a Workspace ID
```bash
curl http://localhost:5000/api/workspaces
# Copy the "id" from response
```

### 2. Create a Brand
```bash
curl -X POST http://localhost:5000/api/brands \
  -H "Content-Type: application/json" \
  -d '{
    "workspace_id": "PASTE-UUID-HERE",
    "brand_name": "My First Brand"
  }'
# Copy the brand "id" from response
```

### 3. Get All Brands
```bash
curl "http://localhost:5000/api/brands?workspace_id=WORKSPACE-UUID"
```

### 4. Create a Campaign
```bash
curl -X POST http://localhost:5000/api/campaigns \
  -H "Content-Type: application/json" \
  -d '{
    "workspace_id": "WORKSPACE-UUID",
    "brand_id": "BRAND-UUID",
    "campaign_name": "Launch Campaign",
    "campaign_type": "social_media",
    "budget": 1000
  }'
```

### 5. Get All Campaigns
```bash
curl "http://localhost:5000/api/campaigns?workspace_id=WORKSPACE-UUID"
```

---

## ⚠️ Important Notes

### Multi-Tenancy
- **All queries require `workspace_id`**
- Brands and campaigns are filtered by workspace
- Users can only see data in their workspace

### UUID Format
- All IDs are UUIDs (e.g., `550e8400-e29b-41d4-a716-446655440000`)
- Invalid UUIDs will cause database errors
- Copy UUIDs exactly from responses

### Error Responses
```json
{
  "status": "error",
  "message": "workspace_id is required"
}
```

---

## 🐛 Troubleshooting

### Error: "workspace_id is required"
**Solution:** Add `?workspace_id=YOUR-UUID` to the URL

### Error: "database connection failed"
**Solution:** Make sure Docker database is running:
```bash
docker-compose ps  # Check if saas_postgres is running
docker-compose up -d db  # Start if not running
```

### Error: "Port 5000 already in use"
**Solution:** Change PORT in `.env` file or kill the process:
```bash
# Windows
netstat -ano | findstr :5000
taskkill /PID <PID> /F

# Or change PORT in .env
PORT=5001
```

---

## 📊 What Works Now

✅ Connect to PostgreSQL database (saas_platform)
✅ Fetch all workspaces
✅ Fetch brands by workspace (multi-tenant)
✅ Create new brands with UUID primary keys
✅ Fetch campaigns by workspace (multi-tenant)
✅ Create new campaigns linked to brands
✅ Get campaign performance analytics (view)
✅ Proper error handling
✅ CORS enabled
✅ Request logging

---

## 🎯 What This Connects To

### Database Tables Used:
- `core.workspaces` - Workspace list
- `product_a.brand_profiles` - Brand management
- `product_a.campaigns` - Campaign management
- `product_a.campaign_performance_summary` - Analytics view

### Database Features Supported:
- ✅ UUID primary keys
- ✅ Multi-tenant (workspace_id filtering)
- ✅ Foreign key relationships (brand → campaigns)
- ✅ Database views (analytics)

---

## 🚀 Next Steps (Optional)

If you want to add more features later:
1. Add authentication (JWT)
2. Add more endpoints (content, requests, etc.)
3. Add input validation (Joi)
4. Add rate limiting
5. Add pagination for large datasets

But for now, **the existing 5 files are fully functional** with brands, campaigns, and analytics! 🎉

---

**Updated Files:** 5
**New Endpoints:** 6
**Database Tables:** 4 (workspaces, brands, campaigns, analytics view)
**Status:** ✅ Ready to Use!

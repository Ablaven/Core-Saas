# Multi-Tenant SaaS Platform

A full-stack PostgreSQL-based multi-tenant SaaS platform with Node.js/Express backend, supporting multiple products (Aliigner & CreatiX), AI-generated content with approval workflows, and comprehensive role-based access control.

## 🏗️ Project Structure

```
Core_Project_Final/
├── Core/
│   └── Back-End/               # Node.js/Express API Backend
│       ├── src/
│       │   ├── config/         # Database & environment configuration
│       │   ├── middleware/     # Auth, RBAC, tenant isolation, validation
│       │   ├── routes/         # API route definitions
│       │   ├── controllers/    # Request handlers
│       │   ├── services/       # Business logic layer
│       │   ├── server.js       # Entry point
│       │   └── app.js          # Express app configuration
│       ├── test/               # Jest test suites
│       ├── package.json        # Dependencies
│       ├── .env.example        # Environment template
│       └── Dockerfile          # Container definition
│
├── db/                         # PostgreSQL Schema & Migrations
│   ├── 001_schemas_types.sql   # Schemas & custom types
│   ├── 002_core.sql            # Core tables (workspaces, users, projects)
│   ├── 003_Aliigner.sql        # Product A: Brand & Marketing Management
│   ├── 004_CreatiX.sql         # Product B: Campaign & Market Insights
│   ├── 005_roles.sql           # Application roles & permissions
│   ├── 006_seed.sql            # Seed data
│   └── 007_core_rls.sql        # Row-level security policies
│
├── Aliigner/                   # Product A Frontend (TBD)
├── CreatiX/                    # Product B Frontend (TBD)
├── docker-compose.yml          # Multi-service orchestration
├── .env                        # Environment configuration
└── README.md                   # This file
```

## 🚀 Quick Start

### Prerequisites
- **Node.js** 22.x or higher
- **Docker & Docker Compose**
- **PostgreSQL Client** (optional, for manual connections)
- **npm** 10.x or higher

### 1. Clone & Navigate
```bash
cd C:\Users\Ablaven\Desktop\WebSties\Core_Project_Final
```

### 2. Environment Setup
```bash
# Copy and configure environment variables
cp .env.example .env
# Edit .env with your configuration
```

### 3. Database Setup
```bash
# Start PostgreSQL database
docker-compose up -d db

# Verify database is running
docker-compose ps
docker-compose logs db

# Wait for initialization (check health status)
docker-compose exec db pg_isready -U saas_admin -d saas_platform
```

### 4. Backend Setup
```bash
# Navigate to backend directory
cd Core/Back-End

# Install dependencies
npm install

# Copy environment configuration
cp .env.example .env

# Configure your .env file with:
# - DATABASE_URL=postgresql://saas_admin:your_password@localhost:5432/saas_platform
# - JWT_SECRET=your_secure_secret
# - PORT=3000

# Start development server
npm run dev
```

### 5. Verify Installation
```bash
# Backend should be running on http://localhost:3000
# Database accessible on localhost:5432
```

## 🏛️ Architecture Overview

### Multi-Tenancy Model
- **Workspace-based isolation**: Each workspace is a tenant
- **Shared schema approach**: All tenants share tables with `workspace_id` filtering
- **Product-specific schemas**: Separate schemas for Aliigner and CreatiX

### Technology Stack

#### Backend
- **Runtime**: Node.js 22.x
- **Framework**: Express 4.x
- **Database Client**: node-postgres (pg)
- **Authentication**: JWT with bcrypt password hashing
- **Validation**: Joi schema validation
- **Security**: Helmet, CORS, express-rate-limit
- **Testing**: Jest + Supertest
- **Development**: Nodemon for hot-reload

#### Database
- **PostgreSQL 16+** with UUID v4 primary keys
- **Multi-schema design**: `core`, `product_a`, `product_b`
- **Custom types**: `source_type`, `approval_status`
- **Row-Level Security (RLS)** for tenant isolation

### API Architecture
```
Request → Routes → Controllers → Services → Database
            ↓
       Middleware Chain:
       - Error Handler
       - Auth (JWT verification)
       - Tenant Isolation
       - Role-Based Access Control (RBAC)
       - Input Validation
```

## 📊 Database Schema

### Core Schema (`core`)

**workspaces** - Multi-tenant workspaces
- `id` (uuid PK), `name`, `product_code`, `created_at`

**users** - Platform users
- `id` (uuid PK), `email` (unique), `password_hash`, `first_name`, `last_name`, `account_status`

**roles** - System roles
- `id` (uuid PK), `role_name` (Admin | Manager | Member | Viewer)

**workspace_members** - User ↔ Workspace ↔ Role mapping
- `workspace_id`, `user_id`, `role_id`

**projects** - Client projects
- `id`, `workspace_id`, `client_id`, `manager_id`, `name`, `status`

**tasks** - Project tasks with AI approval
- `id`, `workspace_id`, `phase_id`, `assigned_to`, `source_type`, `approval_status`

### Product A Schema (`product_a`) - Aliigner

**Brand Management**
- `brand_profiles`, `brand_colors`, `brand_assets`

**Campaign Management**
- `campaigns`, `campaign_channels`, `campaign_analytics`

**Content Management**
- `content_calendar`, `content_pieces`

**Marketing Requests**
- `marketing_requests`, `request_responses`

### Product B Schema (`product_b`) - CreatiX

**Agency Management**
- `agencies`, `agency_members`, `agency_invitations`, `agency_reviews`

**Client Management**
- `client_companies`, `client_users`

**Project Management**
- `proposals`, `proposal_items`, `project_sources`, `project_members`

**Campaign & Analytics**
- `campaigns`, `campaign_metrics`, `competitors`, `competitor_analyses`, `trend_analyses`

**AI Features**
- `ai_suggestions`

## 🔐 Security & Authentication

### JWT Authentication
- Token-based authentication with refresh tokens
- Secure password hashing using bcrypt (cost factor: 10)
- Token expiration: 1h (access), 7d (refresh)

### Role-Based Access Control (RBAC)
- **Admin**: Full workspace control
- **Manager**: Project management + team oversight
- **Member**: Task execution + collaboration
- **Viewer**: Read-only access

### Database Roles
- **team_a_app**: Access to `core` + `product_a` schemas
- **team_b_app**: Access to `core` + `product_b` schemas

### Security Headers (Helmet)
- XSS Protection
- Content Security Policy
- HSTS (HTTP Strict Transport Security)
- Frame Options (DENY)

## 🤖 AI Integration

### AI-Generated Content Workflow
1. **Generation**: AI creates tasks/summaries with `source_type: 'ai_generated'`
2. **Proposal**: Content marked as `approval_status: 'proposed'`
3. **Review**: Human reviews and approves/rejects
4. **Approval**: Updates `approved_by` and `approved_at` fields

### Approval States
- `proposed` - Awaiting review
- `approved` - Accepted by human reviewer
- `rejected` - Declined by human reviewer

## 🛠️ Backend API

### Available Scripts

```bash
# Development (with hot-reload)
npm run dev

# Production
npm start

# Testing
npm test                 # Run all tests
npm run test:watch      # Watch mode

# Linting (if configured)
npm run lint
```

### Environment Variables (Backend)

Create `Core/Back-End/.env`:

```env
# Application
NODE_ENV=development
PORT=3000

# Database
DATABASE_URL=postgresql://saas_admin:password@localhost:5432/saas_platform
DB_HOST=localhost
DB_PORT=5432
DB_NAME=saas_platform
DB_USER=saas_admin
DB_PASSWORD=your_secure_password

# JWT Authentication
JWT_SECRET=your_very_secure_secret_key_here
JWT_EXPIRES_IN=1h
JWT_REFRESH_SECRET=your_refresh_token_secret
JWT_REFRESH_EXPIRES_IN=7d

# Security
BCRYPT_ROUNDS=10

# CORS
CORS_ORIGIN=http://localhost:5173

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

## 🔍 API Endpoints (Planned)

### Authentication
```
POST   /api/auth/register          # User registration
POST   /api/auth/login             # User login
POST   /api/auth/refresh           # Refresh access token
POST   /api/auth/logout            # User logout
```

### Workspaces
```
GET    /api/workspaces             # List user workspaces
POST   /api/workspaces             # Create workspace
GET    /api/workspaces/:id         # Get workspace details
PUT    /api/workspaces/:id         # Update workspace
DELETE /api/workspaces/:id         # Delete workspace
```

### Users
```
GET    /api/users/me               # Current user profile
PUT    /api/users/me               # Update profile
GET    /api/users                  # List workspace users (Admin)
```

### Members
```
GET    /api/workspaces/:id/members           # List members
POST   /api/workspaces/:id/members           # Invite member
DELETE /api/workspaces/:id/members/:userId   # Remove member
PUT    /api/workspaces/:id/members/:userId   # Update role
```

## 🗄️ Database Management

### Access Database
```bash
# Via Docker
docker exec -it saas_postgres psql -U saas_admin -d saas_platform

# Via local psql
psql -h localhost -p 5432 -U saas_admin -d saas_platform
```

### Common Commands
```sql
-- List all schemas
\dn

-- List tables in core schema
\dt core.*

-- View all workspaces
SELECT * FROM core.workspaces;

-- Check pending AI approvals
SELECT * FROM core.tasks 
WHERE source_type = 'ai_generated' 
  AND approval_status = 'proposed';

-- View project progress
SELECT * FROM core.project_progress;
```

### Backup & Restore
```bash
# Backup
docker exec saas_postgres pg_dump -U saas_admin saas_platform > backup_$(date +%Y%m%d).sql

# Restore
docker exec -i saas_postgres psql -U saas_admin saas_platform < backup.sql
```

## 🧪 Testing

### Run Tests
```bash
cd Core/Back-End
npm test                    # Run all tests
npm run test:watch          # Watch mode with coverage
```

### Test Structure
```
test/
├── auth.test.js           # JWT authentication tests
├── tenant.test.js         # Multi-tenancy isolation tests
└── rbac.test.js           # Role-based access control tests
```

## 📦 Docker Services

### Available Services
```bash
# Start database only
docker-compose up -d db

# Start with pgAdmin
docker-compose --profile admin up -d

# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Remove all data (⚠️ destructive)
docker-compose down -v
```

### pgAdmin Access
- URL: http://localhost:5050
- Email: admin@saas.local
- Password: (from .env)

## 🐛 Troubleshooting

### Backend won't start
```bash
# Check Node.js version
node --version    # Should be 22.x

# Clear node_modules and reinstall
cd Core/Back-End
rm -rf node_modules package-lock.json
npm install

# Check environment variables
cat .env
```

### Database connection fails
```bash
# Verify database is running
docker-compose ps

# Check logs
docker-compose logs db

# Test connection
docker exec -it saas_postgres pg_isready -U saas_admin
```

### Port already in use
```bash
# Check what's using port 3000
netstat -ano | findstr :3000

# Change PORT in .env
PORT=3001
```

### npm vulnerabilities
```bash
# Update to latest secure versions
npm update

# Audit and fix
npm audit fix

# Note: Some vulnerabilities in bcrypt's build dependencies are safe to ignore
```

## 📚 Additional Resources

- [Express.js Documentation](https://expressjs.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [JWT.io](https://jwt.io/)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)

## 🤝 Contributing

### Adding New Features
1. Update SQL schema in `/db`
2. Create migration script if needed
3. Update backend services/controllers
4. Add tests
5. Update this README

### Code Style
- Use ES6+ features
- Follow async/await pattern
- Maintain Routes → Controllers → Services architecture
- Add JSDoc comments for functions

## 📄 License

[Add your license here]

---

**Database Schema Version**: 1.0.0  
**Backend API Version**: 1.0.0  
**Last Updated**: 2026-11-19

**God help us all** 🙏

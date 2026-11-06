# Multi-Tenant SaaS Platform - Database Schema

A PostgreSQL-based multi-tenant SaaS platform with support for multiple products (Product A & Product B), AI-generated content with approval workflows, and comprehensive role-based access control.

## 🏗️ Architecture Overview

### Multi-Tenancy Model
- **Workspace-based isolation**: Each workspace is a tenant
- **Shared schema approach**: All tenants share the same tables with workspace_id filtering
- **Product-specific schemas**: Separate schemas for Product A and Product B features

### Schema Structure
```
├── core (shared across all products)
│   ├── workspaces
│   ├── users
│   ├── roles
│   ├── workspace_members
│   ├── clients
│   ├── projects
│   ├── phases
│   ├── tasks
│   ├── meetings
│   └── meeting_summaries
├── product_a (Product A specific)
│   ├── brand_profiles
│   └── marketing_requests
└── product_b (Product B specific)
    └── campaigns
```

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose
- PostgreSQL client (optional, for manual connections)

### Setup Instructions

1. **Clone/Navigate to project directory**
   ```bash
   cd Core_Project_Final
   ```

2. **Configure environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

3. **Start the database**
   ```bash
   # Start database only
   docker-compose up -d db
   
   # Start with pgAdmin (optional)
   docker-compose --profile admin up -d
   ```

4. **Verify database is running**
   ```bash
   docker-compose ps
   docker-compose logs db
   ```

5. **Connect to database**
   ```bash
   docker exec -it saas_postgres psql -U saas_admin -d saas_platform
   ```

### Database Initialization

The database is automatically initialized with all schemas, tables, and seed data when the container starts. The SQL files are executed in order:

1. `001_schemas_types.sql` - Creates schemas and custom types
2. `002_core.sql` - Creates core tables
3. `003_product_a.sql` - Creates Product A tables
4. `004_product_b.sql` - Creates Product B tables
5. `005_roles.sql` - Creates application roles and permissions
6. `006_seed.sql` - Inserts seed data

## 📊 Database Schema

### Core Tables

#### workspaces
Multi-tenant workspaces (one per customer/organization)
```sql
- id: uuid (PK)
- name: text
- product_code: text (PROD_A | PROD_B)
- created_at: timestamptz
```

#### users
Platform users across all workspaces
```sql
- id: uuid (PK)
- email: text (unique)
- password_hash: text
- first_name: text
- last_name: text
- avatar_url: text
- account_status: text (active | suspended | pending)
- created_at: timestamptz
```

#### roles
System-wide roles
```sql
- id: uuid (PK)
- role_name: text (unique) - Admin, Manager, Member, Viewer
```

#### workspace_members
User membership in workspaces
```sql
- id: uuid (PK)
- workspace_id: uuid (FK → workspaces)
- user_id: uuid (FK → users)
- role_id: uuid (FK → roles)
- joined_at: timestamptz
```

#### projects
Client projects within workspaces
```sql
- id: uuid (PK)
- workspace_id: uuid (FK → workspaces)
- client_id: uuid (FK → clients)
- manager_id: uuid (FK → users)
- name: text
- status: text (planned | active | on_hold | completed | cancelled)
- created_at: timestamptz
```

#### tasks
Project tasks with AI approval workflow
```sql
- id: uuid (PK)
- workspace_id: uuid (FK → workspaces)
- phase_id: uuid (FK → phases)
- assigned_to: uuid (FK → users)
- title: text
- status: text (todo | in_progress | review | done)
- source_type: enum (manual | ai_generated)
- approval_status: enum (proposed | approved | rejected)
- approved_by: uuid (FK → users)
- approved_at: timestamptz
```

### Product A Tables

#### brand_profiles
Marketing brand profiles
```sql
- id: uuid (PK)
- workspace_id: uuid (FK → workspaces)
- brand_name: text
```

#### marketing_requests
Marketing campaign requests
```sql
- id: uuid (PK)
- workspace_id: uuid (FK → workspaces)
- brand_id: uuid (FK → brand_profiles)
- title: text
- status: text (draft | open | awarded | closed | cancelled)
```

### Product B Tables

#### campaigns
Marketing campaigns
```sql
- id: uuid (PK)
- workspace_id: uuid (FK → workspaces)
- project_id: uuid (FK → projects)
- campaign_name: text
- budget: numeric(12,2)
```

## 🔐 Security & Permissions

### Application Roles

Two application-level roles are created automatically:

- **team_a_app**: Full access to `core` and `product_a` schemas
- **team_b_app**: Full access to `core` and `product_b` schemas

### Permission Model

```sql
# Team A Permissions
- core: SELECT, INSERT, UPDATE
- product_a: SELECT, INSERT, UPDATE, DELETE

# Team B Permissions
- core: SELECT, INSERT, UPDATE
- product_b: SELECT, INSERT, UPDATE, DELETE
```

## 🤖 AI Integration & Approval Workflow

### AI-Generated Content

Tasks and meeting summaries can be:
1. **Manually created** (`source_type: 'manual'`) - Auto-approved
2. **AI-generated** (`source_type: 'ai_generated'`) - Requires approval

### Approval States
- `proposed` - Awaiting review
- `approved` - Reviewed and accepted
- `rejected` - Reviewed and declined

### Approval Requirements
AI-generated content requires:
- `approved_by` (user UUID)
- `approved_at` (timestamp)

## 🔍 Views & Computed Data

### project_progress
Real-time project completion percentage
```sql
SELECT * FROM core.project_progress;
-- Returns: project_id, progress_pct
```

## 🛠️ Management Commands

### Database Management

```bash
# Stop database
docker-compose down

# Stop and remove volumes (⚠️ destroys all data)
docker-compose down -v

# View logs
docker-compose logs -f db

# Backup database
docker exec saas_postgres pg_dump -U saas_admin saas_platform > backup.sql

# Restore database
docker exec -i saas_postgres psql -U saas_admin saas_platform < backup.sql
```

### Access pgAdmin (if enabled)

1. Start with admin profile: `docker-compose --profile admin up -d`
2. Navigate to: http://localhost:5050
3. Login with credentials from `.env`
4. Add server:
   - Host: `db` (or `host.docker.internal` on Windows/Mac)
   - Port: `5432`
   - Username: from `.env` (POSTGRES_USER)
   - Password: from `.env` (POSTGRES_PASSWORD)

## 📝 Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `POSTGRES_DB` | Database name | `saas_platform` |
| `POSTGRES_USER` | Admin username | `saas_admin` |
| `POSTGRES_PASSWORD` | Admin password | *(required)* |
| `DB_HOST` | Database host | `localhost` |
| `DB_PORT` | Database port | `5432` |
| `TEAM_A_PASSWORD` | Product A app role password | *(required)* |
| `TEAM_B_PASSWORD` | Product B app role password | *(required)* |

## 🧪 Testing

### Connect via psql

```bash
docker exec -it saas_postgres psql -U saas_admin -d saas_platform
```

### Sample Queries

```sql
-- List all schemas
\dn

-- List all tables in core schema
\dt core.*

-- View all workspaces
SELECT * FROM core.workspaces;

-- View all roles
SELECT * FROM core.roles;

-- Get project progress
SELECT * FROM core.project_progress;

-- Check AI-generated tasks pending approval
SELECT * FROM core.tasks 
WHERE source_type = 'ai_generated' 
  AND approval_status = 'proposed';
```

## 📚 Additional Documentation

- `SQL_FIXES_SUMMARY.md` - Details of SQL fixes applied
- `SaaS_Review_Feedback_English.docx` - Comprehensive review and feedback

## 🤝 Contributing

When adding new features:
1. Update the appropriate SQL file in `/db`
2. Follow UUID primary key pattern
3. Include workspace_id for multi-tenancy
4. Add proper foreign key constraints with ON DELETE CASCADE
5. Update this README with schema changes

## 📄 License

[Add your license here]

## 🐛 Troubleshooting

### Database won't start
```bash
# Check logs
docker-compose logs db

# Remove and recreate
docker-compose down -v
docker-compose up -d
```

### Permission denied errors
- Ensure SQL files have read permissions
- Check Docker volume permissions

### Connection refused
- Wait for health check to pass (~30 seconds)
- Verify port 5432 isn't already in use
- Check firewall settings

---

**Gold Help us all**

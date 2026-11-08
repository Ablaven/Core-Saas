-- ============================================================
-- TEAM B - CAMPAIGN & MARKET INSIGHTS
-- All external tables are expected to exist in the "core" schema
-- ============================================================

SET search_path TO product_b, core, public;

-- 1. Agencies
CREATE TABLE agencies (
    agency_id           SERIAL PRIMARY KEY,
    workspace_id        UUID NOT NULL REFERENCES core.workspaces(id),
    name                VARCHAR(150) NOT NULL,
    description         TEXT,
    website_url         VARCHAR(255),
    logo_url            VARCHAR(500),
    country             VARCHAR(100),
    city                VARCHAR(100),
    business_email      VARCHAR(255),
    phone               VARCHAR(30),
    profile_status      VARCHAR(30) DEFAULT 'pending',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Agency Members
CREATE TABLE agency_members (
    agency_member_id    SERIAL PRIMARY KEY,
    agency_id           INTEGER NOT NULL REFERENCES agencies(agency_id) ON DELETE CASCADE,
    user_id             UUID NOT NULL REFERENCES core.users(id),
    member_status       VARCHAR(30) DEFAULT 'active',
    joined_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    workspace_id UUID NOT NULL REFERENCES core.workspaces(id),
    UNIQUE (agency_id, user_id)
);

-- 3. Client Companies
CREATE TABLE client_companies (
    client_company_id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id        UUID NOT NULL REFERENCES core.workspaces(id),
    owner_user_id       UUID NOT NULL REFERENCES core.users(id),
    legal_name          VARCHAR(200) NOT NULL,
    display_name        VARCHAR(150),
    website_url         VARCHAR(255),
    country             VARCHAR(100),
    city                VARCHAR(100),
    company_size        VARCHAR(50),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. Client Users
CREATE TABLE client_users (
    client_user_id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_company_id   UUID NOT NULL REFERENCES client_companies(client_company_id) ON DELETE CASCADE,
    user_id             UUID NOT NULL REFERENCES core.users(id),
    workspace_id UUID NOT NULL REFERENCES core.workspaces(id),
    UNIQUE (client_company_id, user_id)
);

-- 5. Services
CREATE TABLE services (
    service_id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name                VARCHAR(150) NOT NULL,
    category            VARCHAR(100),
    description         TEXT,
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 6. Marketing Requests
CREATE TABLE marketing_requests (
    request_id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id        UUID NOT NULL REFERENCES core.workspaces(id),
    created_by_user_id  UUID NOT NULL REFERENCES core.users(id),
    title               VARCHAR(200) NOT NULL,
    brief               TEXT,
    marketing_goals     TEXT,
    target_audience     TEXT,
    budget_min          DECIMAL(12,2),
    budget_max          DECIMAL(12,2),
    status              VARCHAR(30) DEFAULT 'draft',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 7. Request Services
CREATE TABLE request_services (
    request_service_id  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    request_id          UUID NOT NULL REFERENCES marketing_requests(request_id) ON DELETE CASCADE,
    service_id          UUID NOT NULL REFERENCES services(service_id),
    requirements_notes  TEXT,
    priority            VARCHAR(20) DEFAULT 'medium',
    workspace_id UUID NOT NULL REFERENCES core.workspaces(id),
    UNIQUE (request_id, service_id)
);

-- 8. Agency Invitations
CREATE TABLE agency_invitations (
    invitation_id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    request_id          UUID NOT NULL REFERENCES marketing_requests(request_id) ON DELETE CASCADE,
    agency_id           INTEGER NOT NULL REFERENCES agencies(agency_id),
    created_by_user_id  UUID NOT NULL REFERENCES core.users(id),
    invited_to_user_id  UUID REFERENCES core.users(id),
    status              VARCHAR(30) DEFAULT 'pending',
    invited_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    viewed_at           TIMESTAMPTZ,
    workspace_id UUID NOT NULL REFERENCES core.workspaces(id),
    response_deadline   TIMESTAMPTZ
);

-- 9. Proposals
CREATE TABLE proposals (
    proposal_id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id        UUID NOT NULL REFERENCES core.workspaces(id),
    request_id          UUID NOT NULL REFERENCES marketing_requests(request_id),
    invitation_id       UUID REFERENCES agency_invitations(invitation_id),
    title               VARCHAR(200) NOT NULL,
    strategy_summary    TEXT,
    total_price         DECIMAL(14,2),
    currency_code       VARCHAR(10) DEFAULT 'EGP',
    status              VARCHAR(30) DEFAULT 'draft',
    approval_status     VARCHAR(20) CHECK (approval_status IN ('proposed', 'approved', 'rejected')),
    approved_by         UUID REFERENCES core.users(id),
    approved_at         TIMESTAMPTZ,
    submitted_at        TIMESTAMPTZ,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_approved_requires_fields
        CHECK (
            (approval_status = 'approved' AND approved_by IS NOT NULL AND approved_at IS NOT NULL)
            OR approval_status <> 'approved'
        )
);

-- 10. Proposal Items
CREATE TABLE proposal_items (
    proposal_item_id    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    proposal_id         UUID NOT NULL REFERENCES proposals(proposal_id) ON DELETE CASCADE,
    service_id          UUID REFERENCES services(service_id),
    item_name           VARCHAR(150) NOT NULL,
    description         TEXT,
    quantity            INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
    unit_price          DECIMAL(12,2) NOT NULL,
    workspace_id uuid NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
    line_total          DECIMAL(14,2) GENERATED ALWAYS AS (quantity * unit_price) STORED
);

-- 11. Project Sources
CREATE TABLE project_sources (
    project_source_id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id          UUID NOT NULL REFERENCES core.projects(id),
    proposal_id         UUID NOT NULL REFERENCES proposals(proposal_id),
    workspace_id uuid NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
    UNIQUE (project_id, proposal_id)
);

-- 12. Project Members
CREATE TABLE project_members (
    project_member_id   SERIAL PRIMARY KEY,
    project_id          UUID NOT NULL REFERENCES core.projects(id),
    workspace_member_id UUID NOT NULL REFERENCES core.workspace_members(id),
    role_id UUID REFERENCES core.roles(id),
    workspace_id uuid NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
    assigned_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 13. Project Updates
CREATE TABLE project_updates (
    update_id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id          UUID NOT NULL REFERENCES core.projects(id),
    author_user_id      UUID NOT NULL REFERENCES core.users(id),
    title               VARCHAR(200),
    update_text         TEXT NOT NULL,
    client_visible      BOOLEAN NOT NULL DEFAULT FALSE,
    workspace_id uuid NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 14. Documents
CREATE TABLE documents (
    document_id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id        UUID NOT NULL REFERENCES core.workspaces(id),
    project_id          UUID REFERENCES core.projects(id),
    uploaded_by_user_id UUID NOT NULL REFERENCES core.users(id),
    name                VARCHAR(200) NOT NULL,
    file_url            VARCHAR(500) NOT NULL,
    document_type       VARCHAR(50),
    version_number      INTEGER DEFAULT 1,
    visibility          VARCHAR(30) DEFAULT 'internal',
    approval_status     VARCHAR(30) DEFAULT 'pending',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 15. Document Links
CREATE TABLE document_links (
    document_link_id    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id         UUID NOT NULL REFERENCES documents(document_id) ON DELETE CASCADE,
    request_id          UUID REFERENCES marketing_requests(request_id),
    workspace_id uuid NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
    proposal_id         UUID REFERENCES proposals(proposal_id)
);

-- 16. Tickets
CREATE TABLE tickets (
    ticket_id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id            UUID NOT NULL REFERENCES core.workspaces(id),
    project_id              UUID REFERENCES core.projects(id),
    submitted_by_user_id    UUID NOT NULL REFERENCES core.users(id),
    title                   VARCHAR(200) NOT NULL,
    description             TEXT,
    priority                VARCHAR(20) DEFAULT 'medium',
    status                  VARCHAR(30) DEFAULT 'open',
    assigned_to_member_id   UUID REFERENCES core.workspace_members(id),
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 17. Ticket Messages
CREATE TABLE ticket_messages (
    message_id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_id           UUID NOT NULL REFERENCES tickets(ticket_id) ON DELETE CASCADE,
    sender_user_id      UUID NOT NULL REFERENCES core.users(id),
    message_text        TEXT NOT NULL,
    workspace_id uuid NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 18. Quotes
CREATE TABLE quotes (
    quote_id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id          UUID NOT NULL REFERENCES core.projects(id),
    document_id         UUID REFERENCES documents(document_id),
    amount              DECIMAL(14,2) NOT NULL,
    currency            VARCHAR(10) DEFAULT 'USD',
    status              VARCHAR(30) DEFAULT 'draft',
    valid_until         DATE,
    created_by          UUID NOT NULL REFERENCES core.users(id),
    workspace_id uuid NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 19. Invoices
CREATE TABLE invoices (
    invoice_id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id          UUID NOT NULL REFERENCES core.projects(id),
    quote_id            UUID REFERENCES quotes(quote_id),
    document_id         UUID REFERENCES documents(document_id),
    amount              DECIMAL(14,2) NOT NULL,
    currency            VARCHAR(10) DEFAULT 'USD',
    status              VARCHAR(30) DEFAULT 'draft',
    due_date            DATE,
    issued_at           TIMESTAMPTZ,
    created_by          UUID NOT NULL REFERENCES core.users(id),
    workspace_id uuid NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 20. Agency Reviews
CREATE TABLE agency_reviews (
    agency_review_id    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id          UUID NOT NULL REFERENCES core.projects(id),
    rating              SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment             TEXT,
    visibility          VARCHAR(30) DEFAULT 'public',
    workspace_id uuid NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 21. Campaigns
CREATE TABLE campaigns (
    campaign_id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id          UUID NOT NULL REFERENCES core.projects(id),
    client_id           UUID REFERENCES client_companies(client_company_id),
    name                VARCHAR(200) NOT NULL,
    objective           TEXT,
    platform            VARCHAR(100),
    start_date          DATE,
    end_date            DATE,
    budget              DECIMAL(14,2),
    currency            VARCHAR(10) DEFAULT 'USD',
    status              VARCHAR(30) DEFAULT 'draft',
    created_by          UUID NOT NULL REFERENCES core.users(id),
    workspace_id uuid NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 22. Campaign Metrics
CREATE TABLE campaign_metrics (
    metric_id           SERIAL PRIMARY KEY,
    campaign_id         UUID NOT NULL REFERENCES campaigns(campaign_id) ON DELETE CASCADE,
    metric_date         DATE NOT NULL,
    reach               BIGINT DEFAULT 0,
    impressions         BIGINT DEFAULT 0,
    engagement          BIGINT DEFAULT 0,
    clicks              BIGINT DEFAULT 0,
    conversions         BIGINT DEFAULT 0,
    spend               DECIMAL(14,2) DEFAULT 0,
    revenue             DECIMAL(14,2) DEFAULT 0,
    source              VARCHAR(100),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    workspace_id uuid NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
    UNIQUE (campaign_id, metric_date, source)
);

-- 23. Competitors
CREATE TABLE competitors (
    competitor_id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id          UUID REFERENCES client_companies(client_company_id),
    name                VARCHAR(150) NOT NULL,
    industry            VARCHAR(100),
    website_url         VARCHAR(255),
    social_profiles     TEXT,
    notes               TEXT,
    created_by          UUID NOT NULL REFERENCES core.users(id),
    workspace_id uuid NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 24. Competitor Analyses
CREATE TABLE competitor_analyses (
    analysis_id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    competitor_id       UUID NOT NULL REFERENCES competitors(competitor_id) ON DELETE CASCADE,
    project_id          UUID REFERENCES core.projects(id),
    analysis_date       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    analysis_type       VARCHAR(100),
    source_url          VARCHAR(500),
    findings            TEXT,
    ai_summary          TEXT,
    created_by          UUID NOT NULL REFERENCES core.users(id),
    workspace_id uuid NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 25. Trend Analyses
CREATE TABLE trend_analyses (
    trend_id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id          UUID REFERENCES core.projects(id),
    trend_name          VARCHAR(200) NOT NULL,
    category            VARCHAR(100),
    source_name         VARCHAR(150),
    source_url          VARCHAR(500),
    observed_at         TIMESTAMPTZ,
    trend_data          TEXT,
    ai_summary          TEXT,
    relevance_score     DECIMAL(5,2),
    created_by          UUID NOT NULL REFERENCES core.users(id),
    workspace_id uuid NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 26. AI Suggestions
CREATE TABLE ai_suggestions (
    suggestion_id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id          UUID REFERENCES core.projects(id),
    campaign_id         UUID REFERENCES campaigns(campaign_id),
    type                VARCHAR(50),
    title               VARCHAR(200),
    content             TEXT,
    source_reference    TEXT,
    source_quote        TEXT,
    confidence          VARCHAR(20),
    status              VARCHAR(30) DEFAULT 'pending',
    reviewed_by         UUID REFERENCES core.users(id),
    reviewed_at         TIMESTAMPTZ,
    workspace_id uuid NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 27. Notifications
CREATE TABLE notifications (
    notification_id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id        UUID NOT NULL REFERENCES core.workspaces(id),
    recipient_user_id   UUID NOT NULL REFERENCES core.users(id),
    title               VARCHAR(200) NOT NULL,
    body                TEXT,
    related_entity_type VARCHAR(50),
    related_entity_id   UUID,
    is_read             BOOLEAN NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 28. Audit Logs
CREATE TABLE audit_logs (
    audit_log_id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id        UUID NOT NULL REFERENCES core.workspaces(id),
    user_id             UUID REFERENCES core.users(id),
    action              VARCHAR(100) NOT NULL,
    entity_type         VARCHAR(50),
    entity_id           UUID,
    details             TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


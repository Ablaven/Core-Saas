-- 1. Create application roles
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT FROM pg_catalog.pg_roles
        WHERE rolname = 'team_a_app'
    ) THEN
        CREATE ROLE team_a_app LOGIN PASSWORD 'team_a_secure_pass';
    END IF;

    IF NOT EXISTS (
        SELECT FROM pg_catalog.pg_roles
        WHERE rolname = 'team_b_app'
    ) THEN
        CREATE ROLE team_b_app LOGIN PASSWORD 'team_b_secure_pass';
    END IF;
END
$$;


-- 2. Schema permissions
GRANT USAGE ON SCHEMA core, product_a TO team_a_app;
GRANT USAGE ON SCHEMA core, product_b TO team_b_app;


-- 3. Core table permissions
GRANT SELECT, INSERT, UPDATE
ON ALL TABLES IN SCHEMA core
TO team_a_app, team_b_app;


-- 4. Product table permissions
GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA product_a
TO team_a_app;

GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA product_b
TO team_b_app;


-- 5. Sequence permissions
GRANT USAGE, SELECT
ON ALL SEQUENCES IN SCHEMA product_a
TO team_a_app;

GRANT USAGE, SELECT
ON ALL SEQUENCES IN SCHEMA product_b
TO team_b_app;


-- 6. Enable and force RLS on Product A tables
DO $$
DECLARE
    t RECORD;
BEGIN
    FOR t IN
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'product_a'
    LOOP
        EXECUTE format(
            'ALTER TABLE product_a.%I ENABLE ROW LEVEL SECURITY',
            t.tablename
        );

        EXECUTE format(
            'ALTER TABLE product_a.%I FORCE ROW LEVEL SECURITY',
            t.tablename
        );

        EXECUTE format(
            'CREATE POLICY workspace_isolation ON product_a.%I
             USING (workspace_id = NULLIF(current_setting(''app.current_workspace_id'', true), '''')::uuid)
             WITH CHECK (workspace_id = NULLIF(current_setting(''app.current_workspace_id'', true), '''')::uuid)',
            t.tablename
        );
    END LOOP;
END
$$;


-- 7. Enable and force RLS on Product B tenant tables
DO $$
DECLARE
    t RECORD;
BEGIN
    FOR t IN
        SELECT table_name
        FROM information_schema.columns
        WHERE table_schema = 'product_b'
          AND column_name = 'workspace_id'
    LOOP
        EXECUTE format(
            'ALTER TABLE product_b.%I ENABLE ROW LEVEL SECURITY',
            t.table_name
        );

        EXECUTE format(
            'ALTER TABLE product_b.%I FORCE ROW LEVEL SECURITY',
            t.table_name
        );

        EXECUTE format(
            'CREATE POLICY workspace_isolation ON product_b.%I
             USING (workspace_id = NULLIF(current_setting(''app.current_workspace_id'', true), '''')::uuid)
             WITH CHECK (workspace_id = NULLIF(current_setting(''app.current_workspace_id'', true), '''')::uuid)',
            t.table_name
        );
    END LOOP;
END
$$;
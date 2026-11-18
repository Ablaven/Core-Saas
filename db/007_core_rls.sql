-- 007: Row Level Security for the shared CORE tables (005_roles.sql only protected product_a / product_b)
-- Tables with workspace_id: same rule as the product tables.
DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['clients','projects','tasks','meetings'] LOOP
    EXECUTE format('ALTER TABLE core.%I ENABLE ROW LEVEL SECURITY', t);
    EXECUTE format('ALTER TABLE core.%I FORCE ROW LEVEL SECURITY', t);
    EXECUTE format(
      'CREATE POLICY workspace_isolation ON core.%I
         USING (workspace_id = NULLIF(current_setting(''app.current_workspace_id'', true), '''')::uuid)
         WITH CHECK (workspace_id = NULLIF(current_setting(''app.current_workspace_id'', true), '''')::uuid)', t);
  END LOOP;
END $$;

-- phases and meeting_summaries have no workspace_id: they inherit isolation from their parent row
ALTER TABLE core.phases ENABLE ROW LEVEL SECURITY;
ALTER TABLE core.phases FORCE ROW LEVEL SECURITY;
CREATE POLICY workspace_isolation ON core.phases
  USING (project_id IN (SELECT id FROM core.projects))
  WITH CHECK (project_id IN (SELECT id FROM core.projects));

ALTER TABLE core.meeting_summaries ENABLE ROW LEVEL SECURITY;
ALTER TABLE core.meeting_summaries FORCE ROW LEVEL SECURITY;
CREATE POLICY workspace_isolation ON core.meeting_summaries
  USING (meeting_id IN (SELECT id FROM core.meetings))
  WITH CHECK (meeting_id IN (SELECT id FROM core.meetings));
-- NOT protected on purpose: workspaces, users, roles, workspace_members (login needs them; handled in the auth session)

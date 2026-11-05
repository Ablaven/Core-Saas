CREATE TABLE core.meeting_summaries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  meeting_id uuid NOT NULL REFERENCES core.meetings(id),
  summary_text text NOT NULL,
  source_type core.source_type NOT NULL DEFAULT 'ai_generated',
  approval_status core.approval_status
    NOT NULL DEFAULT 'proposed',
  approved_by uuid REFERENCES core.users(id),
  approved_at timestamptz,
  CHECK (approval_status <> 'approved'
    OR (approved_by IS NOT NULL AND approved_at IS NOT NULL))
);

-- Seed Data
-- Insert default roles
INSERT INTO core.roles (role_name) VALUES 
  ('Admin'),
  ('Manager'),
  ('Member'),
  ('Viewer')
ON CONFLICT (role_name) DO NOTHING;

-- Insert sample workspace
INSERT INTO core.workspaces (name, product_code) VALUES 
  ('Default Workspace', 'PROD_A')
ON CONFLICT DO NOTHING;

-- Seed Data

-- Insert default roles
INSERT INTO core.roles (role_name)
VALUES
    ('Admin'),
    ('Manager'),
    ('Member'),
    ('Viewer')
ON CONFLICT (role_name) DO NOTHING;


-- Insert sample workspaces for Product A
INSERT INTO core.workspaces (name, product_code)
VALUES
    ('Marketing Agency Demo', 'product_a'),
    ('Creative Studio Demo', 'product_a')
ON CONFLICT DO NOTHING;
-- Create a new user with IP-based access
CREATE USER 'labadmin'@'%' IDENTIFIED BY 'your-strong-password-here';

-- Grant specific privileges
GRANT SELECT, INSERT, UPDATE, DELETE ON lab_management.* TO 'labadmin'@'%';

-- Additional specific grants
GRANT CREATE TEMPORARY TABLES ON lab_management.* TO 'labadmin'@'%';
GRANT LOCK TABLES ON lab_management.* TO 'labadmin'@'%';

-- Do not grant SUPER, FILE, or other administrative privileges
-- Do not grant ALL PRIVILEGES as it's too permissive

-- Require SSL for connections
ALTER USER 'labadmin'@'%' REQUIRE SSL;

-- Apply changes
FLUSH PRIVILEGES; 
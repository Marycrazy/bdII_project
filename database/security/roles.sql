-- Drop existing roles and their dependencies
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'admin_role') THEN
        DROP OWNED BY admin_role;
    END IF;
END $$;
DROP ROLE IF EXISTS admin_role;

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'receptionist_role') THEN
        DROP OWNED BY receptionist_role;
    END IF;
END $$;
DROP ROLE IF EXISTS receptionist_role;

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'client_role') THEN
        DROP OWNED BY client_role;
    END IF;
END $$;
DROP ROLE IF EXISTS client_role;

-- Create roles
CREATE ROLE admin_role;
CREATE ROLE receptionist_role;
CREATE ROLE client_role;

-- Create users if they don't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'admin_dbII') THEN
        CREATE USER "admin_dbII";
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'receptionist_dbII') THEN
        CREATE USER "receptionist_dbII";
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'client_dbII') THEN
        CREATE USER "client_dbII";
    END IF;
END $$;

-- Set passwords
ALTER USER admin_dbII WITH PASSWORD 'adminPass';
ALTER USER receptionist_dbII WITH PASSWORD 'receptionistPass';
ALTER USER client_dbII WITH PASSWORD 'clientPass';

-- Assign roles to users
GRANT admin_role TO admin_dbII;
GRANT receptionist_role TO receptionist_dbII;
GRANT client_role TO client_dbII;

-- Configure role privileges
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE RESERVAS, PAGAMENTOS TO receptionist_role;
GRANT SELECT, UPDATE ON reservas_do_cliente TO client_role;
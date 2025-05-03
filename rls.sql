-- 1. Crear los Roles
-- Super administrador (puede ver todos los tenants)
DROP ROLE IF EXISTS super_admin;
CREATE ROLE super_admin LOGIN PASSWORD 'superpass';

-- Administrador de tenant (puede administrar solo su tenant)
DROP ROLE IF EXISTS tenant_admin;
CREATE ROLE tenant_admin LOGIN PASSWORD 'adminpass';

-- Vendedor (puede ver y gestionar órdenes y productos de su tenant)
DROP ROLE IF EXISTS sales_agent;
CREATE ROLE sales_agent LOGIN PASSWORD 'salespass';

-- Cliente (puede ver productos y gestionar sus propias órdenes)
DROP ROLE IF EXISTS customer;
CREATE ROLE customer LOGIN PASSWORD 'custpass';

-- 2. Asignación de Permisos Básicos
-- Permisos para super_admin
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO super_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO super_admin;

-- Permisos para tenant_admin
GRANT SELECT, INSERT, UPDATE, DELETE ON tenants TO tenant_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON users TO tenant_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON categories TO tenant_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON products TO tenant_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON orders TO tenant_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON order_items TO tenant_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON role_tenant_map TO tenant_admin;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO tenant_admin;

-- Permisos para sales_agent
GRANT SELECT ON tenants TO sales_agent;
GRANT SELECT ON users TO sales_agent;
GRANT SELECT ON categories TO sales_agent;
GRANT SELECT, INSERT, UPDATE ON products TO sales_agent;
GRANT SELECT, INSERT, UPDATE ON orders TO sales_agent;
GRANT SELECT, INSERT, UPDATE ON order_items TO sales_agent;
GRANT SELECT ON role_tenant_map TO sales_agent;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO sales_agent;

-- Permisos para customer
GRANT SELECT ON tenants TO customer;
GRANT SELECT ON categories TO customer;
GRANT SELECT ON products TO customer;
GRANT SELECT, INSERT ON orders TO customer;
GRANT SELECT, INSERT ON order_items TO customer;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO customer;

-- 3. Activar Row Level Security en tablas relevantes
ALTER TABLE tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE role_tenant_map ENABLE ROW LEVEL SECURITY;

-- 4. Insertar mapeos de roles a tenants para pruebas
INSERT INTO role_tenant_map (role_name, tenant_id, user_id) VALUES
('tenant_admin', 1, 1),
('sales_agent', 1, 2),
('tenant_admin', 2, 3),
('sales_agent', 2, 4),
('tenant_admin', 3, 5);

-- 5. Crear función para verificar permisos de tenant
-- Sinceramente, esta función me la generó chat, hay que ser honestos jaja =P
CREATE OR REPLACE FUNCTION current_tenant_id() RETURNS INTEGER AS $$
DECLARE
    tenant_id INTEGER;
BEGIN
    -- Para super_admin, devolver NULL (lo que permitirá acceso a todos)
    IF current_user = 'super_admin' THEN
        RETURN NULL;
    END IF;
    
    -- Obtener el tenant_id asignado al rol actual
    SELECT rtm.tenant_id INTO tenant_id
    FROM role_tenant_map rtm
    WHERE rtm.role_name = current_user;
    
    -- Si no se encuentra, usar un valor que no existe
    RETURN COALESCE(tenant_id, -1);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Crear políticas de RLS para cada tabla

-- Políticas para tenants
CREATE POLICY tenant_isolation_policy ON tenants
    USING (tenant_id = current_tenant_id() OR current_user = 'super_admin');

-- Políticas para users
CREATE POLICY tenant_isolation_policy ON users
    USING (tenant_id = current_tenant_id() OR current_user = 'super_admin');

-- Políticas para categories
CREATE POLICY tenant_isolation_policy ON categories
    USING (tenant_id = current_tenant_id() OR current_user = 'super_admin');

-- Políticas para products
CREATE POLICY tenant_isolation_policy ON products
    USING (tenant_id = current_tenant_id() OR current_user = 'super_admin');

-- Políticas para orders
CREATE POLICY tenant_isolation_policy ON orders
    USING (tenant_id = current_tenant_id() OR current_user = 'super_admin');

-- Políticas para order_items
CREATE POLICY tenant_isolation_policy ON order_items
    USING (
        order_id IN (
            SELECT o.order_id
            FROM orders o
            WHERE o.tenant_id = current_tenant_id() OR current_user = 'super_admin'
        )
    );

-- Política para role_tenant_map
CREATE POLICY tenant_isolation_policy ON role_tenant_map
    USING (tenant_id = current_tenant_id() OR current_user = 'super_admin');

-- 7. Permitir a los super_admin saltarse RLS
ALTER ROLE super_admin BYPASSRLS;

-- 8. Mapear funciones para simular la operación como un tenant específico
-- Esta última parte también jaja

-- Función para asignar un tenant_id a un rol
CREATE OR REPLACE FUNCTION assign_tenant_to_role(
    p_role_name VARCHAR,
    p_tenant_id INTEGER
) RETURNS VOID AS $$
BEGIN
    -- Eliminar asignaciones anteriores para este rol
    DELETE FROM role_tenant_map WHERE role_name = p_role_name;
    
    -- Crear la nueva asignación
    INSERT INTO role_tenant_map (role_name, tenant_id)
    VALUES (p_role_name, p_tenant_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
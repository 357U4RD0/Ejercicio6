-- Crear la función para obtener el tenant actual desde la sesión
CREATE OR REPLACE FUNCTION current_tenant_id()
RETURNS INTEGER AS $$
BEGIN
    RETURN current_setting('app.current_tenant_id', true)::INTEGER;
EXCEPTION
    WHEN others THEN
        RETURN NULL;
END;
$$ LANGUAGE plpgsql STABLE;

-- Aplicar RLS y políticas de acceso por tenant en cada tabla relevante

-- Tabla: products
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS tenant_isolation_policy ON products;
CREATE POLICY tenant_isolation_policy ON products
FOR SELECT USING (
    tenant_id = current_tenant_id() OR current_user = 'super_admin'
);

-- Tabla: categories
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS tenant_isolation_policy ON categories;
CREATE POLICY tenant_isolation_policy ON categories
FOR SELECT USING (
    tenant_id = current_tenant_id() OR current_user = 'super_admin'
);

-- Tabla: users
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS tenant_isolation_policy ON users;
CREATE POLICY tenant_isolation_policy ON users
FOR SELECT USING (
    tenant_id = current_tenant_id() OR current_user = 'super_admin'
);

-- Tabla: orders
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS tenant_isolation_policy ON orders;
CREATE POLICY tenant_isolation_policy ON orders
FOR SELECT USING (
    tenant_id = current_tenant_id() OR current_user = 'super_admin'
);

-- Tabla: order_items (requiere verificación contra orders)
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS tenant_isolation_policy ON order_items;
CREATE POLICY tenant_isolation_policy ON order_items
FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM orders
        WHERE orders.order_id = order_items.order_id
        AND orders.tenant_id = current_tenant_id()
    ) OR current_user = 'super_admin'
);

-- Tabla: role_tenant_map
ALTER TABLE role_tenant_map ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS tenant_isolation_policy ON role_tenant_map;
CREATE POLICY tenant_isolation_policy ON role_tenant_map
FOR SELECT USING (
    tenant_id = current_tenant_id() OR current_user = 'super_admin'
);

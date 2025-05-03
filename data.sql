-- Datos de prueba: Tenants
INSERT INTO tenants (name, contact_email, contact_phone, subscription_level) VALUES
('TechStore', 'admin@techstore.com', '555-1234', 'premium'),
('FashionOutlet', 'contact@fashionoutlet.com', '555-5678', 'standard'),
('HomeDecor', 'info@homedecor.com', '555-9012', 'basic');

-- Datos de prueba: Usuarios (con contraseña hash simplificado para el ejemplo)
INSERT INTO users (tenant_id, username, password_hash, email, role) VALUES
(1, 'admin_tech', 'hash1234', 'admin@techstore.com', 'admin'),
(1, 'sales_tech', 'hash5678', 'sales@techstore.com', 'sales'),
(2, 'admin_fashion', 'hash9012', 'admin@fashionoutlet.com', 'admin'),
(2, 'sales_fashion', 'hash3456', 'sales@fashionoutlet.com', 'sales'),
(3, 'admin_home', 'hash7890', 'admin@homedecor.com', 'admin');

-- Datos de prueba: Categorías
INSERT INTO categories (tenant_id, name, description) VALUES
(1, 'Laptops', 'Buenas laptops para jugar'),
(1, 'Teléfonos', 'Teléfonos de último modelo'),
(1, 'Accesorios', 'Accesorios para el teléfono o laptop'),
(2, 'Hombres', 'Ropa para hombre'),
(2, 'Mujeres', 'Ropa para mujer'),
(2, 'Niños', 'Ropa para niños'),
(3, 'Sala', 'Muebles para una sala'),
(3, 'Cuarto', 'Muebles para un cuarto'),
(3, 'Cocina', 'Muebles y utensilios de cocina');

-- Datos de prueba: Productos
INSERT INTO products (tenant_id, category_id, name, description, price, stock_quantity, sku) VALUES
(1, 1, 'UltraBook Pro', '15" laptop con procesador i7', 1299.99, 10, 'LT-001'),
(1, 1, 'GameMaster X', '17" laptop gaming', 1599.99, 5, 'LT-002'),
(1, 2, 'PowerPhone 12', '6.5" teléfono con 2 cámaras', 899.99, 20, 'SP-001'),
(1, 3, 'Mouse Inalámbrico', 'Mouse inalámbrico económico', 45.99, 50, 'AC-001'),
(2, 4, 'Camisa', 'Camisa de algodón', 59.99, 100, 'MS-001'),
(2, 5, 'Vestido', 'Vestido liviano para verano', 79.99, 80, 'WD-001'),
(2, 6, 'Pantalón', 'Pantalones para niños', 39.99, 120, 'KJ-001'),
(3, 7, 'Sofá', 'Sofá gris de 3 asientos', 899.99, 3, 'LS-001'),
(3, 8, 'Cama', 'Cama matrimonial con acabados de madera', 599.99, 5, 'BF-001'),
(3, 9, 'Licuadora', 'Licuadora con 10 estilos de licuado', 129.99, 15, 'KA-001');

-- Datos de prueba: Órdenes
INSERT INTO orders (tenant_id, user_id, total_amount, status, shipping_address, payment_method) VALUES
(1, 1, 1345.98, 'completado', '123 Tech St, Silicon Valley, CA', 'credit_card'),
(1, 2, 899.99, 'procesando', '456 Byte Rd, San Francisco, CA', 'paypal'),
(2, 3, 179.97, 'completado', '789 Fashion Ave, New York, NY', 'credit_card'),
(2, 4, 119.98, 'enviado', '101 Style Blvd, Los Angeles, CA', 'credit_card'),
(3, 5, 1029.98, 'pendiente', '202 Home St, Chicago, IL', 'bank_transfer');

-- Datos de prueba: Items de órdenes
INSERT INTO order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES
(1, 1, 1, 1299.99, 1299.99),
(1, 4, 1, 45.99, 45.99),
(2, 3, 1, 899.99, 899.99),
(3, 5, 3, 59.99, 179.97),
(4, 6, 1, 79.99, 79.99),
(4, 7, 1, 39.99, 39.99),
(5, 8, 1, 899.99, 899.99),
(5, 10, 1, 129.99, 129.99);
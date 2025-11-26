
-- CREATE TABLES -- 

CREATE TABLE IF NOT EXISTS categories (
	id_category INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	category_name VARCHAR(100) UNIQUE NOT NULL, 
    category_description VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS products (
	id_product INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	product_name VARCHAR(100) NOT NULL, 
    price NUMERIC CHECK (price > 0), 
    stock_available INT CHECK (stock_available > -1), 
    id_category INT NOT NULL, 
    CONSTRAINT fk_id_category FOREIGN KEY (id_category) 
	REFERENCES categories(id_category)
);

CREATE TABLE IF NOT EXISTS customers (
    id_customer INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(200) UNIQUE NOT NULL, 
    created_at DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS orders (
	id_order INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_customer INT NOT NULL,
	order_date DATE NOT NULL, 
    order_status VARCHAR(30) NOT NULL CHECK (order_status IN ('PENDING', 'PAID', 'SHIPPED', 'CANCELLED')),  
    CONSTRAINT fk_id_customer FOREIGN KEY (id_customer) 
	REFERENCES customers(id_customer)
);

CREATE TABLE IF NOT EXISTS order_items (
	id_order_items INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_order INT NOT NULL,
    id_product INT NOT NULL, 
	quantity NUMERIC NOT NULL CHECK (quantity > 0), 
    unit_price NUMERIC CHECK (unit_price > 0), 
    CONSTRAINT fk_id_product FOREIGN KEY (id_product) 
	REFERENCES products(id_product),
    CONSTRAINT fk_id_order FOREIGN KEY (id_order) 
	REFERENCES orders(id_order)
);




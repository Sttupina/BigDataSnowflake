DROP TABLE IF EXISTS fact_sales CASCADE;
DROP TABLE IF EXISTS dim_product CASCADE;
DROP TABLE IF EXISTS dim_product_color CASCADE;
DROP TABLE IF EXISTS dim_product_size CASCADE;
DROP TABLE IF EXISTS dim_product_brand CASCADE;
DROP TABLE IF EXISTS dim_product_material CASCADE;
DROP TABLE IF EXISTS dim_product_category CASCADE;
DROP TABLE IF EXISTS dim_store CASCADE;
DROP TABLE IF EXISTS dim_supplier CASCADE;
DROP TABLE IF EXISTS dim_seller CASCADE;
DROP TABLE IF EXISTS dim_customer CASCADE;
DROP TABLE IF EXISTS dim_pet CASCADE;
DROP TABLE IF EXISTS dim_pet_type CASCADE;
DROP TABLE IF EXISTS dim_pet_category CASCADE;
DROP TABLE IF EXISTS dim_date CASCADE;

CREATE TABLE dim_date (
    date_id SERIAL PRIMARY KEY,
    date_actual DATE UNIQUE NOT NULL,
    year INT NOT NULL,
    quarter INT NOT NULL,
    month INT NOT NULL,
    day INT NOT NULL,
    weekday INT NOT NULL,
    is_weekend BOOLEAN NOT NULL
);

CREATE TABLE dim_pet_category (
    pet_category_id SERIAL PRIMARY KEY,
    category_name TEXT UNIQUE NOT NULL
);

CREATE TABLE dim_pet_type (
    pet_type_id SERIAL PRIMARY KEY,
    type_name TEXT UNIQUE NOT NULL
);

CREATE TABLE dim_pet (
    pet_id SERIAL PRIMARY KEY,
    pet_type_id INT REFERENCES dim_pet_type(pet_type_id),
    name TEXT,
    breed TEXT,
    pet_category_id INT REFERENCES dim_pet_category(pet_category_id)
);

CREATE TABLE dim_customer (
    customer_id SERIAL PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    age INT,
    email TEXT UNIQUE,
    country TEXT,
    postal_code TEXT
);

CREATE TABLE dim_seller (
    seller_id SERIAL PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    email TEXT UNIQUE,
    country TEXT,
    postal_code TEXT
);

CREATE TABLE dim_supplier (
    supplier_id SERIAL PRIMARY KEY,
    name TEXT,
    contact TEXT,
    email TEXT UNIQUE,
    phone TEXT,
    address TEXT,
    city TEXT,
    country TEXT
);

CREATE TABLE dim_store (
    store_id SERIAL PRIMARY KEY,
    name TEXT,
    location TEXT,
    city TEXT,
    state TEXT,
    country TEXT,
    phone TEXT,
    email TEXT UNIQUE
);


CREATE TABLE dim_product_category (
    product_category_id SERIAL PRIMARY KEY,
    category_name TEXT UNIQUE NOT NULL
);

CREATE TABLE dim_product_brand (
    brand_id SERIAL PRIMARY KEY,
    brand_name TEXT UNIQUE NOT NULL
);

CREATE TABLE dim_product_material (
    material_id SERIAL PRIMARY KEY,
    material_name TEXT UNIQUE NOT NULL
);

CREATE TABLE dim_product_size (
    size_id SERIAL PRIMARY KEY,
    size_name TEXT UNIQUE NOT NULL
);

CREATE TABLE dim_product_color (
    color_id SERIAL PRIMARY KEY,
    color_name TEXT UNIQUE NOT NULL
);

CREATE TABLE dim_product (
    product_id SERIAL PRIMARY KEY,
    name TEXT,
    category_id INT REFERENCES dim_product_category(product_category_id),
    price NUMERIC,
    weight NUMERIC,
    color_id INT REFERENCES dim_product_color(color_id),
    size_id INT REFERENCES dim_product_size(size_id),
    brand_id INT REFERENCES dim_product_brand(brand_id),
    material_id INT REFERENCES dim_product_material(material_id),
    description TEXT,
    rating NUMERIC,
    reviews INT,
    release_date_id INT REFERENCES dim_date(date_id),
    expiry_date_id INT REFERENCES dim_date(date_id)
);

CREATE TABLE fact_sales (
    sale_id SERIAL PRIMARY KEY,
    sale_date_id INT REFERENCES dim_date(date_id),
    customer_id INT REFERENCES dim_customer(customer_id),
    seller_id INT REFERENCES dim_seller(seller_id),
    product_id INT REFERENCES dim_product(product_id),
    store_id INT REFERENCES dim_store(store_id),
    supplier_id INT REFERENCES dim_supplier(supplier_id),
    sale_quantity INT,
    sale_total_price NUMERIC
);

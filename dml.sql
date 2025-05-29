-- Вставка дат из sale_date
INSERT INTO dim_date (date_actual, year, quarter, month, day, weekday, is_weekend)
SELECT DISTINCT
    sale_date::date,
    EXTRACT(YEAR FROM sale_date::date)::int,
    EXTRACT(QUARTER FROM sale_date::date)::int,
    EXTRACT(MONTH FROM sale_date::date)::int,
    EXTRACT(DAY FROM sale_date::date)::int,
    EXTRACT(DOW FROM sale_date::date)::int + 1,
    CASE WHEN EXTRACT(DOW FROM sale_date::date) IN (0,6) THEN true ELSE false END
FROM (
    SELECT to_date(sale_date, 'MM/DD/YYYY') AS sale_date
    FROM mock_data
) AS dates
WHERE sale_date IS NOT NULL
ON CONFLICT (date_actual) DO NOTHING;

-- Вставка дат из product_release_date
INSERT INTO dim_date (date_actual, year, quarter, month, day, weekday, is_weekend)
SELECT DISTINCT
    release_date::date,
    EXTRACT(YEAR FROM release_date::date)::int,
    EXTRACT(QUARTER FROM release_date::date)::int,
    EXTRACT(MONTH FROM release_date::date)::int,
    EXTRACT(DAY FROM release_date::date)::int,
    EXTRACT(DOW FROM release_date::date)::int + 1,
    CASE WHEN EXTRACT(DOW FROM release_date::date) IN (0,6) THEN true ELSE false END
FROM (
    SELECT to_date(product_release_date, 'MM/DD/YYYY') AS release_date
    FROM mock_data
) AS dates
WHERE release_date IS NOT NULL
ON CONFLICT (date_actual) DO NOTHING;

-- Вставка дат из product_expiry_date
INSERT INTO dim_date (date_actual, year, quarter, month, day, weekday, is_weekend)
SELECT DISTINCT
    expiry_date::date,
    EXTRACT(YEAR FROM expiry_date::date)::int,
    EXTRACT(QUARTER FROM expiry_date::date)::int,
    EXTRACT(MONTH FROM expiry_date::date)::int,
    EXTRACT(DAY FROM expiry_date::date)::int,
    EXTRACT(DOW FROM expiry_date::date)::int + 1,
    CASE WHEN EXTRACT(DOW FROM expiry_date::date) IN (0,6) THEN true ELSE false END
FROM (
    SELECT to_date(product_expiry_date, 'MM/DD/YYYY') AS expiry_date
    FROM mock_data
) AS dates
WHERE expiry_date IS NOT NULL
ON CONFLICT (date_actual) DO NOTHING;

-- Вставка в dim_pet_category
INSERT INTO dim_pet_category (category_name)
SELECT DISTINCT pet_category
FROM mock_data
WHERE pet_category IS NOT NULL AND pet_category <> ''
ON CONFLICT (category_name) DO NOTHING;

-- Вставка в dim_pet_type
INSERT INTO dim_pet_type (type_name)
SELECT DISTINCT customer_pet_type
FROM mock_data
WHERE customer_pet_type IS NOT NULL AND customer_pet_type <> ''
ON CONFLICT (type_name) DO NOTHING;

-- Вставка в dim_product_category
INSERT INTO dim_product_category (category_name)
SELECT DISTINCT product_category
FROM mock_data
WHERE product_category IS NOT NULL AND product_category <> ''
ON CONFLICT (category_name) DO NOTHING;

-- Вставка в dim_product_brand
INSERT INTO dim_product_brand (brand_name)
SELECT DISTINCT product_brand
FROM mock_data
WHERE product_brand IS NOT NULL AND product_brand <> ''
ON CONFLICT (brand_name) DO NOTHING;

-- Вставка в dim_product_material
INSERT INTO dim_product_material (material_name)
SELECT DISTINCT product_material
FROM mock_data
WHERE product_material IS NOT NULL AND product_material <> ''
ON CONFLICT (material_name) DO NOTHING;

-- Вставка в dim_product_size
INSERT INTO dim_product_size (size_name)
SELECT DISTINCT product_size
FROM mock_data
WHERE product_size IS NOT NULL AND product_size <> ''
ON CONFLICT (size_name) DO NOTHING;

-- Вставка в dim_product_color
INSERT INTO dim_product_color (color_name)
SELECT DISTINCT product_color
FROM mock_data
WHERE product_color IS NOT NULL AND product_color <> ''
ON CONFLICT (color_name) DO NOTHING;

-- Вставка в dim_customer
INSERT INTO dim_customer (first_name, last_name, age, email, country, postal_code)
SELECT DISTINCT
    customer_first_name,
    customer_last_name,
    NULLIF(customer_age, '')::int,
    customer_email,
    customer_country,
    customer_postal_code
FROM mock_data
WHERE customer_email IS NOT NULL AND customer_email <> ''
ON CONFLICT (email) DO NOTHING;

-- Вставка в dim_seller
INSERT INTO dim_seller (first_name, last_name, email, country, postal_code)
SELECT DISTINCT
    seller_first_name,
    seller_last_name,
    seller_email,
    seller_country,
    seller_postal_code
FROM mock_data
WHERE seller_email IS NOT NULL AND seller_email <> ''
ON CONFLICT (email) DO NOTHING;

-- Вставка в dim_supplier
INSERT INTO dim_supplier (name, contact, email, phone, address, city, country)
SELECT DISTINCT
    supplier_name,
    supplier_contact,
    supplier_email,
    supplier_phone,
    supplier_address,
    supplier_city,
    supplier_country
FROM mock_data
WHERE supplier_email IS NOT NULL AND supplier_email <> ''
ON CONFLICT (email) DO NOTHING;

-- Вставка в dim_store
INSERT INTO dim_store (name, location, city, state, country, phone, email)
SELECT DISTINCT
    store_name,
    store_location,
    store_city,
    store_state,
    store_country,
    store_phone,
    store_email
FROM mock_data
WHERE store_email IS NOT NULL AND store_email <> ''
ON CONFLICT (email) DO NOTHING;

-- Вставка в dim_pet
INSERT INTO dim_pet (pet_type_id, name, breed, pet_category_id)
SELECT DISTINCT
    pt.pet_type_id,
    md.customer_pet_name,
    md.customer_pet_breed,
    pc.pet_category_id
FROM mock_data md
LEFT JOIN dim_pet_type pt ON pt.type_name = md.customer_pet_type
LEFT JOIN dim_pet_category pc ON pc.category_name = md.pet_category
WHERE md.customer_pet_name IS NOT NULL AND md.customer_pet_name <> '';

-- Вставка в dim_product
INSERT INTO dim_product (
    name, category_id, price, weight, color_id, size_id, brand_id, material_id,
    description, rating, reviews, release_date_id, expiry_date_id
)
SELECT DISTINCT
    md.product_name,
    pc.product_category_id,
    NULLIF(md.product_price, '')::numeric,
    NULLIF(md.product_weight, '')::numeric,
    color.color_id,
    size.size_id,
    brand.brand_id,
    material.material_id,
    md.product_description,
    NULLIF(md.product_rating, '')::numeric,
    NULLIF(md.product_reviews, '')::int,
    dr.date_id,
    de.date_id
FROM mock_data md
LEFT JOIN dim_product_category pc ON pc.category_name = md.product_category
LEFT JOIN dim_product_color color ON color.color_name = md.product_color
LEFT JOIN dim_product_size size ON size.size_name = md.product_size
LEFT JOIN dim_product_brand brand ON brand.brand_name = md.product_brand
LEFT JOIN dim_product_material material ON material.material_name = md.product_material
LEFT JOIN dim_date dr ON dr.date_actual = to_date(md.product_release_date, 'MM/DD/YYYY')
LEFT JOIN dim_date de ON de.date_actual = to_date(md.product_expiry_date, 'MM/DD/YYYY')
WHERE md.product_name IS NOT NULL AND md.product_name <> '';

-- Вставка в fact_sales
INSERT INTO fact_sales (
    sale_date_id, customer_id, seller_id, product_id, store_id, supplier_id, sale_quantity, sale_total_price
)
SELECT
    ddate.date_id,
    cust.customer_id,
    sell.seller_id,
    prod.product_id,
    store.store_id,
    supp.supplier_id,
    NULLIF(md.sale_quantity, '')::int,
    NULLIF(md.sale_total_price, '')::numeric
FROM mock_data md
LEFT JOIN dim_date ddate ON ddate.date_actual = to_date(md.sale_date, 'MM/DD/YYYY')
LEFT JOIN dim_customer cust ON cust.email = md.customer_email
LEFT JOIN dim_seller sell ON sell.email = md.seller_email
LEFT JOIN dim_product prod ON prod.name = md.product_name
LEFT JOIN dim_store store ON store.email = md.store_email
LEFT JOIN dim_supplier supp ON supp.email = md.supplier_email;


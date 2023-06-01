CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    user_lastname VARCHAR(100) NOT NULL,
    user_firstname VARCHAR(100) NOT NULL,
    user_username VARCHAR(50) NOT NULL,
    user_password VARCHAR(50) NOT NULL,
    user_email VARCHAR(100) NOT NULL,
    user_phonenumber VARCHAR(30) NOT NULL,
    user_role VARCHAR(22) NOT NULL
);

CREATE TABLE suppliers (
    supplier_id SERIAL PRIMARY KEY,
    supplier_lastname VARCHAR(50) NOT NULL,
    supplier_firstname VARCHAR(50) NOT NULL,
    contact_number VARCHAR(30) NOT NULL,
    email VARCHAR(100) NOT NULL,
    address VARCHAR(100) NOT NULL,
    country VARCHAR(50) NOT NULL,
    postal_code VARCHAR(50) NOT NULL,
    active VARCHAR(10) NOT NULL
);

CREATE TABLE category_list (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    image_name VARCHAR(100) NOT NULL,
    active VARCHAR(10) NOT NULL
);

CREATE TABLE food_list (
    food_id SERIAL PRIMARY KEY,
    category_id INT NOT NULL,
    supplier_id INT NOT NULL,
    food_name VARCHAR(100) NOT NULL,
    description VARCHAR(255) NOT NULL,
    food_price DECIMAL(10, 2) NOT NULL,
    available_quantity INT NOT NULL,
    image_name VARCHAR(100) NOT NULL,
    active VARCHAR(10) NOT NULL,
    FOREIGN KEY (category_id) REFERENCES category_list (category_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers (supplier_id)
);

CREATE TABLE delivery_rider (
    rider_id SERIAL PRIMARY KEY,
    rider_lastname VARCHAR(50) NOT NULL,
    rider_firstname VARCHAR(50) NOT NULL,
    contact_number VARCHAR(30) NOT NULL,
    email VARCHAR(100) NOT NULL,
    active VARCHAR(45) NOT NULL
);

CREATE TABLE order_details (
    order_id VARCHAR(100) PRIMARY KEY,
    customer_lastname VARCHAR(100) NOT NULL,
    customer_firstname VARCHAR(100) NOT NULL,
    contact_number VARCHAR(30) NOT NULL,
    delivery_address VARCHAR(255) NOT NULL,
    postalcode VARCHAR(50) NOT NULL,
    rider_id INT NOT NULL,
    food_id INT NOT NULL,
    quantity INT NOT NULL,
    total DECIMAL(10, 2) NOT NULL,
    mode_of_payment VARCHAR(50) NOT NULL,
    order_date TIMESTAMP NOT NULL,
    expected_delivery TIMESTAMP NOT NULL,
    status VARCHAR(45) NOT NULL,
    FOREIGN KEY (rider_id) REFERENCES delivery_rider (rider_id),
    FOREIGN KEY (food_id) REFERENCES food_list (food_id)
);

CREATE TABLE messages (
    message_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    message VARCHAR(255) NOT NULL,
    date_message TIMESTAMP NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users (user_id)
);

CREATE VIEW family_meal AS 
    SELECT food_name, food_price FROM food_list WHERE food_price >= 5; 

CREATE VIEW budget_meal AS 
    SELECT food_name, food_price FROM food_list WHERE food_price < 5;
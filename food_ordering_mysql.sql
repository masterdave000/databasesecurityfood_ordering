CREATE DATABASE food_ordering;
USE food_ordering;
CREATE TABLE
    users (
        user_id int NOT NULL AUTO_INCREMENT,
        user_lastname varchar(100) NOT NULL,
        user_firstname varchar(100) NOT NULL,
        user_username varchar(50) NOT NULL,
        user_password varchar(50) NOT NULL,
        user_email varchar(100) NOT NULL,
        user_phonenumber varchar(30) NOT NULL,
        user_role varchar(22) NOT NULL,
        PRIMARY KEY(user_id)
    );

CREATE TABLE
    suppliers(
        supplier_id int NOT NULL AUTO_INCREMENT,
        supplier_lastname varchar(50) NOT NULL,
        supplier_firstname varchar(50) NOT NULL,
        contact_number varchar(30) NOT NULL,
        email varchar(100) NOT NULL,
        address varchar(100) NOT NULL,
        country varchar(50) NOT NULL,
        postal_code varchar(50) NOT NULL,
        active varchar(10) NOT NULL,
        PRIMARY KEY(supplier_id)
    );

CREATE TABLE
    category_list (
        category_id int NOT NULL AUTO_INCREMENT,
        category_name varchar(100) NOT NULL,
        image_name varchar(100) NOT NULL,
        active varchar(10) NOT NULL,
        PRIMARY KEY(category_id)
    );

CREATE TABLE
    food_list (
        food_id int NOT NULL AUTO_INCREMENT,
        category_id INT NOT NULL,
        supplier_id int NOT NULL,
        food_name varchar(100) NOT NULL,
        description varchar(255) NOT NULL,
        food_price decimal(10, 2) NOT NULL,
        available_quantity int NOT NULL,
        image_name varchar(100) NOT NULL,
        active varchar(10) NOT NULL,
        PRIMARY KEY(food_id),
        FOREIGN KEY(category_id) REFERENCES category_list(category_id),
        FOREIGN KEY(supplier_id) REFERENCES suppliers(supplier_id)
    );

CREATE TABLE
    delivery_rider (
        rider_id int NOT NULL AUTO_INCREMENT,
        rider_lastname varchar(50) NOT NULL,
        rider_firstname varchar(50) NOT NULL,
        contact_number varchar(30) NOT NULL,
        email varchar(100) NOT NULL,
        active varchar(45) NOT NULL,
        PRIMARY KEY(rider_id)
    );

CREATE TABLE
    order_details (
        order_id varchar(100) NOT NULL,
        customer_lastname varchar(100) NOT NULL,
        customer_firstname varchar(100) NOT NULL,
        contact_number varchar(30) NOT NULL,
        delivery_address varchar(255) NOT NULL,
        postalcode varchar(50) NOT NULL,
        rider_id int NOT NULL,
        food_id int NOT NULL,
        quantity int NOT NULL,
        total decimal(10, 2) NOT NULL,
        mode_of_payment varchar(50) NOT NULL,
        order_date datetime NOT NULL,
        expected_delivery datetime NOT NULL,
        status varchar(45) NOT NULL,
        PRIMARY KEY(order_id),
        FOREIGN KEY(rider_id) REFERENCES delivery_rider(rider_id),
        FOREIGN KEY(food_id) REFERENCES food_list(food_id)
    );

CREATE TABLE
    messages (
        message_id int NOT NULL AUmysql> 
TO_INCREMENT,
        user_id int NOT NULL,
        message varchar(255) NOT NULL,
        date_message datetime NOT NULL,
        PRIMARY KEY(message_id),
        FOREIGN KEY(user_id) REFERENCES users(user_id)
    );

-- triggers --

DELIMITER //

CREATE TRIGGER update_available_quantity
AFTER INSERT ON order_details
FOR EACH ROW
BEGIN
    DECLARE food_qty INT;
    SELECT available_quantity INTO food_qty FROM food_list WHERE food_id = NEW.food_id;
    IF food_qty >= NEW.quantity THEN
        UPDATE food_list SET available_quantity = available_quantity - NEW.quantity WHERE food_id = NEW.food_id;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient quantity available.';
    END IF;
END//

DELIMITER ;


DELIMITER //

CREATE TRIGGER calculate_order_total
BEFORE INSERT ON order_details
FOR EACH ROW
BEGIN
    DECLARE food_price DECIMAL(10, 2);
    SELECT food_price INTO food_price FROM food_list WHERE food_id = NEW.food_id;
    SET NEW.total = NEW.quantity * food_price;
END//

DELIMITER ;

-- Create the trigger function
DELIMITER // 

CREATE FUNCTION insert_order_message() 
RETURNS TRIGGER 
BEGIN 
    INSERT INTO messages (user_id, message, date_message) 
    VALUES (NEW.user_id, CONCAT('A new order with ID ', NEW.order_id, ' has been placed.'), NOW()); 
    RETURN NEW; 
END// 

DELIMITER ; 

-- Create the trigger
CREATE TRIGGER insert_order_message_trigger
AFTER INSERT ON order_details
FOR EACH ROW
BEGIN
    CALL insert_order_message();
END;



DELIMITER //

CREATE TRIGGER update_order_status
BEFORE INSERT ON order_details
FOR EACH ROW
BEGIN
    IF NEW.expected_delivery < NOW() THEN
        SET NEW.status = 'Delayed';
    ELSE
        SET NEW.status = 'Pending';
    END IF;
END//

DELIMITER ;

-- views --

CREATE VIEW active_suppliers AS
SELECT *
FROM suppliers
WHERE active = 'Active';

CREATE VIEW user_order_history AS 
SELECT o.order_id, o.order_date, o.total, o.status, f.food_name 
FROM order_details o 
JOIN food_list f ON o.food_id = f.food_id 
JOIN users u ON o.customer_lastname = u.user_lastname AND o.customer_firstname = u.user_firstname 
WHERE u.user_id = user_id;

CREATE VIEW category_sales AS
SELECT c.category_name, COUNT(o.order_id) AS total_orders, SUM(o.total) AS total_revenue
FROM order_details o
JOIN food_list f ON o.food_id = f.food_id
JOIN category_list c ON f.category_id = c.category_id
GROUP BY c.category_name;

CREATE VIEW FAMILY_MEAL AS 
	SELECT food_name, food_price FROM food_list WHERE food_price >= 
5; 

CREATE VIEW BUDGET_MEAL AS 
	SELECT food_name, food_price FROM food_list WHERE food_price < 
5; 


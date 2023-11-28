CREATE DATABASE Dressmann
GO
USE Dressmann
GO


-- Users Table -----------------------------------------------------------------------------------------------------------

CREATE TABLE Users (
    UserID NVARCHAR(10) PRIMARY KEY,
    FirstName NVARCHAR(255) NOT NULL,
    LastName NVARCHAR(255) NOT NULL,
    Email NVARCHAR(255) UNIQUE NOT NULL,  -- constraints ensure that each email is both unique and mandatory, 
	Password NVARCHAR(255) NOT NULL,
	PhoneNumber NVARCHAR(20) NOT NULL,
    RegistrationDate DATE NOT NULL,
    ReceiveSMSOffers BIT NOT NULL,
    ReceiveEmailOffers BIT NOT NULL
);

-- The inclusion of a sequence (UserIDSequence) and a default constraint (DF_UserID) for the UserID column automates the assignment of unique identifiers to users upon insertion into the table.
-- To automatically generate a unique UserID combining 'U' and an identity column
CREATE SEQUENCE UserIDSequence
    AS INT
    START WITH 1
    INCREMENT BY 1;

-- A default constraint for UserID
ALTER TABLE Users
ADD CONSTRAINT DF_UserID DEFAULT ('U' + CAST(NEXT VALUE FOR UserIDSequence AS NVARCHAR(10)))
FOR UserID;


--UserAddress Table ---------------------------------------------------------------------------------------------------------

CREATE TABLE UserAddress (
    AddressID INT PRIMARY KEY IDENTITY(1, 1),
    UserID NVARCHAR(10) REFERENCES Users(UserID),
    StreetAddress NVARCHAR(255) NOT NULL,
    City NVARCHAR(50) NOT NULL,
    PostalCode NVARCHAR(20) NOT NULL,
    Country NVARCHAR(50) NOT NULL,
    IsDefault BIT NOT NULL,
    CHECK (IsDefault IN (0, 1)), -- Ensures that the "IsDefault" field only contains valid values (0 or 1)
    UNIQUE (UserID, IsDefault) -- Guarantees that each user can have at most one default address
);



--UserActivity Table ---------------------------------------------------------------------------------------------------------

CREATE TABLE UserActivity (
    ActivityID INT PRIMARY KEY IDENTITY(1,1),
    UserID NVARCHAR(10) REFERENCES Users(UserID),
    ActivityType NVARCHAR(255) NOT NULL,
    ActivityTimestamp DATETIME NOT NULL
);

-- PaymentMethods ---------------------------------------------------------------------------------------------------------


CREATE TABLE PaymentMethods (
    PaymentMethodID INT PRIMARY KEY IDENTITY(1, 1),
    UserID NVARCHAR(10) REFERENCES Users(UserID),
    PaymentMethodName NVARCHAR(255) NOT NULL,
    IsDefault BIT NOT NULL,
    CONSTRAINT CHK_BooleanDefault CHECK (IsDefault IN (0, 1))
);

-----------------------------------------------------------------------------------------------------------

CREATE TABLE ProductCategory (
    CategoryID INT PRIMARY KEY IDENTITY(1, 1),
    CategoryName NVARCHAR(255) NOT NULL,
    ParentCategoryID INT NULL,
    CONSTRAINT FK_Categories_ParentCategory FOREIGN KEY (ParentCategoryID) REFERENCES ProductCategory(CategoryID)
);



-----------------------------------------------------------------------------------------------------------

-- Products Table
CREATE TABLE Products (
    ProductID NVARCHAR(10) PRIMARY KEY,
    ProductName NVARCHAR(255) NOT NULL,
    Description NVARCHAR(MAX), 
    Color NVARCHAR(255), 
    Produktinformation TEXT, 
	IsInOutlet BIT,
    Price MONEY NOT NULL,
    StockQuantity INT,
    CategoryID INT REFERENCES ProductCategory(CategoryID)
);

-- To automatically generate a unique ProductID combining 'P' and an identity column
CREATE SEQUENCE ProductIDSequence
    AS INT
    START WITH 30333
    INCREMENT BY 1;

-- Create a default constraint for ProductID
ALTER TABLE Products
ADD CONSTRAINT DF_ProductID DEFAULT ('P' + CAST(NEXT VALUE FOR ProductIDSequence AS NVARCHAR(10)))
FOR ProductID;

-----------------------------------------------------------------------------------------------------------

-- Product Inventory 
CREATE TABLE ProductInventory  (
    QuantityID INT PRIMARY KEY IDENTITY(1, 1),
    ProductID NVARCHAR(10) REFERENCES Products(ProductID),
    AvailableQuantity INT NOT NULL
);

-----------------------------------------------------------------------------------------------------------


-- Carts Table
CREATE TABLE ShoppingCart  (
    CartID INT PRIMARY KEY IDENTITY(1, 1),
    UserID NVARCHAR(10) REFERENCES Users(UserID),
    ProductID NVARCHAR(10) REFERENCES Products(ProductID),
    Quantity INT NOT NULL,
    CONSTRAINT UC_Cart UNIQUE (UserID, ProductID)
);


-----------------------------------------------------------------------------------------------------------

-- Orders Table
CREATE TABLE Orders (
    OrderID NVARCHAR(10) PRIMARY KEY,
    UserID NVARCHAR(10) REFERENCES Users(UserID),
    OrderDate DATETIME,
    Status NVARCHAR(50),
    ShippingAddress NVARCHAR(255),
    BillingAddress NVARCHAR(255),
    PaymentInformation NVARCHAR(MAX),
    TotalAmount MONEY,
    ShippingMethod NVARCHAR(50),
    NotesComments NVARCHAR(MAX),
    CONSTRAINT CHK_ValidStatus CHECK (Status IN ('Processing', 'Out for delivery', 'Delivered', 'OtherStatus'))
);

-- To automatically generate a unique OrderID combining 'O' and an identity column
CREATE SEQUENCE OrderIDSequence
    AS INT
    START WITH 999  -- Start value similar to your original setup
    INCREMENT BY 1;

-- Create a default constraint for OrderID
ALTER TABLE Orders
ADD CONSTRAINT DF_OrderID DEFAULT ('O' + CAST(NEXT VALUE FOR OrderIDSequence AS NVARCHAR(10)))
FOR OrderID;

-----------------------------------------------------------------------------------------------------------

-- OrderItems Table
CREATE TABLE OrderItems (
    OrderItemID NVARCHAR(12) PRIMARY KEY,
    OrderID NVARCHAR(10) REFERENCES Orders(OrderID),
    ProductID NVARCHAR(10) REFERENCES Products(ProductID), -- Corrected the data type here
    Quantity INT,
    Price MONEY,
    TotalPrice MONEY
);

-- To automatically generate a unique OrderItemID combining 'OI' and an identity column
CREATE SEQUENCE OrderItemIDSequence
    AS INT
    START WITH 1
    INCREMENT BY 1;

-- Create a default constraint for OrderItemID
ALTER TABLE OrderItems
ADD CONSTRAINT DF_OrderItemID DEFAULT ('OI' + CAST(NEXT VALUE FOR OrderItemIDSequence AS NVARCHAR(12)))
FOR OrderItemID;

-----------------------------------------------------------------------------------------------------------

-- Reviews Table
CREATE TABLE Reviews (
    ReviewID INT PRIMARY KEY IDENTITY(1, 1),
    ProductID NVARCHAR(10) REFERENCES Products(ProductID), -- Corrected the data type here
    UserID NVARCHAR(10) REFERENCES Users(UserID),
    Rating INT,
    Comment NVARCHAR(MAX),
    ReviewDate DATETIME
);


-----------------------------------------------------------------------------------------------------------

-- Favorites Table
CREATE TABLE Favorites (
    FavoriteID INT PRIMARY KEY IDENTITY(1, 1),
    UserID NVARCHAR(10) REFERENCES Users(UserID), 
    ProductID NVARCHAR(10) REFERENCES Products(ProductID),
    CONSTRAINT UC_Favorite UNIQUE (UserID, ProductID)
);

-----------------------------------------------------------------------------------------------------------

-- Promotions Table
CREATE TABLE Promotions (
    PromotionID INT PRIMARY KEY IDENTITY(1, 1),
    ProductID NVARCHAR(10) REFERENCES Products(ProductID),
    DiscountPercentage DECIMAL(5, 2),
    StartDate DATETIME,
    EndDate DATETIME
);

--------------------------------------------------------------------------


-- Insert data for 15 rows with Swedish information
INSERT INTO Users (UserID, FirstName, LastName, Email, Password, PhoneNumber, RegistrationDate, ReceiveSMSOffers, ReceiveEmailOffers)
VALUES
    ('U1', 'Anna', 'Andersson', 'anna.andersson@example.com', 'password123', '1234567890', '2023-04-14', 1, 1),
    ('U2', 'Bengt', 'Berg', 'bengt.berg@example.com', 'securepass', '9876543210', '2023-05-14', 0, 1),
    ('U3', 'Carina', 'Carlsson', 'carina.carlsson@example.com', 'pass123', '5551234567', '2023-05-14', 1, 0),
    ('U4', 'David', 'Dahl', 'david.dahl@example.com', 'strongpass', '7890123456', '2023-05-14', 1, 1),
    ('U5', 'Eva', 'Ek', 'eva.ek@example.com', 'mypassword', '1237894560', '2023-11-14', 0, 0),
    ('U6', 'Fredrik', 'Fors', 'fredrik.fors@example.com', 'letmein', '4567890123', '2023-05-14', 1, 1),
    ('U7', 'Gunilla', 'Gustavsson', 'gunilla.gustavsson@example.com', 'secret123', '7890123456', '2023-06-14', 0, 1),
    ('U8', 'Henrik', 'Holm', 'henrik.holm@example.com', 'passphrase', '9876543210', '2023-06-14', 1, 0),
    ('U9', 'Ida', 'Isaksson', 'ida.isaksson@example.com', 'p@ssw0rd', '5551234567', '2023-06-14', 0, 0),
    ('U10', 'Jakob', 'Johansson', 'jakob.johansson@example.com', 'qwerty123', '1237894560', '2023-07-14', 1, 1),
    ('U11', 'Karin', 'Karlsson', 'karin.karlsson@example.com', 'adminpass', '7890123456', '2023-07-14', 0, 1),
    ('U12', 'Lars', 'Lind', 'lars.lind@example.com', 'letmein', '9876543210', '2023-08-14', 1, 0),
    ('U13', 'Maria', 'Månsson', 'maria.mansson@example.com', 'mypass123', '5551234567', '2023-08-14', 0, 0),
    ('U14', 'Nils', 'Nilsson', 'nils.nilsson@example.com', 'securepassword', '1237894560', '2023-11-14', 1, 1),
    ('U15', 'Oskar', 'Olsson', 'oskar.olsson@example.com', 'strongpass', '9876543210', '2023-11-14', 0, 1);


-- Insert data into UserAddress table
INSERT INTO UserAddress (UserID, StreetAddress, City, PostalCode, Country, IsDefault)
VALUES
    ('U1', 'Svärdvägen 123', 'Milan', '12345', 'Italy', 1), 
    ('U2', 'Rosengatan 456', 'Gothenburg', '56789', 'Sweden', 0),
    ('U3', 'Liljevägen 789', 'Malmo', '98765', 'Sweden', 0),
    ('U4', 'Björkvägen 234', 'Uppsala', '23456', 'Sweden', 1), 
    ('U5', 'Ekbacken 567', 'Milan', '34567', 'Italy', 0),
    ('U6', 'Granvägen 890', 'Berlin', '45678', 'Germany', 0),
    ('U7', 'Ekgatan 123', 'Västerås', '56789', 'Sweden', 1), 
    ('U8', 'Drottninggatan 456', 'Berlin', '67890', 'Germany', 0),
    ('U9', 'Solskensvägen 789', 'Norrköping', '78901', 'Sweden', 0),
    ('U10', 'Kungsgatan 234', 'Helsingborg', '89012', 'Sweden', 1), 
    ('U11', 'Vasagatan 567', 'Umeå', '90123', 'Sweden', 0),
    ('U12', 'Skogsvägen 890', 'Gävle', '01234', 'Sweden', 0),
    ('U13', 'Karlsgatan 123', 'Borås', '12345', 'Sweden', 1), 
    ('U14', 'Storgatan 456', 'Växjö', '23456', 'Sweden', 0),
    ('U15', 'Sjövägen 789', 'Lund', '34567', 'Sweden', 0);

-- Insert data into UserActivity table
INSERT INTO UserActivity (UserID, ActivityType, ActivityTimestamp)
VALUES
    ('U1', 'Login', '2023-11-14 08:30:00'),
    ('U2', 'Purchase', '2023-11-14 12:45:00'),
    ('U3', 'Update Profile', '2023-11-14 15:20:00'),
    ('U4', 'Login', '2023-11-14 09:15:00'),
    ('U5', 'Logout', '2023-11-14 17:30:00'),
    ('U6', 'Purchase', '2023-11-14 14:10:00'),
    ('U7', 'Update Profile', '2023-11-14 16:40:00'),
    ('U8', 'Login', '2023-11-14 10:05:00'),
    ('U9', 'Logout', '2023-11-14 18:00:00'),
    ('U10', 'Purchase', '2023-11-14 13:00:00'),
    ('U11', 'Login', '2023-11-14 11:30:00'),
    ('U12', 'Update Profile', '2023-11-14 14:50:00'),
    ('U13', 'Logout', '2023-11-14 19:20:00'),
    ('U14', 'Purchase', '2023-11-14 15:35:00'),
    ('U15', 'Login', '2023-11-14 12:00:00');

INSERT INTO PaymentMethods (UserID, PaymentMethodName, IsDefault)
VALUES
    ('U1', 'Credit Card', 1),  
    ('U1', 'PayPal', 0),
    ('U2', 'Bank Transfer', 1), 
    ('U2', 'Klarna', 0),
    ('U3', 'Credit Card', 1),  
    ('U3', 'PayPal', 0),
    ('U4', 'Klarna', 1),  
    ('U4', 'Bank Transfer', 0),
    ('U5', 'Credit Card', 1),  
    ('U5', 'PayPal', 0),
    ('U6', 'Klarna', 1),  
    ('U6', 'Bank Transfer', 0),
    ('U7', 'Credit Card', 1),  
    ('U7', 'PayPal', 0),
    ('U8', 'Bank Transfer', 1), 
    ('U8', 'Klarna', 0),
    ('U9', 'Credit Card', 1),  
    ('U9', 'PayPal', 0),
    ('U10', 'Bank Transfer', 1),  
    ('U10', 'Credit Card', 0),
    ('U11', 'Klarna', 1),  
    ('U11', 'Bank Transfer', 0),
    ('U12', 'Credit Card', 1),  
    ('U12', 'PayPal', 0),
    ('U13', 'Klarna', 1),  
    ('U13', 'Credit Card', 0),
    ('U14', 'Bank Transfer', 1),  
    ('U14', 'PayPal', 0),
    ('U15', 'Credit Card', 1),  
    ('U15', 'Klarna', 0);

-- Insert data into ProductCategory table
INSERT INTO ProductCategory (CategoryName, ParentCategoryID)
VALUES
    ('Men''s Clothing', NULL), 
    ('Formal Shirts', 2), 
    ('Jeans', 1),  
    ('Slim Fit Jeans', 5),  
    ('Regular Fit Jeans', 5), 
    ('Accessories', NULL), 
    ('Belts', 8),  
    ('Hats', 8), 
    ('Shoes', NULL),  
    ('Casual Shoes', 11), 
	('Shirts', 1),  
    ('T-Shirts', 2),
    ('Formal Shoes', 11); 

INSERT INTO Products (ProductID, ProductName, Description, Color, Produktinformation, IsInOutlet, Price, StockQuantity, CategoryID)
VALUES
    ('P1', 'Men''s Formal Shirt', 'Classic formal shirt for men', 'White', 'Premium quality formal shirt for special occasions.', 0, 39.99, 100, 2), 
    ('P2', 'Slim Fit Jeans', 'Slim fit jeans for men', 'Blue', 'Comfortable and stylish slim fit jeans.', 0, 49.99, 150, 5), 
    ('P3', 'Leather Belt', 'Genuine leather belt', 'Brown', 'High-quality leather belt with a classic design.', 0, 19.99, 200, 8), 
    ('P4', 'Casual Shoes', 'Casual shoes for men', 'Black', 'Versatile and comfortable shoes for everyday wear.', 0, 59.99, 120, 11), 
    ('P5', 'Men''s T-Shirt', 'Comfortable cotton T-shirt for men', 'Gray', 'Casual and stylish T-shirt for daily wear.', 0, 24.99, 180, 2), 
    ('P6', 'Regular Fit Jeans', 'Regular fit jeans for men', 'Dark Blue', 'Classic regular fit jeans for a timeless look.', 0, 44.99, 130, 5), 
    ('P7', 'Formal Shoes', 'Classic formal shoes for men', 'Black', 'Elegant and timeless formal shoes for special occasions.', 0, 69.99, 90, 11), 
    ('P8', 'Stylish Hat', 'Stylish hat for men', 'Navy Blue', 'Add a touch of style to your outfit with this fashionable hat.', 0, 29.99, 70, 9), 
    ('P9', 'Men''s Polo Shirt', 'Casual polo shirt for men', 'Red', 'Comfortable and trendy polo shirt for a casual look.', 0, 34.99, 110, 2), 
    ('P10', 'Leather Wallet', 'Slim leather wallet', 'Black', 'Compact and stylish leather wallet for your essentials.', 0, 14.99, 160, 8), 
    ('P11', 'Classic Denim Jacket', 'Timeless denim jacket for men', 'Denim Blue', 'Versatile and durable denim jacket for various occasions.', 0, 79.99, 80, 5), 
    ('P12', 'Sports Shoes', 'Comfortable sports shoes for men', 'White', 'Ideal for sports and an active lifestyle.', 0, 49.99, 100, 11),
    ('P13', 'Printed T-Shirt', 'Graphic printed T-shirt for men', 'Black', 'Express your style with this unique printed T-shirt.', 0, 29.99, 120, 2), 
    ('P14', 'Cargo Pants', 'Cargo pants with multiple pockets', 'Khaki', 'Functional and stylish cargo pants for a casual look.', 0, 39.99, 90, 5), 
    ('P15', 'Suede Loafers', 'Suede loafers for men', 'Tan', 'Add a touch of sophistication to your outfit with these suede loafers.', 0, 59.99, 110, 11), 
    ('P16', 'Striped Shirt', 'Striped shirt for men', 'Blue/White', 'Classic striped design for a timeless and elegant look.', 0, 34.99, 80, 2), 
    ('P17', 'Cotton Shorts', 'Comfortable cotton shorts for men', 'Beige', 'Perfect for a casual and relaxed summer look.', 0, 24.99, 130, 5), 
    ('P18', 'Canvas Backpack', 'Canvas backpack for everyday use', 'Gray', 'Spacious and durable backpack for your daily essentials.', 0, 44.99, 70, 9), 
    ('P19', 'Denim Overalls', 'Denim overalls for men', 'Medium Wash', 'Cool and trendy denim overalls for a unique style.', 0, 64.99, 60, 5), 
    ('P20', 'Classic Fedora Hat', 'Classic fedora hat for men', 'Brown', 'Elevate your style with this classic fedora hat.', 0, 29.99, 100, 9);

-- Insert data into ProductInventory table
INSERT INTO ProductInventory (ProductID, AvailableQuantity)
VALUES
    ('P1', 80),  
    ('P2', 120),  
    ('P3', 150),  
    ('P4', 100),  
    ('P5', 90),  
    ('P6', 110), 
    ('P7', 70),   
    ('P8', 60),   
    ('P9', 100),  
    ('P10', 80),  
    ('P11', 50),  
    ('P12', 120), 
    ('P13', 70),  
    ('P14', 60),
    ('P15', 90),  
    ('P16', 40),  
    ('P17', 80),  
    ('P18', 50),  
    ('P19', 30),  
    ('P20', 60);  

-- Insert data into ShoppingCart table
INSERT INTO Orders (OrderID, UserID, OrderDate, Status, ShippingAddress, BillingAddress, PaymentInformation, TotalAmount, ShippingMethod, NotesComments)
VALUES
    ('O1', 'U1', '2023-11-15 08:30:00', 'Processing', '123 Main St, Cityville', '123 Billing St, Cityville', 'Credit Card ending in 1234', 99.99, 'Express Shipping', 'Special instructions for processing order O1.'),
    ('O2', 'U2', '2023-11-15 09:45:00', 'Out for delivery', '456 Oak St, Townsville', '456 Billing St, Townsville', 'PayPal transaction ID: ABC123', 149.99, 'Standard Shipping', 'Order O2 is out for delivery.'),
    ('O3', 'U3', '2023-11-15 11:15:00', 'Delivered', '789 Pine St, Villagetown', '789 Billing St, Villagetown', 'Bank Transfer reference: XYZ987', 199.99, 'Express Shipping', 'Order O3 has been successfully delivered.'),
    ('O4', 'U4', '2023-11-15 12:30:00', 'Processing', '101 Maple St, Hamletville', '101 Billing St, Hamletville', 'Credit Card ending in 5678', 79.99, 'Standard Shipping', 'Special instructions for processing order O4.'),
    ('O5', 'U5', '2023-11-15 14:00:00', 'Out for delivery', '111 Birch St, Forestville', '111 Billing St, Forestville', 'PayPal transaction ID: DEF456', 129.99, 'Express Shipping', 'Order O5 is out for delivery.'),
    ('O6', 'U6', '2023-11-15 15:30:00', 'Delivered', '222 Cedar St, Mountainville', '222 Billing St, Mountainville', 'Bank Transfer reference: UVW789', 179.99, 'Standard Shipping', 'Order O6 has been successfully delivered.'),
    ('O7', 'U7', '2023-11-15 16:45:00', 'Processing', '333 Elm St, Riverside', '333 Billing St, Riverside', 'Credit Card ending in 9876', 109.99, 'Express Shipping', 'Special instructions for processing order O7.'),
    ('O8', 'U8', '2023-11-15 18:00:00', 'Out for delivery', '444 Walnut St, Lakeside', '444 Billing St, Lakeside', 'PayPal transaction ID: GHI123', 159.99, 'Standard Shipping', 'Order O8 is out for delivery.'),
    ('O9', 'U9', '2023-11-15 19:30:00', 'Delivered', '555 Pineapple St, Beachville', '555 Billing St, Beachville', 'Bank Transfer reference: JKL456', 209.99, 'Express Shipping', 'Order O9 has been successfully delivered.'),
    ('O10', 'U10', '2023-11-15 21:00:00', 'Processing', '666 Banana St, Tropicatown', '666 Billing St, Tropicatown', 'Credit Card ending in 5432', 89.99, 'Standard Shipping', 'Special instructions for processing order O10.'),
    ('O11', 'U11', '2023-11-15 22:15:00', 'Out for delivery', '777 Mango St, Orchardville', '777 Billing St, Orchardville', 'PayPal transaction ID: MNO789', 139.99, 'Express Shipping', 'Order O11 is out for delivery.'),
    ('O12', 'U12', '2023-11-15 23:45:00', 'Delivered', '888 Papaya St, Juicetown', '888 Billing St, Juicetown', 'Bank Transfer reference: PQR123', 189.99, 'Standard Shipping', 'Order O12 has been successfully delivered.'),
    ('O13', 'U13', '2023-11-16 01:00:00', 'Processing', '999 Guava St, Smoothieville', '999 Billing St, Smoothieville', 'Credit Card ending in 8765', 99.99, 'Express Shipping', 'Special instructions for processing order O13.'),
    ('O14', 'U14', '2023-11-16 02:30:00', 'Out for delivery', '101 Coconut St, Tropicalville', '101 Billing St, Tropicalville', 'PayPal transaction ID: STU456', 149.99, 'Standard Shipping', 'Order O14 is out for delivery.'),
    ('O15', 'U15', '2023-11-16 04:00:00', 'Delivered', '202 Pineapple St, Islandville', '202 Billing St, Islandville', 'Bank Transfer reference: VWX789', 199.99, 'Express Shipping', 'Order O15 has been successfully delivered.');


INSERT INTO OrderItems (OrderItemID, OrderID, ProductID, Quantity, Price, TotalPrice)
VALUES
    ('OI1', 'O1', 'P1', 2, 49.99, 99.98),
    ('OI2', 'O2', 'P2', 1, 149.99, 149.99),
    ('OI3', 'O3', 'P3', 3, 199.99, 599.97),
    ('OI4', 'O4', 'P4', 2, 79.99, 159.98),
    ('OI5', 'O5', 'P5', 1, 129.99, 129.99),
    ('OI6', 'O6', 'P6', 4, 179.99, 719.96),
    ('OI7', 'O7', 'P7', 2, 109.99, 219.98),
    ('OI8', 'O8', 'P8', 1, 159.99, 159.99),
    ('OI9', 'O9', 'P9', 3, 209.99, 629.97),
    ('OI10', 'O10', 'P10', 2, 89.99, 179.98),
    ('OI11', 'O11', 'P11', 1, 139.99, 139.99),
    ('OI12', 'O12', 'P12', 4, 189.99, 759.96),
    ('OI13', 'O13', 'P13', 2, 99.99, 199.98),
    ('OI14', 'O14', 'P14', 1, 149.99, 149.99),
    ('OI15', 'O15', 'P15', 3, 199.99, 599.97);


INSERT INTO Reviews (ProductID, UserID, Rating, Comment, ReviewDate)
VALUES
    ('P1', 'U1', 4, 'Great product! I love it.', '2023-11-16 08:30:00'),
    ('P2', 'U2', 5, 'Excellent quality and fast delivery.', '2023-11-16 09:45:00'),
    ('P3', 'U3', 3, 'Average product, could be better.', '2023-11-16 11:15:00'),
    ('P4', 'U4', 5, 'Perfect fit and comfortable.', '2023-11-16 12:30:00'),
    ('P5', 'U5', 2, 'Disappointed with the color.', '2023-11-16 14:00:00'),
    ('P6', 'U6', 4, 'Nice design and good quality material.', '2023-11-16 15:30:00'),
    ('P7', 'U7', 5, 'Amazing service and product!', '2023-11-16 16:45:00'),
    ('P8', 'U8', 3, 'Average, expected more for the price.', '2023-11-16 18:00:00'),
    ('P9', 'U9', 4, 'Happy with the purchase.', '2023-11-16 19:30:00'),
    ('P10', 'U10', 5, 'Top-notch quality, highly recommend.', '2023-11-16 21:00:00'),
    ('P11', 'U11', 2, 'Not satisfied, considering a return.', '2023-11-16 22:15:00'),
    ('P12', 'U12', 4, 'Good value for the price.', '2023-11-16 23:45:00'),
    ('P13', 'U13', 5, 'Excellent service and fast shipping.', '2023-11-17 01:00:00'),
    ('P14', 'U14', 3, 'Decent product, but expected better.', '2023-11-17 02:30:00'),
    ('P15', 'U15', 4, 'Satisfied with the purchase.', '2023-11-17 04:00:00');


-- Favorites Table
INSERT INTO Favorites (UserID, ProductID)
VALUES
    ('U1', 'P1'),
    ('U2', 'P3'),
    ('U3', 'P5'),
    ('U4', 'P7'),
    ('U5', 'P9'),
    ('U6', 'P11'),
    ('U7', 'P13'),
    ('U8', 'P15'),
    ('U9', 'P2'),
    ('U10', 'P4'),
    ('U11', 'P6'),
    ('U12', 'P8'),
    ('U13', 'P10'),
    ('U14', 'P12'),
    ('U15', 'P14');

-- Promotions Table
INSERT INTO Promotions (ProductID, DiscountPercentage, StartDate, EndDate)
VALUES
    ('P1', 10.00, '2023-11-15', '2023-11-30'),
    ('P3', 15.00, '2023-11-16', '2023-11-25'),
    ('P5', 20.00, '2023-11-18', '2023-12-01'),
    ('P7', 25.00, '2023-11-20', '2023-11-28'),
    ('P9', 30.00, '2023-11-22', '2023-11-29'),
    ('P11', 12.00, '2023-11-17', '2023-11-26'),
    ('P13', 18.00, '2023-11-19', '2023-11-27'),
    ('P15', 22.00, '2023-11-21', '2023-11-30'),
    ('P2', 14.00, '2023-11-16', '2023-11-29'),
    ('P4', 16.00, '2023-11-18', '2023-11-25'),
    ('P6', 28.00, '2023-11-20', '2023-11-27'),
    ('P8', 32.00, '2023-11-22', '2023-11-30'),
    ('P10', 21.00, '2023-11-17', '2023-11-26'),
    ('P12', 24.00, '2023-11-19', '2023-11-28'),
    ('P14', 26.00, '2023-11-21', '2023-11-29');

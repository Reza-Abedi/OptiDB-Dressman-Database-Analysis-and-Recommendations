/****************************** Assignment Report **************************************
           Database Queries and Operations for Dressman Database

Overview:
The queries and operations performed on the Dressman database span a range of tasks,
from basic data retrieval to more complex analysis and optimization techniques. 
This report provides a comprehensive summary of the SQL queries, stored procedures, views, 
and an index implemented for various purposes within the Dressman database.
*****************************************************************************************/

-- 1. Select a user by name and display all their contact information

SELECT 
    U.UserID,
    U.FirstName,
    U.LastName,
    U.Email,
    U.PhoneNumber,
    UA.StreetAddress,
    UA.City,
    UA.PostalCode,
    UA.Country
FROM Users U
INNER JOIN UserAddress UA ON U.UserID = UA.UserID
WHERE U.FirstName = 'Anna' AND U.LastName = 'Andersson';
-- Utilizing an INNER JOIN between Users and UserAddress, this query offers a glimpse into the detailed user profile.

---------------------------------------------------------------------------------------------

-- 2. Which user has spent the most money?

SELECT TOP 1
    u.UserID,
    u.FirstName,
    u.LastName,
    SUM(o.TotalAmount) AS TotalSpent
FROM Users u
INNER JOIN Orders o ON u.UserID = o.UserID
GROUP BY u.UserID, u.FirstName, u.LastName
ORDER BY TotalSpent DESC;
-- The aggregation function SUM is then applied to calculate the total amount spent by each user, grouping the results by the unique user identifiers.

---------------------------------------------------------------------------------------------

-- 3. Select all users from a specific country and display all their orders

-- Replace a Country 
DECLARE @Country NVARCHAR(50) = 'Italy';

-- Select all users from the specified country and display their orders
SELECT 
    U.UserID,
    U.FirstName,
    U.LastName,
    A.Country,
    O.OrderID,
    O.OrderDate,
    O.Status,
    O.ShippingAddress,
    O.BillingAddress,
    O.PaymentInformation,
    O.TotalAmount,
    O.ShippingMethod,
    O.NotesComments
FROM Users U
JOIN UserAddress A ON U.UserID = A.UserID
LEFT JOIN Orders O ON U.UserID = O.UserID
WHERE A.Country = @Country;
-- A LEFT JOIN is established with the Orders table (alias O) based on the user ID. 
-- This type of join ensures that all users, regardless of order history, are included in the result.
-- The WHERE clause specifies that the query should only consider users from the country specified by the @Country variable. 

---------------------------------------------------------------------------------------------

-- 4. What is the most expensive product in the store?

SELECT TOP 1
    ProductID,
    ProductName,
    Price
FROM Products
ORDER BY Price DESC;
/* 
this query identifies the most expensive product in the store by leveraging a
straightforward SELECT statement with TOP 1 and ORDER BY clauses.
*/

---------------------------------------------------------------------------------------------

-- 5. How many products are there in total in the store?

SELECT SUM(AvailableQuantity) AS TotalStockQuantity
FROM ProductInventory;

/*  
The query calculates the total number of products available,
contributing to a holistic view of stock levels
*/

---------------------------------------------------------------------------------------------

-- 6. What is the total value (SEK) of all products?

SELECT 
    p.ProductID, 
    p.ProductName,
    p.StockQuantity,
    p.price,
    CONCAT(SUM(p.price * pi.AvailableQuantity), ' SEK') AS total_value
FROM products p
JOIN ProductInventory pi ON p.ProductID = pi.ProductID
GROUP BY p.ProductID, p.ProductName, p.price, p.StockQuantity

UNION 

-- Grand total
SELECT 
    'Grand Total ' AS ProductID, 
    '----------> ' AS ProductName,
    ' ' AS StockQuantity,
    ' ' AS price,
    CONCAT(SUM(p.price * pi.AvailableQuantity), ' SEK') AS total_value
FROM products p
INNER JOIN ProductInventory pi ON p.ProductID = pi.ProductID;
/*
The query starts by calculating the total value for each individual 
product by multiplying the unit price (p.price) with the available quantity (pi.AvailableQuantity).
A UNION statement is used to append a row representing the grand total to the result set.
The grand total row summarizes the overall value of Dressman's entire 
inventory by summing up the total values of all individual products.
*/


---------------------------------------------------------------------------------------------

-- 7. Create syntax using GROUP BY

-- Get the total quantity sold for each product in each city, along with customer information
SELECT
    U.FirstName,
    U.LastName,
    UA.City,
    OI.ProductID,
    P.ProductName,
    SUM(OI.Quantity) AS TotalQuantitySold
FROM UserAddress UA
INNER JOIN Users U ON UA.UserID = U.UserID
INNER JOIN Orders O ON U.UserID = O.UserID
INNER JOIN OrderItems OI ON O.OrderID = OI.OrderID
INNER JOIN Products P ON OI.ProductID = P.ProductID
GROUP BY U.FirstName, U.LastName, UA.City, OI.ProductID, P.ProductName;

/*
GROUP BY Clause: The GROUP BY clause is applied to the columns 
FirstName, LastName, City, ProductID, and ProductName.
This grouping is essential to aggregate data based on these attributes.
Aggregate Function (SUM): The SUM function is employed to calculate the 
total quantity sold for each product in every city.
*/


---------------------------------------------------------------------------------------------

-- 8. Create syntax using MIN, MAX, SUM & AVG

-- Select user information along with order statistics
SELECT
    U.UserID,
    U.FirstName,
    U.LastName,
    COUNT(O.OrderID) AS NumberOfOrders,
    MIN(O.TotalAmount) AS MinOrderAmount,
    MAX(O.TotalAmount) AS MaxOrderAmount,
    SUM(O.TotalAmount) AS TotalOrderAmount,
    AVG(O.TotalAmount) AS AvgOrderAmount
FROM Users U
INNER JOIN Orders O ON U.UserID = O.UserID
GROUP BY U.UserID, U.FirstName, U.LastName;

---------------------------------------------------------------------------------------------

-- 9. Create syntaxes that use sorting in the result

-- Sort orders by customer and date in ascending order
SELECT
    OrderID,
    UserID,
    OrderDate
FROM
    Orders
ORDER BY
    UserID, OrderDate;

---------------------------------------------------------------------------------------------

-- 10. Create syntax using variables

DECLARE @MinOrderAmount money; -- Declare a variable with the name

SET @MinOrderAmount = 100.00; -- Assign the value 100.00 to the variable

-- This is a SELECT query that retrieves orders where TotalAmount is greater than or equal to 
SELECT
    OrderID,
    OrderDate,
    TotalAmount
FROM
    Orders
WHERE
    TotalAmount >= @MinOrderAmount;

---------------------------------------------------------------------------------------------

-- 11. Create at least 1 stored procedure

-- Stored procedure to get user information
CREATE PROCEDURE GetUserInformation
    @UserID NVARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        UserID,
        FirstName,
        LastName,
        Email,
        PhoneNumber,
        RegistrationDate,
        ReceiveSMSOffers,
        ReceiveEmailOffers
    FROM
        Users
    WHERE
        UserID = @UserID;
END;
-- Example of how to execute the stored procedure
EXEC GetUserInformation @UserID = 'U4';

-- Create a stored procedure to get order information for a specific user
CREATE PROCEDURE GetOrdersByUser
    @UserID NVARCHAR(10)
AS
BEGIN
    SELECT
        O.OrderID,
        O.OrderDate,
        O.Status,
        O.ShippingAddress,
        O.BillingAddress,
        O.TotalAmount,
        O.ShippingMethod,
        O.NotesComments,
        P.ProductName,
        OI.Quantity,
        OI.Price,
        OI.TotalPrice
    FROM
        Orders O
    INNER JOIN
        OrderItems OI ON O.OrderID = OI.OrderID
    INNER JOIN
        Products P ON OI.ProductID = P.ProductID
    WHERE
        O.UserID = @UserID;
END;

-- Execute the stored procedure for a specific user (e.g., 'U1')
EXEC GetOrdersByUser @UserID = 'U1';

---------------------------------------------------------------------------------------------

-- 12. Create syntax using IF

DECLARE @UserID Nvarchar(10); -- Declare the variable
SET @UserID = 'U10'; -- Try U20

IF EXISTS (SELECT * FROM Favorites WHERE UserID = @UserID)
BEGIN
    SELECT 
        U.UserID,
        F.ProductID,
        P.ProductName
    FROM Users U
    INNER JOIN Favorites F ON U.UserID = F.UserID
    INNER JOIN Products P ON F.ProductID = P.ProductID
    WHERE U.UserID = @UserID;
END
ELSE
BEGIN
    PRINT '-----> VERY LAZY USER Maybe: The user has no favorites or The user is not available in this DB :)) ';
END

---------------------------------------------------------------------------------------------

-- 13. Create at least 2 SQL views

-- View 1: CustomerOrders: Show all customer orders and order details

CREATE VIEW CustomerOrders AS
SELECT
    O.OrderID,
    O.UserID,
    U.FirstName + ' ' + U.LastName AS CustomerName,
    O.OrderDate,
    O.Status,
    O.TotalAmount,
    O.ShippingMethod,
    O.NotesComments,
    O.ShippingAddress,
    O.BillingAddress,
    P.ProductID,
    P.ProductName,
    OI.Quantity,
    OI.Price AS UnitPrice,
    OI.TotalPrice AS ItemTotal
FROM Orders O
INNER JOIN Users U ON O.UserID = U.UserID
INNER JOIN OrderItems OI ON O.OrderID = OI.OrderID
INNER JOIN Products P ON OI.ProductID = P.ProductID;

-- Query the created view
SELECT * FROM CustomerOrders

-- View 2: ProductTotalSales: Create a view to show total sales for each product
CREATE VIEW ProductTotalSales AS
SELECT
    P.ProductID,
    P.ProductName,
    SUM(OI.Quantity) AS TotalQuantitySold,
    SUM(OI.TotalPrice) AS TotalSales
FROM OrderItems OI
INNER JOIN Products P ON OI.ProductID = P.ProductID
GROUP BY P.ProductID, P.ProductName;

-- Query to retrieve total sales for each product
SELECT * FROM ProductTotalSales;

---------------------------------------------------------------------------------------------

-- 14. Create at least 1 syntax that contains a subquery

-- List of users along with details about their most recent activity, including the activity type and timestamp.
SELECT 
    u.UserID,
    u.FirstName,
    u.LastName,
    (SELECT TOP 1 ua.ActivityType 
     FROM UserActivity ua 
     WHERE ua.UserID = u.UserID 
     ORDER BY ua.ActivityTimestamp DESC) AS LatestActivityType,
    (SELECT TOP 1 ua.ActivityTimestamp 
     FROM UserActivity ua 
     WHERE ua.UserID = u.UserID 
     ORDER BY ua.ActivityTimestamp DESC) AS LatestActivityTimestamp
FROM Users u;

-- Fetch products that are currently offered with a discount percentage greater than 15%.
SELECT *
FROM Products
WHERE ProductID IN (
    SELECT ProductID
    FROM Promotions
    WHERE DiscountPercentage > 15.00
);

---------------------------------------------------------------------------------------------

-- 15. Create at least 1 Index

-- The purpose of creating an index is to enhance the speed of data retrieval operations, particularly SELECT queries. 
CREATE INDEX IX_UserAddress_UserID ON UserAddress(UserID);

-- The purpose of this index is to enhance the speed of queries that filter or merge data based on the "UserID" column in the "Orders" table.
CREATE INDEX IX_Orders_UserID ON Orders(UserID);

-- 1. Find the top 10 customers who have placed the most orders.
SELECT
    c.customerName,
    COUNT(*) AS count_order_placed
FROM
    customers c
JOIN
    orders o ON c.customerNumber = o.customerNumber
GROUP BY
    c.customerName
ORDER BY
    count_order_placed DESC
LIMIT 10;

-- 2. Retrieve the list of customers who have placed orders but haven't made any payments yet.
SELECT
    c.customername,
    o.orderNumber
FROM
    customers c
JOIN
    orders o ON c.customerNumber = o.customerNumber
LEFT JOIN
    payments p ON o.customerNumber = p.customerNumber 
WHERE
    p.customerNumber IS NULL
ORDER BY
    c.customerName, o.orderNumber;

-- 3. Retrieve a product that has been ordered the least number of times.
SELECT
    p.productCode,
    p.productname,
    COUNT(o.orderNumber) AS ordercount
FROM
    products p
JOIN
    orderdetails od ON p.productCode = od.productCode
JOIN
    orders o ON od.orderNumber = o.orderNumber
GROUP BY
    p.productCode, p.productName
ORDER BY
    ordercount
LIMIT 1;

-- 4. Calculate the total revenue generated by the "Vintage Cars" product line in the last quarter of 2003.
DELIMITER //

CREATE PROCEDURE GetVintageCarsRevenue()
BEGIN
    SELECT 
        SUM(od.quantityOrdered * od.priceEach) AS totalRevenue
    FROM  
        orderdetails od
    JOIN
        orders o ON od.orderNumber = o.orderNumber
    JOIN
        products p ON od.productCode = p.productCode
    WHERE  
        p.productLine = 'Vintage Cars'
        AND YEAR(o.orderDate) = 2003
        AND QUARTER(o.orderDate) = 4;
END //

DELIMITER ;

-- 5. Retrieve the top 5 customers along with their total order values across all orders.
WITH CustomerOrderTotals AS (
    SELECT
        c.customerNumber,
        c.customerName,
        SUM(od.quantityOrdered * od.priceEach) AS totalOrderValue,
        RANK() OVER (ORDER BY SUM(od.quantityOrdered * od.priceEach) DESC) AS ranking
    FROM
        customers c
    JOIN
        orders o ON c.customerNumber = o.customerNumber
    JOIN
        orderdetails od ON o.orderNumber = od.orderNumber
    GROUP BY
        c.customerNumber, c.customerName
)
SELECT
    customerNumber,
    customerName,
    totalOrderValue
FROM
    CustomerOrderTotals
ORDER BY
    ranking
LIMIT 5;

use northwind;
#-------------------------------#
#               1               #
#-------------------------------#
#              1.1              #
SELECT OrderID, ShippedDate, ShipVia FROM Orders WHERE ShippedDate >= '1998-05-05 00:00:00' and ShipVia >= 2;

# 			   1.2				#
SELECT OrderID, 
CASE 
	WHEN ShippedDate IS NULL
		THEN 'Not Shipped'
	ELSE ShippedDate
END AS ShippedDate
FROM Orders;

# 			   1.3				#
SELECT OrderID AS `Order Number`, COALESCE(DATE_FORMAT(ShippedDate, '%d.%m.%Y'), 'Not shipped') AS `Shipped Date`
FROM Orders WHERE ( ShippedDate >= '1998-05-05 00:00:00' OR ShippedDate IS NULL);

#-------------------------------#
#				2				#
#-------------------------------#
# 			   2.1				#
SELECT ContactName, Country FROM Customers WHERE Country IN ('Canada', 'USA') ORDER BY ContactName, Country;

# 			   2.2				#
SELECT ContactName, Country FROM Customers WHERE Country NOT IN ('Canada', 'USA') ORDER BY ContactName;

# 			   2.3				#
SELECT DISTINCT Country FROM Customers ORDER BY Country DESC;

#-------------------------------#
#				3				#
#-------------------------------#
# 			   3.1				#
SELECT DISTINCT OrderID FROM `Order Details` WHERE Quantity BETWEEN 3 AND 10;

# 			   3.2				#
EXPLAIN
SELECT CustomerID, Country From Customers WHERE Country BETWEEN 'B' AND 'H' ORDER BY Country;

# 			   3.3				#
EXPLAIN
SELECT CustomerId, Country FROM Customers WHERE Country >= 'B' AND Country <= 'H' ORDER BY Country;

#-------------------------------#
#				4				#
#-------------------------------#
SELECT * FROM Products WHERE ProductName LIKE '%cho_olade%';

#-------------------------------#
#				5				#
#-------------------------------#
# 			   5.1				#
SELECT CONCAT('$', FORMAT(SUM((UnitPrice - Discount/100 * UnitPrice) * Quantity), 2)) AS Totals FROM `order details`;

# 			   5.2				#
SELECT COUNT(*) - COUNT(ShippedDate) AS NotShippedOrdersCount FROM Orders;

# 			   5.3				#
SELECT COUNT(DISTINCT CustomerId) AS CustomersCount FROM Orders;

#-------------------------------#
#				6				#
#-------------------------------#
# 			   6.1				#
SELECT YEAR(ShippedDate) AS Year, COUNT(*) AS Total FROM Orders GROUP BY YEAR(ShippedDate);
#Проверочный запрос:
SELECT COUNT(*) FROM Orders; -- 830 (Совпадает)

# 			   6.2				#
SELECT (SELECT CONCAT(FirstName, ' ', LastName) FROM Employees WHERE EmployeeId = Orders.EmployeeId) AS Seller, 
COUNT(*) AS Amount  
FROM Orders GROUP BY EmployeeId ORDER BY Amount DESC;

# 			   6.3				#
SELECT ShipCountry AS Country, COUNT(ShipCountry) AS Count FROM Orders 
GROUP BY ShipCountry order by COUNT DESC LIMIT 5;

# 			   6.4				#

SELECT 
IF (GROUPING(Suppliers.CompanyName) = 1, ' ALL ', Suppliers.CompanyName) AS Seller, 
IF (GROUPING(Customers.CompanyName) = 1, ' ALL ', Customers.CompanyName) AS Customer,
COUNT(*) AS Amount
FROM  Orders, Customers, `Order Details`, Products, Suppliers 
WHERE Orders.OrderId = `Order Details`.OrderId
AND `Order Details`.ProductId = Products.ProductId 
AND Products.SupplierId = Suppliers.SupplierId 
AND Orders.CustomerId = Customers.CustomerId
GROUP BY Suppliers.CompanyName, Customers.CompanyName WITH ROLLUP ORDER BY Seller, Customer, Amount DESC; 


# 			   6.5				#
SELECT Customers.ContactName AS Person, 'Customer' AS Type, Customers.City 
FROM Customers, Suppliers WHERE Customers.City = Suppliers.City 
UNION 
SELECT Suppliers.ContactName, 'Supplier', Suppliers.City
FROM Suppliers, Customers WHERE Customers.City = Suppliers.City  
ORDER BY City, Person ;

# 			   6.6				#
SELECT DISTINCT Customers.CustomerId, Customers.City FROM Customers, Customers AS CustomersMatch 
WHERE Customers.City = CustomersMatch.City  AND Customers.CustomerId <> CustomersMatch.CustomerId ORDER By City;

SELECT City, COUNT(City) FROM Customers GROUP BY City  HAVING COUNT(City) > 1 ORDER By City;

# 			   6.7				#
SELECT Employees.LastName AS UserName, Bosses.LastName AS Boss 
FROM Employees, Employees AS Bosses WHERE Employees.ReportsTo = Bosses.EmployeeId;
-- В запросе не высвечен вице-президент, который ни перед кем не отчитывается

#-------------------------------#
#				7				#
#-------------------------------#
SELECT LastName, Territories.TerritoryDescription FROM Employees 
JOIN Employeeterritories ON Employeeterritories.EmployeeId = Employees.EmployeeId
JOIN Territories ON Territories.TerritoryId = Employeeterritories.TerritoryId 
JOIN Region ON Region.RegionId = Territories.RegionId  
WHERE Region.RegionDescription LIKE 'WESTERN%';

#-------------------------------#
#				8				#
#-------------------------------#
SELECT ContactName, Count(Orders.OrderId) AS Amount FROM Customers LEFT JOIN 
Orders ON Orders.CustomerId = Customers.CustomerId GROUP BY ContactName ORDER BY Amount;

#-------------------------------#
#				9				#
#-------------------------------#
SELECT CompanyName FROM Suppliers WHERE SupplierId IN (SELECT SupplierId FROM PRODUCTS WHERE UnitsInStock = 0 ) ;
SELECT CompanyName FROM Suppliers WHERE SupplierId = SOME (SELECT SupplierId FROM PRODUCTS WHERE UnitsInStock = 0 ) ;
 
#-------------------------------#
#				10				#
#-------------------------------#
SELECT 
(SELECT CompanyName FROM Suppliers WHERE SupplierId = Products.SupplierId) AS Supplier, ProductId, ProductName, 
(SELECT SUM((SELECT COUNT(ProductId) FROM `Order details` WHERE ProductId = Products.ProductId))) AS OrdersQuantity
FROM Products GROUP BY SUPPLIER  HAVING OrdersQuantity > 150 ;

#-------------------------------#
#				11				#
#-------------------------------#
SELECT * FROM Customers WHERE NOT EXISTS (SELECT * FROM Orders Where CustomerId = Customers.CustomerId);

#-------------------------------#
#				12				#
#-------------------------------#
SELECT DISTINCT LEFT(LastName, 1) AS LastNameLetter FROM Employees ORDER BY LastNameLetter;

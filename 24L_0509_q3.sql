-- Writing down the simple queries for Question 3 here ... 


-- 1. List the part number for every part that is shipped by more than one supplier
SELECT pnum 
FROM Shipments 
GROUP BY pnum 
HAVING COUNT(DISTINCT snum) > 1 

-- 2. Find the average weight of all the parts
SELECT 
	AVG(weight) AS Average_Weight 
FROM Parts 

-- 3. For each part list the part number and the total quantity in which that part is shipped and
--order the results in descending order of the total quantity shipped. Name the total quantity
--shipped in the result as total Shipped.

SELECT 
	pnum 
	SUM(quantity) AS total_shipped 
FROM shipments 
GROUP BY pnum 
ORDER BY total_shipped DESC 

--4. List the name of those suppliers who ship a part that weighs more than 200 
SELECT DISTINCT 
	S.name 
FROM Suppliers S 
JOIN Shipments Sh ON s.snum = Sh.snum 
JOIN Parts P ON Sh.pnum = P.pnum 
WHERE P.weight > 200 

--5. List the name of those cities in which both supplier and a job are located. 
-- This relationship has a transitive property where we don't look at the shipment table for the city name. We use the 
-- Shipments table to find the pair, then "look around the corner" into the Suppliers and Jobs tables to compare their 
--	city columns. 
-- Here there is already a relationship that is established so we are not joining on the basis of the properties but rather 
-- we are joining on the basis of the city here 

SELECT DISTINCT S.city 
FROM Supplier S 
INNER JOIN Jobs J ON J.city = S.city 

-- 6. List the name of those jobs that recieve a shipment from supplier number S1 
SELECT DISTINCT 
	J.jname 
FROM Jobs J 
INNER JOIN Shipments S ON J.jnum = S.jnum 
WHERE S.num = 'S1'

-- 7. List the names of those parts that are not shipped to any job 
-- For this we need to find the parts in the parts table that have no matching records in the Shipments table. 
--Using Not Exists, we find all the parts that exists in the parts table but not in the shipments table 
SELECT P.pname 
FROM Parts p
WHERE NOT EXISTS( 
	SELECT 1 
	FROM Shipments S 
	WHERE S.pnum = P.pnum
) 

-- 8. List the name of those suppliers who ship part number P2 to any job 
SELECT 
	S.sname 
FROM Suppliers S 
INNER JOIN Shipments Sh ON S.snum = Sh.snum 
WHERE Sh.pnum = 'P2'

-- 9. List the name of those suppliers who ship part at least one red part to any job 
SELECT DISTINCT 
	S.sname 
FROM Supplier S 
INNER JOIN Shipments SH ON SH.snum = S.snum 
INNER JOIN Parts P ON P.pnum = SH.pnum 
WHERE P.Color = 'Red' 


-- 10. List the part for every part that is shipped more than once (the part must be shipped more than one time) 
-- To solve this we need to count how many times each part number pnum appears in the Shipments table. 
-- If a part appears multiple times, it means it has been shipped more than once, regardless of whether 
-- it was sent by different suppliers or to different jobs 

SELECT pnum 
FROM Shipments 
GROUP BY pnum 
HAVING COUNT(*) > 1 

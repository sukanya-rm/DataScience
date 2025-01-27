/*

-----------------------------------------------------------------------------------------------------------------------------------
                                               Guidelines
-----------------------------------------------------------------------------------------------------------------------------------

The provided document is a guide for the project. Follow the instructions and take the necessary steps to finish
the project in the SQL file			

-----------------------------------------------------------------------------------------------------------------------------------

                                                         Queries
                                               
-----------------------------------------------------------------------------------------------------------------------------------*/

-- 1. WRITE A QUERY TO DISPLAY CUSTOMER FULL NAME WITH THEIR TITLE (MR/MS), BOTH FIRST NAME AND LAST NAME ARE IN UPPER CASE WITH 
-- CUSTOMER EMAIL ID, CUSTOMER CREATIONDATE AND DISPLAY CUSTOMER’S CATEGORY AFTER APPLYING BELOW CATEGORIZATION RULES:
	-- i.IF CUSTOMER CREATION DATE YEAR <2005 THEN CATEGORY A
    -- ii.IF CUSTOMER CREATION DATE YEAR >=2005 AND <2011 THEN CATEGORY B
    -- iii.IF CUSTOMER CREATION DATE YEAR>= 2011 THEN CATEGORY C
    
    -- HINT: USE CASE STATEMENT, NO PERMANENT CHANGE IN TABLE REQUIRED. [NOTE: TABLES TO BE USED -ONLINE_CUSTOMER TABLE]

SELECT 
	CONCAT(CASE WHEN CUSTOMER_GENDER = 'M' THEN 'MR. ' ELSE 'MS. ' END,
	UPPER(CUSTOMER_FNAME) , ' ', UPPER(CUSTOMER_LNAME)) AS CUSTOMER_NAME,
	CUSTOMER_EMAIL, CUSTOMER_CREATION_DATE,
	CASE
		WHEN YEAR(CUSTOMER_CREATION_DATE) < 2005 THEN 'CATEGORY A'
		WHEN (YEAR(CUSTOMER_CREATION_DATE) >= 2005 AND YEAR(CUSTOMER_CREATION_DATE)) < 2011 THEN 'CATEGORY B'
	ELSE 'CATEGORY C'
	END AS 'CUSTOMER CATEGORY'
FROM online_customer
LIMIT 5;



-- 2. WRITE A QUERY TO DISPLAY THE FOLLOWING INFORMATION FOR THE PRODUCTS, WHICH HAVE NOT BEEN SOLD:  PRODUCT_ID, PRODUCT_DESC, 
-- PRODUCT_QUANTITY_AVAIL, PRODUCT_PRICE,INVENTORY VALUES(PRODUCT_QUANTITY_AVAIL*PRODUCT_PRICE), NEW_PRICE AFTER APPLYING DISCOUNT 
-- AS PER BELOW CRITERIA. SORT THE OUTPUT WITH RESPECT TO DECREASING VALUE OF INVENTORY_VALUE.
	-- i.IF PRODUCT PRICE > 20,000 THEN APPLY 20% DISCOUNT
    -- ii.IF PRODUCT PRICE > 10,000 THEN APPLY 15% DISCOUNT
    -- iii.IF PRODUCT PRICE =< 10,000 THEN APPLY 10% DISCOUNT
    
    -- HINT: USE CASE STATEMENT, NO PERMANENT CHANGE IN TABLE REQUIRED. [NOTE: TABLES TO BE USED -PRODUCT, ORDER_ITEMS TABLE] 


SELECT 
		PRODUCT_ID, 
    	PRODUCT_DESC, 
    	PRODUCT_QUANTITY_AVAIL, 
    	PRODUCT_PRICE,
		(PRODUCT_QUANTITY_AVAIL)*PRODUCT_PRICE AS INVENTORY_VALUES,
	CASE 
		WHEN PRODUCT_PRICE > 20000 THEN PRODUCT_PRICE - (PRODUCT_PRICE*0.20)
		WHEN PRODUCT_PRICE > 10000 THEN PRODUCT_PRICE - (PRODUCT_PRICE*0.15)
	ELSE PRODUCT_PRICE - (PRODUCT_PRICE*0.1)
	END AS NEW_PRICE
FROM product p
WHERE  p.PRODUCT_ID NOT IN (SELECT DISTINCT noi.PRODUCT_ID 
			    FROM order_items noi
			    WHERE noi.ORDER_ID IS NOT NULL)
ORDER BY INVENTORY_VALUES DESC
LIMIT 5;    



-- 3. WRITE A QUERY TO DISPLAY PRODUCT_CLASS_CODE, PRODUCT_CLASS_DESCRIPTION, COUNT OF PRODUCT TYPE IN EACH PRODUCT CLASS, 
-- INVENTORY VALUE (P.PRODUCT_QUANTITY_AVAIL*P.PRODUCT_PRICE). INFORMATION SHOULD BE DISPLAYED FOR ONLY THOSE PRODUCT_CLASS_CODE 
-- WHICH HAVE MORE THAN 1,00,000 INVENTORY VALUE. SORT THE OUTPUT WITH RESPECT TO DECREASING VALUE OF INVENTORY_VALUE.
	-- [NOTE: TABLES TO BE USED -PRODUCT, PRODUCT_CLASS]

   
SELECT 
		PRODUCT_CLASS_CODE, 
    	PRODUCT_CLASS_DESC,
		(SELECT COUNT(*) from product WHERE PRODUCT_CLASS_CODE=product_class.PRODUCT_CLASS_CODE) AS PRODUCT_COUNT,
		(SELECT SUM(product.PRODUCT_QUANTITY_AVAIL*product.PRODUCT_PRICE) FROM PRODUCT 
WHERE PRODUCT_CLASS_CODE=product_class.PRODUCT_CLASS_CODE) AS INVENTORY_VALUE
FROM product_class
HAVING INVENTORY_VALUE > 100000 
ORDER BY 4 DESC
LIMIT 5;


-- 4. WRITE A QUERY TO DISPLAY CUSTOMER_ID, FULL NAME, CUSTOMER_EMAIL, CUSTOMER_PHONE AND COUNTRY OF CUSTOMERS WHO HAVE CANCELLED 
-- ALL THE ORDERS PLACED BY THEM(USE SUB-QUERY)
	-- [NOTE: TABLES TO BE USED - ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]


SELECT 
	onc.CUSTOMER_ID, 
	CONCAT(customer_fname, ' ', customer_lname) AS FULLNAME, 
	onc.CUSTOMER_EMAIL, 
	onc.CUSTOMER_PHONE,
	ad.country AS COUNTRY
FROM online_customer onc
		LEFT JOIN address ad USING (address_id)
    	LEFT JOIN order_header orh USING (customer_id)
WHERE CUSTOMER_ID IN (SELECT CUSTOMER_ID 
			FROM online_customer
			WHERE order_status = 'CANCELLED')
LIMIT 5;
	
 
-- 5. WRITE A QUERY TO DISPLAY SHIPPER NAME, CITY TO WHICH IT IS CATERING, NUMBER OF CUSTOMER CATERED BY THE SHIPPER IN THE CITY AND 
-- NUMBER OF CONSIGNMENTS DELIVERED TO THAT CITY FOR SHIPPER DHL(9 ROWS)
	-- [NOTE: TABLES TO BE USED -SHIPPER, ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]
    

SELECT 
	shp.SHIPPER_NAME,
	ad.CITY,
        COUNT(onc.customer_id) AS NO_OF_CUSTOMERS,
        COUNT(orh.order_id) AS NO_OF_CONSIGNMENTS
FROM shipper shp
	JOIN order_header orh USING (shipper_id)
	JOIN online_customer onc USING (customer_id)
	JOIN address ad USING (address_id)
WHERE shipper_name = 'DHL'
GROUP BY 1,2
ORDER BY 3 DESC;


-- 6. WRITE A QUERY TO DISPLAY CUSTOMER ID, CUSTOMER FULL NAME, TOTAL QUANTITY AND TOTAL VALUE (QUANTITY*PRICE) SHIPPED WHERE MODE 
-- OF PAYMENT IS CASH AND CUSTOMER LAST NAME STARTS WITH 'G'
	-- [NOTE: TABLES TO BE USED -ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER]


SELECT 
	onc.CUSTOMER_ID,
	CONCAT(onc.customer_fname, ' ', onc.customer_lname) AS CUSTOMER_FULL_NAME,
    	SUM(ori.product_quantity) AS TOTAL_QUANTITY,
    	SUM(ori.product_quantity*p.product_price) AS TOTAL_VALUE,
    	orh.PAYMENT_MODE
FROM online_customer onc
	INNER JOIN order_header orh USING (customer_id)	
	INNER JOIN order_items ori USING (order_id)
    	INNER JOIN product p using (product_id)
WHERE orh.payment_mode = 'CASH' AND onc.customer_lname LIKE 'G%'
GROUP BY 1,2,5;


    
-- 7. WRITE A QUERY TO DISPLAY ORDER_ID AND VOLUME OF BIGGEST ORDER (IN TERMS OF VOLUME) THAT CAN FIT IN CARTON ID 10  
	-- [NOTE: TABLES TO BE USED -CARTON, ORDER_ITEMS, PRODUCT]
    
SELECT 
	ori.ORDER_ID,
	ori.PRODUCT_QUANTITY*(p.len*p.width*p.height) AS VOLUME_BIGGEST_ORDER 
FROM product p
	JOIN order_items ori USING (product_id)
WHERE 
	ori.PRODUCT_QUANTITY*(p.len*p.width*p.height) < 
		(SELECT (c.len*c.width*c.height) AS VOLUME 
       		FROM carton c WHERE carton_id = 10)
ORDER BY 2 DESC
LIMIT 1;


-- 8. WRITE A QUERY TO DISPLAY PRODUCT_ID, PRODUCT_DESC, PRODUCT_QUANTITY_AVAIL, QUANTITY SOLD, AND SHOW INVENTORY STATUS OF 
-- PRODUCTS AS BELOW AS PER BELOW CONDITION:
	-- A.FOR ELECTRONICS AND COMPUTER CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY',
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 10% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY', 
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 50% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY', 
        -- iv.IF INVENTORY QUANTITY IS MORE OR EQUAL TO 50% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
	-- B.FOR MOBILES AND WATCHES CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY', 
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 20% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY',  
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 60% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY', 
        -- iv.IF INVENTORY QUANTITY IS MORE OR EQUAL TO 60% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
	-- C.REST OF THE CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY', 
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 30% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY',  
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 70% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY', 
        -- iv. IF INVENTORY QUANTITY IS MORE OR EQUAL TO 70% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
        
			-- [NOTE: TABLES TO BE USED -PRODUCT, PRODUCT_CLASS, ORDER_ITEMS] (USE SUB-QUERY)

SELECT 
	OI.PRODUCT_ID, 
    	P.PRODUCT_DESC,
    	PC.PRODUCT_CLASS_DESC,
    	P.PRODUCT_QUANTITY_AVAIL AS INVENTORY,
    	SUM(OI.PRODUCT_QUANTITY) AS QUANTITY_SOLD,
    		CASE
			WHEN SUM(OI.PRODUCT_QUANTITY) = 0 THEN 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY'
        		WHEN (P.PRODUCT_QUANTITY_AVAIL) < 0.1 * SUM(OI.PRODUCT_QUANTITY) THEN 'LOW INVENTORY, NEED TO ADD INVENTORY'
        		WHEN (P.PRODUCT_QUANTITY_AVAIL) < 0.5 * SUM(OI.PRODUCT_QUANTITY) THEN 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY'
        		WHEN (P.PRODUCT_QUANTITY_AVAIL) > 0.5 * SUM(OI.PRODUCT_QUANTITY) OR SUM(P.PRODUCT_QUANTITY_AVAIL) = 0.5 * SUM(OI.PRODUCT_QUANTITY) THEN 'SUFFICIENT INVENTORY'
		END AS INVENTORY_STATUS
FROM ORDER_ITEMS AS OI
	JOIN PRODUCT AS P USING (PRODUCT_ID)
	JOIN PRODUCT_CLASS AS PC USING (PRODUCT_CLASS_CODE)
WHERE PC.PRODUCT_CLASS_DESC IN ('ELECTRONICS', 'COMPUTER')
GROUP BY 1,2,3;

SELECT 
	OI.PRODUCT_ID,  
    	P.PRODUCT_DESC,
    	PC.PRODUCT_CLASS_DESC,
    	P.PRODUCT_QUANTITY_AVAIL AS INVENTORY,
    	SUM(OI.PRODUCT_QUANTITY) AS QUANTITY_SOLD,
    		CASE
			WHEN SUM(OI.PRODUCT_QUANTITY) = 0 THEN 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY'
        		WHEN (P.PRODUCT_QUANTITY_AVAIL) < 0.2 * SUM(OI.PRODUCT_QUANTITY) THEN 'LOW INVENTORY, NEED TO ADD INVENTORY'
        		WHEN (P.PRODUCT_QUANTITY_AVAIL) < 0.6 * SUM(OI.PRODUCT_QUANTITY) THEN 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY'
        		WHEN (P.PRODUCT_QUANTITY_AVAIL) > 0.6 * SUM(OI.PRODUCT_QUANTITY) OR (P.PRODUCT_QUANTITY_AVAIL) = 0.6 * SUM(OI.PRODUCT_QUANTITY) THEN 'SUFFICIENT INVENTORY'
		END AS INVENTORY_STATUS
FROM ORDER_ITEMS AS OI
	JOIN PRODUCT AS P USING (PRODUCT_ID)
	JOIN PRODUCT_CLASS AS PC USING (PRODUCT_CLASS_CODE)
WHERE PC.PRODUCT_CLASS_DESC IN ('MOBILES', 'WATCHES')
GROUP BY 1,2,3; 


SELECT 
	OI.PRODUCT_ID,  
    	P.PRODUCT_DESC,
    	PC.PRODUCT_CLASS_DESC,
    	P.PRODUCT_QUANTITY_AVAIL AS INVENTORY,
    	SUM(OI.PRODUCT_QUANTITY) AS QUANTITY_SOLD,
    		CASE
			WHEN SUM(OI.PRODUCT_QUANTITY) = 0 THEN 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY'
        		WHEN (P.PRODUCT_QUANTITY_AVAIL) < 0.3 * SUM(OI.PRODUCT_QUANTITY) THEN 'LOW INVENTORY, NEED TO ADD INVENTORY'
        		WHEN (P.PRODUCT_QUANTITY_AVAIL) < 0.7 * SUM(OI.PRODUCT_QUANTITY) THEN 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY'
        		WHEN (P.PRODUCT_QUANTITY_AVAIL) > 0.7 * SUM(OI.PRODUCT_QUANTITY) OR (P.PRODUCT_QUANTITY_AVAIL) = 0.7 * SUM(OI.PRODUCT_QUANTITY) THEN 'SUFFICIENT INVENTORY'
		END AS INVENTORY_STATUS
FROM ORDER_ITEMS AS OI
	JOIN PRODUCT AS P USING (PRODUCT_ID)
	JOIN PRODUCT_CLASS AS PC USING (PRODUCT_CLASS_CODE)
WHERE PC.PRODUCT_CLASS_DESC NOT IN ('MOBILES', 'WATCHES','ELECTRONICS', 'COMPUTER' )
GROUP BY 1,2,3;


-- 9. WRITE A QUERY TO DISPLAY PRODUCT_ID, PRODUCT_DESC AND TOTAL QUANTITY OF PRODUCTS WHICH ARE SOLD TOGETHER WITH PRODUCT ID 201 
-- AND ARE NOT SHIPPED TO CITY BANGALORE AND NEW DELHI. DISPLAY THE OUTPUT IN DESCENDING ORDER WITH RESPECT TO TOT_QTY.(USE SUB-QUERY)
	-- [NOTE: TABLES TO BE USED -ORDER_ITEMS,PRODUCT,ORDER_HEADER, ONLINE_CUSTOMER, ADDRESS]

    
SELECT 
	    p.PRODUCT_ID, 
	    p.PRODUCT_DESC, 
	    SUM(oi.product_quantity) AS TOTAL_QUANTITY_SOLD
FROM order_items oi
	 JOIN product p USING (product_id)
	 JOIN order_header ord USING (order_id)
	 JOIN online_customer oni USING (customer_id)
	 JOIN address ad USING (address_id)
WHERE ad.city NOT IN ('BANGALORE', 'NEW DELHI') 
	 AND ord.order_id in (SELECT noi.ORDER_ID 
				FROM order_items noi
				WHERE noi.product_id = 201)
	 AND p.PRODUCT_ID != 201
GROUP BY 1,2
ORDER BY 3 DESC ;


-- 10. WRITE A QUERY TO DISPLAY THE ORDER_ID,CUSTOMER_ID AND CUSTOMER FULLNAME AND TOTAL QUANTITY OF PRODUCTS SHIPPED FOR ORDER IDS 
-- WHICH ARE EVENAND SHIPPED TO ADDRESS WHERE PINCODE IS NOT STARTING WITH "5" 
	-- [NOTE: TABLES TO BE USED - ONLINE_CUSTOMER,ORDER_HEADER, ORDER_ITEMS, ADDRESS]


SELECT 
	orh.ORDER_ID,
	orh.CUSTOMER_ID,
	CONCAT(customer_fname, ' ', customer_lname) AS CUSTOMER_FULLNAME,
	COUNT(orh.order_id) AS TOTAL_QUANTITY_SHIPPED
FROM order_header orh
	LEFT JOIN online_customer USING (customer_id)
    	LEFT JOIN address ad USING (address_id)
WHERE ORDER_ID % 2 = 0 AND ad.PINCODE NOT LIKE '5%'
GROUP BY 1,2,3;
    
    

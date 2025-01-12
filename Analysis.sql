use walmart_db ;

SELECT * FROM walmart ;

SELECT DISTINCT payment_method
FROM walmart ;

SELECT 
	payment_method,
    count(payment_method) as Count
FROM walmart
GROUP BY payment_method ;

SELECT COUNT(DISTINCT Branch) as Branch_Count
FROM walmart ;

-- Business Problems
-- Q.1 Find Different Payment Method and number of transactions, number of qty sold
SELECT 
	payment_method,
    count(payment_method) as Count,
    SUM(quantity) as number_of_quantity_sold
FROM walmart
GROUP BY payment_method ;

-- Q.2 Identify the Highest-Rated Category in Each Branch
-- 	   Display the Branch, Category, AVG Rating
SELECT * FROM
(
SELECT 
	Branch,
    category,
    ROUND(AVG(rating),2) as Avg_rating,
    RANK() OVER(PARTITION BY Branch ORDER BY AVG(rating) desc ) as 'Ranking'
FROM walmart 
GROUP BY Branch,category
) as cte
WHERE Ranking =  1 
ORDER BY Avg_rating desc ;

-- Q.3 Identify the busiest day for each branch based on the number of transactions
SELECT 
    branch,
    dayname(str_to_date(date,'%d/%m/%y')) as dayname,
    count(*) as transactions
FROM walmart 
GROUP BY 1,2 
ORDER BY transactions desc ;

-- Q.4 Calcualte the total quantity of items sold per payment method. 
--     List payment_method and total_quantity
SELECT 
	payment_method,
    sum(quantity) as total_quantity
FROM walmart
GROUP BY payment_method 
ORDER BY total_quantity desc ;

-- Q.5 Determine the average, minimum, and maximum rating of products for each city.
--     List the city, average_rating, min_rating, and max_rating.
SELECT 
	City,
    Category,
    ROUND(AVG(rating),2) Avg_Rating,
    MIN(rating) Min_rating,
    MAX(rating) max_rating
FROM walmart 
GROUP BY City,Category ;


-- Q.6 Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin).
-- List category and total_profit, ordered from highest to lowest profit.

SELECT 
	category,
    round(sum((total * profit_margin)),2) as total_profit
FROM walmart 
GROUP BY category
ORDER BY total_profit desc ;

-- Q.7 Display Branch and the preferred_payment_method.
-- Determine the most common payment method for each Branch.
SELECT 
	*
FROM (
SELECT 
	Branch,
    payment_method,
    count(*) as total_trans,
    RANK() OVER(PARTITION BY Branch ORDER BY COUNT(*) DESC) as ranking
FROM walmart 
GROUP BY Branch,payment_method 
) AS common_payment
WHERE  ranking = 1
;

-- Q.8 -- Categorize sales into 3 group MORNING, AFTERNOON, EVENING
--        Find out each of the shift and number of invoices
WITH cte as 
(SELECT 
    Branch,
CASE 
	WHEN time < 12 THEN 'MORNING'
    WHEN time between 12 AND 17 THEN 'AFTERNOON'
    ELSE 'EVENING'
END AS Shift
FROM walmart ) 

SELECT 
	Branch,
	Shift,
    COUNT(*) as invoice_count
FROM cte
GROUP BY Branch,Shift
ORDER BY Branch,Shift DESC
;

-- #9 Identify 5 branch with highest decrese ratio in
-- revevenue compare to last year(current year 2023 and last year 2022).

-- rdr == last_rev-cur_rev/ls_rev*100
with revenue_2022 as
(
SELECT 
	branch,
    SUM(total) as revenue
FROM walmart 
WHERE year(str_to_date(date,'%d/%m/%y')) = 2022 
GROUP BY branch
), 
revenue_2023 as
(
SELECT 
	branch,
    SUM(total) as revenue
FROM walmart 
WHERE year(str_to_date(date,'%d/%m/%y')) = 2023
GROUP BY branch
)
-- rdr == last_rev-cur_rev/ls_rev*100
SELECT 
	ls.branch,
    ls.revenue as last_year_revenue,
    cr.revenue as cr_year_revenue,
    ROUND((ls.revenue - cr.revenue) /ls.revenue * 100,2) as rev_decrese_ratio
FROM revenue_2022 ls
JOIN revenue_2023 cr
ON ls.branch = cr.branch 
WHERE ls.revenue > cr.revenue 
ORDER BY rev_decrese_ratio desc 
LIMIT 5 ;
WITH customer_last_purchase AS (	
	SELECT
		customerkey,
		cleaned_name,
		first_purchase_date,
		orderdate,
		cohort_year,
		ROW_NUMBER () over(PARTITION BY customerkey ORDER BY orderdate DESC) AS rn
	FROM
	cohort_analysis
),

churned_customers AS (
SELECT 
	customerkey,
	cohort_year,
	cleaned_name,
	orderdate AS last_purchase_date,
	CASE 
		WHEN orderdate < (SELECT max (orderdate) FROM sales) - INTERVAL '6 months' THEN 'Churned'
		ELSE  'Active'
	END AS customer_status
FROM customer_last_purchase
WHERE rn = 1 AND first_purchase_date < (SELECT max (orderdate) FROM sales) - INTERVAL  '6 months'
)

SELECT
	cohort_year::text,
	customer_status,
	count(customerkey) AS number_cust,
	sum(count(customerkey)) OVER (PARTITION BY cohort_year) AS total_cohort_customers,
	round(count(customerkey) / sum(count(customerkey)) OVER(PARTITION BY cohort_year) * 100) AS status_percentage
FROM churned_customers
GROUP BY cohort_year, customer_status
WITH 
customer_ltv AS (
	SELECT 
		ca.customerkey,
		ca.cleaned_name,
		sum(total_net_revenue) AS total_ltv 
	FROM 
		cohort_analysis ca 
	GROUP BY 
		customerkey,
		cleaned_name
	ORDER BY customerkey 
),
customer_segments AS (
SELECT 
	percentile_cont(0.25) WITHIN GROUP (ORDER BY total_ltv) AS ltv_25th,
	percentile_cont(0.75) WITHIN GROUP (ORDER BY total_ltv) AS ltv_75th
FROM 
	customer_ltv
),
segment_values AS (
SELECT
c.*,
CASE
	WHEN c.total_ltv <= cs.ltv_25th THEN '1- Low Value'
	WHEN c.total_ltv < cs.ltv_75th THEN '2- Medium Value'
	ELSE  '3- High Value'
END AS customer_segment
FROM 
	customer_ltv c,
	customer_segments cs
)

SELECT
	customer_segment,
	sum(total_ltv) AS LTV,
	count(customerkey),
	sum(total_ltv) / count(customerkey) AS avg_ltv
FROM 
	segment_values
	customer_ltv
GROUP BY
	customer_segment
ORDER BY ltv ASC 

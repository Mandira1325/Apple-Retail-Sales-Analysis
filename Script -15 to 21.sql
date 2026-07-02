-- Complex
select * from sales;
-- 16 Determine the percentage chance of receiving warranty claims after each purchase for each country.
-- first will find out total sales for each country and then 
-- will find out total claims for each country
with total_sales as (
					 select st.country  as country,count(s.quantity) as total_sales, count(w.claim_id) as total_claim
					 from sales s 
					 join stores st on st.store_id=s.store_id 
					 left join warranty w on w.sale_id=s.sale_id
					 group by st.country
)
select  country ,  total_sales , total_claim,
		round(total_claim::numeric/total_sales::numeric*100 ,2)as risk
from total_sales 


-- 17.Analyze the year-by-year growth ratio for each store.
-- each store and their yearly sale

with sales_table as    ( select s.store_id ,
								st.store_name,
								Extract(Year from s.sale_date) as year,
								sum(s.quantity*p.price) as total_sales
								from sales s 
								join products p on s.product_id=p.product_id
								join stores st on st.store_id=s.store_id
								group by s.store_id ,
										  st.store_name,
										 Extract(Year from s.sale_date)
								order by st.store_name , year	),
growth as (select store_name , year , total_sales as present_year,
		lag(total_sales,1) over(partition by store_name order by year) as previous_year
from sales_table)
select store_name , 
		year,
		previous_year,
		present_year,
		(present_year-previous_year)::numeric/previous_year::numeric*100 as growth_ratio_pct
from growth
where previous_year is not null


-- 18 Calculate the correlation between product price and warranty claims 
-- for products sold in the last five years, segmented by price range.

with new_table as (select p.price as price ,
						case when p.price<500 then 'Low-Range Product'
							 when p.price between 500 and 1000 then 'Mid-Range Product'
							 else 'Hig-Range Product'
						end as Price_Segment,
						   w.claim_id as claim
					from warranty w 
					left join sales s on s.sale_id=w.sale_id
					join products p on p.product_id=s.product_id
					where s.sale_date>=current_date-Interval '5 Year')
select price_segment, count(claim) as total_claims
from new_table
group by price_segment
		
-- 19th Identify the store with the highest percentage of "completed" repair status claims relative to total claims filed.

with complete_repair as (select s.store_id as store,
					count(w.claim_id) as total_repair_completed
			from sales s 
			right join warranty w on w.sale_id=s.sale_id
			where w.repair_status='Completed'
			group by 1),
total_repair as (select s.store_id as store,
					count(w.claim_id) as total_repair
			from sales s 
			right join warranty w on w.sale_id=s.sale_id
			group by 1)
select tr.store as store_id, st.store_name as store_name,
		cr.total_repair_completed as repair_completed  , 
		tr.total_repair as total_repair, 
		round((cr.total_repair_completed::numeric/tr.total_repair::numeric)*100 ,2)as pct_repair_completed
from complete_repair cr
join total_repair tr on tr.store=cr.store
join stores st on st.store_id=tr.store
order by pct_repair_completed desc;

-- 20 Write a query to calculate the monthly running total of sales for each store 
--over the past four years and compare trends during this period.

with cte as (select s.store_id as store_id, 
		extract(year from s.sale_date) as year,
		extract(month from s.sale_date) as monthly,
		sum(s.quantity*p.price) as total_sales
from sales s
left join products p on p.product_id=s.product_id
where s.sale_date>=current_date-Interval '4 Year'
group by 1,2,3) ,
cte2 as (select * , 
sum(total_sales) over(partition by store_id order by year ,monthly 
	ROWS BETWEEN unbounded PRECEDING AND CURRENT ROW) as cummulative_total,
lag(total_sales) over(partition by store_id order by year ,monthly ) as previous_month_sales 
from cte)
select * , 
round(((total_sales-previous_month_sales )*100/nullif(previous_month_sales,0))::numeric,2)  as grwth_pct
from cte2;

--Bonus Question
-- Analyze product sales trends over time, segmented into key periods:
--from launch to 6 months, 6-12 months, 12-18 months, and beyond 18 months.

select
	   p.product_name as product_name,
		case 
		when s.sale_date between p.launch_date and p.launch_date +Interval '6 month' then '0-6 Months'
		when s.sale_date between p.launch_date + Interval '6 month' and p.launch_date +Interval '12 month' then '6-12 Months'
		when s.sale_date between p.launch_date+ Interval '12 month' and p.launch_date +Interval '18 month' then '12-18 Months'
		else '18+ Months'
		end as period_segments,
		sum(s.quantity) as total_quantity
from products p 
join sales s on s.product_id=p.product_id
group by 1,2
order by 1,3 desc;





































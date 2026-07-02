-- Medium to Hard (5 Questions)
--11 Identify the least selling product in each country for each year based on total units sold.

with cte as (select st.country as country,
					s.product_id as p_id, 	
					Extract(Year from s.sale_date) as year,
					sum(s.quantity) as total_sold
			from sales s
			join stores st on st.store_id=s.store_id
			group by 1,2,3),
ranking_table as (select country , 
							p_id,
							year,
							total_sold,
							dense_rank() over(partition by country,year order by total_sold asc) as ranking
					from cte)
select country , 
		p_id,
		year,
		total_sold
from ranking_table
where ranking=1


-- 12 Calculate how many warranty claims were filed within 180 days of a product sale.

select count(w.claim_id) as counts
from warranty w 
join sales s on s.sale_id=w.sale_id
where w.claim_date between sale_date and sale_date +interval '180 Day'


--13 Determine how many warranty claims were filed for products launched in the last two years.
select count(w.claim_id)
from products p
join sales s on s.product_id=p.product_id
join warranty w on w.sale_id=s.sale_id 
where p.launch_date>=current_date-Interval '2 Year';

-- 14 List the months in the last three years where sales exceeded 5000 units in the UAE.

Select extract(year from s.sale_date) as years,
	   extract(month from s.sale_date) as months,
	   SUM(Quantity) as total_sales
from sales s
join stores st on st.store_id=s.store_id
where st.country='UAE' and 
	  s.sale_date>=current_date-Interval '3 Year'
group by 1,2
having  SUM(Quantity)>5000
order by 1,2

--15 Identify the product category with the most warranty claims filed in the last two years.

select 	c.category_id as category_id , 
		c.category_name as category_name,
		count(w.claim_id) as claim_counts
from warranty w
join sales s 
	on w.sale_id=s.sale_id
join products p 
	on p.product_id=s.product_id
join category c 
	on c.category_id=p.category_id
where w.claim_date>=current_date-Interval '2 years'
group by 1,2
order by 3 desc
limit 3;











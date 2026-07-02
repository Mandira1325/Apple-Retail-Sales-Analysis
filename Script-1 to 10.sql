-- Easy to Medium (10 Questions)

-- 1 Find the number of stores in each country.
select country , 
	   count(distinct store_id)
from stores 
group by 1
order by 2 desc;

-- 2 Calculate the total number of units sold by each store.
select  st.store_id as store_id,
		st.store_name as store_name,
		sum(s.quantity) as total_units
from sales s 
left join stores st 
on st.store_id=s.store_id
group by 1,2
order by 3 desc;

-- 3 Identify how many sales occurred in December 2023.
select count(sale_id) as total_sales
from sales 
where to_char(sale_date , 'YYYY-MM')='2023-12';

-- 4 Determine how many stores have never had a warranty claim filed.
select count(*) as stores_count
from stores 
where store_id not in (
						select distinct store_id
						from sales s
						left join warranty w on w.sale_id=s.sale_id );

-- 5 Calculate the percentage of warranty claims marked as "Rejected".

select round(
			(count(*)*100/(select count(*) from warranty)::numeric),2) as pct
from warranty
where repair_status='Rejected';

-- 6 Identify which store had the highest total units sold in the last 2 year.

select store_id ,	
	   sum(quantity) as total_units 
from sales 
where sale_date>=current_date -Interval '2 Year'
group by 1
order by 2 desc
limit 1;

-- 7 Count the number of unique products sold in the last 2 year.
select count(distinct product_id)
from sales 
where sale_date>=current_date -Interval '2 Year'


-- 8 Find the average price of products in each category.

select c.category_name as category_name ,
		c.category_id as category_id,
		round(avg(p.price)::numeric,2) as avg_price
from products p
join category c on p.category_id=c.category_id
group by 1,2;

-- 9 How many warranty claims were filed in 2024?

select count(claim_id) as total_claims 
from warranty 
where extract(year from claim_date)=2024

-- 10 For each store, identify the best-selling day based on highest quantity sold.
with ranking_table as (   select store_id, 
						   trim(to_char(sale_date ,'Day')) as days,
						   sum(quantity) as total_quantity,
						   dense_rank() over(partition by store_id order by sum(quantity) desc ) as ranking
					from sales
					group by 1,2)
select store_id,
		days,
		total_quantity
from ranking_table
where ranking =1









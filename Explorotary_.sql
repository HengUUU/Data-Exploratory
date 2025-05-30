
---  1.Explore dimensions
--------------------------------------------

--- Explore All Objects in the Database
select * from INFORMATION_SCHEMA.tables;

--- Explore All columns in the database
select * from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'crm_prd_info';
go

--- Explore all categories (the major divisions)
select * from gold.dim_products;
select distinct category, sub_category, product_name  from gold.dim_products
order by 1,2,3;


--- 2. Explore Date Dimensions
--------------------------------------------

--- Explore the date dimensions in fact_table
select min(order_date) as min_order,
max(order_date) as max_order
from gold.fact_sales;
go
--- Explore the  youngest and oldest customer
select
min(birth_date) as oldest_customer,
DATEDIFF(year, min(birth_date), getdate()) as oldest_aged,
max(birth_date) as oldest_customer,
DATEDIFF(year, max(birth_date), getdate()) as youngest_aged
from gold.dim_customer;
go

--- 3. Measure exploration on sale
--- Generating a friendly report
--------------------------------------------

select * from gold.fact_sales;
-- Find the Total sale
select sum(sales_amount) as total_sale_amount 
from gold.fact_sales;

-- count number of unique order
select count(distinct order_number) as total_count_order from gold.fact_sales;

-- average sale_amount 
select avg(sales_amount) as aver_sale from gold.fact_sales;

-- select distinct product are sold
select count(distinct product_key) from gold.fact_sales;

-- find total_product in inventory
select count(distinct product_name) as number_products from gold.dim_products;

-- find total_customer that purchased
select count(distinct customer_key) from gold.fact_sales;

-- Generate a Report that shows all key metrics
select 'total sale amount' as measure_name, sum(sales_amount) as measure_value from gold.fact_sales
union all
select 'total count order' as measure_name, count(distinct order_number) as measure_value from gold.fact_sales
union all
select 'number of products are sold' as measure_name,  count(distinct product_key) as measure_value from gold.fact_sales
union all
select 'average sale amount' as measure_name, avg(sales_amount) as measure_value from gold.fact_sales
union all
select 'number of products in stores' as measure_name,  count(distinct product_name) as measure_value from gold.dim_products
union all
select 'number customer made purchase' as measure_name,  count(distinct customer_key) as measure_value from gold.fact_sales;


-- 4. Magnitude
--------------------------------------------


select * from gold.dim_products;
-- group by category on products
select category,count(product_key) as total_product 
from gold.dim_products
group by category
order by count(product_key);

-- group by sub_cate
select sub_category,count(product_key) as total_product
from gold.dim_products
group by sub_category
order by count(product_key);

-- group by product_line
select prducts_line,count(product_key) as total_product
from gold.dim_products
group by prducts_line
order by count(product_key);

--- find the avg cost of product group by category
select category, avg(product_cost) as avg_price from 
gold.dim_products
group by category 
order by avg(product_cost) desc ;

--- find the total_revenue base on the category 
select  dp.category, sum(fs.sales_amount) as total_revenue
from gold.dim_products dp
join gold.fact_sales fs
on dp.product_key = fs.product_key
group by dp.category
order by sum(fs.sales_amount) desc;

select * from gold.fact_sales;
select * from gold.dim_customer;

--- find the total_revenuer generated by customer?
select  cus.customer_key, cus.first_name, cus.last_name, sum(fs.sales_amount) as total_spend
from gold.dim_customer cus
join gold.fact_sales fs
on cus.customer_key = fs.customer_key
group by cus.customer_key, cus.first_name, cus.last_name
order by sum(fs.sales_amount) desc;

select * from gold.fact_sales;
go

-- find total_revenue by country
select cus.country, 
sum(fas.sales_amount) as total_revenue
from gold.dim_customer cus
join gold.fact_sales fas
on cus.customer_key = fas.customer_key
group by cus.country
order by sum(fas.sales_amount) desc;


--- 5. Selecting the Top and Bottom N
--- select Top 3 products has the highest total_revenue

select top 3
prod.category,
prod.sub_category,
prod.product_name, 
sum(sales_amount) as total_revenue
from gold.fact_sales fas
join gold.dim_products prod
on fas.product_key = prod.product_key
group by prod.category,prod.sub_category,prod.product_name
order by sum(sales_amount) desc;

--- select Bottom 3 products 
select top 3
prod.category,
prod.sub_category,
prod.product_name, 
sum(sales_amount) as total_revenue
from gold.fact_sales fas
join gold.dim_products prod
on fas.product_key = prod.product_key
group by prod.category,prod.sub_category,prod.product_name
order by sum(sales_amount) asc;


--- find the 3 customer who placed fewest orders
select * from 
	(select cus.first_name, cus.last_name,
	count(fas.order_number) as orders_placed,
	row_number() over (order by count(fas.order_number) asc ) as ranking
	from gold.dim_customer cus
	join gold.fact_sales fas
	on cus.customer_key = fas.customer_key
	group by cus.first_name, cus.last_name)t
where  ranking <= 5;


















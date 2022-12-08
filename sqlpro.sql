use rfm_analysis

select * from dbo.sales_sample


--- top customer by revenue

select customername,
	sum(sales) Revenue
from dbo.sales_sample
group by customername
order by 2 desc

--- sales by product line(The most sold product)

select productline,
	sum(sales) Revenue
from dbo.sales_sample
group by productline
order by 2 desc


--- The most selling year from 2003-2005

select year_id,
	sum(sales) Revenue
from dbo.sales_sample
group by YEAR_ID
order by 2 desc

---Total Orderdproduct by product line 
select productline,
	count(QUANTITYORDERED) orderdproduct_per_productline
from dbo.sales_sample
group by PRODUCTLINE
order by 2 desc
  
--- customer order by product line and quantityorder

select customername,
	productline,
	count(quantityordered) totalorderd
from dbo.sales_sample
group by CUSTOMERNAME,productline
order by 3 desc 


select customername,
	sum(sales) Revenue,
	count(quantityordered) frquency,
	max(orderday) last_orderday
from dbo.sales_sample
group by customername
order by 4 desc

---RFM analysis
 ;with rfm as 
 (
select customername,
	sum(sales) Montaryvalue,
	count(QUANTITYORDERED) frequency,
	max(orderday) Last_orderday,
	(select max(orderday) from dbo.sales_sample) Max_oderday,
	DATEDIFF(day,max(orderday),(select max(orderday) from dbo.sales_sample)) recency
from dbo.sales_sample
group by CUSTOMERNAME
),

rfm_1 as 
(
select *,
	ntile(4) over (order by recency desc) rfm_recency,
	ntile(4) over (order by frequency) rfm_frequency,
	ntile(4) over (order by Montaryvalue) rfm_montaryvalue
	
from rfm 
)


select *,
	cast(rfm_montaryvalue as varchar) + cast (rfm_recency as varchar)+ cast (rfm_frequency as varchar) rfm_string
from rfm_1

select * from dbo.srfm

select customername,rfm_recency,rfm_frequency,rfm_montaryvalue,
	case
		when rfm_string in (111,112,113,114,121,132,122,133,123,124,144) then 'Lost_customer'
		when rfm_string in (211,212,222,213,214,221,232) then 'edge_of losing them'
		when rfm_string in (223,233,232,234,231,241,244,344) then 'Potentail_customer'
		when rfm_string in (333,321,311,314,322,332,411,412,343,421) then 'new_customers'
		when rfm_string in (422,423,433,444,414,424,443,434) then 'Loyal customer'
	end rfm_segment
from dbo.srfm

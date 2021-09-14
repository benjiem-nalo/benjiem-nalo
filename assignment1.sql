use [SQL4DevsDb]


select [CustomerId], count([OrderId]) as [OrderCount]	--1e.	Fields to return: CustomerId and OrderCount 
from [dbo].[Order]										--1a.	Use [dbo].[Order] table to query the result 
where YEAR([OrderDate]) in (2017 , 2018)				--1b.	List of customer ids with total number of orders for the year 2017 and 2018. 
	and [ShippedDate] is null							--1d.	Orders should not have been shipped yet 
group by [CustomerId]
having count([OrderId]) >= 2							--1c.	Customer’s orders should be at least 2 

--2a.	Create a backup of dbo.Product table with this format: <table name>_<yyyymmdd> and exclude records with Model Year of 2016 
select * 
into [dbo].[Product_20210915] 
from [dbo].[Product]
where [ModelYear] <> 2016

--2b.	Using the backup table, raise the list price of each product by 20% for “Heller” and “Sun Bicycles” brands while 10% for the other brands. 
update p 
set p.[ListPrice] =
	case when b.[BrandName] in ('Heller','Sun Bicycles') 
	then p.[ListPrice] + (p.[ListPrice] * .2) 
	else p.[ListPrice] + (p.[ListPrice] * .1) end 
from [dbo].[Product_20210915] p join [dbo].[Brand] b 
on p.[BrandId] = b.[BrandId]

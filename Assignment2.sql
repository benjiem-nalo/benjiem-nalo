
--1
select	p.ProductName 
		,sum(oi.Quantity) as TotalQuantity
from dbo.[Order] o
join [dbo].[Store] s on o.StoreId = s.StoreId
join [dbo].[OrderItem] oi on o.OrderId = oi.OrderId
join dbo.[Product] p on oi.ProductId = p.ProductId
where s.[State] = 'TX' 
group by p.ProductName
having sum(oi.Quantity) > 10
order by TotalQuantity desc

--2
select	replace(c.CategoryName,'Bikes','Bicycles') as CategoryName
		,sum(oi.Quantity) as TotalQuantity
from dbo.[Order] o
join [dbo].[Store] s on o.StoreId = s.StoreId
join [dbo].[OrderItem] oi on o.OrderId = oi.OrderId
join dbo.[Product] p on oi.ProductId = p.ProductId
join [dbo].[Category] c on c.CategoryId = p.CategoryId
group by c.CategoryName
order by TotalQuantity desc

--3
--table1 and table2 can't be merge as is
--and i think it makes no sense to merge it by TotalQuantity
--so I used the productname and categoryname as 'Name' column
IF OBJECT_ID(N'tempdb..#tb1') IS NOT NULL  
   DROP TABLE #tb1;  
IF OBJECT_ID(N'tempdb..#tb1') IS NOT NULL  
   DROP TABLE #tb1;  

select	p.ProductName as [Name]
		,sum(oi.Quantity) as TotalQuantity
into #tb1
from dbo.[Order] o
join [dbo].[Store] s on o.StoreId = s.StoreId
join [dbo].[OrderItem] oi on o.OrderId = oi.OrderId
join dbo.[Product] p on oi.ProductId = p.ProductId
where s.[State] = 'TX' 
group by p.ProductName
having sum(oi.Quantity) > 10
order by TotalQuantity desc

select	replace(c.CategoryName,'Bikes','Bicycles') as [Name]
		,sum(oi.Quantity) as TotalQuantity
into #tb2
from dbo.[Order] o
join [dbo].[Store] s on o.StoreId = s.StoreId
join [dbo].[OrderItem] oi on o.OrderId = oi.OrderId
join dbo.[Product] p on oi.ProductId = p.ProductId
join [dbo].[Category] c on c.CategoryId = p.CategoryId
group by c.CategoryName
order by TotalQuantity desc

merge #tb1 as tpp
using #tb2 as tpc
on (tpp.[Name] = tpc.[Name])
when MATCHED
then update 
set tpp.TotalQuantity = tpc.TotalQuantity
when NOT MATCHED 
then insert 
values(tpc.[Name], tpc.TotalQuantity)
when NOT MATCHED BY SOURCE
then delete;

select @@ROWCOUNT
select * from #tb1 order by TotalQuantity desc


--4
with cteYearMonthTotalOrders as
(
select	year(o.OrderDate) as OrderYear
		,month(o.OrderDate) as OrderMonth
		,p.ProductName
		,sum(oi.Quantity) as TotalQuantity
from dbo.[Order] o
join [dbo].[OrderItem] oi on o.OrderId = oi.OrderId
join dbo.[Product] p on oi.ProductId = p.ProductId
join [dbo].[Category] c on c.CategoryId = p.CategoryId
group by year(o.OrderDate), month(o.OrderDate), p.ProductName
)
select 
	OrderYear
	,OrderMonth 
	,ProductName
	,TotalQuantity
	,rank() over (partition by OrderYear, OrderMonth order by OrderYear, OrderMonth, TotalQuantity ) as ProductRank
from cteYearMonthTotalOrders
order by OrderYear, OrderMonth


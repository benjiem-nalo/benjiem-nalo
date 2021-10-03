use [SQL4DevsDb]

-- 1.	Write a script that would return the id and name of the store that does NOT have any Order record (1 pt).

	select s.StoreId, s.StoreName, o.OrderId
	from dbo.[Store] s
	left join dbo.[Order] o
	on s.StoreId = o.StoreId
	where o.OrderId is null

-- 2	a.	Query all Products from Baldwin Bikes store with the model year of 2017 to 2018
--		b.	Query should return the following fields: Product Id, Product Name, Brand Name, Category Name and Quantity
--		c.	Result set should be sorted from the highest quantity, Product Name, Brand Name and Category Name

	select 
	stk.ProductId
	, p.ProductName
	, b.BrandName
	, c.CategoryName
	, stk.Quantity
	from dbo.Store s
	left join dbo.Stock stk on s.StoreId = stk.StoreId
	left join dbo.Product p on p.ProductId = stk.ProductId
	left join dbo.Brand b on b.BrandId = p.BrandId
	left join dbo.Category c on c.CategoryId = p.CategoryId
	where s.StoreName = 'Baldwin Bikes'
	and p.ModelYear in (2017,2018)
	order by stk.Quantity desc
	, p.ProductName
	, b.BrandName
	, c.CategoryName

-- 3	a.	Return the total number of orders per year and store name
--		b.	Query should return the following fields: Store Name, Order Year and the Number of Orders of that year
--		c.	Result set should be sorted by Store Name and most recent order year

	select s.StoreName
	, YEAR(o.OrderDate) as OrderYear
	, COUNT(o.OrderId) as OrderCount
	from dbo.[Order] o
	left join dbo.[Store] s on o.StoreId = s.StoreId
	group by s.StoreName
	, YEAR(o.OrderDate)
	order by s.StoreName
	, OrderYear desc

-- 4	a.	Using a CTE and Window function, select the top 5 most expensive products per brand
--		b.	Data should be sorted by the most expensive product and product name

	;with productPrice as
	(
		select b.BrandName, p.ProductId, p.ProductName, ListPrice, 
		ROW_NUMBER() over (partition by brandname order by listprice desc, productname) rn
		from Product p 
		left join Brand b on p.BrandId = b.BrandId
	)
	select BrandName, ProductId, ProductName, ListPrice from productPrice where rn <=5

-- 5	Using the script from #3, use a cursor to print the records following the format below (3 pts):

	declare @printCol varchar(500)
	declare order_cursor cursor for 

		select s.StoreName +CHAR(32)+ CAST(YEAR(o.OrderDate) as varchar) +CHAR(32)+ cast(COUNT(o.OrderId) as varchar)
		from dbo.[Order] o
		left join dbo.[Store] s on o.StoreId = s.StoreId
		group by s.StoreName
		, YEAR(o.OrderDate)
		order by s.StoreName
		, YEAR(o.OrderDate) desc

	open  order_cursor
	fetch next from order_cursor into @printCol
	while @@FETCH_STATUS = 0
	begin
		print @printCol
		fetch next from order_cursor into @printCol
	end
	close order_cursor
	deallocate order_cursor

-- 6.	Create a script with one loop is nested within another to output the multiplication tables for the numbers one to ten

	declare @multiplicand int
	set @multiplicand = 1

	declare @multiplier int
	set @multiplier = 1

	declare @product int

	while (@multiplicand <= 10)
	begin
		while (@multiplier <= 10)
		begin
			set @product = @multiplicand * @multiplier
			print cast(@multiplicand as varchar) +' * '+ cast(@multiplier as varchar) + ' = ' + cast(@product as varchar)
			set  @multiplier = @multiplier + 1
		end

		set @multiplicand = @multiplicand + 1
		set @multiplier = 1
	end

--7.	Create a script using a PIVOT operator to get the monthly sales
--		a.	Use Order and OrderItems table

	declare @monthNameColumns varchar(500)
	declare @monthNameWithNullCheck varchar(500)
	
	;with salesMonth as 
	(
		select distinct quotename(CONVERT(varchar(3),  o.OrderDate, 100)) as mmm , MONTH(o.OrderDate) mi
		from dbo.[Order] o 
	) 
	 SELECT @monthNameWithNullCheck = STUFF((SELECT ',' + 'ISNULL(' + mmm + ',0) as ' + mmm
            FROM salesMonth order by mi
            FOR XML PATH('')) ,1,1,''),
			@monthNameColumns = STUFF((SELECT ',' + mmm
            FROM salesMonth order by mi
            FOR XML PATH('')) ,1,1,'')

	exec ('
	select SalesYear, '+ @monthNameWithNullCheck +' from
	(
		select Year(o.OrderDate) as SalesYear
			, CONVERT(varchar(3),  o.OrderDate, 100) as SalesMonth
			, ISNULL(ListPrice,0) as SalesAmount
		from dbo.[Order] o
		join dbo.OrderItem oi 
		on o.OrderId = oi.OrderId
	) t
	pivot
	(
		sum(SalesAmount)
		for SalesMonth in ('+@monthNameColumns+')
	) as pt')

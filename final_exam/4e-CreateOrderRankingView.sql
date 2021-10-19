create view dbo.vwCustomerOrders 
as

	select 
	c.CustomerId,
	c.FirstName,
	c.LastName,
	sum(oi.Quantity * oi.ListPrice) as TotalOrderAmount,
	r.[Description] as CustomerRanking 
	from dbo.Customer c 
	join dbo.[Order] o on c.CustomerId = o.CustomerId
	join dbo.OrderItem oi on o.OrderId = oi.OrderId
	left join dbo.Ranking r on c.RankingId = r.Id
	group by c.CustomerId,
	c.FirstName,
	c.LastName,
	r.[Description]


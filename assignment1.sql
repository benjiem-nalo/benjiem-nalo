select [CustomerId], count([OrderId]) OrderCount from [dbo].[Order]
where [ShippedDate] is null
group by [CustomerId]
having count([OrderId]) >= 2

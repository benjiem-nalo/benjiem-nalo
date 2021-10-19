-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		benjie
-- Create date: <Create Date,,>
-- Description:	updates customer's rank based on total orders
-- =============================================
CREATE PROCEDURE uspRankCustomers 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	with totalOrdersPerCustomer as 
	(
	select 
	c.CustomerId,
	sum(oi.Quantity * oi.ListPrice) as TotalOrderAmount 
	from dbo.Customer c 
	join dbo.[Order] o on c.CustomerId = o.CustomerId
	join dbo.OrderItem oi on o.OrderId = oi.OrderId
	group by c.CustomerId
	)
	update c
	set c.RankingId = 
		case
		when t.TotalOrderAmount = 0 then 1
		when t.TotalOrderAmount < 1000 then 2
		when t.TotalOrderAmount < 2000 then 3
		when t.TotalOrderAmount < 3000 then 4
		when t.TotalOrderAmount >= 1000 then 5
		end
	from totalOrdersPerCustomer t 
	join dbo.Customer c on c.CustomerId = t.CustomerId
END
GO

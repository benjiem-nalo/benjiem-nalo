USE [SQL4DevsDb]
GO

/****** Object:  StoredProcedure [dbo].[GetFilteredProductListWithPagination]    Script Date: 10/18/2021 2:13:51 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		benjie
-- Create date: <Create Date,,>
-- Description:	Returns filtered product list with pagination support
-- =============================================
CREATE PROCEDURE [dbo].[GetFilteredProductListWithPagination]
	@productname varchar(255) = null,
	@brandid int = null,
	@categoryid int = null,
	@modelyear smallint = null,
	@offsetrowsize int = 0,
	@pagesize int = 10
AS
BEGIN

	SET NOCOUNT ON;

	select 
	p.ProductId,
	p.ProductName,
	p.BrandId,
	b.BrandName,
	p.CategoryId,
	c.CategoryName,
	p.ModelYear,
	p.ListPrice
	from dbo.Product p
	left join dbo.Brand b on p.BrandId = b.BrandId
	left join dbo.Category c on p.CategoryId = c.CategoryId
	where
	(p.ProductName = @productname or @productname is null)
	and (p.BrandId = @brandid or @brandid is null)
	and (p.CategoryId = @categoryid or @categoryid is null)
	and (p.ModelYear = @modelyear or @modelyear is null)
	order by 
	p.ModelYear desc, 
	p.ListPrice desc,
	p.ProductName asc
	offset @offsetrowsize rows
	fetch next @pagesize rows only;
END
GO



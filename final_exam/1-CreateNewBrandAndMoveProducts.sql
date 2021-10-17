USE [SQL4DevsDb]
GO

/****** Object:  StoredProcedure [dbo].[CreateNewBrandAndMoveProducts]    Script Date: 10/18/2021 2:12:55 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		benjie
-- Create date: 
-- Description:	Procedure to create new brand and move products from old brand to new
-- =============================================
CREATE PROCEDURE [dbo].[CreateNewBrandAndMoveProducts] 
	@NewBrandName varchar(255),
	@OldBrandName varchar(255)
AS
BEGIN
	SET NOCOUNT ON;

	declare @newBrandId int
	declare @oldBrandId int

	begin try
		begin tran
			-- create a new Brand 
			insert into dbo.Brand (BrandName) values (@NewBrandName)

			-- get brand ids based on brandname
			select @newBrandId = brandid from dbo.Brand where BrandName = @NewBrandName
			select @oldBrandId = brandid from dbo.Brand where BrandName = @OldBrandName

			-- Move all products of the existing brand to the new brand 
			update dbo.Product set BrandId = @newBrandId where BrandId = @oldBrandId

			-- Delete the existing brand 
			delete from dbo.Brand where BrandId = @oldBrandId

		commit tran
	end try
	begin catch
		if @@TRANCOUNT > 0 
			rollback tran main
	end catch
	
END
GO



update p 
set p.ListPrice =
(case when 
	(CategoryName = 'Children Bicycles' 
    OR CategoryName = 'Cyclocross Bicycles' 
    OR CategoryName = 'Road Bikes')
	then
	(ListPrice * 1.2) 
	when 
	(CategoryName = 'Comfort Bicycles' 
    OR CategoryName = 'Cruisers Bicycles' 
    OR CategoryName = 'Electric Bikes')
	then
	(ListPrice * 1.7) 
	when
	(CategoryName = 'Mountain Bikes') 
	then
	(ListPrice * 1.4) 
	else
	ListPrice
	end )
from Product_20211017 p
join dbo.Category c on p.CategoryId = c.CategoryId
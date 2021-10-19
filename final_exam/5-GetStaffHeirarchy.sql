;with cte as 
(
	select StaffId, 
		(FirstName +' '+ LastName) as FullName, 
		cast(FirstName +' '+ 
			LastName + ',' as varchar(500)) as EmployeeHeirarchy
	from Staff 
	where ManagerId is null

	union all

	select s.StaffId, 
		(s.FirstName +' '+ s.LastName) as FullName, 
		cast(c.EmployeeHeirarchy +' '+ 
			s.FirstName +' '+ 
			s.LastName + ',' as varchar(500)) as EmployeeHeirarchy 
	from Staff s 
	join cte c on c.StaffId = s.ManagerId
)
	select 
		StaffId, 
		FullName, 
		substring(EmployeeHeirarchy, 1, len(EmployeeHeirarchy)-1) 
	from cte 
	order by StaffId
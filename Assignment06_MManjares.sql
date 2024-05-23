--*************************************************************************--
-- Title: Assignment06
-- Author: MarcelManjares
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,MarcelManjares,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_MarcelManjares')
	 Begin 
	  Alter Database [Assignment06DB_MarcelManjares] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_MarcelManjares;
	 End
	Create Database Assignment06DB_MarcelManjares;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_MarcelManjares;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
Create View vCategories
With SchemaBinding
	as
		Select CategoryID, CategoryName
			from dbo.Categories;
go
Create View vProducts
With SchemaBinding
	As
		Select ProductID, ProductName, CategoryID, UnitPrice
			From dbo.Products;
go
Create view vEmployees
With SchemaBinding
	as
		select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
			From dbo.Employees
go
Create View vInventories
With SchemaBinding
	As
		Select InventoryID, InventoryDate, EmployeeID, ProductID, [Count]
			from dbo.Inventories
go

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
deny select on categories to public;
deny select on products to public;
deny select on employees to public;
deny select on inventories to public;
go
grant select on vCategories to public;
grant select on vProducts to public;
grant select on vEmployees to public;
grant select on vInventories to public;
go
-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!
create view vProductsByCategories
as
	select top 1000000
	C.CategoryName,
	P.ProductName,
	P.UnitPrice
	from vCategories as c
		inner join vProducts as p
			on c.CategoryID = p.CategoryID
		order by 1,2,3
go

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!
create view vInventoriesByProductsByDates
as
	select top 1000000
	p.productname,
	i.inventorydate,
	i.[count]
	from vproducts as p
		inner join vinventories as i
			on p.productID = i.productID
		order by 2,1,3;
go

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!
create view vInventoriesByEmployeesByDates
as
	select distinct top 1000000
	i.inventorydate,
	e.employeefirstname + '' + e.employeelastname as EmployeeName
	from vInventories as i
		inner join vEmployees as e
			on I.employeeID = E.employeeID
		order by 1,2;
go
-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!
create view vInventoriesByProductsByCategories
as
	select top 1000000
	c.categoryname,
	p.productname,
	i.inventorydate,
	i.[count]
	from vInventories as i
		inner join vemployees as e
			on i.EmployeeID = e.employeeid
		inner join vproducts as p
			on i.productid = p.productid
		inner join vcategories as c
			on p.categoryid = c.categoryid
order by 1,2,3,4;
go


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!
create view vInventoriesByProductsByEmployees
as
	select top 1000000
	c.categoryname,
	p.productname,
	i.inventorydate,
	i.[count],
	e.employeefirstname + ' ' + e.employeelastname as EmployeeName
	from vInventories as i
		inner join vemployees as e
			on i.EmployeeID = e.employeeid
		inner join vproducts as p
			on i.productid = p.productid
		inner join vcategories as c
			on p.categoryid = c.categoryid
order by 3,1,2,4;
go

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
create view vInventoriesForChaiAndChangByEmployees
as
	select top 1000000
	c.categoryname,
	p.productname,
	i.inventorydate,
	i.[count],
	e.employeefirstname + ' ' + e.employeelastname as EmployeeName
	from vInventories as i
		inner join vemployees as e
			on i.EmployeeID = e.employeeid
		inner join vproducts as p
			on i.productid = p.productid
		inner join vcategories as c
			on p.categoryid = c.categoryid
			where i.productid in (select productid from products where productname in ('Chai', 'Chang'))
order by 3,1,2,4;
go

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
create view vEmployeesByManager
as
	select top 1000000
	m.employeefirstname + ' ' + m.employeelastname as Manager,
	e.employeefirstname + ' ' + e.employeelastname as Employee
	from vemployees as E
	inner join vemployees as M
	on e.managerid = m.employeeid
	order by 1,2;
go

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.
create view vInventoriesByProductsByCategoriesByEmployees
as
	select top 1000000
	c.categoryid,
	c.categoryname,
	p.productid,
	p.productname,
	p.unitprice,
	i.inventoryid,
	i.inventorydate,
	i.[count],
	e.employeeid,
	e.employeefirstname + ' ' + e.employeelastname as Employee,
	m.employeefirstname + ' ' + m.employeelastname as Manager
	from vcategories as c
		inner join vproducts as p
			on p.categoryid = c.categoryid
		inner join vinventories as i
			on p.productid = i.productid
		inner join vemployees as e
			on i.employeeid = e.employeeid
		inner join vemployees as m
			on e.managerid = m.employeeid
		order by 1,3,6,9;
go

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/
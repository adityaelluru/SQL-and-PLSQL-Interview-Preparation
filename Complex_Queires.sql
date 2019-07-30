----Basic but important functions
--ROW_NUMBER()
--RANK()
--DENSE_RANK()
--NTILE()

--ROW_NUMBER() --Returns a sequential row number with in partition of result set
--use Northwind;
SELECT ROW_NUMBER() over(order by productid) as RowNo, ProductName from Products;

----Getting alternate rows
------Odd Row
select * from (SELECT ROW_NUMBER() over(order by productid) as [Row No.], ProductName from Products) p where p.[Row No.]%2=1;
------Even Row
select * from (SELECT ROW_NUMBER() over(order by productid) as [Row No.], ProductName from Products) p where p.[Row No.]%2=0;
------Row Between
select * from (SELECT ROW_NUMBER() over(order by productid) as [Row No.], ProductName from Products) p where p.[Row No.] 
Between 5 and 10;

------ With CTE (commmon type expression)
with result_with_row_no([Row No.],ProductName)
as
(SELECT ROW_NUMBER() over(order by productid) as [Row No.], ProductName from Products)
select * from result_with_row_no where [Row No.]%2=1;

------ RANK() --Returns the rank of each row within the partition of a result set
select ProductID,COUNT(OrderID) [Number sold], RANK() OVER(order by count(orderid)) [Ranking] from [Order Details]
group by ProductID order by ranking,[Number sold];

------ DENSE_RANK() ----Returns the rank of each row within the partition of a result set without gap;
select ProductID,COUNT(OrderID) [Number sold], DENSE_RANK() OVER(order by count(orderid)) [Ranking] from [Order Details]
group by ProductID order by ranking,[Number sold];

----- Complex Example -- getting product total quantity sale with group category and rank by sale
with sale_detail(CatID,ProdID,Prod_Name,Sale)
as
(
select CategoryID,p.ProductID, p.ProductName, COUNT(o.productid) as [Sale] from Products p,[Order Details] o 
where p.ProductID=o.ProductID group by CategoryID,p.ProductID,p.ProductName 
)
select catid,prodid,prod_name,sale,RANK() over (partition by catid order by sale desc) [Ranking]
 from sale_detail order by catid,ranking;

----- NTILE --Distributes the rows in an ordered partition into a specified number of groups.
with sale_detail(CatID,ProdID,Prod_Name,Sale)
as
(
select CategoryID,p.ProductID, p.ProductName, COUNT(o.productid) as [Sale] from Products p,[Order Details] o 
where p.ProductID=o.ProductID group by CategoryID,p.ProductID,p.ProductName 
)
select catid,prodid,prod_name,sale,NTILE(4) over (partition by catid order by prodid desc) [Ranking]
 from sale_detail order by catid,ranking;

----- Customer with order count
select CustomerID,COUNT(OrderID) [Count] from orders group by CustomerID order by Count desc;


----- Customer with nth highest count
Declare @n int;
set @n=1;
with cust_count(customeid,count)
as
(select CustomerID,COUNT(OrderID) [Count] from orders group by CustomerID
)
select * from cust_count c1 where (@n-1)=(select count(*) from cust_count c2 where c2.count>c1.count);

----- Product Total sale, Max order, Percentage to total sale
with totv(productid,maxsale,total)
as
(
select e.ProductID,e.maxsale,e.total from (select Productid,SUM(quantity) total,MAX(quantity) as maxsale from [Order Details] group by ProductID) e
)
select productid,maxsale,total,convert(float, (convert(money,total)/(select SUM(total) from totv)*100)) [percentage sale] from totv


----- nth Highest salary problem
Use Employee;

declare @n int;
set @n=1;
Select e1.* from tbemp e1 where (@n-1)=(Select COUNT(*) from tbemp e2 where e2.empsal>e1.empsal);


----- No. of Employee in department
Select depnam,COUNT(empno) [No of employee] from tbdep inner join tbemp on depcod=empdepcod group by depnam;

----- No. of employee in department
select depnam,COUNT(empno) [No. of employee] from tbdep left outer join tbemp on depcod=empdepcod group by depnam;

----- City Case
Select empnam,case empcity
				when 'Chandigarh' then 'Tricity'
				when 'Panchkula' then 'Tricity'
				When 'Mohali' then 'Tricity'
				else empcity 
				end [City] from tbemp;

----- Get duplicate entries
select * from tbemp e1 where e1.empno!=(select MAX(empno) from tbemp e2 where e1.empnam=e2.empnam);
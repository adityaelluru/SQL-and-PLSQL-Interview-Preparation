

--Query To print prime numbers in range of 1 to 1000
    WITH  NUMBER_SERIES AS(
    SELECT LEVEL sequence_numbers
      FROM DUAL
CONNECT BY LEVEL <= 1000)
SELECT * FROM NUMBER_SERIES a
where not exists ( select 1 from NUMBER_SERIES b where  b.sequence_numbers >1 
and a.sequence_numbers >b.sequence_numbers
and mod(a.sequence_numbers , b.sequence_numbers) =0);


--Query to print Prime numbers only even positions


WITH NUMBER_SERIES AS
  ( SELECT LEVEL sequence_numbers FROM DUAL CONNECT BY LEVEL <= 1000
  )
SELECT sequence_numbers,
  position
FROM
  (SELECT sequence_numbers ,
    rank() over (order by sequence_numbers) AS position
  FROM NUMBER_SERIES a
  WHERE NOT EXISTS
    (SELECT 1
    FROM NUMBER_SERIES b
    WHERE b.sequence_numbers                         >1
    AND a.sequence_numbers                           >b.sequence_numbers
    AND mod(a.sequence_numbers , b.sequence_numbers) =0
    )
  )
WHERE mod(position,2)=0;

--Query To print prime numbers in range of 1 to 1000 with  '&' as delimiter 
WITH NUMBER_SERIES AS
  ( SELECT LEVEL sequence_numbers FROM DUAL CONNECT BY LEVEL <= 1000
  )
SELECT LISTAGG(sequence_numbers, '&') WITHIN GROUP (
ORDER BY sequence_numbers)
FROM NUMBER_SERIES a
WHERE sequence_numbers >1
AND NOT EXISTS
  (SELECT 1
  FROM NUMBER_SERIES b
  WHERE b.sequence_numbers                         >1
  AND a.sequence_numbers                           >b.sequence_numbers
  AND mod(a.sequence_numbers , b.sequence_numbers) =0
  );

  
-- Hirarchical data queries 

SELECT ename ,
  job ,
  prior ename manager ,
  level
FROM emp
  START WITH mgr IS NULL
  CONNECT BY mgr  = prior empno
ORDER BY level;

--Print Sequences in Oracle

SELECT rpad ('A',level,'X') ,level FROM dual CONNECT BY level <=5 ;

https://stackoverflow.com/questions/24911454/sql-or-pl-sql-queries-to-print-sequence-of-given-n-numbers


-- Analytical functions with example

SELECT ename ,
  sal,
  MIN(sal) over (partition BY deptno order by sal) min_salary ,
  MAX(sal) over (partition BY deptno order by sal) max_salary ,
  SUM(sal) over (partition BY deptno order by sal) cum_salary,
  AVG(sal) over (partition BY deptno order by sal) avg_salary,
  deptno
FROM emp;

SELECT lead(hiredate) over (partition BY deptno order by hiredate) next_joinee_date ,
  SUM(sal) over (partition BY deptno order by hiredate) cumilative_sal,
  a.*
FROM emp a
ORDER BY deptno,
  hiredate;
 
/* 
  1.Select the details of employees with minimum salary on their designation

2.Select the oldest employees from each department, Add an additional column and give them a 10% bonus  of their salary

3.Display all employee details  along with the count of reportees their manager has.

For example :Neena (employee_id 101) has manager steven  and steven has 14 reportees show Neena’s details along with 14

4.Details of all employees along with an additional column which shows average of salary partitioned by Designation but only for employees that were hired before 12 years

*/

USE [AdventureWorks]
GO

-- Observe the sensitive fields in this query that summarize the pay rate for employees: NationalIDNumber, Rate
SELECT TOP 10 emp.BusinessEntityID, NationalIDNumber, JobTitle, RateChangeDate, Rate 
FROM HumanResources.Employee emp INNER JOIN HumanResources.EmployeePayHistory pay 
ON emp.BusinessEntityID = pay.BusinessEntityId;

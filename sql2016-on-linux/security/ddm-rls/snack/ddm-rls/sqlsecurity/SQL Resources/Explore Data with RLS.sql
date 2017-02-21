USE [AdventureWorks]
GO

-- Query the table as usual: observe that no rows are returned because no login ID context is set
SELECT * FROM HumanResources.Employee;  



-- SET the context to Contractor user and make it immutable for the duration of the connection
EXEC sp_set_session_context @key=N'LoginID', @value=N'adventure-works\lynn0';  

-- Query the table as usual: observe that only the one row is returned
SELECT * FROM HumanResources.Employee;  



-- SET the context to an HR user
EXEC sp_set_session_context @key=N'LoginID', @value=N'adventure-works\paula0';  

-- Query the table as usual: observe that only rows with OrganizationLevel of 2 or greater are returned
SELECT * FROM HumanResources.Employee;  



-- SET the context to an Executive user
EXEC sp_set_session_context @key=N'LoginID', @value=N'adventure-works\ken0';  

-- Query the table as usual: observe that all rows are returned
SELECT * FROM HumanResources.Employee;  
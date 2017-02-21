USE [AdventureWorks]
GO

-- Best practice, create a schema to hold security predicates
CREATE SCHEMA Security;  
GO 


-- Create the predicate function
CREATE FUNCTION Security.LimitAccess(@LoginID nvarchar(256), @OrganizationLevel smallint)
	RETURNS TABLE
	WITH SCHEMABINDING
AS
    RETURN SELECT 1 as LimitAccess_Result
	FROM HumanResources.EmployeeDepartmentHistory deptHist INNER JOIN HumanResources.Employee emp
	ON deptHist.BusinessEntityID = emp.BusinessEntityID
	WHERE	(emp.LoginID = CAST(SESSION_CONTEXT(N'LoginID') AS nvarchar(256)) AND EndDate is NULL AND DepartmentID = 9 AND @OrganizationLevel > 1) OR
			(emp.LoginID = CAST(SESSION_CONTEXT(N'LoginID') AS nvarchar(256)) AND EndDate is NULL AND DepartmentID = 16) OR
			CAST(SESSION_CONTEXT(N'LoginID') AS nvarchar(256)) = @LoginID;
GO


-- Create a policy that applies the predicate
CREATE SECURITY POLICY Security.HumanResourcesPolicy
	ADD FILTER PREDICATE Security.LimitAccess(LoginID, OrganizationLevel) ON HumanResources.Employee
	WITH (STATE = ON);
GO
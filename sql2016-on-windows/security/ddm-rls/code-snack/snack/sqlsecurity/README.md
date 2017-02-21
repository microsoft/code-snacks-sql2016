#  Dynamic Data Masking & Row Level Security Code Snack (SQL Server 2016)
In this code snack, developers will create a database having human resources data, including a table containing simulated employee pay data. They will be guided thru the sample data to highlight the sensitive information it contains (e.g., social security numbers and salaries) and then configuring the masking of the sensitive data. In addition, they will enable Row Level Security to handle three different roles: contractors (who have no visibility to any rows except their own in the table), HR (who can view all employee rows except those of executives) and Executives (who can view all employee rows). They will complete a .NET application that queries the database to see the differing outcomes that result based on Row Level Security policy.

## Requirements
- Visual Studio 2015 with Update 3 (or later)
- SQL Server 2016 Developer Edition (or higher)

## Clone the provided project
Clone this repo on to your local machine.
The recommended path is C:\SQL Server Security

## Create the database and tables
1. Open the SqlSecurity.sln solution using Visual Studio 2015.
2. From Solution Explorer, expand the SqlSecurity solution, then Solution Items folder and open “Create Sample Database.sql”.
3. Adjust the file paths for the variables SqlSamplesDatabasePath and SqlSamplesSourceDataPath if you cloned to a different location.
4. Using the toolbar, select SQLCMD Mode button so that query runs in that mode. 

![alt text][SQLCMD]

[SQLCMD]: images/sqlcmd.png "SQLCMD Mode Toggle"
5. Select the Execute button.
6. In the Connect dialog, provide your server name, authentication mode, username and password (as appropriate).
7. Wait for the script to complete successfully.

## Explore the Sample Data
1. Within Visual Studio, open “Explore Data.sql"
2. Execute the script to observe the sensitive fields in this query that summarize the pay rate for employees: NationalIDNumber (e.g., social security number) and Rate (e.g., pay rate)
3. Notice the employee table has the NationalIDNumber which is sensitive field and the EmployePayHistory table has the Rate field which is sensitive because it captures the employees rate of pay.
![alt text][Explore Data]

[Explore Data]: images/exploredatacleartext.png "Explore Data"

## Configure Masking
1. Within Visual Studio, open “Configure Masking.sql"
2. Execute the script to create mask both the NationalIDNumber and Rate fields.
```
-- Mask the NationalIDNumber column so it only displays the last two digits of field (for example: XX-XXX-XX43)
ALTER TABLE HumanResources.Employee
ALTER COLUMN NationalIDNumber ADD MASKED WITH(FUNCTION = 'partial(0,"XX-XXX-XX",2)')


-- Mask the rate by providing a random value in place of the actual rate
ALTER TABLE HumanResources.EmployeePayHistory
ALTER COLUMN Rate ADD MASKED WITH (FUNCTION = 'random(20,150)')
```
3. Return to “Explore Data.sql” and execute this script again.
4. Observe that even though you enabled masking on the table, these fields are still available to you (the administrative user) in their original unmasked format.
5. To view the results with the masks applied, create a new user who can query from the database who does not have priveleges to see the unmasked data (in other words, they will always see the masked data).
6. Open “Create Contract User.sql” and execute it to create a new login and user with the name Contractor and password Abc!1234.
7. Return to “Explore Data.sql” and execute this script again.
8. Select the Change Connection button from toolbar, and login to your SQL Server instance with the Contractor login (Login: Contractor and Password: Abc!1234)
9. Execute this script again.
10. Observe that now the NationalIDNumber only displays the last two digits, and the Rate values are different from before.
![alt text][Masked Data]

[Masked Data]: images/maskedata.png "Masked Data"

## Configure Row Level Security
1. Next, consider the scenario where you want to enforce a policy where only Executive users in the organization can see all employee rows in the Employee table. Users in the Human resources department can see all rows except those of the executives. Finally, all other users can only see their row.
2. This is something you can accomplish using Row Level Security in a fashion that “just works” and applies transparently to the user issuing the query.
3. Within Visual Studio, open “Configure Row Level Security.sql”.
4. Execute the script. This will create a schema (to hold our security related functions), a predicate function that filters the rows based upon the user performing the querying, and a policy that is applied to the Employee table that uses the predicate function to filter the result set to only the rows the user should be seeing.
```
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
```
5. Now, open “Explore Data with RLS.sql”. This query will show the differing result sets that appear for different users when the policy is in action. Notice that this query does not rely on the credentials used to connect to SQL Server, but rather the login store in the session context.
6. This is a useful pattern when you have an application that uses one connection string to SQL Server, but is operating in an environment where your application handles the login, and that login is different from the credentials used to access SQL Server. You can uses this application login information to inform the Row Level Security policy.
```
-- SET the context to Contractor user and make it immutable for the duration of the connection
EXEC sp_set_session_context @key=N'LoginID', @value=N'adventure-works\lynn0';  

-- Query the table as usual: observe that only the one row is returned
SELECT * FROM HumanResources.Employee;  
```
7. Execute the query. Observe the different result sets that appear for the exact same query— they are made different only because of the LoginID session context provided.
![alt text][RLS Data]

[RLS Data]: images/rlsresults.png "RLS Data"


## Leverage Row Level Security from an Application
1. Let’s put Row Level Security to work within the context of an application, in this case a .NET application.
2. Within Visual Studio, open app.config located underneath the SqlSecurity project in Solution Explorer.
3. Set the connectionString value so that it points to your SQL Server.
4. Save the file.
5. From the Debug menu, select Start Without Debugging.
6. In the console dialog that appears, select option 1 to run the query as a Contractor.
7. Observe the query that is run and that only 1 row is returned (the row for that user in the employee table).

![alt text][RLS in App]

[RLS in App]: images/rlsinapp.png "RLS in App"

8. Run the console again, this time select option 2 (Human Resources).
9. Observe that the same query is run as before, but 283 rows are returned. This represents all of the non-executive rows in the employee table.
10. Run the console on last time and select option 3 (Executive).
11. Observe that the same query is run, but that 290 rows are returned. This represents that all employee rows are returned, because an executive can should have access to all rows.
12. To see how this is implemented, within Visual Studio, open Program.cs.
13. Take a look at the QueryEmployeeTable method. Observe that is implements the same pattern as was shown in “Explore Data with RLS.sql”. First, the stored procedure sp_set_session_context is executed using the loginID selected (from the list of options made available when the console app starts) as the loginID parameter. Second, the query that counts all rows in the employee table is run.
14. Notice that the policy is applied transparently to the application- the only change made between the queries is the loginID used to identify the user.
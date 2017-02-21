#  Dynamic Data Masking & Row Level Security Code Snack (SQL Server 2016)
In this code snack, developers will create a database having human resources data, including a table containing simulated employee pay data. They will be guided thru the sample data to highlight the sensitive information it contains (e.g., social security numbers and salaries) and then configuring the masking of the sensitive data. In addition, they will enable Row Level Security to handle three different roles: contractors (who have no visibility to any rows except their own in the table), HR (who can view all employee rows except those of executives) and Executives (who can view all employee rows). They will complete a node.js application that queries the database to see the differing outcomes that result based on Row Level Security policy.

## Requirements
- [Visual Studio Code](https://code.visualstudio.com/download)
- [SQL Server on Linux](https://www.microsoft.com/en-us/sql-server/sql-server-on-linux)
- [Node.js](https://nodejs.org/en/download/)
- [MSSQL extension for VS Code](https://marketplace.visualstudio.com/items?itemName=sanagama.vscode-mssql) 


## Clone the provided project
Clone this repo on to your local machine.

## Configure your connection to SQL on Linux
1. Launch Visual Studio Code and open the project folder in Visual Studio Code.
2. From Code, Preferences select User Settings.
3. In between the curly braces, paste the following which adds two connection to SQL Server on Linux that the MSSQL extension will utilize:
```
    "vscode-mssql.connections":
    [
        {
            // connection 1
            // All required inputs are present. No prompts when you choose this connection from the picklist.
            "server": "localhost",
            "database": "master",
            "user": "sa",
            "password": "Abc1234567890"
        },
        {
            // connection 2
            // All required inputs are present. No prompts when you choose this connection from the picklist.
            "server": "localhost",
            "database": "AdventureWorks",
            "user": "Contractor",
            "password": "Abc!1234"
        }
    ]

```
4. Update the server for both of the above entries to match your SQL on Linux server. 
5. Update the password for the first entry (sa user) so it is set to the value used by your SA user.
6. Leave the password as is for the second connection (contractor user). You will create and use this user later in the steps.


## Create the database and tables
1. Launch Visual Studio Code and open the project folder in Visual Studio Code.
2. Open “Create Sample Database.sql” underneath the SQL Resources folder.
3. Bring up the Command Palette (cmd+shift+P on Mac)
4. Type mssql

![alt text][mssqlcmd]

[mssqlcmd]: images/mssqlcommand.png "mssql command"

5. Choose Connect to database
6. Choose the localhost using your SA user

![alt text][mssqlcmd3]

[mssqlcmd3]: images/mssqlchoose.png "mssql choose connection"

7. Back in the document editor for Create Sample Database.sql, make sure you have nothing highlighted and execute it with cmd+shift+e
8. Wait for the script to complete successfully.


## Explore the Sample Data
1. Within Visual Studio Code, open “Explore Data.sql"
2. Execute the script to observe the sensitive fields in this query that summarize the pay rate for employees: NationalIDNumber (e.g., social security number) and Rate (e.g., pay rate)
3. Notice the employee table has the NationalIDNumber which is sensitive field and the EmployePayHistory table has the Rate field which is sensitive because it captures the employees rate of pay.

![alt text][Explore Data]

[Explore Data]: images/mssqlunmaskedresults.png "Explore Data"

4. Click the X to close the MSSQL Output tab. In the steps that follow, remember to close this anytime you will execute a new query or you may not see the results of your latest query.


## Configure Masking
1. Within Visual Studio Code, open “Configure Masking.sql"
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
6. Open “Create Contractor User.sql” and execute it to create a new login and user with the name Contractor and password Abc!1234.
7. Return to “Explore Data.sql” and execute this script again.
8. Bring up the Command Palette (cmd+shift+P on Mac)
9. Type mssql
10. Choose Connect to database
11. Choose the localhost using your Contractor user
12. Execute this script again.
13. Observe that now the NationalIDNumber only displays the last two digits, and the Rate values are different from before.
![alt text][Masked Data]

[Masked Data]: images/mssqlmaskedresults.png "Masked Data"

## Configure Row Level Security
1. Next, consider the scenario where you want to enforce a policy where only Executive users in the organization can see all employee rows in the Employee table. Users in the Human resources department can see all rows except those of the executives. Finally, all other users can only see their row.
2. This is something you can accomplish using Row Level Security in a fashion that “just works” and applies transparently to the user issuing the query.
3. Within Visual Studio Code, change your localhost connection back to use the SA user.
4. Open “Configure Row Level Security.sql”.
5. Execute the script. This will create a schema (to hold our security related functions), a predicate function that filters the rows based upon the user performing the querying, and a policy that is applied to the Employee table that uses the predicate function to filter the result set to only the rows the user should be seeing.
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
6. Now, open “Explore Data with RLS.sql”. This query will show the differing result sets that appear for different users when the policy is in action. Notice that this query does not rely on the credentials used to connect to SQL Server, but rather the login store in the session context.
7. This is a useful pattern when you have an application that uses one connection string to SQL Server, but is operating in an environment where your application handles the login, and that login is different from the credentials used to access SQL Server. You can uses this application login information to inform the Row Level Security policy.
```
-- SET the context to Contractor user and make it immutable for the duration of the connection
EXEC sp_set_session_context @key=N'LoginID', @value=N'adventure-works\lynn0';  

-- Query the table as usual: observe that only the one row is returned
SELECT * FROM HumanResources.Employee;  
```
8. Execute the query. Observe the different result sets that appear for the exact same query— they are made different only because of the LoginID session context provided.

![alt text][RLS Data]

[RLS Data]: images/rlsresults.png "RLS Data"


## Leverage Row Level Security from an Application
1. Let’s put Row Level Security to work within the context of an application, in this case a node.js application.
2. Within Visual Studio Code, open SqlClient.js located underneath the SqlSecurity folder root.
3. Near the top, modify the values of the config element so that they contain the appropriate values to connect to your instance of the database.
```
// Provide the connection details appropriate to your environment
var config = {
    userName: 'sa',
    password: 'Abc1234567890',
    server: 'localhost',
    options: {
        database: 'adventureworks',
        encrypt: true
    },
    loginID : 'adventure-works\\ken0'
};
```
4. Save the file.
5. Open an instance of Terminal and navigate to the directory that contains SqlClient.js.
6. Execute the following to install the tediuos package:
```
npm install tedious 
```
6. Now run the node.js app:
```
node SqlClient.js 
```
7. Observe the query that is run and that only 1 row is returned (the row for that user in the employee table).
```
$ node SqlClient.js 
Connected.
Executing query: SELECT Count(*) FROM [HumanResources].[Employee]
 = 1
1 rows
```
8. Experiment with the other users to see the differing query counts that are returned. In SqlClient.js modify the config object, loginID value to either 'adventure-works\\paula0' or 'adventure-works\\ken0'.
```
var config = {
    userName: 'sa',
    password: 'Abc1234567890',
    server: 'localhost',
    options: {
        database: 'adventureworks',
        encrypt: true
    },
    loginID : 'adventure-works\\paula0'
};
```
8. Run the node application again as previously shown.
9. Observe that the same query is run as before, but either 283 rows or 290 row are returned depending on the loginID used. 
# In-Memory & Columnar Store Code Snack (SQL Server 2016)
In this code snack, developers will experience the benefit of performing real-time operation analytics enabled by leveraging a memory optimized table in combination with a columnstore index. The Visual Studio project contains a load generator that will be used to simulate a write heavy workload. They will initially run the simulator against a disk based table with a clustered index (btree) and take note of the rows inserted per second, and will measure the performance of a provided analytics query while the system is under the heavy write load. They will then author the T-SQL to create the memory optimized table with a columnstore index, update the load generator to target the memory optimized table and observe the improved performance characteristics.

## Requirements
- Visual Studio 2015 with Update 3 (or later)
- [SQL Server Data Tools for Visual Studio 2015](https://msdn.microsoft.com/en-us/mt186501) 
- SQL Server 2016 Developer Edition (or higher)
- Your developer machine should have at least 8 GB of RAM

## Clone the provided project
Clone this repo on to your local machine.
The recommended path is C:\In-Memory and Columnar\

## Download the sample data
This project requires a sample set of data you will load into SQL Server.
Download the data from: [http://bit.ly/2envb8m](http://bit.ly/2envb8m)

## Create the database and tables
1. Open the SqlLoadgenerator solution using Visual Studio 2015.
2. From Solution Explorer, expand the SqlGenerator solution, then SQL Resources folder and open "Create Database.sql".
3. Adjust the file paths for the FILENAME attributes if you installed SQL Server to a different location.
4. Select the Execute button
5. In the Connect dialog, provide your server name, authentication mode, username and password (as appropriate).
6. Wait for the script to complete successfully.
7. Within Visual Studio, open "Create Table- Disk Based.sql"
8. Execute the script to create the DataPointsDiskBased table.
This table  will be used to store simulated IoT device telemetry, using traditional disk based table as well as clustered and non-clustered indexes on the fields commonly used in both point queries and analytic queries.
9. Within Visual Studio, open "Create Table- In Memory.sql"
10. Execute the script to create the DataPointsInMem table.
This table will be used to store the same simulated IoT device telemetry, but this time using a memory optimized table as well as clustered column store index against all fields (which will support analytic queries) and non-clustered hash indexes on the id field (which will support point lookups common to transactional queries).
```
CREATE TABLE [DataPointsInMem] (
	-- ID should be a Primary Key, fields with a b-tree or hash index
	Id bigint IDENTITY NOT NULL PRIMARY KEY NONCLUSTERED HASH WITH (BUCKET_COUNT = 30000000),
	[Value] decimal(18,5),
	[TimestampUtc] datetime,
	DeviceId int,
	--  This table should have a columnar index
	INDEX Transactions_CCI CLUSTERED COLUMNSTORE
) WITH (
	--  This should be an in-memory table
	MEMORY_OPTIMIZED = ON
);

--  In-memory tables should auto-elevate their transaction level to Snapshot
ALTER DATABASE CURRENT SET MEMORY_OPTIMIZED_ELEVATE_TO_SNAPSHOT=ON ; 
```

## Load initial data

1. Within Visual Studio, open "Load Sample Data.sql"
2. Adjust the path to the DataPoint.bcp file so it matches the location of your project and save the script.
3. Execute the script to load each table with 4 million rows worth of sample data. This will take some time to complete.

## Execute the sample analytics query

1. Within Visual Studio, open "SampleQueries - DiskBased.sql".
2. Execute the script to summarize the time series data stored in the disk based table.
3. When the script completes, observe that 334 rows were returned.Take note of how long the query took to execute. Query time is shown in the bottom right of the document window in Visual Studio.
![alt text][Disk Based Results]

[Disk Based Results]: images/DiskBasedResults.png "Disk Based Results"
4. Now, execute the script to summarize the time series data stored in the memory-optimized table, in "SampleQueries - InMemory.sql".
When the script completes, observe that 334 rows were returned.Take note of how long the query took to execute.
You should notice that the performance of the query against the memory-optimized table runs between 2x-10x faster than the same query, running against the same data stored in a disk based table. Query time is shown in the bottom right of the document window in Visual Studio.
![alt text][In-Memory Results]

[In-Memory Results]: images/InMemoryResults.png "In-Memory Results"

## Execute the queries under load

1. Within Visual Studio, Solution Explorer, expand the SqlLoadGenerator project and then open "App.config".
2. Locate the connection string with the name "SqlConnection" and modify it so it points to your instance of SQL Server 2016.
3. Save the App.config.
4. From the Debug menu, select Start Without Debugging.
5. At the prompt, choose option 1 to target the disk based table.
You should see log entries when every 1000 rows are inserted.
Leave the console running (it should run for about 3 minutes) and return to Visual Studio.
6. Open "SampleQueries - DiskBased.sql".
7. Execute the script to summarize the time series data stored in the disk based table.
8. Observe that more than 334 rows were returned.Take note of how long the query took to execute.
9. Repeat the query a few times, waiting a few seconds in between queries to get a sense of how long the query takes, even as new rows are inserted by the load generator.
10. Close the console load generator.
11. Run the SqlLoadGenerator again.
This time at the prompt, choose option 2 to target the memory-optimized table.
You should see log entries when every 1000 rows are inserted.
12. Leave the console running (it should run for about 3 minutes) and return to Visual Studio.
13. Open "SampleQueries - In Memory.sql".
14. Execute the script to summarize the time series data stored in the disk based table.
15. Observe that more than 334 rows were returned.Take note of how long the query took to execute.
Repeat the query a few times, waiting a few seconds in between queries to get a sense of how long the query takes, even as new rows are inserted by the load generator.
16. Close the console load generator.

## Conclusion
You should observe that while neither query was affected by the heavy insert load, the query against the analytics query continued to run 2x-10x faster than the same query against the disk-based table.
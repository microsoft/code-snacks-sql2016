# In-Memory & Column Store 
In this code snack you will see the benefits of memory optimized tables in combination with a columnstore index on analytical workloads. The sample project contains a load generator that will be used to simulate a write heavy workload. You will initially run the simulator against a disk based table with a clustered index (btree) and take note of the rows inserted per second, and will measure the performance of a provided analytics query while the system is under the heavy write load. Then you will edit the T-SQL to create the memory optimized table with a columnstore index, update the load generator to target the memory optimized table and observe the improved performance. 

## Requirements
- Visual Studio Code with the MSSQL extension or Visual Studio 2015 with Update 3 (or later) with SSDT
- SQL Server 2016 or above, you can use the [SQL Server vNext on Linux](https://hub.docker.com/r/microsoft/mssql-server-linux/) docker image
- In order to run SQL Server on docker, you'll need to edit the docker configuration to allow at least 4 GB of RAM
The instructions assume that Visual Studio has been installed, but you can follow all the steps with teh mssql command line interface tools or with Visual Studio Code, just ignore the tool specific steps (i.e. Open the solution XXYY) and focus on the files that you'd need to edit or execute ;)

## Clone the provided project
Create a folder and clone this repo on to your local machine

## Download the sample data
This project requires a sample set of data you will load into SQL Server.
Download the data from: [http://bit.ly/2envb8m](http://bit.ly/2envb8m)

## Copy the sample data to your SQL on Linux host
1. Let's start by assuming that you've chosen a Docker based approach, grab the container ID of your SQL Server on Linux container. The Container ID is the value present in the first column.
```
docker ps
```
2. Copy over the sample data from the host to the container running SQL on Linux by using docker cp as follows (replace ContainerID with the container ID your retrieved). Note that the path /var/opt/mssql will map to C: in any T-SQL scripts executed against this server.
```
docker cp datapoints.bcp [ContainerID]:/var/opt/mssql/data/datapoints.bcp
```
3. Verify that the copy was successful. By connecting to bash within the container. Connect to your container (substitute your container ID in the command below) and list out the files:
```
docker exec -t -i [ContainerID] /bin/bash
ls /var/opt/mssql/data -1 -s -h
```
4. You should see datapoints.bcp in the listing
```
-rw-r--r-- 1 root root  256 Nov 13 22:49 Entropy.bin
-rw-r--r-- 1 root root  14M Nov 13 22:50 MSDBData.mdf
-rw-r--r-- 1 root root 768K Nov 14 22:48 MSDBLog.ldf
-rw-r--r-- 1 root root 161M Nov 11 04:18 datapoints.bcp
-rw-r--r-- 1 root root 4.0M Nov 14 22:55 master.mdf
-rw-r--r-- 1 root root 768K Nov 14 23:07 mastlog.ldf
-rw-r--r-- 1 root root 8.0M Nov 14 23:00 model.mdf
-rw-r--r-- 1 root root 8.0M Nov 14 23:00 modellog.ldf
-rw-r--r-- 1 root root 264M Nov 14 23:07 tempdb.mdf
-rw-r--r-- 1 root root 8.0M Nov 14 23:07 templog.ldf
drwxr-xr-x 3 root root 4.0K Nov 14 23:01 xtp
```
5. You are all set to continue the lab in Visual Studio 2015.

## Create the database and tables
Now you'll need to run few .sql scripts, you can do it using the command line tools, Visual Studio or Visual Studio Code with the MSSQL extension. Remember to adjust the FILENAME attributes if you installed SQL Server on a non default location.
i.e. Steps for the Visual Studio approach
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
2. Adjust the path to the DataPoint.bcp file so it matches the location of your BCP file within the SQL on Linux container (if necessary) and save the script. Recall the path /var/opt/mssql will map to C: in any T-SQL scripts executed against SQL Server on Linux.
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
2. Locate the connection string with the name "SqlConnection" and modify it so it points to your instance of SQL Server on Linux.
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
Et voilá! You should observe that while neither query was affected by the heavy insert load, the query against the analytics query continued to run 2x-10x faster than the same query against the disk-based table.

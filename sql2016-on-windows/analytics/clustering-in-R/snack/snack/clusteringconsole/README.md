# Clustering in R (SQL Server 2016)
In this code snack, developers will experience authoring R code to help them run a clustering exercise that “magically” groups data into distinct populations by using an unsupervised clustering algorithm, k-means. The k-means script will be packaged within a SQL stored procedure for convenient execution from a .NET application.

## About Clustering
The goal of a clustering algorithm is to look at an input set of data and attempt to identify groups of data by virtue of the similarity between the features of each example in the data set. What makes clustering algorithms particularly powerful is that they do not need a training step like the other algorithms— you simply provide them the data, tell them how many clusters you want to create and they assign each example to a group. The canonical clustering algorithm is k-means. 

## Requirements
- Visual Studio 2015 with Update 3 (or later)
- SQL Server 2016 Developer Edition (or higher)

## Required SQL Server Configuration
-	Make sure that your installation of SQL Server includes R Services, see [https://msdn.microsoft.com/en-us/library/mt696069.aspx](https://msdn.microsoft.com/en-us/library/mt696069.aspx)
-	Using SQL Server Configuration Manager (which is launched from the Start menu), make sure that TCP/IP connections are enabled to your instance of SQL Server (under SQL Server Network Configuration). 
![alt text][SQL Config]

[SQL Config]: images/SqlConfig.png "SQL Server Network Configuration"
- Be sure that the SQL Server, SQL Server Launchpad and SQL Server Browser  services are all running.

## Clone the provided project
Clone this repo on to your local machine.
The recommended path is C:\Clustering in R

## Create the database and tables
1. Open the ClusteringConsole.sln solution using Visual Studio 2015
2. From Solution Explorer, expand the ClusteringConsole solution, then Solution Items folder and open “Create Sample Database.sql”.
3. Adjust the file path for the FROM clause in the BULK INSERT statement if you cloned the project to a different location.
4. Select the Execute button
5. In the Connect dialog, provide your server name, authentication mode, username and password (as appropriate).
6. Wait for the script to complete successfully.

## Create the Clustering Stored Procedure
1. Within Visual Studio, open “Create Procedure ClusterTaxiData.sql”.
This stored procedure queries the data in the nyctaxi_features table and creates four clusters of data based on the passenger_count (the number of passengers in the taxi cab) and direct_distance (the distance traveled, measured as the crow flies). It uses the rxKmeans method to accomplish this, which runs the K-Means algorithm to group the data into the configured number of clusters (four clusters in this case). The formula syntax "~ passenger_count + direct_distance” used in the first parameter simply means to cluster around those two columns from the input data.
```
CREATE PROCEDURE [dbo].[ClusterTaxiData]  
AS  
BEGIN  
  DECLARE @inquery nvarchar(max) = N'  
    select tipped,  passenger_count, trip_time_in_secs, trip_distance, direct_distance   
    from nyctaxi_features   
'  
  
  EXEC sp_execute_external_script
	@language = N'R',  
    @script = N'  

	## Cluster the data 
	clusters <- rxKmeans(~ passenger_count + direct_distance, data = InputDataSet, numClusters = 4, algorithm = "lloyd")  

	## Return the result (by convention the result data set is retrieved from a variable named OutputDataSet).
	OutputDataSet <- as.data.frame(clusters$centers) ;

									',  
    @input_data_1 = @inquery 
	WITH RESULT SETS ((passenger_count real, direct_distance real))
  ;  
END  
GO  
```
2. Execute the script to create the stored procedure.

## Execute the Clustering Stored Procedure
1. Within Visual Studio, open “Execute Procedure ClusterTaxiData.sql”.
2. Select the Execute button
3. In the Connect dialog, provide your server name, authentication mode, username and password (as appropriate).
4. Wait for the script to complete successfully.
5. Observe the results, you should have four clusters of data, each a row in the results. You might interpret these results in order as short trips with one passenger, long trips with two passengers, moderate trips with two passengers and short trips with lots of passengers.

![alt text][Clustering Results]

[Clustering Results]: images/ClusteringResults.png "Clustering Results"

## Leverage Clustering from an Application
1. Within Visual Studio, open app.config located underneath the SqlSecurity project in Solution Explorer.
2. Set the connectionString value so that it points to your SQL Server.
3. Save the file.
4. From the Debug menu, select Start Without Debugging.

Observe the clusters for the taxi rides as retrieved by the application, you have now integrated machine learning into your console application!

![alt text][Application Results]

[Application Results]: images/ApplicationResults.png "Application Results"
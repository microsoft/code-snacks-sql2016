USE [taxidata]
GO

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
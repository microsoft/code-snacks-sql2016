USE master;
GO

CREATE DATABASE taxidata;
GO

USE [taxidata]
GO

CREATE TABLE [dbo].[nyctaxi_features](
	[passenger_count] [int] NULL,
	[trip_time_in_secs] [bigint] NULL,
	[trip_distance] [float] NULL,
	[direct_distance] [float] NULL,
	[tip_amount] [float] NULL,
	[tipped] [int] NULL
) ON [PRIMARY]

GO


BULK INSERT taxidata.dbo.nyctaxi_features
    FROM 'C:\Clustering in R\ClusteringConsole\SQL Resources\nyctaxi_features.bcp'
    WITH (
        DATAFILETYPE = 'native'
    );
GO


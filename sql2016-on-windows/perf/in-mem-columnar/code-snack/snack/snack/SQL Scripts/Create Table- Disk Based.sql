USE Telemetry;
GO

DROP INDEX IF EXISTS dbo.DataPointsDiskBased.IX_DeviceId;
DROP INDEX IF EXISTS dbo.DataPointsDiskBased.IX_Timestamp;
DROP TABLE IF EXISTS dbo.DataPointsDiskBased;

CREATE TABLE [DataPointsDiskBased] (
	Id bigint IDENTITY NOT NULL PRIMARY KEY CLUSTERED,
	[Value] decimal(18,5),
	[TimestampUtc] datetime,
	DeviceId int,
);

CREATE NONCLUSTERED INDEX IX_DeviceId   
    ON dbo.DataPointsDiskBased (DeviceId);   
GO  

CREATE NONCLUSTERED INDEX IX_Timestamp   
    ON dbo.DataPointsDiskBased (TimestampUtc);   
GO  




USE Telemetry;
GO

DROP INDEX IF EXISTS dbo.DataPointsInMem.IX_DeviceId;
DROP INDEX IF EXISTS dbo.DataPointsInMem.IX_Timestamp;
DROP TABLE IF EXISTS dbo.DataPointsInMem;

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

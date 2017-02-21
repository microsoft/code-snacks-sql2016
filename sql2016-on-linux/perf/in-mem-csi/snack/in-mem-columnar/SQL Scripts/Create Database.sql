
-- For SQL Server 2016, create the Database with a master data file (mdf), 
-- the log data file (ldf) and a separate filegroup to support memory-optimized tables.
CREATE DATABASE [Telemetry]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Telemetry', FILENAME = N'C:\data\Telemetry.mdf' , SIZE = 128MB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB ), 
 FILEGROUP [TelemetryInMem] CONTAINS MEMORY_OPTIMIZED_DATA  DEFAULT
( NAME = N'Telemetry_mem', FILENAME = N'C:\data\Telemetry_mem' , MAXSIZE = UNLIMITED)
 LOG ON 
( NAME = N'Telemetry_log', FILENAME = N'C:\data\Telemetry_log.ldf' , SIZE = 128MB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO

ALTER DATABASE [Telemetry] SET COMPATIBILITY_LEVEL = 130
GO
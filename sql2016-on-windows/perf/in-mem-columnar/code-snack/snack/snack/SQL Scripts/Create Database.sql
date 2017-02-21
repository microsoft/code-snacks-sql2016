
-- For SQL Server 2016, create the Database with a master data file (mdf), 
-- the log data file (ldf) and a separate filegroup to support memory-optimized tables.
CREATE DATABASE [Telemetry]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Telemetry', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.SQL2016DEVED\MSSQL\DATA\Telemetry.mdf' , SIZE = 2498560KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB ), 
 FILEGROUP [TelemetryInMem] CONTAINS MEMORY_OPTIMIZED_DATA  DEFAULT
( NAME = N'Telemetry_mem', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.SQL2016DEVED\MSSQL\DATA\Telemetry_mem' , MAXSIZE = UNLIMITED)
 LOG ON 
( NAME = N'Telemetry_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.SQL2016DEVED\MSSQL\DATA\Telemetry_log.ldf' , SIZE = 9838592KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO

ALTER DATABASE [Telemetry] SET COMPATIBILITY_LEVEL = 130
GO
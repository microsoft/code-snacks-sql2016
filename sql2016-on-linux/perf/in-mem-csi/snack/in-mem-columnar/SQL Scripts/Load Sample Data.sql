USE Telemetry;
GO

BULK INSERT Telemetry.dbo.DataPointsDiskBased
    FROM 'C:\data\datapoints.bcp'
    WITH (
        DATAFILETYPE = 'native'
    );
GO

BULK INSERT Telemetry.dbo.DataPointsInMem
    FROM 'C:\data\datapoints.bcp'
    WITH (
        DATAFILETYPE = 'native'
    );
GO


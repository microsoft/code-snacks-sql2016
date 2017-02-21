BULK INSERT Telemetry.dbo.DataPointsDiskBased
    FROM 'C:\In-Memory and Columnar\SQL Scripts\datapoints.bcp'
    WITH (
        DATAFILETYPE = 'native'
    );
GO

BULK INSERT Telemetry.dbo.DataPointsInMem
    FROM 'C:\In-Memory and Columnar\SQL Scripts\datapoints.bcp'
    WITH (
        DATAFILETYPE = 'native'
    );
GO


USE Telemetry;

SELECT 
	Count(*) Counted, 
	Max([Value]) MaxValue,
	Avg([Value]) AvgValue,
	Min([Value]) MinValue,
	DatePart(YYYY, TimestampUtc) [year],
	DatePart(MM, TimestampUtc) [month],
	DatePart(DD, TimestampUtc) [day],
	DatePart(hh, TimestampUtc) [hour],
	DatePart(mi, TimestampUtc) [minute],
	DatePart(ss, TimestampUtc) [second]
FROM DataPointsDiskBased
GROUP BY
	DatePart(YYYY, TimestampUtc),
	DatePart(MM, TimestampUtc),
	DatePart(DD, TimestampUtc),
	DatePart(hh, TimestampUtc),
	DatePart(mi, TimestampUtc),
	DatePart(ss, TimestampUtc)

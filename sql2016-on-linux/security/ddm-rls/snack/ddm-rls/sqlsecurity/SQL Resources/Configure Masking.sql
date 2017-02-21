USE [AdventureWorks]
GO

-- Mask the NationalIDNumber column so it only displays the last two digits of field (for example: XX-XXX-XX43)
ALTER TABLE HumanResources.Employee
ALTER COLUMN NationalIDNumber ADD MASKED WITH(FUNCTION = 'partial(0,"XX-XXX-XX",2)')


-- Mask the rate by providing a random value in place of the actual rate
ALTER TABLE HumanResources.EmployeePayHistory
ALTER COLUMN Rate ADD MASKED WITH (FUNCTION = 'random(20,150)')
USE DTTS;
GO

-- 5.1 View: Driver Violation Summary
CREATE VIEW vw_DriverViolationSummary AS
SELECT
    D.DriverID,
    D.FirstName,
    D.LastName,
    COUNT(V.ViolationID) AS TotalViolations,
    SUM(F.Amount) AS TotalFinesIssued,
    SUM(CASE WHEN F.PaymentStatus = 'Unpaid' THEN F.Amount ELSE 0 END) AS TotalOutstanding
FROM Driver D
LEFT JOIN Violation V ON D.DriverID = V.DriverID
LEFT JOIN Fine F ON V.ViolationID = F.ViolationID
GROUP BY D.DriverID, D.FirstName, D.LastName;
GO

SELECT * FROM vw_DriverViolationSummary;


-- 5.2 Stored Procedure: Register a new violation and its fine
CREATE PROCEDURE sp_RegisterViolationAndFine
    @DriverID INT,
    @VehicleID INT,
    @OfficerID INT,
    @ViolationDate DATE,
    @ViolationTime TIME,
    @ViolationType NVARCHAR(100),
    @Description NVARCHAR(255),
    @Location NVARCHAR(255),
    @FineAmount DECIMAL(10, 2)
AS
BEGIN
    DECLARE @NewViolationID INT;

    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO Violation (DriverID, VehicleID, OfficerID, ViolationDate, ViolationTime, ViolationType, Description, Location)
        VALUES (@DriverID, @VehicleID, @OfficerID, @ViolationDate, @ViolationTime, @ViolationType, @Description, @Location);

        SET @NewViolationID = SCOPE_IDENTITY();

        INSERT INTO Fine (ViolationID, Amount, IssueDate, DueDate, PaymentStatus)
        VALUES (@NewViolationID, @FineAmount, @ViolationDate, DATEADD(MONTH, 1, @ViolationDate), 'Unpaid');

        COMMIT TRANSACTION;
        PRINT 'Violation and Fine registered successfully.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error occurred. Transaction rolled back.';
        THROW;
    END CATCH;
END;
GO


-- test execution of the stored procedure
EXEC sp_RegisterViolationAndFine
    @DriverID = 5,
    @VehicleID = 5,
    @OfficerID = 3,
    @ViolationDate = '2024-10-28',
    @ViolationTime = '10:45:00',
    @ViolationType = 'Illegal Parking',
    @Description = 'Parked in a no-parking zone.',
    @Location = 'Molepolole',
    @FineAmount = 300.00;


-- 5.3 Function: Calculate total demerit points for a driver
CREATE FUNCTION fn_CalculateDriverDemeritPoints (@DriverID INT)
RETURNS INT
AS
BEGIN
    DECLARE @TotalPoints INT;

    SELECT @TotalPoints = COALESCE(SUM(
        CASE
            WHEN ViolationType = 'Speeding' THEN 2
            WHEN ViolationType = 'Red Light' THEN 3
            WHEN ViolationType = 'Overloading' THEN 4
            ELSE 1 
        END
    ), 0)
    FROM Violation
    WHERE DriverID = @DriverID;

    RETURN @TotalPoints;
END;
GO

-- test usage of the function
SELECT DriverID, FirstName, LastName, dbo.fn_CalculateDriverDemeritPoints(DriverID) AS CurrentDemeritPoints
FROM Driver
WHERE DriverID = 1;


-- 5.4 Trigger: Update driver demerit points after a new violation is inserted
CREATE TRIGGER trg_UpdateDemeritPoints
ON Violation
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DriverID INT;
    DECLARE @ViolationType NVARCHAR(100);

    SELECT @DriverID = DriverID, @ViolationType = ViolationType FROM inserted;

    UPDATE Driver
    SET DemeritPoints = DemeritPoints +
        CASE
            WHEN @ViolationType = 'Speeding' THEN 2
            WHEN @ViolationType = 'Red Light' THEN 3
            WHEN @ViolationType = 'Overloading' THEN 4
            ELSE 1
        END
    WHERE DriverID = @DriverID;
END;
GO
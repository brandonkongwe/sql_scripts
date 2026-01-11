USE DTTS;
GO

-- 1. Drivers with licenses expiring in the next 30 days
SELECT D.FirstName, D.LastName, L.LicenseNumber, L.ExpiryDate
FROM Driver D
INNER JOIN License L ON D.DriverID = L.DriverID
WHERE L.ExpiryDate BETWEEN GETDATE() AND DATEADD(DAY, 30, GETDATE());

-- 2. Vehicles registered under a specific driver
SELECT V.RegistrationNumber, V.Make, V.Model, V.Year, V.Color
FROM Vehicle V
INNER JOIN Driver D ON V.DriverID = D.DriverID
WHERE D.FirstName = 'Boipelo' AND D.LastName = 'Ramoshibidu';

-- 3. Outstanding fines for drivers
SELECT D.DriverID, D.FirstName, D.LastName, SUM(F.Amount) AS TotalOutstanding
FROM Driver D
INNER JOIN Violation V ON D.DriverID = V.DriverID
INNER JOIN Fine F ON V.ViolationID = F.ViolationID
WHERE F.PaymentStatus = 'Unpaid'
GROUP BY D.DriverID, D.FirstName, D.LastName;

-- 4. Daily violation report for a specific date
SELECT V.ViolationID, D.FirstName, D.LastName, Veh.RegistrationNumber, V.ViolationType, V.ViolationDate, V.Location
FROM Violation V
INNER JOIN Driver D ON V.DriverID = D.DriverID
INNER JOIN Vehicle Veh ON V.VehicleID = Veh.VehicleID
WHERE V.ViolationDate = '2024-09-20';

-- 5. Monthly violation report (September 2024)
SELECT V.ViolationID, D.FirstName, D.LastName, Veh.RegistrationNumber, V.ViolationType, V.ViolationDate, V.Location
FROM Violation V
INNER JOIN Driver D ON V.DriverID = D.DriverID
INNER JOIN Vehicle Veh ON V.VehicleID = Veh.VehicleID
WHERE YEAR(V.ViolationDate) = 2024 AND MONTH(V.ViolationDate) = 9;

-- 6. Failed vehicle inspections and their details
SELECT V.RegistrationNumber, V.Make, V.Model, I.InspectionDate, I.Details
FROM Inspection I
INNER JOIN Vehicle V ON I.VehicleID = V.VehicleID
WHERE I.Result = 'Fail';
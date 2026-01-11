CREATE DATABASE DTTS;
GO
USE DTTS;
GO

CREATE TABLE Driver (
    DriverID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    DateOfBirth DATE NOT NULL,
    Address NVARCHAR(255) NOT NULL,
    Phone NVARCHAR(20),
    DemeritPoints INT DEFAULT 0 CHECK (DemeritPoints >= 0)
);

CREATE TABLE License (
    LicenseID INT IDENTITY(1,1) PRIMARY KEY,
    DriverID INT NOT NULL UNIQUE, 
    LicenseNumber NVARCHAR(20) NOT NULL UNIQUE,
    IssueDate DATE NOT NULL,
    ExpiryDate DATE NOT NULL,
    LicenseType NVARCHAR(50) NOT NULL,
    FOREIGN KEY (DriverID) REFERENCES Driver(DriverID) ON DELETE CASCADE
);

CREATE TABLE Vehicle (
    VehicleID INT IDENTITY(1,1) PRIMARY KEY,
    DriverID INT NOT NULL, 
    RegistrationNumber NVARCHAR(15) NOT NULL UNIQUE,
    Make NVARCHAR(50) NOT NULL,
    Model NVARCHAR(50) NOT NULL,
    Year INT NOT NULL,
    Color NVARCHAR(20),
    VehicleType NVARCHAR(30) NOT NULL,
    FOREIGN KEY (DriverID) REFERENCES Driver(DriverID)
);

CREATE TABLE TrafficOfficer (
    OfficerID INT IDENTITY(1,1) PRIMARY KEY,
    BadgeNumber NVARCHAR(10) NOT NULL UNIQUE,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Rank NVARCHAR(50),
    AssignedRegion NVARCHAR(50) NOT NULL
);

CREATE TABLE Violation (
    ViolationID INT IDENTITY(1,1) PRIMARY KEY,
    DriverID INT NOT NULL,
    VehicleID INT NOT NULL,
    OfficerID INT NOT NULL,
    ViolationDate DATE NOT NULL,
    ViolationTime TIME NOT NULL,
    ViolationType NVARCHAR(100) NOT NULL,
    Description NVARCHAR(255),
    Location NVARCHAR(255) NOT NULL,
    FOREIGN KEY (DriverID) REFERENCES Driver(DriverID),
    FOREIGN KEY (VehicleID) REFERENCES Vehicle(VehicleID),
    FOREIGN KEY (OfficerID) REFERENCES TrafficOfficer(OfficerID)
);

CREATE TABLE Fine (
    FineID INT IDENTITY(1,1) PRIMARY KEY,
    ViolationID INT NOT NULL UNIQUE, 
    Amount DECIMAL(10, 2) NOT NULL CHECK (Amount > 0),
    IssueDate DATE NOT NULL,
    DueDate DATE NOT NULL,
    PaymentStatus NVARCHAR(20) DEFAULT 'Unpaid' CHECK (PaymentStatus IN ('Paid', 'Unpaid')),
    FOREIGN KEY (ViolationID) REFERENCES Violation(ViolationID) ON DELETE CASCADE
);

CREATE TABLE Inspection (
    InspectionID INT IDENTITY(1,1) PRIMARY KEY,
    VehicleID INT NOT NULL,
    InspectionDate DATE NOT NULL,
    Result NVARCHAR(10) NOT NULL CHECK (Result IN ('Pass', 'Fail')),
    Details NVARCHAR(255),
    FOREIGN KEY (VehicleID) REFERENCES Vehicle(VehicleID)
);

CREATE TABLE Permit (
    PermitID INT IDENTITY(1,1) PRIMARY KEY,
    VehicleID INT NOT NULL,
    PermitType NVARCHAR(50) NOT NULL,
    IssueDate DATE NOT NULL,
    ExpiryDate DATE NOT NULL,
    FOREIGN KEY (VehicleID) REFERENCES Vehicle(VehicleID)
);
GO



INSERT INTO Driver (FirstName, LastName, DateOfBirth, Address, Phone, DemeritPoints) VALUES
('Kagiso', 'Mogwe', '1985-03-15', '123 Main Mall, Gaborone', '26712345678', 2),
('Amantle', 'Modise', '1990-07-22', '456 Commercial Ave, Francistown', '26723456789', 0),
('Tumelo', 'Kgosi', '1978-11-05', '789 Station St, Maun', '26734567890', 5),
('Oarabile', 'Dintwa', '1982-09-30', '321 Noka Rd, Palapye', '26745678901', 1),
('Boipelo', 'Ramoshibidu', '1995-12-14', '654 Thapong Ave, Molepolole', '26756789012', 0),
('Lorato', 'Motsumi', '1988-06-18', '987 Dikgatlhong St, Serowe', '26767890123', 3),
('Gosego', 'Mokgosi', '1975-04-25', '147 Matsitama Rd, Mahalapye', '26778901234', 7),
('Kefilwe', 'Seboni', '1992-08-08', '258 Tswapong St, Bobonong', '26789012345', 1),
('Ontiretse', 'Pitse', '1980-01-12', '369 Kgale View, Gaborone', '26790123456', 0),
('Masego', 'Moloi', '1987-05-19', '741 Okavango Rd, Kasane', '26701234567', 4),
('Tshepiso', 'Keabetswe', '1993-10-03', '852 Broadhurst, Gaborone', '26712345098', 2),
('Kago', 'Mothibi', '1979-02-28', '963 Aerodrome St, Francistown', '26723456109', 6),
('Dineo', 'Phiri', '1984-07-11', '159 Nhabe Rd, Maun', '26734567210', 1),
('Phenyo', 'Mpofu', '1991-11-23', '753 Main St, Kanye', '26745678321', 0),
('Thato', 'Sekgoma', '1986-09-07', '486 Lobatse Rd, Gaborone', '26756789432', 2);


INSERT INTO License (DriverID, LicenseNumber, IssueDate, ExpiryDate, LicenseType) VALUES
(1, 'BW123456A', '2020-01-10', '2025-01-10', 'Class B'),
(2, 'BW234567B', '2021-05-18', '2026-05-18', 'Class C'),
(3, 'BW345678C', '2019-03-22', '2024-03-22', 'Class B'),
(4, 'BW456789D', '2022-08-15', '2027-08-15', 'Class EC'),
(5, 'BW567890E', '2021-11-30', '2026-11-30', 'Class B'),
(6, 'BW678901F', '2020-07-04', '2025-07-04', 'Class C1'),
(7, 'BW789012G', '2018-09-12', '2023-09-12', 'Class B'),
(8, 'BW890123H', '2023-02-28', '2028-02-28', 'Class B'),
(9, 'BW901234I', '2022-04-17', '2027-04-17', 'Class EC'),
(10, 'BW012345J', '2021-06-09', '2026-06-09', 'Class B'),
(11, 'BW112233K', '2020-12-01', '2025-12-01', 'Class C'),
(12, 'BW223344L', '2019-10-25', '2024-10-25', 'Class B'),
(13, 'BW334455M', '2023-01-14', '2028-01-14', 'Class EB'),
(14, 'BW445566N', '2022-03-08', '2027-03-08', 'Class B'),
(15, 'BW556677O', '2021-08-19', '2026-08-19', 'Class C');


INSERT INTO Vehicle (DriverID, RegistrationNumber, Make, Model, Year, Color, VehicleType) VALUES
(1, 'B123ABC', 'Toyota', 'Hilux', 2018, 'White', 'Private'),
(2, 'B234BCD', 'Volkswagen', 'Polo', 2020, 'Red', 'Private'),
(3, 'B345CDE', 'Ford', 'Ranger', 2019, 'Blue', 'Private'),
(4, 'B456DEF', 'Mercedes', 'Actros', 2017, 'Silver', 'Commercial'),
(5, 'B567EFG', 'Nissan', 'Almera', 2021, 'Black', 'Private'),
(6, 'B678FGH', 'Toyota', 'Quantum', 2016, 'White', 'Public Service'),
(7, 'B789GHI', 'Hyundai', 'i20', 2022, 'Grey', 'Private'),
(8, 'B890HIJ', 'Isuzu', 'NPR', 2015, 'Green', 'Commercial'),
(9, 'B901IJK', 'Toyota', 'Corolla', 2020, 'Red', 'Private'),
(10, 'B012JKL', 'Mercedes', 'Sprinter', 2019, 'Blue', 'Public Service'),
(11, 'B123KLM', 'Volkswagen', 'Golf', 2018, 'White', 'Private'),
(12, 'B234LMN', 'Ford', 'Transit', 2017, 'Yellow', 'Commercial'),
(13, 'B345MNO', 'Toyota', 'Camry', 2021, 'Silver', 'Private'),
(14, 'B456NOP', 'Nissan', 'Navara', 2019, 'Black', 'Private'),
(15, 'B567OPQ', 'Toyota', 'Hiace', 2020, 'White', 'Public Service');


INSERT INTO TrafficOfficer (BadgeNumber, FirstName, LastName, Rank, AssignedRegion) VALUES
('T001', 'Karabo', 'Mokgosi', 'Sergeant', 'Gaborone'),
('T002', 'Odirile', 'Sebele', 'Constable', 'Francistown'),
('T003', 'Naledi', 'Kgamanyane', 'Captain', 'South East'),
('T004', 'Tshepo', 'Rasebotsa', 'Corporal', 'Central'),
('T005', 'Boitumelo', 'Mosweu', 'Constable', 'Ngamiland'),
('T006', 'Goitsemang', 'Motsumi', 'Sergeant', 'Kweneng'),
('T007', 'Lesego', 'Phiri', 'Constable', 'North East'),
('T008', 'Mpho', 'Molwantwa', 'Corporal', 'Chobe'),
('T009', 'Kelebogile', 'Mpofu', 'Captain', 'Kgalagadi'),
('T010', 'Kagiso', 'Ntirang', 'Constable', 'Ghanzi'),
('T011', 'Onalenna', 'Keitshepile', 'Sergeant', 'Southern'),
('T012', 'Tsholofelo', 'Mogapi', 'Constable', 'Kgatleng'),
('T013', 'Oratile', 'Sekgoma', 'Corporal', 'North West'),
('T014', 'Lorato', 'Mothibi', 'Constable', 'Okavango'),
('T015', 'Gontse', 'Matsheka', 'Sergeant', 'Boteti');


INSERT INTO Violation (DriverID, VehicleID, OfficerID, ViolationDate, ViolationTime, ViolationType, Description, Location) VALUES
(1, 1, 1, '2024-09-15', '08:30:00', 'Speeding', 'Exceeded limit by 20km/h', 'Main Mall, Gaborone'),
(3, 3, 2, '2024-09-20', '14:15:00', 'Red Light', 'Failed to stop at red light', 'Blue Jacket St, Francistown'),
(5, 5, 3, '2024-10-05', '09:45:00', 'Illegal Parking', 'Parked in disabled spot without permit', 'Game City Mall, Gaborone'),
(7, 7, 4, '2024-10-12', '16:20:00', 'Speeding', 'Exceeded limit by 15km/h in school zone', 'Matsitama Rd, Mahalapye'),
(2, 2, 5, '2024-10-18', '11:10:00', 'Seatbelt', 'Driver not wearing seatbelt', 'A1 Highway, Palapye'),
(9, 9, 6, '2024-09-25', '13:45:00', 'Document Violation', 'Failed to produce license on demand', 'Molepolole Checkpoint'),
(12, 12, 7, '2024-10-08', '10:30:00', 'Overloading', 'Vehicle exceeding weight limit', 'Tlokweng Weighbridge'),
(8, 8, 8, '2024-10-15', '07:50:00', 'Speeding', 'Exceeded limit by 25km/h', 'Kasane-Kazungula Rd'),
(10, 10, 9, '2024-09-30', '18:15:00', 'Vehicle Lights', 'Headlight not working', 'Maun Main St'),
(14, 14, 10, '2024-10-22', '12:05:00', 'Illegal Overtaking', 'Overtaking on solid line', 'Lobatse-Kanye Rd'),
(6, 6, 11, '2024-10-10', '15:40:00', 'PSV Violation', 'Operating without valid permit', 'Gaborone Bus Rank'),
(11, 11, 12, '2024-10-14', '08:55:00', 'Red Light', 'Ran red light at intersection', 'Airport Junction, Gaborone'),
(13, 13, 13, '2024-10-19', '17:25:00', 'Speeding', 'Exceeded limit by 30km/h', 'Trans-Kalahari Highway'),
(4, 4, 14, '2024-10-24', '06:30:00', 'Overloading', 'Cargo exceeding height limit', 'Sefhare Bridge'),
(15, 15, 15, '2024-10-25', '11:00:00', 'Overloading', 'Exceeded passenger capacity', 'Francistown-Maun Rd');


INSERT INTO Fine (ViolationID, Amount, IssueDate, DueDate, PaymentStatus) VALUES
(1, 500.00, '2024-09-16', '2024-10-16', 'Unpaid'),
(2, 750.00, '2024-09-21', '2024-10-21', 'Paid'),
(3, 300.00, '2024-10-06', '2024-11-06', 'Unpaid'),
(4, 600.00, '2024-10-13', '2024-11-13', 'Paid'),
(5, 250.00, '2024-10-19', '2024-11-19', 'Unpaid'),
(6, 400.00, '2024-09-26', '2024-10-26', 'Paid'),
(7, 1000.00, '2024-10-09', '2024-11-09', 'Unpaid'),
(8, 550.00, '2024-10-16', '2024-11-16', 'Unpaid'),
(9, 200.00, '2024-10-01', '2024-11-01', 'Paid'),
(10, 450.00, '2024-10-23', '2024-11-23', 'Unpaid'),
(11, 800.00, '2024-10-11', '2024-11-11', 'Paid'),
(12, 750.00, '2024-10-15', '2024-11-15', 'Unpaid'),
(13, 700.00, '2024-10-20', '2024-11-20', 'Unpaid'),
(14, 900.00, '2024-10-25', '2024-11-25', 'Paid'),
(15, 1200.00, '2024-10-26', '2024-11-26', 'Unpaid');


INSERT INTO Inspection (VehicleID, InspectionDate, Result, Details) VALUES
(1, '2024-08-01', 'Pass', 'All components in good condition'),
(2, '2024-08-10', 'Fail', 'Faulty brakes and worn tires'),
(3, '2024-08-15', 'Pass', 'Vehicle meets all safety standards'),
(4, '2024-08-22', 'Fail', 'Emission levels above permissible limit'),
(5, '2024-09-05', 'Pass', 'All systems functioning properly'),
(6, '2024-09-12', 'Pass', 'Valid for public service operation'),
(7, '2024-09-18', 'Fail', 'Suspension issues and steering wheel play'),
(8, '2024-09-25', 'Pass', 'Commercial vehicle certified'),
(9, '2024-10-02', 'Pass', 'Roadworthy certificate issued'),
(10, '2024-10-08', 'Fail', 'Seatbelts not functioning properly'),
(11, '2024-10-14', 'Pass', 'Vehicle in excellent condition'),
(12, '2024-10-20', 'Fail', 'Brake system requires overhaul'),
(13, '2024-10-25', 'Pass', 'All safety features operational'),
(14, '2024-11-01', 'Pass', 'Vehicle meets inspection criteria'),
(15, '2024-10-15', 'Pass', 'Valid for public service');


INSERT INTO Permit (VehicleID, PermitType, IssueDate, ExpiryDate) VALUES
(15, 'Taxi Permit', '2024-01-01', '2024-12-31'),
(10, 'Bus Permit', '2024-02-15', '2025-02-14'),
(6, 'Taxi Permit', '2024-03-10', '2025-03-09'),
(10, 'Tour Operator Permit', '2024-01-20', '2024-12-19'),
(15, 'Cross-border Permit', '2024-04-05', '2025-04-04'),
(6, 'School Transport Permit', '2024-05-12', '2025-05-11'),
(10, 'Charter Permit', '2024-06-01', '2025-05-31'),
(15, 'Airport Shuttle Permit', '2024-03-18', '2025-03-17'),
(6, 'Long Distance Permit', '2024-07-22', '2025-07-21'),
(10, 'Freight Permit', '2024-08-30', '2025-08-29'),
(15, 'Special Event Permit', '2024-09-14', '2024-12-31'),
(6, 'Night Operation Permit', '2024-10-05', '2025-10-04'),
(10, 'Hazardous Material Permit', '2024-11-11', '2025-11-10'),
(15, 'Disabled Transport Permit', '2024-12-01', '2025-11-30'),
(12, 'Commercial Carrier Permit', '2024-06-01', '2025-05-31');
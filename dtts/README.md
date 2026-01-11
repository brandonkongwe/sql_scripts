# DTTS - Driver Traffic Ticket System

A SQL Server database system for managing traffic violations, driver information, vehicles, and traffic enforcement operations in Botswana.

## Overview

The DTTS (Driver Traffic Ticket System) is designed to streamline the management of traffic violations and related administrative processes. It tracks drivers, vehicles, traffic officers, violations, fines, licenses, inspections, and permits in a centralized database.

## Database Structure

### Core Tables

#### **Driver**
- Stores driver information including personal details, address, and contact
- Tracks demerit points for violations
- `DriverID`: Primary key (auto-increment)
- Fields: FirstName, LastName, DateOfBirth, Address, Phone, DemeritPoints

#### **License**
- Manages driver licenses with issuance and expiry dates
- Tracks license types (Class B, Class C, Class EC, etc.)
- One-to-one relationship with Driver
- Foreign key constraint with CASCADE delete

#### **Vehicle**
- Records vehicle information linked to drivers
- Tracks registration numbers, make, model, year, color, and type
- Supports Private, Commercial, and Public Service vehicle types
- Foreign key to Driver table

#### **TrafficOfficer**
- Maintains traffic officer records with badge numbers and ranks
- Tracks assigned regions for enforcement
- Ranks include: Constable, Corporal, Sergeant, Captain

#### **Violation**
- Records traffic violations with date, time, type, and location
- Links violations to drivers, vehicles, and officers
- Violation types include: Speeding, Red Light, Illegal Parking, Overloading, etc.
- Contains detailed description and location data

#### **Fine**
- Records financial penalties associated with violations
- Tracks payment status (Paid/Unpaid) and due dates
- One-to-one relationship with Violation
- Automatic cascade delete

#### **Inspection**
- Vehicle inspection records with pass/fail results
- Stores inspection details and date
- Links to Vehicle table

#### **Permit**
- Tracks various permits for vehicles (Taxi, Bus, School Transport, etc.)
- Manages permit issue and expiry dates
- Supports multiple permit types per vehicle

## Files Included

### 1. **DDL Script.sql**
Contains all database creation scripts:
- Database creation (DTTS)
- Table definitions with constraints and relationships
- Sample data insertion for all tables (15 drivers, vehicles, officers, violations, fines, inspections, and permits)

### 2. **Queries.sql**
Ready-to-use SQL queries for common operations:
1. Drivers with licenses expiring in the next 30 days
2. Vehicles registered under a specific driver
3. Outstanding fines for drivers
4. Daily violation reports
5. Monthly violation reports
6. Failed vehicle inspections

### 3. **Section 5.sql**
Advanced database objects and features:

#### Views
- **vw_DriverViolationSummary**: Aggregates violation and fine data by driver with totals and outstanding amounts

#### Stored Procedures
- **sp_RegisterViolationAndFine**: Registers a new violation and its associated fine with transaction control and error handling

#### Functions
- **fn_CalculateDriverDemeritPoints**: Calculates total demerit points for a driver based on violation types

#### Triggers
- **trg_UpdateDemeritPoints**: Automatically updates driver demerit points when a new violation is recorded

## Key Features

### Data Integrity
- Primary and foreign key constraints
- Unique constraints on critical fields (LicenseNumber, RegistrationNumber, BadgeNumber)
- Check constraints for valid data ranges and values
- Cascading deletes for related records

### Violation Tracking
- Demerit point system based on violation type:
  - Speeding: 2 points
  - Red Light: 3 points
  - Overloading: 4 points
  - Other violations: 1 point

### Financial Management
- Fine amount validation (must be > 0)
- Payment status tracking
- Outstanding fine calculations
- Due date management (typically 30 days from issue)

### Reporting Capabilities
- Driver violation summaries
- Monthly and daily violation reports
- Outstanding fines by driver
- License expiry tracking
- Vehicle inspection status

## Sample Data

The database includes sample data representing a realistic traffic management scenario:
- **15 Drivers** with Botswana-based names and locations
- **15 Vehicles** of various types (Private, Commercial, Public Service)
- **15 Traffic Officers** across different regions
- **15 Violations** with varied violation types and statuses
- **15 Fines** with mix of paid and unpaid statuses
- **15 Inspections** with pass/fail results
- **15 Permits** for various vehicle types

## Usage

### Setup
1. Open SQL Server Management Studio (or whatever you use to query SQL Server)
2. Run `DDL Script.sql` to create the database and populate sample data
3. Run `Queries.sql` to test common queries
4. Run `Section 5.sql` to create views, stored procedures, functions, and triggers

### Common Operations

**Register a new violation:**
```sql
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
```

**View driver violation summary:**
```sql
SELECT * FROM vw_DriverViolationSummary;
```

**Calculate demerit points:**
```sql
SELECT dbo.fn_CalculateDriverDemeritPoints(1) AS DemeritPoints;
```

## Database Locations (Botswana)

The system includes data from various Botswana locations:
- Gaborone, Francistown, Maun, Palapye, Molepolole, Serowe, Mahalapye, Bobonong, Kasane, Kanye, Lobatse, and others
- Traffic officers assigned to different regions (South East, Central, Ngamiland, Kweneng, North East, etc.)

## Technical Requirements

- **SQL Server 2016 or later**


/*
PROJECT: San Diego Animal Shelter Analysis
FILE: 00_database_setup.sql

PURPOSE:
Create the database and table used for
the animal shelter analysis.
*/

-- Step 1: Create the database if it does not exist
IF DB_ID('SanDiegoAnimalShelter') IS NULL
BEGIN
    CREATE DATABASE SanDiegoAnimalShelter;
END;
GO

-- Step 2: Select the database
USE SanDiegoAnimalShelter;
GO

-- Step 3: Create the table if it does not exist
IF OBJECT_ID('dbo.AnimalShelterData', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.AnimalShelterData (
        FiscalYear VARCHAR(50),
        AnimalType VARCHAR(50),
        TotalIntake INT,
        Adoptions INT,
        TransfersOut INT,
        ReturnedToOwner INT,
        Euthanized INT,
        DiedOrLost INT,
        LiveReleaseRate VARCHAR(50)
    );
END;
GO


/*
STEP 4: IMPORT THE CSV DATA

The dataset is provided in:
san_diego_animal_shelter.csv

To import the data using SQL Server Management Studio:

1. Open SSMS and connect to SQL Server.

2. In Object Explorer, expand Databases.

3. Right-click SanDiegoAnimalShelter.

4. Select Tasks > Import Flat File.

5. Browse to san_diego_animal_shelter.csv.

6. Verify that the first row contains column names.

7. Import the data into AnimalShelterData.

8. Confirm that the numeric columns use INT
   and the text columns use VARCHAR.

9. Complete the import wizard.

NOTE:
If AnimalShelterData already exists, the Import
Flat File Wizard may require a new table name.

For a fresh setup, you can use the wizard to
create and populate AnimalShelterData directly
instead of running the CREATE TABLE section above.
*/

-- STEP 5: VERIFY THE IMPORT

SELECT *
FROM dbo.AnimalShelterData;

SELECT COUNT(*) AS TotalRecords
FROM dbo.AnimalShelterData;

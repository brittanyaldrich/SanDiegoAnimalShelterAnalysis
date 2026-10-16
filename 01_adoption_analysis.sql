
/*
PROJECT: San Diego Animal Shelter Analysis
DATABASE: SanDiegoAnimalShelter
TABLE: AnimalShelterData

DESCRIPTION:
Analysis of animal shelter intake, adoptions,
euthanasia, and live release rates across
four fiscal years (2021-2022 through 2024-2025).

DATA SOURCE:
Official annual Asilomar Accord reports
for San Diego animal services.

SKILLS DEMONSTRATED:
- Data aggregation (SUM, GROUP BY)
- Filtering (WHERE, IN)
- Sorting (ORDER BY)
- Calculated columns and percentages
- Data type conversion (CAST, REPLACE)
- Conditional aggregation (CASE)
- Common Table Expressions (CTEs)
- Window functions (LAG)
- Year-over-year trend analysis

NOTE:
Data represents reported shelter statistics.
Reporting scope and definitions may vary
between fiscal years.
*/

/* Adoption Analysis */

--Which animal type had the most adoptions?

SELECT
	AnimalType,
	SUM(Adoptions) AS TotalAdoptions
FROM AnimalShelterData
GROUP BY AnimalType
ORDER BY TotalAdoptions DESC;

--Which fiscal year had the most adoptions?

SELECT
	FiscalYear,
	SUM(Adoptions) AS TotalAdoptions
FROM AnimalShelterData
GROUP BY FiscalYear
ORDER BY FiscalYear ASC;

--How do cat and dog adoptions compare by year?

SELECT
	FiscalYear,
	AnimalType,
	SUM(Adoptions) AS TotalAdoptions
FROM AnimalShelterData
WHERE AnimalType IN ('Cat', 'Dog')
GROUP BY FiscalYear, AnimalType
ORDER BY FiscalYear ASC, AnimalType ASC;

--What is the adoption-to-intake percentage for each animal type?

SELECT
	AnimalType,
	SUM(TotalIntake) AS TotalIntake,
	SUM(Adoptions) AS TotalAdoptions,
	CAST(
		ROUND(
			SUM(Adoptions) * 100.0 / NULLIF(SUM(TotalIntake), 0),
			2
		) AS DECIMAL(10,2)
	) AS AdoptionPercentage
FROM AnimalShelterData
GROUP BY AnimalType
ORDER BY AdoptionPercentage DESC;

/* Euthanasia Analysis */

--How have euthenasia counts changed over time?

SELECT
	FiscalYear,
	SUM(Euthanized) AS TotalEuthanized
FROM AnimalShelterData
GROUP BY FiscalYear
ORDER BY FiscalYear ASC;

--Which animal type had the highest euthenasia counts?

SELECT
	AnimalType,
	SUM(Euthanized) AS TotalEuthanized
FROM AnimalShelterData
GROUP BY AnimalType
ORDER BY TotalEuthanized DESC;

--What is the euthanasia-to-intake percentage for each animal type?

SELECT
	AnimalType,
	SUM(TotalIntake) AS TotalIntake,
	SUM(Euthanized) AS TotalEuthanized,
	CAST(
		ROUND(
			SUM(Euthanized) * 100.00 / NULLIF(SUM(TotalIntake), 0),
			2
		) AS DECIMAL(10,2)
	) AS EuthanasiaPercentage
FROM AnimalShelterData
GROUP BY AnimalType
ORDER BY EuthanasiaPercentage DESC;

/* Live Release Analysis */

--How have live release rates changed by year and animal type?

SELECT 
	FiscalYear,
	AnimalType,
	LiveReleaseRate,
	CAST(
		REPLACE(LiveReleaseRate, '%', '')
		AS DECIMAL(5,2)
	) AS LiveReleasePercentage
FROM AnimalShelterData
ORDER BY FiscalYear ASC, AnimalType ASC;

--How did live release rates change by animal type?

SELECT
	AnimalType,
	MAX(CASE
		WHEN FiscalYear = '2021-2022'
		THEN CAST(REPLACE(LiveReleaseRate, '%', '') AS DECIMAL(5,2))
	END) AS Rate2022,
	MAX(CASE
		WHEN FiscalYear = '2024-2025'
		THEN CAST(REPLACE(LiveReleaseRate, '%', '') AS DECIMAL(5,2))
	END) AS Rate2025
FROM AnimalShelterData
GROUP BY AnimalType
ORDER BY AnimalType;

--Which animal types had the largest changes in live release rates?

SELECT 
	AnimalType,
	MAX(CASE
		WHEN FiscalYear = '2021-2022'
		THEN CAST(REPLACE(LiveReleaseRate, '%', '') AS DECIMAL(5,2))
	END) AS Rate2022,

	MAX(CASE
		WHEN FiscalYear = '2024-2025'
		THEN CAST(REPLACE(LiveReleaseRate, '%', '') AS DECIMAL(5,2))
	END) AS Rate2025,

	MAX(CASE
		WHEN FiscalYear = '2024-2025'
		THEN CAST(REPLACE(LiveReleaseRate, '%', '') AS DECIMAL(5,2))
	END)
	-
	MAX(CASE
		WHEN FiscalYear = '2021-2022'
		THEN CAST(REPLACE(LiveReleaseRate, '%', '') AS DECIMAL(5,2))
	END) AS PercentagePointChange

FROM AnimalShelterData
GROUP BY AnimalType
ORDER BY PercentagePointChange DESC;

/* Advanced Trend Analysis */

--Which fiscal year had the highest adoption-to-intake percentage?

;WITH YearlyAdoptions AS (
	SELECT
		FiscalYear,
		SUM(TotalIntake) AS TotalIntake,
		SUM(Adoptions) AS TotalAdoptions
	FROM AnimalShelterData
	GROUP BY FiscalYear
)

SELECT
	FiscalYear,
	TotalIntake,
	TotalAdoptions,
	CAST(
		TotalAdoptions * 100.00 / NULLIF(TotalIntake, 0)
		AS DECIMAL(10,2)
	) AS AdoptionPercentage
FROM YearlyAdoptions
ORDER BY AdoptionPercentage DESC;

--How did adoption totals change over year?

;WITH YearlyAdoptions AS (
	SELECT
		FiscalYear,
		SUM(Adoptions) AS TotalAdoptions
	FROM AnimalShelterData
	GROUP BY FiscalYear
)

SELECT
	FiscalYear,
	TotalAdoptions,
	LAG(TotalAdoptions) OVER (
		ORDER BY FiscalYear
	) AS PreviousYearAdoptions,

	TotalAdoptions - LAG(TotalAdoptions) OVER (
		ORDER BY FiscalYear
	) AS AdoptionChange

FROM YearlyAdoptions
ORDER BY FiscalYear;

--What was the year-over-year percentage change in total adoptions?

;WITH YearlyAdoptions AS (
	SELECT
		FiscalYear,
		SUM(Adoptions) AS TotalAdoptions
	FROM AnimalShelterData
	GROUP BY FiscalYear
),
AdoptionChanges AS (
	SELECT
		FiscalYear,
		TotalAdoptions,
		LAG(TotalAdoptions) OVER (
			ORDER BY FiscalYear
			) AS PreviousYearAdoptions
	FROM YearlyAdoptions
)

SELECT
	FiscalYear,
	TotalAdoptions,
	PreviousYearAdoptions,
	CAST(
		(TotalAdoptions - PreviousYearAdoptions)
		* 100.0 / NULLIF(PreviousYearAdoptions, 0)
		AS DECIMAL(10,2)
	) AS PercentageChange
FROM AdoptionChanges
ORDER BY FiscalYear;
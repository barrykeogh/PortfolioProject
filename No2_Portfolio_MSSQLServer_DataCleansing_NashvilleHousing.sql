---CLEANING DATA IN MS SQL SERVER-----------------------------------------------------------
--ADD COLUMN
--RENAME COLUMN
--SELF JOINS
--SPLITTING COLUMN DATA WITH FUNCTIONS
	--CHARINDEX
	--REVERSE
	--LEFT
	--SUBSTRING
	--LEN
	--PARSENAME
	--TRIM
	--REPLACE
--CTES
--ROWNUMBER FUNCTION
--RANK FUNCTION
--PARTITION BY CLAUSE
--CASE STATEMENT

--REPLACE THE SALEDATE COLUMN WITH A NEW COLUMN CONTAINING THE REQUIRED DATE FORMAT---------
-- Standardise Date Format
-- Recreate the SaleDate column in the format MM/DD/YYYY
-- YYYY-MM-DD	-> 23
-- MM/DD/YY		-> 1
-- dd Mon yyyy	-> 106
-- DD-MM-YYYY	-> 103
-- hh:mm:ss		-> 8 (12 hour clock)
-- Mon dd yyyy hh:mm AM/PM	-> 0

--Return the current SaleDate, a converted SaleDate and the sysdate in the format that we require
SELECT SaleDate
	, CONVERT(DATE,SaleDate,1) AS CONVERT_DATE
	, FORMAT(GETDATE(),'dd-MM-yyyy') AS FORMATTED_DATE 
FROM PortfolioProject.dbo.['NashvilleHousing'];

--Add a new column, saledateconverted, to the table
ALTER TABLE PortfolioProject.dbo.['NashvilleHousing'] ADD saledateconverted DATE;

--Update the new column to set the values to those held in the SaleDate column and set to the format we require
BEGIN TRANSACTION
GO
UPDATE PortfolioProject.dbo.['NashvilleHousing']
SET saledateconverted = CONVERT(DATE,SaleDate,103);
COMMIT;

 --Drop the orignal SaleDate column
ALTER TABLE PortfolioProject.dbo.['NashvilleHousing'] DROP COLUMN saledate;

--Rename the new column to SaleDate
 EXEC SP_RENAME 
 @objname='PortfolioProject.dbo.[''NashvilleHousing''].saledateconverted', 
 @newname='saledate', 
 @objtype='COLUMN';


 --POPULATE MISSING PROPERTY ADDRESS DATA WITH DATA FROM RECORDS FOR THE SAME ADDRESS-------

--Return all records where Property Address is NULL and the corresponding records with the same ParcelID and PropertyAddress is NOT NULL
SELECT
	NH1.ParcelID AS ParcelID_NOTNULL
	, NH1.PropertyAddress AS PropertyAddress_NOTNULL
	, NH2.ParcelID AS ParcelID_NULL
	, NH2.PropertyAddress AS PropertyAddress_NULL
	, ISNULL(NH2.PropertyAddress, NH1.PropertyAddress) as Updated_PropertyAddress_NULL
FROM PortfolioProject.dbo.NashvilleHousing_BKUP NH1
JOIN PortfolioProject.dbo.NashvilleHousing_BKUP NH2
	ON NH1.ParcelID=NH2.ParcelID
	AND NH1.[UniqueID ]<>NH2.[UniqueID ]
WHERE NH2.PropertyAddress IS NULL
	AND NH1.PropertyAddress IS NOT NULL
ORDER BY NH1.ParcelID, NH1.PropertyAddress;

--Update NULL PropertyAddress to PreopertyAddress with the same ParcelID
BEGIN TRANSACTION
GO
UPDATE NH2
SET PropertyAddress = ISNULL(NH2.PropertyAddress, NH1.PropertyAddress)
FROM PortfolioProject.dbo.['NashvilleHousing'] NH1
JOIN PortfolioProject.dbo.['NashvilleHousing'] NH2
	ON NH1.ParcelID=NH2.ParcelID
	AND NH1.[UniqueID ]<>NH2.[UniqueID ]
WHERE NH2.PropertyAddress IS NULL
	AND NH1.PropertyAddress IS NOT NULL
COMMIT


--BREAKING ADDRESS DATA INTO INDIVIDUAL ADDRESS, CITY AND STATE COLUMNS---------------------

--Create new column Address and populate with part of owneraddress
ALTER TABLE PortfolioProject.dbo.['NashvilleHousing'] ADD Address NVARCHAR(255);
BEGIN TRANSACTION
GO
UPDATE PortfolioProject.dbo.['NashvilleHousing'] 
	--option 1
	SET Address = LEFT(owneraddress, CHARINDEX(',',owneraddress, 1)-1)
	--option 2
	--SET Address = TRIM(PARSENAME(REPLACE(owneraddress,', ', '.'),3))
COMMIT;

--Create new column City and populate with part of owneraddress
ALTER TABLE PortfolioProject.dbo.['NashvilleHousing'] ADD City NVARCHAR(255);
BEGIN TRANSACTION
GO
UPDATE PortfolioProject.dbo.['NashvilleHousing'] 
	--option 1
	SET City = SUBSTRING(owneraddress, CHARINDEX(',',owneraddress, 1)+2, (LEN(owneraddress)-((CHARINDEX(',',owneraddress)+1)+CHARINDEX(',',REVERSE(owneraddress)))))
	--option 2
	--SET City = TRIM(PARSENAME(REPLACE(owneraddress,', ', '.'),2))
COMMIT;

--Create new column State and populate with part of owneraddress
ALTER TABLE PortfolioProject.dbo.['NashvilleHousing'] ADD State NVARCHAR(255)
BEGIN TRANSACTION
GO
UPDATE PortfolioProject.dbo.['NashvilleHousing'] 
	--option 1
	SET State = REVERSE(LEFT(REVERSE(owneraddress),(CHARINDEX(',',REVERSE(owneraddress))-2)))
	--option 2
	--SET State = TRIM(PARSENAME(REPLACE(owneraddress,', ', '.'),1))
COMMIT;



--CHANGE Y AND N TO YES AND NO IN 'SOLDASVACANT' FIELD--------------------------------------

--Count the number of records with SoldAsVacant set to Y and N
SELECT SoldAsVacant, COUNT(*)
FROM PortfolioProject.dbo.['NashvilleHousing']
GROUP BY SoldAsVacant;

--Update Y to Yes and N to No in the SoldAsVacant field
USE PortfolioProject
GO
UPDATE ['NashvilleHousing']
SET soldasvacant = (
	CASE 
		WHEN soldasvacant='No' THEN 'No'
		WHEN soldasvacant='N' THEN 'No'
		WHEN soldasvacant='Yes' THEN 'Yes'
		WHEN soldasvacant='Y' THEN 'Yes'
		END );


--REMOVE DUPLICATE RECORDS (NOT STANDARD PRACTICE TO DELETE DATA FROM DATABASE--------------

--Identify Duplicate Records (same parcelid, propertyaddress, saleprice, legalreference, saledate)
WITH duplicatesCTE AS (
	SELECT 
		RANK() OVER (PARTITION BY
			parcelid
			, propertyaddress
			, saleprice
			, legalreference
			, saledate
			ORDER BY
			uniqueid) as rank
		, *
	FROM ['NashvilleHousing'] )
SELECT
	t.uniqueid
	, t.parcelid
	, t.propertyaddress
	, t.saleprice
	, t.legalreference
	, t.saledate
FROM ['NashvilleHousing'] t
JOIN duplicatesCTE v
	ON t.parcelid=v.parcelid
	AND t.propertyaddress=v.propertyaddress
	AND t.saleprice=v.saleprice
	AND t.legalreference=v.legalreference
	AND t.saledate=v.saledate
	AND v.rank > 1
ORDER BY parcelid;

--Remove duplicate records
WITH duplicatesCTE AS (
	SELECT 
		ROW_NUMBER() OVER (PARTITION BY
			parcelid
			, propertyaddress
			, saleprice
			, legalreference
			, saledate
			ORDER BY
			uniqueid) AS row
		, *
	FROM ['NashvilleHousing'])
DELETE FROM duplicatesCTE
WHERE row > 1;
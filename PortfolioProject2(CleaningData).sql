
/*
Cleaning Data in SQL Queries
*/


SELECT *
FROM [PortfolioProject2(cleaningData)].dbo.NashvileHousingMkt;

---- Standardize Date Format

SELECT SaleDate
FROM [PortfolioProject2(cleaningData)].dbo.NashvileHousingMkt;

--Rid off the time in the dates

SELECT SaleDate, CAST(SaleDate AS Date) 
FROM [PortfolioProject2(cleaningData)].dbo.NashvileHousingMkt;

--Convert table by update/alter

UPDATE NashvileHousingMkt
SET SaleDate = CAST(SaleDate AS Date);
     
	 --OR ALTER IF UPDATE DOESNT WORK

ALTER TABLE NashvileHousingMkt
ADD SaleDateConverted Date;

UPDATE NashvileHousingMkt
SET SaleDateConverted = CAST(SaleDate AS Date);


---we confirm for update

SELECT SaleDateConverted, CAST(SaleDate AS Date) 
FROM [PortfolioProject2(cleaningData)].dbo.NashvileHousingMkt;


-- Look at Property Address data

SELECT PropertyAddress
FROM [PortfolioProject2(cleaningData)].dbo.NashvileHousingMkt
WHERE PropertyAddress IS NULL;

--ALL NULL VALUES
SELECT *
FROM [PortfolioProject2(cleaningData)].dbo.NashvileHousingMkt
WHERE PropertyAddress IS NULL;

--Check repeating ParcelID and eliminate/merge to rid off repeat ID/ADDRESS
SELECT *
FROM [PortfolioProject2(cleaningData)].dbo.NashvileHousingMkt
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID;


--jOIN this table to itself

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [PortfolioProject2(cleaningData)].dbo.NashvileHousingMkt AS a
JOIN [PortfolioProject2(cleaningData)].dbo.NashvileHousingMkt AS b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [PortfolioProject2(cleaningData)].dbo.NashvileHousingMkt AS a
JOIN [PortfolioProject2(cleaningData)].dbo.NashvileHousingMkt AS b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;  

--CONFIRM BY EXECUTING

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [PortfolioProject2(cleaningData)].dbo.NashvileHousingMkt AS a
JOIN [PortfolioProject2(cleaningData)].dbo.NashvileHousingMkt AS b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;


-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM [PortfolioProject2(cleaningData)].dbo.NashvileHousingMkt;

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) AS Address
FROM [PortfolioProject2(cleaningData)].dbo.NashvileHousingMkt;

--we check position of the comma
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) AS Address, CHARINDEX(',', PropertyAddress)
FROM [PortfolioProject2(cleaningData)].dbo.NashvileHousingMkt;



--We get rid of the comma 

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
FROM [PortfolioProject2(cleaningData)].dbo.NashvileHousingMkt;

--seperate address and rid comma before state name

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM [PortfolioProject2(cleaningData)].dbo.NashvileHousingMkt

--Create two new columns and add two values seperated from initial column

ALTER TABLE NashvileHousingMkt
ADD PropertySplitAddress NVARCHAR(255);


UPDATE NashvileHousingMkt
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvileHousingMkt
ADD PropertySplitCity NVARCHAR(255)

UPDATE NashvileHousingMkt
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--we then confirm the new columns/values are updated

SELECT *
FROM [PortfolioProject2(cleaningData)].dbo.NashvileHousingMkt;


--split OwnerAddress using ParseName. nb use of substring is also valid but longer.
--view 
SELECT OwnerAddress
FROM [PortfolioProject2(cleaningData)].dbo.NashvileHousingMkt;

--split

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM [PortfolioProject2(cleaningData)].dbo.NashvileHousingMkt

--create values/columns and update 

ALTER TABLE NashvileHousingMkt
ADD OwnerSplitAddress NVARCHAR(255);


UPDATE NashvileHousingMkt
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvileHousingMkt
ADD OwnerSplitCity NVARCHAR(255);


UPDATE NashvileHousingMkt
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvileHousingMkt
ADD OwnerSplitState NVARCHAR(255);


UPDATE NashvileHousingMkt
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--confirming our updates

SELECT *
FROM [PortfolioProject2(cleaningData)].dbo.NashvileHousingMkt;



-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [PortfolioProject2(cleaningData)].dbo.NashvileHousingMkt
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
  CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
       WHEN SoldAsVacant = 'N' THEN 'NO'
  ELSE SoldAsVacant
  END
FROM [PortfolioProject2(cleaningData)].dbo.NashvileHousingMkt;


UPDATE NashvileHousingMkt
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
       WHEN SoldAsVacant = 'N' THEN 'NO'
  ELSE SoldAsVacant
  END
FROM [PortfolioProject2(cleaningData)].dbo.NashvileHousingMkt;

--confirm update
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [PortfolioProject2(cleaningData)].dbo.NashvileHousingMkt
GROUP BY SoldAsVacant
ORDER BY 2;



-- Remove Duplicates

--look for repeat data

SELECT *,
     ROW_NUMBER() OVER(
	 PARTITION BY ParcelID,
	              PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  ORDER BY
				       UniqueID
					   ) row_num
FROM [PortfolioProject2(cleaningData)].dbo.NashvileHousingMkt
ORDER BY ParcelID;

--identify the repeat values

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM [PortfolioProject2(cleaningData)].dbo.NashvileHousingMkt
--order by ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

--Delete duplicates once identified

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM [PortfolioProject2(cleaningData)].dbo.NashvileHousingMkt
--order by ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress;

--Check that deleted values no longer there

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM [PortfolioProject2(cleaningData)].dbo.NashvileHousingMkt
--order by ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;


-- Delete Unused Columns(not recomended) 

SELECT *
FROM [PortfolioProject2(cleaningData)].dbo.NashvileHousingMkt

--ALTER TABLE [PortfolioProject2(cleaningData)].dbo.NashvileHousingMkt
--DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

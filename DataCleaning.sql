--Cleaning Data in SQL queries


SELECT *
FROM NashvilleHousing

--Standardize Data Format
SELECT SaleDateConverted, CAST(SaleDate AS TEXT)
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CAST(SaleDate AS TEXT)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CAST(SaleDate AS TEXT)

--Populate Property Address data
 SELECT *
 FROM NashvilleHousing
			--WHERE PropertyAddress is NULL
 ORDER by ParcelID
 
 
 
 SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress)
 FROM NashvilleHousing a
 JOIN NashvilleHousing b
 on a.ParcelID = b.ParcelID
 AND a.[UniqueID] <> b.[UniqueID]
 WHERE a.PropertyAddress is NULL
 
UPDATE NashvilleHousing AS a
SET PropertyAddress = IFNULL(a.PropertyAddress, (
    SELECT b.PropertyAddress
    FROM NashvilleHousing AS b
    WHERE a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID]
    AND b.PropertyAddress IS NOT NULL
))
WHERE a.PropertyAddress IS NULL
 
 --Breaking out Address into individual  columns (address, city, state)
 SELECT PropertyAddress
 FROM NashvilleHousing
 
 
SELECT
    SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',') - 1) AS Address
	, SUBSTRING(PropertyAddress, instr(PropertyAddress, ',') + 1 , length(PropertyAddress)) AS Address
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress TEXT

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',') - 1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity TEXT

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, instr(PropertyAddress, ',') + 1 , length(PropertyAddress)) 

SELECT *
FROM NashvilleHousing

SELECT OwnerAddress
FROM NashvilleHousing

SELECT
    TRIM(SUBSTR(OwnerAddress, 1, INSTR(OwnerAddress, ',') - 1)),

    TRIM(SUBSTR(OwnerAddress, INSTR(OwnerAddress, ',') + 1,
        INSTR(SUBSTR(OwnerAddress, INSTR(OwnerAddress, ',') + 1), ',') - 1)),

    TRIM(SUBSTR(OwnerAddress,
        INSTR(OwnerAddress, ',') +
        INSTR(SUBSTR(OwnerAddress, INSTR(OwnerAddress, ',') + 1), ',') + 1)) 
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress TEXT

UPDATE NashvilleHousing
SET OwnerSplitAddress = TRIM(SUBSTR(OwnerAddress, 1, INSTR(OwnerAddress, ',') - 1))

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity TEXT

UPDATE NashvilleHousing
SET OwnerSplitCity = TRIM(SUBSTR(OwnerAddress, INSTR(OwnerAddress, ',') + 1, INSTR(SUBSTR(OwnerAddress, INSTR(OwnerAddress, ',') + 1), ',') - 1))

ALTER TABLE NashvilleHousing
ADD OwnerSplitState TEXT

UPDATE NashvilleHousing
SET OwnerSplitState = TRIM(SUBSTR(OwnerAddress, INSTR(OwnerAddress, ',') + INSTR(SUBSTR(OwnerAddress, INSTR(OwnerAddress, ',') + 1), ',') + 1)) 

SELECT * 
From NashvilleHousing


--Change Y and N to Yes and No in "Sold as Vacant" field
Select DISTINCT(SoldAsVacant), count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
ORDER by 2

Select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' Then 'No'
ELSE SoldAsVacant
END
From NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' Then 'No'
ELSE SoldAsVacant
END


--Removing Duplicates
WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM NashvilleHousing
)

DELETE FROM NashvilleHousing
WHERE UniqueID IN (
    SELECT UniqueID
    FROM RowNumCTE
    WHERE row_num > 1
)

Select *
    FROM RowNumCTE
    WHERE row_num > 1
	order by PropertyAddress

--Delete unused columns
SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress

ALTER TABLE NashvilleHousing
DROP COLUMN TaxDistrict

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate
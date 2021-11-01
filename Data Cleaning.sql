
/*

Cleaning Data in SQL Queries

*/

-- Standardize Date Format

Select *
from NashvilleHousing
Order by ParcelID

ALTER TABLE NashvilleHousing
ADD SaleDateConverted date;

UPDATE NashvilleHousing
SET SaleDateConverted=CONVERT(date,SaleDate);

--Drop old column
ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate 



 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,
ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress IS NULL 

--fill in the NULL values with Property Address
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress IS NULL 



 --------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

--Property Address split
SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS City
from NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress));

--Owner Address split .
SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS OwnerState,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS OwnerCity,
PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS OwnerAddress
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2);

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3);







--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant) FROM NashvilleHousing --values: Yes,No,Y,N

SELECT 
CASE WHEN SoldAsVacant ='N' THEN 'No'
	 WHEN SoldAsVacant ='Y' THEN 'Yes'
	 ELSE SoldAsVacant
	 END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant=CASE WHEN SoldAsVacant ='N' THEN 'No'
	 WHEN SoldAsVacant ='Y' THEN 'Yes'
	 ELSE SoldAsVacant
	 END



-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH RN_CTE AS(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY PropertySplitAddress,ParcelID,LegalReference,SaleDateConverted
				  ORDER BY UniqueID) AS RN
FROM NashvilleHousing 
)
DELETE
FROM RN_CTE
WHERE RN >1


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE NashvilleHousing
DROP COLUMN TaxDistrict,PropertyAddress





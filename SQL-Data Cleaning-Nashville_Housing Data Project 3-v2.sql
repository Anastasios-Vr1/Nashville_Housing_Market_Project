/*

Cleaning Data in SQL Queries

*/

SELECT * 
FROM dbo.NashvilleHousing

---------------------------------------------------------------------------

--Standarize Date Format

SELECT SaleDate, CONVERT(DATE,SaleDate)
FROM dbo.NashvilleHousing 

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE,SaleDate) 

ALTER TABLE NashvilleHousing
DROP Column SaleDate

EXEC sp_RENAME 'PortfolioProject.dbo.NashvilleHousing.SaleDateConverted', 'SaleDate', 'COLUMN'

--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data (using a self join and ISNULL)

SELECT *
FROM portfolioproject.dbo.NashvilleHousing 
ORDER BY ParcelID

SELECT a.[UniqueID ], 
		a.ParcelID, 
		a. PropertyAddress, 
		b.[UniqueID ], 
		b.ParcelID, 
		ISNULL(a.propertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET a.propertyAddress = ISNULL(a.propertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--------------------------------------------------------------------------------------------------------------------------


-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress, 
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) AS Address, 
SUBSTRING(propertyaddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM PortfolioProject.DBO.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing 
Add PropertySpiltAddress Nvarchar(225), 
	PropertyCityAddress Nvarchar(225)


UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySpiltAddress = SUBSTRING(Propertyaddress,1,CHARINDEX(',',PropertyAddress)-1),
	PropertyCityAddress = SUBSTRING(Propertyaddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


-- Breaking out	Owner Address into Individual Columns (Address, City, State) using PARSENAME


SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT
	PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE  PortfolioProject.dbo.NashvilleHousing
Add OwnerSpiltAddress Nvarchar(225), 
	OwnerCity Nvarchar(225),
	OwnerState Nvarchar(225)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSpiltAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


	--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select SoldAsVacant, COUNT(Soldasvacant) AS Count
From PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant

SELECT soldasvacant,
		CASE
			WHEN SoldAsVacant = 'Y' THEN 'YES'
			WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant
		END 
FROM PortfolioProject.dbo.NashvilleHousing


UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE
						WHEN SoldAsVacant = 'Y' THEN 'YES'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
					END 


-----------------------------------------------------------------------------------------------------------------------------------------------------------


-- Remove Duplicates



WITH CTE_Dupl AS(

SELECT *,
		ROW_NUMBER() OVER (PARTITION BY
									ParcelID, 
									PropertyAddress,
									SalePrice,
									SaleDate,
									LegalReference
									ORDER BY ParcelId) as rowNum
FROM PortfolioProject.dbo.NashvilleHousing
)

SELECT rowNum FROM CTE_Dupl
WHERE rowNum > 1


DELETE FROM CTE_Dupl
WHERE rowNum > 1


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


SELECT * 
FROM PortfolioProject.DBO.NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN Owneraddress, PropertyAddress, TaxDistrict


-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

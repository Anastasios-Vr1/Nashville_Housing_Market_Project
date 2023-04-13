/*

Cleaning Data in SQL Queries

*/


Select *
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------


-- Standardize Date Format(Change Column Data Type Format)

Select SaleDate, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ALTER COLUMN SaleDate Date


--& Rename Column SaleDate to SaleDateConverted

EXEC sp_RENAME 'PortfolioProject.dbo.NashvilleHousing.SaleDate', 'SaleDateConverted', 'COLUMN'


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID


Select a.[UniqueID ], b.[UniqueID ], a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where A.PropertyAddress IS NULL


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where A.PropertyAddress IS NULL



--------------------------------------------------------------------------------------------------------------------------


-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress,
SUBSTRING(Propertyaddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(Propertyaddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousing 


ALTER TABLE PortfolioProject.dbo.NashvilleHousing 
Add PropertySpiltAddress Nvarchar(225), 
	PropertyCityAddress Nvarchar(225)


UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySpiltAddress = SUBSTRING(Propertyaddress,1,CHARINDEX(',',PropertyAddress)-1),
	PropertyCityAddress = SUBSTRING(Propertyaddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))



-- Breaking out	Owner Address into Individual Columns (Address, City, State) using PARSENAME


Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From PortfolioProject.dbo.NashvilleHousing

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


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.DBO.NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant,
CASE SoldAsVacant WHEN 'Y'  THEN 'Yes'
				  WHEN 'N' THEN 'No'
				  ELSE SoldAsVacant
				  END 
From PortfolioProject.DBO.NashvilleHousing


UPDATE PortfolioProject.DBO.NashvilleHousing
SET SoldAsVacant = CASE SoldAsVacant WHEN 'Y'  THEN 'Yes'
				  WHEN 'N' THEN 'No'
				  ELSE SoldAsVacant
				  END 



-----------------------------------------------------------------------------------------------------------------------------------------------------------


-- Remove Duplicates



WITH RowNumCTE as (
Select *,
		ROW_NUMBER() OVER ( 
		PARTITION BY ParcelID, 
								PropertyAddress,
								SaleDateConverted,
								Saleprice,
								LegalReference
								ORDER BY UniqueID) AS row_num

From PortfolioProject.DBO.NashvilleHousing
)

Select * 
From RowNumCTE
WHERE row_num > 1
Order by PropertyAddress


DELETE 
From RowNumCTE
WHERE row_num > 1



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.DBO.NashvilleHousing
DROP COLUMN Owneraddress, PropertyAddress, TaxDistrict



-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
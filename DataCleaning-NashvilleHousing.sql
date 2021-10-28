select * 
from dbo.NashvilleHousing


-- Standardlize Data Format
select saledate, convert(date,SaleDate)
from dbo.NashvilleHousing

ALTER TABLE nashvillehousing
Add salesDateConverted Date;


Update NashvilleHousing
SET salesDateConverted = convert(date,SaleDate)

-- Populate Property Address data
select *
-- where PropertyAddress IS NULL
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
from dbo.NashvilleHousing a join dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress IS NULL

Update a
Set PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
from dbo.NashvilleHousing a join dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress IS NULL

-- Breaking out Address into Individual Columns (Address, City, State)
select PropertyAddress
from [dbo].[NashvilleHousing]
-- where PropertyAddress IS NULL
-- order by ParcelID

SELECT 
SUBSTRING(Propertyaddress, 1, CHARINDEX(',' , PropertyAddress)-1 ) as Address,
SUBSTRING(Propertyaddress, CHARINDEX(',' , PropertyAddress)+1 ,len(Propertyaddress)) as Address
from [dbo].[NashvilleHousing]


ALTER TABLE nashvillehousing
Add PropertySplitAddress NVARCHAR(255);


Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(Propertyaddress, 1, CHARINDEX(',' , PropertyAddress)-1 )

ALTER TABLE nashvillehousing
Add PropertySplitCity NVARCHAR(255);


Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(Propertyaddress, CHARINDEX(',' , PropertyAddress)+1 ,len(Propertyaddress))

SELECT *
from [dbo].[NashvilleHousing]

-- Organizing Owner Address (Address, City, State)

select OwnerAddress
from [dbo].[NashvilleHousing]


select 
PARSENAME( REPLACE( OwnerAddress, ',' , '.') , 3)
,PARSENAME( REPLACE( OwnerAddress, ',' , '.') , 2)
,PARSENAME( REPLACE( OwnerAddress, ',' , '.') , 1)

from [dbo].[NashvilleHousing]


ALTER TABLE nashvillehousing
Add OwnerSplitAddress NVARCHAR(255);


Update nashvillehousing
SET  OwnerSplitAddress = PARSENAME( REPLACE( OwnerAddress, ',' , '.') , 3)

ALTER TABLE nashvillehousing
Add OwnerSplitCity NVARCHAR(255);


Update nashvillehousing
SET OwnerSplitCity = PARSENAME( REPLACE( OwnerAddress, ',' , '.') , 2)

ALTER TABLE nashvillehousing
Add OwnerSplitstate NVARCHAR(255);

Update nashvillehousing
SET OwnerSplitstate = PARSENAME( REPLACE( OwnerAddress, ',' , '.') , 1)


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct (SoldAsVacant), count(*)
from [dbo].[NashvilleHousing]
group by SoldAsVacant
order by SoldAsVacant

select SoldAsVacant,
CASE
when SoldAsVacant = 'N' THEN 'No'
when SoldAsVacant = 'Y' THEN 'Yes'
ELSE SoldAsVacant
END
from [dbo].[NashvilleHousing]
order by SoldAsVacant

Update [dbo].[NashvilleHousing]
SET SoldAsVacant = CASE
	when SoldAsVacant = 'N' THEN 'No'
	when SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
	END


-- Remove Duplicates

WITH RowNumCTE AS (
select *,
ROW_NUMBER() OVER (
PARTITION BY ParcelId,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY 
				UniqueID
				) row_num


from [dbo].[NashvilleHousing]
)
DELETE 
from RowNumCTE
where row_num > 1

-- Delete Unused Columns

select * 
from dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN SaleDate, OwnerAddress, TaxDistrict, PropertyAddress

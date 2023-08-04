Select * from NashvilleHousing

-- Standardize Date Format

Select SaleDateConverted, CONVERT(Date, SaleDate)
From NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

---- Populate Property Address Data
Select * 
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
from PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
   on a.ParcelID = b.ParcelID
   AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress) 
from PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
   on a.ParcelID = b.ParcelID
   AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking address into Indvisual Columns

Select PropertyAddress 
from PortfolioProject.dbo.NashvilleHousing


-- Using Substring
Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,LEN(PropertyAddress)) as Address 
From PortfolioProject.dbo.NashvilleHousing

ALTER table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,LEN(PropertyAddress))

Select *
from PortfolioProject.dbo.NashvilleHousing


Select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

 --- USING PARSENAME

 Select 
 PARSENAME(Replace(OwnerAddress,',','.'), 3),
PARSENAME(Replace(OwnerAddress,',','.'), 2),
PARSENAME(Replace(OwnerAddress,',','.'), 1)
from PortfolioProject.dbo.NashvilleHousing

ALTER table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'), 3)

ALTER table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'), 2)

ALTER table NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'), 1)


--Changing Y to Yes and N to No on SoldAsVacant
Select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant,
Case when SoldAsVacant = 'Y' Then 'Yes'
     when SoldAsVacant = 'N' Then 'No' 
	 Else SoldAsVacant
	 End
from PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = Case when SoldAsVacant = 'Y' Then 'Yes'
     when SoldAsVacant = 'N' Then 'No' 
	 Else SoldAsVacant
	 End

Select Distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

--- Remove Duplicates

WITH ROWNUMCTE As (
Select *, 
  ROW_NUMBER() Over(
  Partition by ParcelID, 
               PropertyAddress,
			   SalePrice,
			   SaleDate,
			   LegalReference
			   Order by
			     UniqueID
				 ) row_num


  from PortfolioProject.dbo.NashvilleHousing
  --Order by ParcelID
  )
Select * 
from ROWNUMCTE
where row_num > 1
order by PropertyAddress


--- Delete unused columns

Select * 
from PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing 
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProject.dbo.NashvilleHousing 
Drop Column SaleDate

















--data cleaning in SQL

-----------------------------------

--standardized Date format

select saledateconverted , CONVERT(date,saledate)
from PortfolioProject..nashvillehousing

update nashvillehousing
set SaleDate = convert(date,saledate)      ---might work sometimes

alter table nashvillehousing
add saledateconverted date;

update nashvillehousing
set saledateconverted = CONVERT(date,saledate)


--populate property address data

select  a.parcelID , a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.propertyaddress,b.PropertyAddress)
from PortfolioProject..nashvillehousing a
join PortfolioProject..nashvillehousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

update a
set propertyaddress = ISNULL(a.propertyaddress,b.propertyaddress)
from PortfolioProject..nashvillehousing a
join PortfolioProject..nashvillehousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null


--breaking out address into individual columns (address,city,state) 

select propertyaddress
from PortfolioProject..nashvillehousing


select SUBSTRING(propertyaddress,1,charindex(',',propertyaddress) -1) as address,
 SUBSTRING(propertyaddress,CHARINDEX(',' ,propertyaddress) + 1 , len(propertyaddress)) as address
from PortfolioProject..nashvillehousing

alter table nashvillehousing
add propertysplitaddress nvarchar (255);

update nashvillehousing
set propertysplitaddress = SUBSTRING(propertyaddress,1,charindex(',',propertyaddress) -1)

alter table nashvillehousing
add propertysplitcity nvarchar(255);

update nashvillehousing
set propertysplitcity = substring(propertyaddress,charindex(',',propertyaddress)+1 ,len(propertyaddress))

select *
from PortfolioProject.. nashvillehousing




--using parsename

select owneraddress
from PortfolioProject..nashvillehousing

select
PARSENAME(replace(owneraddress,',','.'),3),
parsename(replace(owneraddress,',','.'),2),
parsename(replace(owneraddress,',','.'),2)
from PortfolioProject..nashvillehousing


alter table nashvillehousing
add ownersplitaddress nvarchar(255);


update nashvillehousing
set ownersplitaddress = PARSENAME(replace(owneraddress,',','.'),3)

alter table nashvillehousing
add ownersplitcity nvarchar(255);

update nashvillehousing
set ownersplitcity = PARSENAME(replace(owneraddress,',','.'),2)

alter table nashvillehousing
add ownersplitstate nvarchar(255);

update nashvillehousing
set ownersplitstate = PARSENAME(replace(owneraddress,',','.'),1)

select *
from PortfolioProject..nashvillehousing


--change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), COUNT(soldasvacant)
from PortfolioProject..nashvillehousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
	case when SoldAsVacant = 'Y' then 'Yes'
		 when soldasvacant = 'N' then 'No'
		 else SoldAsVacant
		 end
from PortfolioProject..nashvillehousing


update nashvillehousing
set SoldAsVacant= case when SoldAsVacant = 'Y' then 'Yes'
		 when soldasvacant = 'N' then 'No'
		 else SoldAsVacant
		 end
from PortfolioProject..nashvillehousing

------------------------------------------------------------------

--remove duplicates
WITH RowNumCTE as(
select *,
		ROW_NUMBER() over(
		partition by ParcelId,
					 propertyaddress,
					 saleprice,
					 saledate,
					 legalreference
					 order by
						uniqueid
						) row_num
from PortfolioProject..nashvillehousing
)
delete
from RownumCTE
where row_num > 1
order by propertyaddress

----------------------------------

--delete unused columns

select *
from PortfolioProject..nashvillehousing

alter table nashvillehousing
drop column owneraddress,taxdistrict,propertyaddress

alter table nashvillehousing
drop column saledate
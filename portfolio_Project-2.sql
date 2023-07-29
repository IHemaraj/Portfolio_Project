
--Now we're going to do some cleaning process using SQL
--With the help of Alex The Analyst Bootcamp only i've learned all these queries
--First we need to take look in dataset

-----------------------------------------------------------------------------------------------------

SELECT*
FROM portfolioproject.dbo.nashvilleHousing

--Change the format of saleDate column

--we're changing the datetime datatype into date format

SELECT SaleDate, CONVERT(date,SaleDate) 
FROM portfolioproject.dbo.nashvilleHousing

--After changing the type we're updating the column in nashvilleHousing Table

UPDATE portfolioproject.dbo.nashvilleHousing
SET SaleDate = CONVERT(date,SaleDate) 

--Now we need to add the converted column in table so we use alter table clause

ALTER TABLE portfolioproject.dbo.nashvilleHousing
ADD SaleDateConverted Date;

--After creating alter table again we need to update the new column in table

UPDATE portfolioproject.dbo.nashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate) 

--now check whether the column is added or not

SELECT SaleDateConverted, CONVERT(date,SaleDate) 
FROM portfolioproject.dbo.nashvilleHousing

SELECT*
FROM portfolioproject.dbo.nashvilleHousing

--Lets look at property address data

SELECT PropertyAddress
FROM portfolioproject.dbo.nashvilleHousing

--now lets check whether it have null values

SELECT PropertyAddress
FROM portfolioproject.dbo.nashvilleHousing
WHERE PropertyAddress is NULL

--It have, so lets check it for all column

SELECT *
FROM portfolioproject.dbo.nashvilleHousing
WHERE PropertyAddress is NULL


SELECT *
FROM portfolioproject.dbo.nashvilleHousing
--WHERE PropertyAddress is NULL
ORDER BY ParcelId


--now we need to fill the nullvalues, so we're using the help of ParcelId column to complete. JOIN the table with his own table.

SELECT a.ParcelId,a.PropertyAddress,b.ParcelId,b.PropertyAddress
FROM portfolioproject.dbo.nashvilleHousing as a
JOIN portfolioproject.dbo.nashvilleHousing as b
    ON a.ParcelId = b.ParcelId
    AND a.UniqueId <> b.UniqueId
WHERE a.PropertyAddress is NULL
--now we have property address which are in the same row,using this b.property address we can populate the null values in a.property address
--now we are creating new coulmn which have b.property address.use ISNULL clause {ISNULL(what do we need to check if it's null
--put it there , what we need to populate, put it there)}

SELECT a.ParcelId,a.PropertyAddress,b.ParcelId,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM portfolioproject.dbo.nashvilleHousing as a
JOIN portfolioproject.dbo.nashvilleHousing as b
    ON a.ParcelId = b.ParcelId
    AND a.UniqueId <> b.UniqueId
WHERE a.PropertyAddress is  NULL

--The new column is created which have the property addr.Lets update them in a.property addr
UPDATE a
SET PropertyAddress =ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM portfolioproject.dbo.nashvilleHousing as a
JOIN portfolioproject.dbo.nashvilleHousing as b
    ON a.ParcelId = b.ParcelId
    AND a.UniqueId <> b.UniqueId
WHERE a.PropertyAddress is NOT NULL

--Check the total table whether it is updated or not


SELECT*
FROM portfolioproject.dbo.nashvilleHousing
WHERE PropertyAddress is NOT NULL

--successfully updated

--Now lets make the owner address more convinent to read. We are using the PARSENAME 

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM portfolioproject.dbo.nashvilleHousing

--it separet the value from backwards so we need to put the index no in backwards

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM portfolioproject.dbo.nashvilleHousing

ALTER TABLE portfolioproject.dbo.nashvilleHousing
ADD OwnerAddressSplit nvarchar(255);

UPDATE portfolioproject.dbo.nashvilleHousing
SET OwnerAddressSplit  =PARSENAME(REPLACE(OwnerAddress,',','.'), 3)  


ALTER TABLE portfolioproject.dbo.nashvilleHousing
ADD OwnerCitySplit nvarchar(255);

UPDATE portfolioproject.dbo.nashvilleHousing
SET OwnerCitySplit  =PARSENAME(REPLACE(OwnerAddress,',','.'), 2)  


ALTER TABLE portfolioproject.dbo.nashvilleHousing
ADD OwnerStateSplit nvarchar(255);

UPDATE portfolioproject.dbo.nashvilleHousing
SET OwnerStateSplit  =PARSENAME(REPLACE(OwnerAddress,',','.'), 1) 

SELECT *
FROM portfolioproject.dbo.nashvilleHousing

--In nashvilleHousing table there is a colummn named SoldasVacant, in that there are yes and no type of values present. BUt in some places there a y for yes and n for no
--we need to change the format to proper type.

--Use the case statement for this query

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM portfolioproject.dbo.nashvilleHousing
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM portfolioproject.dbo.nashvilleHousing

--update them in SoldAsVacant column

UPDATE  portfolioproject.dbo.nashvilleHousing
SET SoldAsVacant = CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM portfolioproject.dbo.nashvilleHousing

--remove duplicates

--For removing the duplicates we need to specify them as unique.So we are using the ROW_NUMBER to show them as duplicates

SELECT *,
ROW_NUMBER() OVER(
     PARTITION BY ParcelId,
	              PropertyAddress,
				  SaleDate,
				  SalePrice,
				  LegalReference
				  ORDER BY UniqueId) AS Row_Num

FROM portfolioproject.dbo.nashvilleHousing
ORDER BY ParcelID

--Now we need find whether there is any 2 in row_num but we can't use WHERE clause.So we are using the CTE to put the query inside it and then call the where clause.

with RowNumCTE
AS (
SELECT *,
ROW_NUMBER() OVER(
     PARTITION BY ParcelId,
	              PropertyAddress,
				  SaleDate,
				  SalePrice,
				  LegalReference
				  ORDER BY UniqueId) AS Row_Num

FROM portfolioproject.dbo.nashvilleHousing
--ORDER BY ParcelID
)

SELECT *
FROM RowNumCTE
WHERE Row_Num > 1

--Now it shows the duplicates. Lets delete them

with RowNumCTE
AS (
SELECT *,
ROW_NUMBER() OVER(
     PARTITION BY ParcelId,
	              PropertyAddress,
				  SaleDate,
				  SalePrice,
				  LegalReference
				  ORDER BY UniqueId) AS Row_Num

FROM portfolioproject.dbo.nashvilleHousing
--ORDER BY ParcelID
)

DELETE
FROM RowNumCTE
WHERE Row_Num > 1



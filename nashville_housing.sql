
SELECT *
FROM portfolioproject.nashville_housing
ORDER BY ParcelID


-- Checking ParcelID with Same Address
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM portfolioproject.nashville_housing a
JOIN portfolioproject.nashville_housing b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID 
WHERE a.PropertyAddress is NULL


SELECT 
    SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) AS Address,
    SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1) AS Address
FROM portfolioproject.nashville_housing;



UPDATE nashville_housing 
SET PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1);



-- SPLITING FULL PROPPERTY ADDRESS AND TURNING IT INTO PROPERTY ADDRESS AND PROPERTY CITY

ALTER TABLE nashville_housing 
ADD COLUMN PropertyAddressSplit VARCHAR(255);

UPDATE nashville_housing 
SET PropertyAddressSplit = 
    CASE 
        WHEN LOCATE(',', PropertyAddress) > 0 
        THEN SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) 
        ELSE PropertyAddress 
    END;
  


ALTER TABLE nashville_housing 
ADD COLUMN PropertyCitySplit VARCHAR(255);
    
UPDATE nashville_housing 
SET PropertyCitySplit = 
    CASE 
        WHEN LOCATE(',', PropertyAddress) > 0 
        THEN SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1) 
        ELSE PropertyAddress 
    END;



-- Splitting Owner's full address into parts such as House address, city and state
SELECT 
    SUBSTRING_INDEX(OwnerAddress, ',', 1) AS AddressPart1,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) AS AddressPart2, 
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1) AS AddressPart3 
FROM nashville_housing;



ALTER TABLE nashville_housing 
ADD COLUMN OwnerAddressSplit VARCHAR(255);
UPDATE nashville_housing 
SET OwnerAddressSplit = SUBSTRING_INDEX(OwnerAddress, ',', 1);

ALTER TABLE nashville_housing 
ADD COLUMN OwnerCitySplit VARCHAR(255);
UPDATE nashville_housing 
SET OwnerCitySplit = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1);


ALTER TABLE nashville_housing 
ADD COLUMN OwnerStateSplit VARCHAR(255);
UPDATE nashville_housing 
SET OwnerStateSplit = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1)



-- Changing 'Y' and 'N' into 'Yes' and 'No'
SELECT distinct(SoldAsVacant), COUNT(SoldAsVacant)
From nashville_housing
Group by SoldAsVacant


SELECT SoldAsVacant,
CASE  WHEN SoldAsVacant = 'Y' Then 'Yes'
	  When SoldAsVacant = 'N' Then 'No'
      Else SoldAsVacant
      END
From nashville_housing


UPDATE nashville_housing
SET SoldAsVacant = CASE  WHEN SoldAsVacant = 'Y' Then 'Yes'
	  When SoldAsVacant = 'N' Then 'No'
      Else SoldAsVacant
      END



-- DELETING DUPLICATE ROWS
WITH RowNumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
               ORDER BY UniqueID
           ) AS row_num
    FROM nashville_housing
)
DELETE FROM nashville_housing
WHERE UniqueID IN (
    SELECT UniqueID FROM RowNumCTE WHERE row_num > 1
);


-- DROPPING UNNECESSARY COLUMNS
ALTER TABLE nashville_housing
DROP COLUMN PropertyAddress;
ALTER TABLE nashville_housing
DROP COLUMN OwnerAddress;
ALTER TABLE nashville_housing
DROP COLUMN TaxDistrict;


-- Converting dates into simplified form
SELECT STR_TO_DATE('April 9, 2013', '%M %e, %Y') AS converted_date
FROM portfolioproject.nashville_housing;

-- Add a new column to store the simplified date
ALTER TABLE nashville_housing 
ADD COLUMN SimplifiedDate DATE;  -- Use DATE type instead of VARCHAR

-- Update the table to convert existing date values
UPDATE nashville_housing 
SET SimplifiedDate = STR_TO_DATE(SaleDate, '%M %e, %Y');
ALTER TABLE nashville_housing
DROP COLUMN SaleDate;


SELECT *
FROM nashville_housing







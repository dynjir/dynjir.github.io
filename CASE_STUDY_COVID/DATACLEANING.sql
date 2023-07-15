-- DATA CLEANING NASHVILLE HOUSING DATA PROJECT

-- PRE-STEPS EXECUTED IN EXCEL [JUST TO SHOW I KNOW HOW TO USE EXCEL TO DATA CLEAN AS WELL]
# 1.) STANDARDIZE DATE FORMAT.
-- (WHEN WORKING WITH ONLY A FEW FILES, IT'S MORE PRACTICAL TO DO THIS IN EXCEL THAN TRYING TO ALTER IT VIA MYSQL WORKBENCH SPECIFICALLY (UNLESS YOU ALREADY HAVE THE CODE ON-HAND).)
-- OPEN DATA IN EXCEL
-- HIGHLIGHT THE DATE COLUMN, RIGHT-CLICK, AND SELECT "FORMAT CELLS"
-- UNDER THE "DATE" CATEGORY, SELECT THE YYYY-MM-DD FORMAT SPECIFICALLY

# 2.) REPLACE BLANK CELLS WITH NULLS.
-- (WHEN WORKING WITH SMALL FILES, IT'S MORE PRACTICAL TO DO THIS IN EXCEL THAN TRYING TO ALTER IT VIA MYSQL WORKBENCH SINCE IT DOESN'T AUTO-CONVERT BLANK CELLS INTO NULL VALUES.)
-- OPEN DATA IN EXCEL
-- HOME TAB > FIND & SELECT > GO TO SPECIAL
-- SELECT "BLANKS" AND EXECUTE THE SPECIAL FIND FEATURE TO SELECT ALL BLANK CELLS
-- IN THE INPUT FIELD, ENTER "NULL" TO ASSIGN THE VALUE TO REPLACE THE BLANK CELLS
-- PRESS CTRL + ENTER TO FILL ALL SELECTED CELLS WITH THE "NULL" VALUE

# 3.) CHANGE PROPERTYADDRESS = "PROPERTYFULLADDRESS" AND OWNERADDRESS NAME TO "OWNERFULLADDRESS"
-- THIS IS BECAUSE WE WILL BE ALTERING THESE COLUMNS AND SPLITTING IT INTO 3 OTHER COLUMNS

-- IMPORTING THE DATA INTO MYSQL
LOAD DATA LOCAL INFILE 'C:/Users/XXX/Desktop/CASE_STUDY_COVID/NASHVILLE_HOUSING_DATA_PORTFOLIO.csv' IGNORE
INTO TABLE portfolio_covid.nashville_housing_data
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- CHECKING THE DATA
SELECT * FROM portfolio_covid.nashville_housing_data;

-- CORRECTING DATA TYPE
# 1.) SALEDATE => DATE TYPE
ALTER TABLE `portfolio_covid`.`nashville_housing_data` 
CHANGE COLUMN `saledate` `saledate` DATE NULL DEFAULT NULL ;

# 2.) POPULATE PROPERTY FULL ADDRESS' NULL VALUES
-- CONTEXT: PROPERTY ADDRESS TYPICALLY DOESN'T CHANGE. PARCEL ID CAN HELP US FIND A PAPER TRAIL OF WHAT THE ADDRESS WAS ON A PREVIOUS RECORD FOR THE SAME HOUSE.
-- THERE'S 29 RECORDS THAT'S MISSING AN ADDRESS.
SELECT *
FROM portfolio_covid.nashville_housing_data
WHERE propertyfulladdress IS NULL; 

-- THESE ARE THE PARCELIDS OF ALL THE MISSING ADDRESSES
SELECT DISTINCT(parcelid)
FROM portfolio_covid.nashville_housing_data
WHERE propertyfulladdress IS NULL; 

-- A SELF JOIN CAN BE USED TO POPULATE THESE BLANK ADDRESSES USING PARCELID
SELECT
	distinct(A.uniqueid),
	A.parcelid,
    A.propertyfulladdress,
    B.parcelid,
    B.propertyfulladdress
FROM portfolio_covid.nashville_housing_data AS A
LEFT JOIN portfolio_covid.nashville_housing_data AS B
	ON A.parcelid = B.parcelid
    AND A.uniqueid != B.uniqueid
WHERE A.propertyfulladdress IS NULL;

UPDATE portfolio_covid.nashville_housing_data AS A
LEFT JOIN portfolio_covid.nashville_housing_data AS B
	ON A.parcelid = B.parcelid
    AND A.uniqueid != B.uniqueid
SET A.propertyfulladdress = B.propertyfulladdress
WHERE A.propertyfulladdress IS NULL;

# CHECK DATA: THIS SHOULD NOW RETURN NO RECORDS
SELECT *
FROM portfolio_covid.nashville_housing_data
WHERE propertyfulladdress IS NULL; 

-- BREAKING ADDRESSES INTO MULTIPLE COLUMNS
# CREATE THE NEW COLUMNS
ALTER TABLE `portfolio_covid`.`nashville_housing_data`
ADD COLUMN `propertyaddress` VARCHAR(200) NULL AFTER `propertyfulladdress`,
ADD COLUMN `propertycity` VARCHAR(100) NULL AFTER `propertyaddress`,
ADD COLUMN `owneraddress` VARCHAR(200) NULL AFTER `owneraddress`,
ADD COLUMN `ownercity` VARCHAR(100) NULL AFTER `address`,
ADD COLUMN `ownerstate` VARCHAR(100) NULL AFTER `city`;

# POPULATE PROPERTY COLUMNS
SELECT
propertyfulladdress,
substring_index(propertyfulladdress, ", ",1) as propertyaddress,
substring_index(propertyfulladdress, ", ",-1) as propertycity
FROM portfolio_covid.nashville_housing_data;

update portfolio_covid.nashville_housing_data
set propertyaddress = substring_index(propertyfulladdress, ", ",1),
propertycity = substring_index(propertyfulladdress, ", ",-1);

# CHECK DATA
SELECT *
FROM portfolio_covid.nashville_housing_data;

# POPULATE OWNER COLUMNS
SELECT
owneraddress,
substring_index(owneraddress, ", ",1) as owneraddress,
substring_index(substring_index(owneraddress, ", ",2), ", ",-1) as ownercity,
substring_index(owneraddress, ", ",-1) as ownerstate
FROM portfolio_covid.nashville_housing_data;

update portfolio_covid.nashville_housing_data
set address = substring_index(owneraddress, ", ",1),
city = substring_index(substring_index(owneraddress, ", ",2), ", ",-1),
state = substring_index(owneraddress, ", ",-1);

# CHECK DATA
SELECT *
FROM portfolio_covid.nashville_housing_data;

-- CHANGE "Y" AND "N" VALUES IN "SOLD AS VACANT" FIELD"
SELECT
(CASE
    WHEN soldasvacant = "Y" THEN "Yes"
    WHEN soldasvacant = "N" THEN "No"
    ELSE soldasvacant
END) as soldasvacant2
FROM portfolio_covid.nashville_housing_data;

UPDATE portfolio_covid.nashville_housing_data
SET soldasvacant = (CASE
    WHEN soldasvacant = "Y" THEN "Yes"
    WHEN soldasvacant = "N" THEN "No"
    ELSE soldasvacant
	END);
    
# CHECK DATA
SELECT distinct(soldasvacant)
FROM portfolio_covid.nashville_housing_data;

-- REMOVE DUPLICATE RECORDS
# FIND THE DUPLICATES
SELECT parcelid,
	saledate,
    saleprice,
    legalreference,
    COUNT(*) as number_of_instances,
    min(uniqueid) as first_instance_id,
    max(uniqueid) AS second_instance_id
FROM nashville_housing_data
GROUP BY parcelid, saledate, saleprice, legalreference
HAVING COUNT(*) > 1;

# TURN IT INTO A VIEW SO THAT IT CAN BE USED AS A QUALITY CHECK AT ANY TIME (IF YOU DON'T WANT TO SAVE THE CODE IN A MYSQL FILE)
CREATE VIEW `vw_nashville_housing_duplicate_check` AS
SELECT parcelid,
	saledate,
    saleprice,
    legalreference,
    COUNT(*) as number_of_instances,
    min(uniqueid) as first_instance_id,
    max(uniqueid) AS second_instance_id
FROM nashville_housing_data
GROUP BY parcelid, saledate, saleprice, legalreference
HAVING COUNT(*) > 1;

SELECT * FROM portfolio_covid.vw_nashville_housing_duplicate_check;

# USE THE VIEW TO DELETE THE DUPLICATES
SELECT *
FROM portfolio_covid.nashville_housing_data as a
INNER JOIN portfolio_covid.vw_nashville_housing_duplicate_check as b
	ON second_instance_id = uniqueid;

delete a
FROM portfolio_covid.nashville_housing_data as a
INNER JOIN portfolio_covid.vw_nashville_housing_duplicate_check as b
	ON second_instance_id = uniqueid;
    
# CHECK DATA: SHOULD RETURN NO RECORDS
SELECT * FROM portfolio_covid.vw_nashville_housing_duplicate_check;

-- REMOVE UNUSED COLUMNS
# WE DON'T WANT THE FOLLOWING COLUMNS: TAXDISTRICT, OWNERFULLADDRESS, AND PROPERTYFULLADDRESS BECAUSE IT'S UNNECESSARY DATA AT THIS POINT.
ALTER TABLE `portfolio_covid`.`nashville_housing_data` 
DROP COLUMN `taxdistrict`,
DROP COLUMN `ownerfulladdress`,
DROP COLUMN `propertyfulladdress`;

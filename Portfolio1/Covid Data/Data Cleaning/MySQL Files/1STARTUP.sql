# INI FILE: CHANGING SECURE-FILE-PRIV VALUE TO MAKE LOAD DATA LOCAL INFILE WORK
# 1.) GO TO MYSQL'S COMMAND PROMPT AND CHECK THE LOCAL INFILE SETTING:
-- Open MYSQL Command Line
-- Type in your password
-- Enter the following:
-- SHOW GLOBAL VARIABLES LIKE 'local_infile';
-- If local_infile value is equal to false set it to true by:
-- SET GLOBAL local_infile = true;

# 2.) USE IMPORT WIZARD TO CREATE THE TABLES WITH ITS HEADERS + FIX THE FIRST WEIRD HEADER
ALTER TABLE `portfolio_covid`.`covid_deaths` 
CHANGE COLUMN `ï»¿iso_code` `iso_code` TEXT NULL DEFAULT NULL ;

TRUNCATE TABLE `portfolio_covid`.`covid_deaths`;

ALTER TABLE `portfolio_covid`.`covid_vaccs` 
CHANGE COLUMN `ï»¿iso_code` `iso_code` TEXT NULL DEFAULT NULL ;

TRUNCATE TABLE `portfolio_covid`.`covid_vaccs`;

# 3.) LOAD THE FILES USING INLINE
-- NOTE: MYSQL WORKBENCH DOESN'T LIKE "/" FOR FILE PATHS... IT LIKES "/" BETTER
LOAD DATA LOCAL INFILE 'C:/Users/dynam/OneDrive/Documents/COVID_DEATHS.csv' IGNORE
INTO TABLE portfolio_covid.covid_deaths
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;
 
LOAD DATA LOCAL INFILE 'C:/Users/dynam/OneDrive/Documents/COVID_VACCS.csv' IGNORE
INTO TABLE portfolio_covid.covid_vaccs
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

# 4.) IF IT GIVES YOU ERROR 2068
-- GO EDIT THE CONNECTION
-- UNDER THE ADVANCED OPTION, FIND THE 'OTHERS' BOX AND ADD THIS LINE OF CODE AT THE END AND UPDATE IT:
-- OPT_LOCAL_INFILE=1
-- RESTART CONNECTION
-- TRY STEP 3 AGAIN

# .) ADD INDEXES TO TABLES
ALTER TABLE `portfolio_covid`.`covid_deaths` 
ADD COLUMN `index` INT NOT NULL FIRST,
ADD PRIMARY KEY (`index`);

ALTER TABLE `portfolio_covid`.`covid_vaccs` 
ADD COLUMN `index` INT NOT NULL FIRST,
ADD PRIMARY KEY (`index`);

# OPTIONAL: IF YOU HAVE THE INI FILE ERROR, TRY THESE STEPS
C:/ProgramData/MySQL/MySQL Server 8.0 -- INI FILE DIRECTORY
C:/ProgramData/MySQL/MySQL Server 8.0/my.ini -- INI FILE
 
# STEP 1: SEARCH SERVICES.MSC IN THE START MENU AND RUN THE SERVICES APP
# STEP 2: FIND MYSQL, RIGHT CLICK IT, AND LOOK AT ITS PROPERTIES
# STEP 3: UNDER "PATH TO EXECUTABLES", LOOK FOR THE DIRECTORY THAT INCLUDES THE INI FILE AND COPY THE PATH
# STEP 4: OPEN FOLDER DIRECTORY AND PASTE PATH WITHOUT THE FILE NAME IN ADDRESS BAR
# STEP 5: RIGHT CLICK THE INI FILE AND GO TO PROPERTIES > SECURITY > YOUR USERNAME > UNDER "PERMISSIONS", SELECT FULL CONTROL TO BE ABLE TO EDIT IT
# STEP 6: OPEN THE FILE AND FIND "SECURE-FILE-PRIV" SECTION
# STEP 7: CHANGE VALUE TO "" AND OVERWRITE SAVE ON THE FILE
# IN SERVICES APP, RIGHT CLICK MYSQL AND RESTART IT
# MAKE SURE TO RESTART ALL COMMAND PROMPTS AND MYSQL WORKBENCH ONCE YOU RESTART IT IN SERVICES
# SECURE-FILE-PRIV'S PARAMS SHOULD NOW REFLECT THE CHANGES
 
-- LOAD DATA LOCAL INFILE ISSUES:
-- ERROR 29: Permission denied. YOU'RE MISSING THE "LOCAL" PART IN THE CODE.
-- ERROR 3948: Loading-local-data-is-disabled. YOU MUST ENABLE IT VIA THE MYSQL COMMAND LINE (FOUND WHEN SEARCHED IN START MENU).
-- -- USE "SHOW GLOBAL VARIABLES LIKE 'local_infile';" TO VIEW THE VARIABLE VALUE
-- -- USE "SET GLOBAL local_infile = true;" TO ENABLE IT.
-- ERROR 2068: file-requested-rejected-due-to-restrictions-on-access-with-root. THE CONNECTION NEEDS A PARAMETER THAT OPTS LOCAL INFILES.
-- -- GO BACK TO HOME > SERVER > EDIT CONNECTIONS > CONNECTIONS TAB > ADVANCED TAB: ADD "OPT_LOCAL_INFILE=1"
-- ERROR 2: File not found. THE FILE EITHER DOESN'T EXIST WHERE THOUGHT IT'D BE OR MYSQL'S BEING DUMB AND WANTS YOU TO USE "/" INSTEAD OF "/".
-- -- IT'S FUCKING WEIRD, WHEN YOU RUN THE CODE, MYSQL CLEARLY CHANGES THE "/" BACK INTO "/"S BUT WHATEVER, THIS WORKS SO JUST DO THIS.
 
mysql -u root -p
password = blank
 
SELECT @@secure_file_priv
 
SET @@secure_file_priv = "";

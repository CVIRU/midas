# Project: Source code for MIDAS data export from SAS and conversion to R data     
# Author: Davit Sargsyan   
# Created:  07/08/2017
#**********************************************************
require(data.table)

# Read MIDAS15 from CSV----
# The CSV was created on 03/25/2017 with 'export_midas.sas' 
# and 'MIDAS format.sas' files
midas15 <- fread("C:/MIDAS/midas_1986_2015.csv")

# Remove unused variables----
midas15[, LOCATION := NULL]
midas15[, DeathRNUM := NULL]
midas15[, STATUS := NULL]
midas15[, SOURCE := NULL]
midas15[, DRG := NULL]
midas15[, RECDID := NULL]
midas15[, DSHYR := NULL]
midas15[, PRDTE1 := NULL]
midas15[, PRDTE2 := NULL]
midas15[, PRDTE3 := NULL]
midas15[, PRDTE4 := NULL]
midas15[, PRDTE5 := NULL]
midas15[, PRDTE6 := NULL]
midas15[, PRDTE7 := NULL]
midas15[, PRDTE8 := NULL]
midas15[, SECOND := NULL]
midas15[, THIRD := NULL]
gc()

# Sort and remove dulicates
setkey(midas15, Patient_ID, ADMDAT)
midas15 <- unique(midas15)
midas15
gc()

# Read Patient Type from CSV----
# The CSV was created on 07/08/2017 with 'get_pat_type.sas' file
midas15_pat_type <- fread("C:/MIDAS/midas_pat_type_2008_2015.csv")
setkey(midas15_pat_type, Patient_ID, ADMDAT)

# For now, remove HOSP as the numbers are incompatable
# Ask Jerry for HOSP and DIV in 2008 to 2015 data (07/08/02017)
unique(midas15_pat_type$HOSP)
midas15_pat_type[, HOSP := NULL]

# Remove duplicates
midas15_pat_type <- unique(midas15_pat_type)
# 31,801 records removed
midas15_pat_type
gc()

# Merge patient type with the main MIDAS data table
midas15 <- merge(midas15_pat_type,
                 midas15,
                 by = c("Patient_ID",
                        "ADMDAT"),
                 all.y = TRUE,
                 sort = TRUE)
rm(midas15_pat_type)
gc()
midas15

# Number of patients----
length(unique(midas15$Patient_ID))
# 4,842,160

# Convert dates----
midas15[, NEWDTD := as.Date(NEWDTD, format = "%m/%d/%Y")]
midas15[, ADMDAT := as.Date(ADMDAT, format = "%m/%d/%Y")]
midas15[, DSCHDAT := as.Date(DSCHDAT, format = "%m/%d/%Y")]
midas15[, patbdte := as.Date(patbdte, format = "%m/%d/%Y")]

# Missing birthdays
midas15[is.na(midas15$patbdte)]
# All records for these patients
midas15[Patient_ID %in% Patient_ID[is.na(patbdte)]]
# There are 8 patients with missing birthday records; REMOVE THEM
midas15$Patient_ID[is.na(midas15$patbdte)]
midas15 <- subset(midas15, 
                  !(Patient_ID %in% Patient_ID[is.na(patbdte)]))
summary(midas15$patbdte)

# Remove records with discarge date before admission
midas15[which(midas15$ADMDAT > midas15$DSCHDAT), ]
midas15 <- subset(midas15, ADMDAT <= DSCHDAT)
range(midas15$ADMDAT)
# 1985-03-20 to 2015-12-31
range(midas15$DSCHDAT)
# 1985-07-03 to 2016-02-09

# Age at admission
midas15[, AGE := floor(as.numeric(difftime(ADMDAT, 
                                           patbdte,
                                           units = "days"))/365.25)]
# Remove anybody who was younger than 18 at any admisson
id.rm <- midas15$Patient_ID[midas15$AGE < 18]
midas15 <- subset(midas15, !(Patient_ID %in% id.rm))
hist(midas15$AGE, 100)
gc()

# Number of hospitals----
unique(midas15$HOSP)
length(unique(midas15$HOSP))
sum(is.na(midas15$HOSP))
# 94 + 1(#2000, error code?)

# Sex----
midas15[, SEX := factor(SEX, levels = c("F", "M"))]

# Race----
table(midas15$RACE)
midas15$RACE1 <- "Other"
midas15$RACE1[midas15$RACE == 1] <- "White"
midas15$RACE1[midas15$RACE == 2] <- "Black"
midas15[, RACE1 := factor(RACE1,
                          levels = c("White",
                                     "Black",
                                     "Other"))]
table(midas15$RACE1)
midas15[, RACE := NULL]
names(midas15)[ncol(midas15)] <- "RACE"
gc()

# Primary insurance----
midas15$PRIME[(midas15$PRIME %in% c("BLUE CROSS PLANS",
                                    "HMO"))] <- "COMMERCIAL"

midas15$PRIME[!(midas15$PRIME %in% c("medicare",
                                     "COMMERCIAL"))] <- "medicaid/self-pay/other"
midas15$PRIME <- factor(midas15$PRIME,
                        levels = c("medicare",
                                   "COMMERCIAL",
                                   "medicaid/self-pay/other"))
round(100*addmargins(table(midas15$PRIME)/nrow(midas15)), 1)
# |---------------------------------------------------------|
# | medicare | COMMERCIAL | medicaid/self-pay/other | Sum   | 
# |---------------------------------------------------------|
# | 51.7     | 38.2       | 10.1                    | 100.0 |
# |---------------------------------------------------------|
gc()

# Hispanic----
midas15$HISP <- "Hispanic"
midas15$HISP[midas15$HISPAN %in% c(".", "9", "A")] <- "Unknown"
midas15$HISP[midas15$HISPAN == "0"] <- "Non-hispanic"
midas15$HISP <- factor(midas15$HISP,
                       levels = c("Hispanic",
                                  "Non-hispanic",
                                  "Unknown"))
midas15[, HISPAN := NULL]
names(midas15)[ncol(midas15)] <- "HISPAN"
table(midas15$HISPAN)
# |--------------------------------------|
# | Hispanic  | Non-hispanic | Unknown   |
# |--------------------------------------|
# | 2,174,098 | 15,139,071   | 1,762,756 |
# |--------------------------------------|
gc()

# Convert patient type to factor----
midas15$PAT_TYPE[is.na(midas15$PAT_TYPE)] <- -1
midas15$PAT_TYPE <- factor(as.character(midas15$PAT_TYPE),
                           levels = c("-1",
                                      "0",
                                      "1",
                                      "2",
                                      "3"))
table(midas15$PAT_TYPE)
# |-------------------------------------------------------|
# | -1        | 0         | 1       | 2         | 3       |
# |-------------------------------------------------------|
# | 8,969,342 | 4,622,957 | 787,577 | 4,010,435 | 685,614 |
# |-------------------------------------------------------|

summary(midas15)
gc()

# Sort----
setkey(midas15,
       Patient_ID,
       ADMDAT)

# Save as R data----
save(midas15,
     file = "C:/MIDAS/midas15.RData",
     compress = FALSE)
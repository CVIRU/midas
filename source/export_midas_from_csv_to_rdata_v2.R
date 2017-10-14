# Project: Source code for MIDAS data export from SAS and conversion to R data     
# Author: Davit Sargsyan   
# Created:  07/08/2017
#**********************************************************
require(data.table)
require(knitr)
require(ggplot2)

# Read MIDAS15 from CSV----
# The CSV was created on 03/25/2017 with 'export_midas.sas' 
# and 'MIDAS format.sas' files
# midas15 <- fread("C:/MIDAS/midas_1986_2015.csv")
midas15 <- fread("C:/MIDAS/midas_2015_race_corrected.csv")

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
setkey(midas15_pat_type,
       Patient_ID,
       ADMDAT)

# For now, remove HOSP as the numbers are incompatable
# Ask Jerry for HOSP and DIV in 2008 to 2015 data (07/08/02017)
# midas15_pat_type[, HOSP := NULL]
# NOTE: Used Jerry's code below (from Jerry's email, 07/14/2017)
unique(midas15_pat_type$HOSP)
midas15_pat_type$HOSP <- as.numeric(substr(x = midas15_pat_type$HOSP,
                                           start = 4,
                                           stop = 6))
unique(midas15_pat_type$HOSP)

# Remove duplicates
midas15_pat_type <- unique(midas15_pat_type)
# 19,123 records removed
midas15_pat_type
gc()

# Merge patient type with the main MIDAS data table
midas15 <- merge(midas15_pat_type,
                 midas15,
                 by = c("Patient_ID",
                        "ADMDAT",
                        "HOSP"),
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

# Admission year----
midas15$YEAR <- as.numeric(substr(midas15$ADMDAT,
                                  1, 
                                  4))
table(midas15$YEAR)
gc()

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
subset(midas15,
       HOSP == 2000)
# 94 + 1(#2000, error code? 2,543 records) + NA

# Sex----
midas15[, SEX := factor(SEX, levels = c("F", "M"))]
kable(x = data.table(100*prop.table(table(Sex = midas15$SEX))),
      digits = 1)
  # |Sex |    N|
  # |:---|----:|
  # |F   | 53.3|
  # |M   | 46.7|

# Race----
table(midas15$RACE_RECODE)
midas15$RACE1 <- "Other"
midas15$RACE1[midas15$RACE_RECODE == 1] <- "White"
midas15$RACE1[midas15$RACE_RECODE == 2] <- "Black"
midas15[, RACE1 := factor(RACE1,
                          levels = c("White",
                                     "Black",
                                     "Other"))]
midas15[, RACE_DNTUSE := NULL]
midas15[, RACE_RAW := NULL]
midas15[, RACE_RECODE := NULL]
names(midas15)[ncol(midas15)] <- "RACE"
table(midas15$RACE)
kable(x = data.table(100*prop.table(table(Race = midas15$RACE))),
      digits = 1)
  # |Race  |    N|
  # |:-----|----:|
  # |White | 72.9|
  # |Black | 16.7|
  # |Other | 10.4|
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
kable(x = data.table(100*prop.table(table(Insurance = midas15$PRIME))),
      digits = 1)
  # |Insurance               |    N|
  # |:-----------------------|----:|
  # |medicare                | 51.7|
  # |COMMERCIAL              | 38.2|
  # |medicaid/self-pay/other | 10.1|
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
kable(x = data.table(100*prop.table(table(Ethnicity = midas15$HISPAN))),
      digits = 1)
  # |Ethnicity    |    N|
  # |:------------|----:|
  # |Hispanic     | 11.4|
  # |Non-hispanic | 79.3|
  # |Unknown      |  9.2|
gc()

# Convert patient type to factor----
# -1 = Inpatinet Before 2008
# 0 = Inpatient
# 1 = Same Day Surgery
# 2 = Emergency/Other Outpatient
# 3 = Outpatient
midas15$PAT_TYPE[is.na(midas15$PAT_TYPE) &
                   midas15$YEAR < 2008] <- -1
midas15$PAT_TYPE <- factor(as.character(midas15$PAT_TYPE),
                           levels = c("-1",
                                      "0",
                                      "1",
                                      "2",
                                      "3"),
                           labels = c("Inpatinet Before 2008",
                                      "Inpatient",
                                      "Same Day Surgery",
                                      "Emergency/Other Outpatient",
                                      "Outpatient"))
kable(x = data.table(100*prop.table(table(PAT_TYPE = midas15$PAT_TYPE))),
      digits = 1)
  # |PAT_TYPE                   |    N|
  # |:--------------------------|----:|
  # |Inpatient Before 2008      | 47.2|
  # |Inpatient                  | 24.2|
  # |Same Day Surgery           |  4.1|
  # |Emergency/Other Outpatient | 20.9|
  # |Outpatient                 |  3.6|

summary(midas15)
gc()

# Sort----
setkey(midas15,
       Patient_ID,
       ADMDAT)
midas15

# Save as R data----
save(midas15,
     file = "C:/MIDAS/midas15_race_corrected.RData",
     compress = FALSE)
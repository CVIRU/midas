# |------------------------------------------------------------------------------|
# | Project: MIDAS dataset exploration                                           |
# | Script: Source code for MIDAS data export from CSV and conversion to R data  |     
# | Author: Davit Sargsyan                                                       | 
# | Created:  07/08/2017                                                         |
# | Modified: 02/05/2018                                                         |
# | Modified: 03/02/2018: read all columns as character to avoid issues in PROCs |
# | Modified: 03/16/2018: remove data prior to 1995                              |
# |------------------------------------------------------------------------------|
# Header----
# Save consol output to a log file
sink(file = "tmp/log_export_midas_from_csv_to_rdata_v4.txt")
date()

# Load packages
require(data.table)
require(knitr)
require(ggplot2)

# Read MIDAS15 from CSV----
# The CSV was created on 03/25/2017 with 'export_midas.sas' 
# and 'MIDAS format.sas' files
# midas15 <- fread("C:/MIDAS/midas_1986_2015.csv")
# midas15 <- fread("E:/MIDAS/midas_2015_race_corrected.csv")
midas15 <- fread("E:/MIDAS/MIDAS_CLEAN.csv",
                 colClasses = c("character"))
summary(midas15)

# Remove unused variables----
# 1. Place of death
unique(midas15$LOCATION)
# "" = ?
# 1 = inpatient
# 2 = outpatient/ER
# 3 = DOA
# 4 = ?
# 5 = nursing home
# 6 = residence
# 7 = other
# 8 = ?
# 9 = not stated
midas15[, LOCATION := NULL]

# Death record number
midas15[, DeathRNUM := NULL] 

# Discharge (Patient) Status Code
unique(midas15$STATUS)
# Keep this variable, get full legend
# Around 45 codes between 1 and 95)
# E.g. 07 = Left against medical advice
# midas15[, STATUS := NULL]

# How a patient was referred to the hospital?
unique(midas15$SOURCE)
# For non-newborns:
# 1 = Physician Referral
# 2 = Outpatient or Clinic
# 3 = HMO
# 4 = Transfer from Hospital "Different from Facility"
# 5 = Transfer from SNF
# 6 = Transfer from another Health Care Facility
# 7 = Emergency Room
# 8 = Court/Law Enforcement
# 9 = Information Not Available
# A = Transfer from a Rural Primary Care Facility
# D = Transfer From Inpatient Hospital in Same Facility
#     Resulting in Separate Claim to Payer (Effective for inpatient)
midas15[, SOURCE := NULL] 

# Indication of how patient has been grouped by
# QuadraMed into the NJDHSS-specified groupers (AP 8 and 21).
length(unique(midas15$DRG))
# 954 codes, see "E:\MIDAS\Documents\DRGDES21.txt" for the legend.
midas15[, DRG := NULL]

# MIDAS record ID
midas15[, RECDID := NULL] 

# Duplicate discharge year
midas15[, DSHYR := NULL]

# Procedure dates
midas15[, PRDTE1 := NULL]
midas15[, PRDTE2 := NULL]
midas15[, PRDTE3 := NULL]
midas15[, PRDTE4 := NULL]
midas15[, PRDTE5 := NULL]
midas15[, PRDTE6 := NULL]
midas15[, PRDTE7 := NULL]
midas15[, PRDTE8 := NULL]

# Secondary and tertiary insurance
midas15[, SECOND := NULL]
midas15[, THIRD := NULL]

# Old Race variables
midas15[, RACE_RAW := NULL]
midas15[, RACE_DNTUSE := NULL]
gc()

# Rename columns to match previous code----
colnames(midas15)[1] <- "Patient_ID"
colnames(midas15)[2] <- "patbdte"
colnames(midas15)[34] <- "YEAR"

# Sort and remove dulicates
setkey(midas15, 
       Patient_ID,
       ADMDAT)
midas15 <- unique(midas15)
midas15
gc()

# Number of patients----
length(unique(midas15$Patient_ID))
# 4,842,159; previously 4,842,160

# Convert dates----
midas15[, NEWDTD := as.Date(NEWDTD, format = "%m/%d/%Y")]
midas15[, ADMDAT := as.Date(ADMDAT, format = "%m/%d/%Y")]
midas15[, DSCHDAT := as.Date(DSCHDAT, format = "%m/%d/%Y")]
midas15[, patbdte := as.Date(patbdte, format = "%m/%d/%Y")]

# Remove records prior to 1995----
midas15 <- subset(midas15, 
                  ADMDAT >= "1995-01-01")

# Birthdays----
# Missing
midas15[is.na(midas15$patbdte)]
# All records for these patients
midas15[Patient_ID %in% Patient_ID[is.na(patbdte)]]
# There is 1 patient with missing birthday records; REMOVE HIM
midas15$Patient_ID[is.na(midas15$patbdte)]
midas15 <- subset(midas15, 
                  !(Patient_ID %in% Patient_ID[is.na(patbdte)]))
range(midas15$patbdte)
# "1880-01-01" "2015-12-30"

# Check birthdays; all records of a patient should be consistent
midas15[, check := (patbdte[1] != patbdte), 
        by = Patient_ID]

# Are there any NAs?
sum(is.na(midas15$check))
# None

# Are there any discrepancies?
sum(midas15$check)
# None

# Remove records with discarge date before admission----
midas15[which(midas15$ADMDAT > midas15$DSCHDAT), ]
# 7,418 records removed
midas15 <- subset(midas15, 
                  ADMDAT <= DSCHDAT)
range(midas15$ADMDAT)
# "1995-01-01" "2015-12-31"
range(midas15$DSCHDAT)
# "1995-01-01" "2016-02-09"

# Age at admission----
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
# Previously: 94 + 1(#2000, error code? 2,543 records) + NA(449,563 records)
# Now (03/16/2018): 115 hospitals, including "00" and "2E3" ("23"?)

# Sex----
midas15[, SEX := factor(SEX, levels = c("F", "M"))]
# Check gender; all records of a patient should be consistent
midas15[, check := (SEX[1] != SEX), 
        by = Patient_ID]
# Are there any NAs?
sum(is.na(midas15$check))
# None

# Are there any discrepancies?
sum(midas15$check)
# 0 discrepancies, down from 93,791 discrepancies in the previous version

kable(x = data.table(100*prop.table(table(Sex = midas15$SEX))),
      digits = 1)
  # |Sex |    N|
  # |:---|----:|
  # |F   | 53.7|
  # |M   | 46.3|

# Race----
table(midas15$RACE_RECODE)
midas15$RACE <- "Other"
midas15$RACE[midas15$RACE_RECODE == 1] <- "White"
midas15$RACE[midas15$RACE_RECODE == 2] <- "Black"
midas15[, RACE := factor(RACE,
                         levels = c("White",
                                    "Black",
                                    "Other"))]
# Discrepancies
midas15[, check := (RACE[1] != RACE), 
        by = Patient_ID]
# Are there any NAs?
sum(is.na(midas15$check))
# None

# Are there any discrepancies?
sum(midas15$check)
# None, down from 1,149,416 

kable(x = data.table(100*prop.table(table(Race = midas15$RACE))),
      digits = 1)
  # |Race  |    N|
  # |:-----|----:|
  # |White | 72.5|
  # |Black | 17.0|
  # |Other | 10.5|
midas15[, RACE_RECODE := NULL]
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
  # |medicare                | 52.6|
  # |COMMERCIAL              | 39.5|
  # |medicaid/self-pay/other |  7.9|
gc()

# Hispanic----
kable(format(data.frame(addmargins(table(midas15$HISPAN))), 
             big.mark = ","))
  # |Var1 |Freq       |Legend                                           |
  # |:----|:----------|:------------------------------------------------|
  # |.    |27         |?                                                |
  # |0    |14,682,079 |Non-Hispanic                                     |
  # |1    |132,127    |Mexican                                          |
  # |2    |574,538    |Puerto Rican                                     |
  # |3    |142,660    |Cuban                                            |
  # |4    |368,351    |Central or South American                        |
  # |5    |479,854    |Other Hispanic                                   |
  # |6    |357        |?                                                |
  # |7    |91         |?                                                |
  # |8    |406        |?                                                |
  # |9    |1,675,806  |Unknown                                          |
  # |A    |732        |?                                                |
  # |Sum  |18,057,028 |                                                 |
t1 <- addmargins(table(midas15$HISPAN,
                       midas15$YEAR))
kable(format(t(t1), 
             big.mark = ","))
  # |     |.  |0          |1       |2       |3       |4       |5       |6   |7  |8   |9         |A   |Sum        |
  # |:----|:--|:----------|:-------|:-------|:-------|:-------|:-------|:---|:--|:---|:---------|:---|:----------|
  # |1995 |0  |380,065    |2,199   |11,224  |3,493   |3,400   |2,551   |0   |0  |0   |93,514    |0   |496,446    |
  # |1996 |9  |399,526    |1,987   |13,704  |3,930   |3,795   |3,554   |0   |0  |0   |96,907    |0   |523,412    |
  # |1997 |0  |431,742    |1,624   |16,741  |4,292   |5,227   |5,744   |0   |0  |0   |77,613    |0   |542,983    |
  # |1998 |0  |465,007    |1,477   |12,577  |4,500   |5,826   |6,335   |0   |0  |0   |68,162    |0   |563,884    |
  # |1999 |0  |470,753    |4,126   |13,106  |4,990   |7,225   |7,771   |0   |0  |0   |65,413    |0   |573,384    |
  # |2000 |0  |490,514    |7,190   |14,018  |5,508   |8,126   |9,505   |0   |0  |0   |62,680    |0   |597,541    |
  # |2001 |3  |446,689    |15,117  |19,837  |5,391   |8,689   |15,529  |5   |0  |2   |95,095    |0   |606,357    |
  # |2002 |4  |447,758    |11,702  |23,124  |5,374   |10,862  |18,536  |185 |91 |68  |120,463   |0   |638,167    |
  # |2003 |8  |485,223    |4,846   |24,267  |6,049   |11,476  |17,598  |99  |0  |99  |122,277   |0   |671,942    |
  # |2004 |3  |522,063    |4,520   |26,435  |6,859   |12,318  |18,158  |68  |0  |237 |100,114   |0   |690,775    |
  # |2005 |0  |567,396    |5,654   |23,399  |6,636   |11,885  |17,648  |0   |0  |0   |72,412    |0   |705,030    |
  # |2006 |0  |613,399    |6,211   |21,471  |6,667   |12,019  |19,743  |0   |0  |0   |34,987    |1   |714,498    |
  # |2007 |0  |619,386    |7,043   |21,639  |6,351   |11,722  |19,712  |0   |0  |0   |31,407    |731 |717,991    |
  # |2008 |0  |945,208    |6,299   |33,451  |9,207   |23,602  |30,641  |0   |0  |0   |82,526    |0   |1,130,934  |
  # |2009 |0  |1,040,875  |7,073   |38,732  |9,331   |28,299  |32,568  |0   |0  |0   |41,370    |0   |1,198,248  |
  # |2010 |0  |1,080,213  |7,557   |42,669  |9,469   |31,615  |34,929  |0   |0  |0   |35,182    |0   |1,241,634  |
  # |2011 |0  |1,066,677  |6,845   |41,839  |8,828   |31,409  |38,190  |0   |0  |0   |42,829    |0   |1,236,617  |
  # |2012 |0  |1,017,669  |7,248   |43,889  |9,133   |33,437  |40,588  |0   |0  |0   |131,851   |0   |1,283,815  |
  # |2013 |0  |1,018,516  |7,606   |42,878  |8,921   |33,728  |42,459  |0   |0  |0   |121,431   |0   |1,275,539  |
  # |2014 |0  |1,062,965  |7,568   |43,321  |8,777   |35,994  |45,687  |0   |0  |0   |94,082    |0   |1,298,394  |
  # |2015 |0  |1,110,435  |8,235   |46,217  |8,954   |37,697  |52,408  |0   |0  |0   |85,491    |0   |1,349,437  |
  # |Sum  |27 |14,682,079 |132,127 |574,538 |142,660 |368,351 |479,854 |357 |91 |406 |1,675,806 |732 |18,057,028 |
# NOTE: no information prior to 1994

midas15$HISP <- "Hispanic"
midas15$HISP[midas15$HISPAN %in% c("", ".", "6", "7", "8", "9", "A")] <- "Unknown"
midas15$HISP[midas15$HISPAN == "0"] <- "Non-Hispanic"
midas15$HISP <- factor(midas15$HISP,
                       levels = c("Hispanic",
                                  "Non-Hispanic",
                                  "Unknown"))
midas15[, HISPAN := NULL]
names(midas15)[ncol(midas15)] <- "HISPAN"
kable(x = data.table(100*prop.table(table(Ethnicity = midas15$HISPAN))),
      digits = 1)
  # |Ethnicity    |    N|
  # |:------------|----:|
  # |Hispanic     |  9.4|
  # |Non-Hispanic | 81.3|
  # |Unknown      |  9.3|
gc()

# Admission type----
unique(midas15$ADM_TYPE)
sum(is.na(midas15$ADM_TYPE))
# None, down from 449,562

# 1 = inpatient
# 2 = ER outpatient
# 3 = same day surgery (SDS) outpatient
# 4 = other outpatient (non-ER and non-SDS)
# 5 = non-ER outpatient (3 or 4)

t2 <- table(midas15$YEAR,
            as.character(midas15$ADM_TYPE))
kable(format(t2, 
             big.mark = ","))
  # |     |1       |2       |3       |4      |5       |
  # |:----|:-------|:-------|:-------|:------|:-------|
  # |1995 |445,427 |0       |0       |0      |51,019  |
  # |1996 |462,937 |0       |0       |0      |60,475  |
  # |1997 |469,139 |0       |0       |0      |73,844  |
  # |1998 |480,809 |0       |0       |0      |83,075  |
  # |1999 |487,342 |0       |0       |0      |86,042  |
  # |2000 |506,849 |0       |0       |0      |90,692  |
  # |2001 |512,121 |0       |0       |0      |94,236  |
  # |2002 |538,553 |0       |0       |0      |99,614  |
  # |2003 |567,841 |0       |0       |0      |104,101 |
  # |2004 |565,937 |0       |0       |0      |124,838 |
  # |2005 |577,161 |0       |0       |0      |127,869 |
  # |2006 |588,474 |0       |0       |0      |126,024 |
  # |2007 |588,841 |71      |0       |7      |129,072 |
  # |2008 |605,433 |367,436 |78,367  |79,698 |0       |
  # |2009 |605,830 |418,646 |95,288  |78,484 |0       |
  # |2010 |599,233 |456,183 |102,948 |83,270 |0       |
  # |2011 |574,068 |478,511 |105,419 |78,619 |0       |
  # |2012 |568,398 |532,918 |98,152  |84,347 |0       |
  # |2013 |550,449 |540,387 |97,425  |87,278 |0       |
  # |2014 |541,051 |562,339 |102,041 |92,963 |0       |
  # |2015 |530,759 |614,445 |106,091 |98,142 |0       |

kable(x = data.table(100*prop.table(table(ADM_TYPE = midas15$ADM_TYPE))),
      digits = 1)
  # |ADM_TYPE |    N|
  # |:--------|----:|
  # |1        | 62.9|
  # |2        | 22.0|
  # |3        |  4.4|
  # |4        |  3.8|
  # |5        |  6.9|

summary(midas15)
gc()

# Sort----
setkey(midas15,
       Patient_ID,
       ADMDAT)
midas15

# Save as R data----
save(midas15,
     file = "E:/MIDAS/midas15_clean.RData",
     compress = FALSE)

sink()
beepr::beep(3)
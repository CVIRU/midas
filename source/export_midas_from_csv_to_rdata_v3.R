# |------------------------------------------------------------------------------|
# | Project: Source code for MIDAS data export from CSV and conversion to R data |     
# | Author: Davit Sargsyan                                                       | 
# | Created:  07/08/2017                                                         |
# | Modified: 01/17/2018                                                         |
# |------------------------------------------------------------------------------|
# Header----
# Save consol output to a log file
sink(file = "tmp/log_export_midas_from_csv_to_rdata_v3.txt")

# Load packages
require(data.table)
require(knitr)
require(ggplot2)

# Read MIDAS15 from CSV----
# The CSV was created on 03/25/2017 with 'export_midas.sas' 
# and 'MIDAS format.sas' files
# midas15 <- fread("C:/MIDAS/midas_1986_2015.csv")
# midas15 <- fread("E:/MIDAS/midas_2015_race_corrected.csv")
midas15 <- fread("E:/MIDAS/MIDAS_CLEAN.csv")

# Remove unused variables----
# 1. Place of death
unique(midas15$LOCATION)
# 1 = inpatient
# 2 = outpatient/ER
# 3 = DOA
# 5 = nursing home
# 6 = residence
# 7 = other
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

# Birthdays----
# Missing
midas15[is.na(midas15$patbdte)]
# All records for these patients
midas15[Patient_ID %in% Patient_ID[is.na(patbdte)]]
# There are 8 patients with missing birthday records; REMOVE THEM
midas15$Patient_ID[is.na(midas15$patbdte)]
midas15 <- subset(midas15, 
                  !(Patient_ID %in% Patient_ID[is.na(patbdte)]))
range(midas15$patbdte)
# "1877-11-26" "2015-12-30"

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
# 7,526 records removed
midas15 <- subset(midas15, 
                  ADMDAT <= DSCHDAT)
range(midas15$ADMDAT)
# "1985-03-20" "2015-12-31"
range(midas15$DSCHDAT)
# "1985-07-03" "2016-02-09"

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
sum(is.na(midas15$HOSP))
subset(midas15,
       HOSP == 2000)
# 94 + 1(#2000, error code? 2,543 records) + NA(449,563 records)

# Sex----
midas15[, SEX := factor(SEX, levels = c("F", "M"))]
# Check gender; all records of a patient should be consistent
midas15[, check := (SEX[1] != SEX), 
        by = Patient_ID]
# Are there any NAs?
sum(is.na(midas15$check))
# There is 1. Remove
id.rm <- midas15$Patient_ID[is.na(midas15$check)]
id.rm
midas15 <- droplevels(subset(midas15,
                             !(Patient_ID %in% id.rm)))
# Are there any discrepancies?
sum(midas15$check)
# 0 discrepancies, down from 93,791 discrepancies in the previous version

kable(x = data.table(100*prop.table(table(Sex = midas15$SEX))),
      digits = 1)
  # |Sex |    N|
  # |:---|----:|
  # |F   | 53.3|
  # |M   | 46.7|

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
  # |White | 73.0|
  # |Black | 16.7|
  # |Other | 10.4|
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
  # |medicare                | 51.7|
  # |COMMERCIAL              | 38.2|
  # |medicaid/self-pay/other | 10.1|
gc()

# Hispanic----
kable(format(data.frame(addmargins(table(midas15$HISPAN))), 
             big.mark = ","))
  # |Var1 |Freq       |Legend                                           |
  # |:----|:----------|:------------------------------------------------|
  # |     |449,562    |Unknown, prior to 1994 (see the big table below) |
  # |.    |27         |?                                                |
  # |0    |15,064,711 |Non-Hispanic                                     |
  # |1    |135,323    |Mexican                                          |
  # |2    |582,263    |Puerto Rican                                     |
  # |3    |146,215    |Cuban                                            |
  # |4    |371,395    |Central or South American                        |
  # |5    |482,688    |Other Hispanic                                   |
  # |6    |357        |?                                                |
  # |7    |91         |?                                                |
  # |8    |406        |?                                                |
  # |9    |1,756,678  |Unknown                                          |
  # |A    |732        |?                                                |
  # |Sum  |18,990,448 |                                                 |
t1 <- addmargins(table(midas15$HISPAN,
                       midas15$YEAR))
kable(format(t(t1), 
             big.mark = ","))

  # |     |        |.  |0          |1       |2       |3       |4       |5       |6   |7  |8   |9         |A   |Sum        |
  # |:----|:-------|:--|:----------|:-------|:-------|:-------|:-------|:-------|:---|:--|:---|:---------|:---|:----------|
  # |1985 |1,067   |0  |0          |0       |0       |0       |0       |0       |0   |0  |0   |0         |0   |1,067      |
  # |1986 |44,203  |0  |0          |0       |0       |0       |0       |0       |0   |0  |0   |0         |0   |44,203     |
  # |1987 |47,821  |0  |0          |0       |0       |0       |0       |0       |0   |0  |0   |0         |0   |47,821     |
  # |1988 |51,472  |0  |0          |0       |0       |0       |0       |0       |0   |0  |0   |0         |0   |51,472     |
  # |1989 |52,309  |0  |1          |0       |0       |0       |0       |0       |0   |0  |0   |0         |0   |52,310     |
  # |1990 |56,845  |0  |0          |0       |0       |0       |0       |0       |0   |0  |0   |0         |0   |56,845     |
  # |1991 |61,242  |0  |2          |0       |0       |0       |0       |0       |0   |0  |0   |0         |0   |61,244     |
  # |1992 |67,761  |0  |3          |0       |1       |0       |0       |0       |0   |0  |0   |0         |0   |67,765     |
  # |1993 |66,842  |0  |7,670      |70      |145     |79      |32      |64      |0   |0  |0   |1,704     |0   |76,606     |
  # |1994 |0       |0  |377,497    |3,153   |7,742   |3,481   |3,055   |2,904   |0   |0  |0   |79,350    |0   |477,182    |
  # |1995 |0       |0  |380,044    |2,199   |11,222  |3,493   |3,400   |2,551   |0   |0  |0   |93,509    |0   |496,418    |
  # |1996 |0       |9  |399,477    |1,987   |13,699  |3,930   |3,792   |3,554   |0   |0  |0   |96,900    |0   |523,348    |
  # |1997 |0       |0  |431,697    |1,624   |16,736  |4,291   |5,227   |5,743   |0   |0  |0   |77,607    |0   |542,925    |
  # |1998 |0       |0  |464,973    |1,477   |12,574  |4,500   |5,824   |6,334   |0   |0  |0   |68,157    |0   |563,839    |
  # |1999 |0       |0  |470,722    |4,126   |13,103  |4,990   |7,225   |7,770   |0   |0  |0   |65,408    |0   |573,344    |
  # |2000 |0       |0  |490,467    |7,190   |14,015  |5,508   |8,125   |9,503   |0   |0  |0   |62,674    |0   |597,482    |
  # |2001 |0       |3  |446,645    |15,116  |19,832  |5,391   |8,685   |15,524  |5   |0  |2   |95,093    |0   |606,296    |
  # |2002 |0       |4  |447,706    |11,702  |23,119  |5,374   |10,861  |18,533  |185 |91 |68  |120,455   |0   |638,098    |
  # |2003 |0       |8  |485,153    |4,845   |24,258  |6,049   |11,473  |17,598  |99  |0  |99  |122,269   |0   |671,851    |
  # |2004 |0       |3  |521,986    |4,519   |26,422  |6,859   |12,315  |18,143  |68  |0  |237 |100,105   |0   |690,657    |
  # |2005 |0       |0  |567,331    |5,654   |23,393  |6,635   |11,885  |17,641  |0   |0  |0   |72,406    |0   |704,945    |
  # |2006 |0       |0  |613,318    |6,210   |21,458  |6,667   |12,017  |19,735  |0   |0  |0   |34,982    |1   |714,388    |
  # |2007 |0       |0  |619,311    |7,040   |21,630  |6,351   |11,721  |19,708  |0   |0  |0   |31,407    |731 |717,899    |
  # |2008 |0       |0  |944,977    |6,291   |33,447  |9,204   |23,599  |30,635  |0   |0  |0   |82,516    |0   |1,130,669  |
  # |2009 |0       |0  |1,040,665  |7,071   |38,721  |9,331   |28,297  |32,557  |0   |0  |0   |41,361    |0   |1,198,003  |
  # |2010 |0       |0  |1,079,970  |7,556   |42,661  |9,469   |31,613  |34,916  |0   |0  |0   |35,168    |0   |1,241,353  |
  # |2011 |0       |0  |1,066,479  |6,844   |41,826  |8,828   |31,406  |38,178  |0   |0  |0   |42,824    |0   |1,236,385  |
  # |2012 |0       |0  |1,017,393  |7,246   |43,877  |9,133   |33,433  |40,573  |0   |0  |0   |131,836   |0   |1,283,491  |
  # |2013 |0       |0  |1,018,301  |7,605   |42,865  |8,921   |33,724  |42,451  |0   |0  |0   |121,406   |0   |1,275,273  |
  # |2014 |0       |0  |1,062,721  |7,567   |43,308  |8,777   |35,992  |45,675  |0   |0  |0   |94,061    |0   |1,298,101  |
  # |2015 |0       |0  |1,110,202  |8,231   |46,209  |8,954   |37,694  |52,398  |0   |0  |0   |85,480    |0   |1,349,168  |
  # |Sum  |449,562 |27 |15,064,711 |135,323 |582,263 |146,215 |371,395 |482,688 |357 |91 |406 |1,756,678 |732 |18,990,448 |

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
  # |Hispanic     |  9.0|
  # |Non-Hispanic | 79.3|
  # |Unknown      | 11.6|
gc()

# Admission type----
unique(midas15$ADM_TYPE)
sum(is.na(midas15$ADM_TYPE))
# 449,562
midas15$ADM_TYPE[is.na(midas15$ADM_TYPE)] <- 6

# 1 = inpatient
# 2 = ER outpatient
# 3 = same day surgery (SDS) outpatient
# 4 = other outpatient (non-ER and non-SDS)
# 5 = non-ER outpatient (3 or 4)
# 6(missing) = not known (admissions prior to 1994; definitely no ER outpatients)

t2 <- table(midas15$YEAR,
            as.character(midas15$ADM_TYPE))
kable(format(t2, 
             big.mark = ","))
  # |     |1       |2       |3       |4      |5       |6      |
  # |:----|:-------|:-------|:-------|:------|:-------|:------|
  # |1985 |0       |0       |0       |0      |0       |1,067  |
  # |1986 |0       |0       |0       |0      |0       |44,203 |
  # |1987 |0       |0       |0       |0      |0       |47,821 |
  # |1988 |0       |0       |0       |0      |0       |51,472 |
  # |1989 |1       |0       |0       |0      |0       |52,309 |
  # |1990 |0       |0       |0       |0      |0       |56,845 |
  # |1991 |2       |0       |0       |0      |0       |61,242 |
  # |1992 |4       |0       |0       |0      |0       |67,761 |
  # |1993 |9,764   |0       |0       |0      |0       |66,842 |
  # |1994 |433,758 |0       |0       |0      |43,424  |0      |
  # |1995 |445,400 |0       |0       |0      |51,018  |0      |
  # |1996 |462,878 |0       |0       |0      |60,470  |0      |
  # |1997 |469,085 |0       |0       |0      |73,840  |0      |
  # |1998 |480,766 |0       |0       |0      |83,073  |0      |
  # |1999 |487,307 |0       |0       |0      |86,037  |0      |
  # |2000 |506,792 |0       |0       |0      |90,690  |0      |
  # |2001 |512,067 |0       |0       |0      |94,229  |0      |
  # |2002 |538,491 |0       |0       |0      |99,607  |0      |
  # |2003 |567,759 |0       |0       |0      |104,092 |0      |
  # |2004 |565,834 |0       |0       |0      |124,823 |0      |
  # |2005 |577,083 |0       |0       |0      |127,862 |0      |
  # |2006 |588,371 |0       |0       |0      |126,017 |0      |
  # |2007 |588,754 |71      |0       |7      |129,067 |0      |
  # |2008 |605,325 |367,296 |78,358  |79,690 |0       |0      |
  # |2009 |605,727 |418,515 |95,280  |78,481 |0       |0      |
  # |2010 |599,102 |456,049 |102,939 |83,263 |0       |0      |
  # |2011 |573,970 |478,392 |105,409 |78,614 |0       |0      |
  # |2012 |568,312 |532,700 |98,146  |84,333 |0       |0      |
  # |2013 |550,355 |540,234 |97,418  |87,266 |0       |0      |
  # |2014 |540,927 |562,193 |102,029 |92,952 |0       |0      |
  # |2015 |530,671 |614,289 |106,080 |98,128 |0       |0      |

kable(x = data.table(100*prop.table(table(ADM_TYPE = midas15$ADM_TYPE))),
      digits = 1)
  # |ADM_TYPE |    N|
  # |:--------|----:|
  # |1        | 62.2|
  # |2        | 20.9|
  # |3        |  4.1|
  # |4        |  3.6|
  # |5        |  6.8|
  # |6        |  2.4|

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
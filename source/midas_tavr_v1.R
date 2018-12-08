# |------------------------------------------------------------------------------|
# | Project: MIDAS dataset exploration                                           |
# | Script: transcatheter aortic valve replacement (TAVR)                        |     
# | Author: Davit Sargsyan, Aakash Garg                                          | 
# | Created: 12/07/2018                                                          |
# | Modified:                                                                    |
# |------------------------------------------------------------------------------|
# Header----
# Save consol output to a log file
# sink(file = "tmp/log_midas_tavr_v1.txt")
date()

# Load packages
require(data.table)
require(ggplot2)
require(knitr)
require(icd)

# Load MIDAS15
load("E:/MIDAS/midas15_clean.RData")
range(midas15$ADMDAT)
# "1995-01-01" "2015-12-31"

nrow(midas15)
# Total Records: 18,057,028
length(unique(midas15$Patient_ID))
# Total Patients: 4,446,438
gc()

# ICD-9 codes----
proc <- data.table(Patient_ID = midas15$Patient_ID,
                   midas15[, PROC1:PROC8])
proc

# Ankylosing spondylitis and other inflammatory spondylopathies----
l1 <- as.comorbidity_map(list(`Endovascular Replacement Of Aortic Valve` = "3505",
                              `Transapical Replacement Of Aortic Valve` = "3506"))
l1

# Number of patients with each condition----
dtt <- list()
for(i in 1:8){
  dtt[[i]] <- icd9_comorbid(x = proc,
                            map = l1,
                            visit_name = "Patient_ID",
                            icd_name = names(proc)[i + 1])
}

# Patients with these diagnoses (DX1-9)----
dt1 <- data.table(apply(Reduce("+", dtt),
                        MARGIN = 2,
                        function(a){
                          a > 0
                        }))
dt1$Patient_ID <- rownames(dtt[[1]])
kable(format(data.frame(N_Patients = colSums(dt1[, 1:2])),
             big.mark = ","))
  # |                                         |N_Patients |
  # |:----------------------------------------|:----------|
  # |Endovascular Replacement Of Aortic Valve |1,952      |
  # |Transapical Replacement Of Aortic Valve  |488        |

# After 2010----
id.keep <- unique(dt1$Patient_ID[dt1$`Endovascular Replacement Of Aortic Valve` |
                                   dt1$`Transapical Replacement Of Aortic Valve`])
dt2 <- midas15[Patient_ID %in% id.keep, ]
dt2$rec <- as.character(1:nrow(dt2))

proc2 <- data.table(Patient_ID = dt2$Patient_ID,
                    rec = dt2$rec,
                    dt2[, PROC1:PROC8])

tmp <- proc2[, -1]
dtt <- list()
for(i in 1:8){
  dtt[[i]] <- icd9_comorbid(x = tmp,
                            map = l1,
                            visit_name = "rec",
                            icd_name = names(tmp)[i + 1])
}

# Patients with these diagnoses (DX1-9)----
dt3 <- data.table(apply(Reduce("+", dtt),
                        MARGIN = 2,
                        function(a){
                          a > 0
                        }))
dt3$rec <- rownames(dtt[[1]])
kable(format(data.frame(rec = colSums(dt3[, 1:2])),
             big.mark = ","))
  # |                                         |rec        |
  # |:----------------------------------------|:----------|
  # |Endovascular Replacement Of Aortic Valve |1,971      |
  # |Transapical Replacement Of Aortic Valve  |488        |

dt.3505 <- dt3[dt3$`Endovascular Replacement Of Aortic Valve`, ]
dt.3505 <- merge(dt2[, c("rec",
                         "Patient_ID",
                         "YEAR")],
                 dt.3505[, -2],
                 by = "rec")

t1 <- data.table(table(dt.3505$YEAR,
            dt.3505$`Endovascular Replacement Of Aortic Valve`))[, -2]

dt.3506 <- dt3[dt3$`Transapical Replacement Of Aortic Valve`, ]
dt.3506 <- merge(dt2[, c("rec",
                         "Patient_ID",
                         "YEAR")],
                 dt.3506[, -1],
                 by = "rec")

t2 <- data.table(table(dt.3506$YEAR,
                       dt.3506$`Transapical Replacement Of Aortic Valve`))[, -2]

tt <- merge(t1, t2, by = "V1", all = TRUE)
names(tt) <- c("Year",
               names(dt3)[1:2])
kable(tt)
  # |Year | Endovascular Replacement Of Aortic Valve| Transapical Replacement Of Aortic Valve|
  # |:----|----------------------------------------:|---------------------------------------:|
  # |2011 |                                        9|                                      NA|
  # |2012 |                                      157|                                      21|
  # |2013 |                                      317|                                     192|
  # |2014 |                                      595|                                     181|
  # |2015 |                                      893|                                      94|

sink()
beepr::beep(3)
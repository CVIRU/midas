# |------------------------------------------------------------------------------|
# | Project: Simulate dataset that is structured like MIDAS                      |
# |          (BUT NO REAL PATIENTS' DATA!)                                       |
# | Script: Data simulation                                                      |     
# | Author: Davit Sargsyan                                                       | 
# | Created: 02/05/2018                                                          |
# | Modified:                                                                    |
# |------------------------------------------------------------------------------|
# Header----
# Save consol output to a log file
sink(file = "tmp/log_midas_data_simulation_v1.txt")
date()

# ICD-9 codes can be found here:
# http://www.icd9data.com/2015/Volume1/default.htm

# Load packages
require(data.table)
require(ggplot2)

# Load MIDAS15
load("E:/MIDAS/midas15_clean.RData")
midas15
cnames <- colnames(midas15)
cnames
midas15$PRIME

# Simulate demographics----
N = 1000
dt1 <- data.table(Patient_ID = 1:N,
                  # Birthday
                  patbdte = sample(seq(from = as.Date('1920/01/01'), 
                                       to = as.Date('1970/12/31'), 
                                       by="day"), 
                                   size = N,
                                   replace = TRUE),
                  # Death day
                  NEWDTD = sample(seq(from = as.Date('1994/01/01'), 
                                      to = as.Date('2015/12/31'), 
                                      by="day"), 
                                  size = N,
                                  replace = TRUE),
                  SEX = factor(sample(x = c("M", "F"),
                                      size = N,
                                      replace = TRUE)),
                  # Primary insurance
                  PRIME = factor(sample(x = c("Medicare", 
                                              "Commercial",
                                              "Medicaid/Self-Pay/Other"),
                                        size = N,
                                        replace = TRUE,
                                        prob = c(0.5, 0.4, 0.1))))
summary(dt1)

# Diagnoses----
udx <- lapply(midas15[, DX1:DX9],
              function(a){
                unique(a)
              })
udx <- unique(do.call("c", udx))
length(udx)
# 16,102 unique ICD-9 codes. Save the list.
save(udx,
     file = "tmp/unique_dx.RData")

# Sample 500 diagnosis and create a matrix of DX1-DX9
udx.keep <- sample(udx, 500)
udx.keep

# Create K records-----
K = 5000
dxx <- list()
for(i in 1:K) {
  n.dx <- sample(x = 1:9,
                 size = 1)
  dxx[[i]] <- c(sample(x = udx.keep,
                       size = n.dx,
                       replace = FALSE),
                rep(NA, 9 - n.dx)) 
}
dxx <- do.call("rbind", dxx)
colnames(dxx) <- paste("DX", 1:9, sep = "")
dxx

# Assign IDs
dt2 <- data.table(Patient_ID = sample(x = 1:N, 
                                      size = K,
                                      replace = TRUE),
                  dxx)
dt2 <- dt2[order(dt2$Patient_ID),]
dt2

# Admission dates
dt2[, ADMDAT := sample(seq(from = as.Date('1994/01/01'), 
                           to = as.Date('2015/12/31'), 
                           by="day"), 
                       size = .N,
                       replace = FALSE),
    by = Patient_ID]
dt2 <- dt2[order(ADMDAT),]
dt2 <- dt2[order(Patient_ID),]
dt2[, N := 1:.N,
    by = Patient_ID]
dt2

# Merge demographics with diagnises----
dt3 <- merge(dt1,
             dt2,
             by = "Patient_ID")
dt3

# If the latest admissin is past the death date, reset death date to none----
dt3[, lastAdm := ADMDAT[max(N)],
    by = Patient_ID]
dt3$NEWDTD[dt3$NEWDTD <= dt3$lastAdm] <- NA
# Number of people dead----
length(unique(dt3$Patient_ID[!is.na(dt3$NEWDTD)]))

summary(dt3)

# Save the data----
dt.sim <- dt3
dt.sim[, lastAdm := NULL]
dt.sim[, N := NULL]

save(dt.sim,
     file = "tmp/dt.sim.RData")
write.csv(dt.sim,
          file = "tmp/dt.sim.csv",
          row.names = FALSE)

sink()
beepr::beep(3)
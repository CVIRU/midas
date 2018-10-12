# |------------------------------------------------------------------------------|
# | Project: Separate MIDAS tables for DX, PROC, dates and demographics          |
# | Script: Data simulation                                                      |     
# | Author: Davit Sargsyan                                                       | 
# | Created: 09/15/2018                                                          |
# | Modified:                                                                    |
# |------------------------------------------------------------------------------|
# Header----
# Save consol output to a log file
sink(file = "tmp/log_midas_data_separate_tables_v1.txt")
date()

# ICD-9 codes can be found here:
# http://www.icd9data.com/2015/Volume1/default.htm

# Load packages
require(data.table)
require(ggplot2)

# Part I: Load MIDAS15
load("E:/MIDAS/midas15_clean.RData")
midas15
midas15$Record <- 1:nrow(midas15)
cnames <- colnames(midas15)
cnames

midas15_dx <- data.table(midas15[, c("Patient_ID",
                                     "Record")],
                         midas15[, DX1:DX9])
midas15_dx

midas15_proc <- data.table(midas15[, c("Patient_ID",
                                       "Record")],
                           midas15[, PROC1:PROC8])
midas15_proc

# Saved processed data
save(midas15_dx,
     file = "tmp/midas15_dx.RData")

save(midas15_proc,
     file = "tmp/midas15_proc.RData")


# sessionInfo()
# sink()
# beepr::beep(3)
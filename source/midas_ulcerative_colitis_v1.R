# |------------------------------------------------------------------------------|
# | Project: MIDAS dataset exploration                                           |
# | Script: Counting number of ulcerative colitis patients                       |     
# | Author: Davit Sargsyan                                                       | 
# | Created: 02/05/2018                                                          |
# | Modified:                                                                    |
# |------------------------------------------------------------------------------|
# Header----
# Save consol output to a log file
sink(file = "tmp/log_midas_ulcerative_colitis_v1.txt")
date()

# Load packages
require(data.table)
require(ggplot2)

# Load MIDAS15
load("E:/MIDAS/midas15_clean.RData")

# Remove pre-1994 data----
midas15 <- subset(midas15,
                  midas15$ADMDAT > "1993-12-31")
nrow(midas15)
# Total Records: 18,531,115
length(unique(midas15$Patient_ID))
# Total Patients: 4,542,479
gc()

# ICD-9 codes----
dx <- midas15[, .(DX1,
                  DX2,
                  DX3,
                  DX4,
                  DX5, 
                  DX6, 
                  DX7, 
                  DX8, 
                  DX9)]

# 556 Ulcerative enterocolitis: http://www.icd9data.com/2015/Volume1/520-579/555-558/556/default.htm
# 556.0 Ulcerative (chronic) enterocolitis
midas15[, uc5560 := rowSums(apply(dx,
                               MARGIN = 2,
                               FUN = function(a) {
                                 a == "5560"
                               })) > 0]
sum(midas15$uc5560)
# 758
gc()

# 556.1 Ulcerative (chronic) ileocolitis
midas15[, uc5561 := rowSums(apply(dx,
                                  MARGIN = 2,
                                  FUN = function(a) {
                                    a == "5561"
                                  })) > 0]
sum(midas15$uc5561)
# 336
gc()

# 556.2 Ulcerative (chronic) proctitis
midas15[, uc5562 := rowSums(apply(dx,
                                  MARGIN = 2,
                                  FUN = function(a) {
                                    a == "5562"
                                  })) > 0]
sum(midas15$uc5562)
# 2,336
gc()

# 556.3 Ulcerative (chronic) proctosigmoiditis
midas15[, uc5563 := rowSums(apply(dx,
                                  MARGIN = 2,
                                  FUN = function(a) {
                                    a == "5563"
                                  })) > 0]
sum(midas15$uc5563)
# 1,250
gc()

# 556.4 Pseudopolyposis of colon
midas15[, uc5564 := rowSums(apply(dx,
                                  MARGIN = 2,
                                  FUN = function(a) {
                                    a == "5564"
                                  })) > 0]
sum(midas15$uc5564)
# 901
gc()

# 556.5 Left-sided ulcerative (chronic) colitis 
midas15[, uc5565 := rowSums(apply(dx,
                                  MARGIN = 2,
                                  FUN = function(a) {
                                    a == "5565"
                                  })) > 0]
sum(midas15$uc5565)
# 1,148
gc()

# 556.6 Universal ulcerative (chronic) colitis
midas15[, uc5566 := rowSums(apply(dx,
                                  MARGIN = 2,
                                  FUN = function(a) {
                                    a == "5566"
                                  })) > 0]
sum(midas15$uc5566)
# 3,920
gc()

# 556.8 Other ulcerative colitis
midas15[, uc5568 := rowSums(apply(dx,
                                  MARGIN = 2,
                                  FUN = function(a) {
                                    a == "5568"
                                  })) > 0]
sum(midas15$uc5568)
# 3,227
gc()

# 556.9 Ulcerative colitis, unspecified
midas15[, uc5569 := rowSums(apply(dx,
                                  MARGIN = 2,
                                  FUN = function(a) {
                                    a == "5569"
                                  })) > 0]
sum(midas15$uc5569)
# 30,085
gc()

# 556 Ulcerative enterocolitis (All)
midas15[, uc.all := rowSums(midas15[, c("uc5560",
                                        "uc5561",
                                        "uc5562",
                                        "uc5563",
                                        "uc5565",
                                        "uc5566",
                                        "uc5568",
                                        "uc5569")]) > 0]
sum(midas15$uc.all)
# 42,861
gc()

# Separate UC patients----
id.keep <- unique(midas15$Patient_ID[midas15$uc.all])
length(id.keep)
# 24,391 patient

dt1 <- droplevels(subset(midas15,
                         Patient_ID %in% id.keep))
# 198,336 records

rm(midas15,
   dx)
gc()

# Find first instance of UC diagnosis
dt2 <- droplevels(subset(dt1,
                         uc.all))
# Sort by admission date
dt2 <- dt2[order(dt2$ADMDAT), ]
dt2 <- dt2[order(dt2$Patient_ID), ]

dt2[, N := 1:.N,
    by = Patient_ID]
dt3 <- droplevels(subset(dt2,
                         N == 1))

# New UC diagnosis over time and by admission type----
t1 <- table(dt3$YEAR,
            dt3$ADM_TYPE)
t1
write.csv(t1,
          file = "tmp/midas15_uc_by_year_and_admtype.csv")

# Plot the table----
tt1 <- data.table(t1)
names(tt1) <- c("year",
                "admtype",
                "n")
tt1$admtype <- factor(tt1$admtype,
                      levels = 1:5,
                      labels = c("Inpatient", 
                                 "ER outpatient",
                                 "Same day surgery (SDS) outpatient", 
                                 "Other outpatient (non-ER and non-SDS)", 
                                 "non-ER outpatient (3 or 4 before 2008)"))

p1 <- ggplot(data = tt1, 
             aes(x = year,
                 y = n,
                 group = admtype,
                 fill = admtype)) +
  geom_line() +
  geom_point(shape = 21,
             size = 2) +
  
  scale_x_discrete("Year of Admission") +
  scale_y_continuous("Number of New UC Cases") +
  scale_fill_discrete(name = "Admission Type") +
  ggtitle("Number of New UC Cases (i.e. Number of Patients with First\nRecord of UC) in MIDAS by Year and Admission Type") +
  theme(plot.title = element_text(hjust = 0.5),
        axis.text.x = element_text(angle = 45,
                                   hjust = 1))
p1
tiff(filename = "tmp/midas15_uc_by_year_and_admtype.tiff",
     height = 5,
     width = 8,
     units = 'in',
     res = 300,
     compression = "lzw+p")
print(p1)
graphics.off()

sink()
beepr::beep(3)
# Project: Summary of MIDAS data  
# Author: Davit Sargsyan   
# Created:  07/15/2017
# Modified: 10/14/2017
#**********************************************************
# Header----
require(data.table)
require(ggplot2)

# Load MIDAS15
load("C:/MIDAS/midas15_race_corrected.RData")

# Patient type by year----
# Pre-2008
dt.pre2008 <- subset(midas15,
                     YEAR < 2008)

# Post-2008
dt.post2008 <- subset(midas15,
                      YEAR >= 2008)

t1 <- data.table(`Patient Type` = c("Unknown (=-1)",
                                    "Inpatient (=0)",   
                                    "Same Day Surgery (=1)",   
                                    "ER/Other Outpatient (=2)",   
                                    "Outpatient (=3)"),
                 `Prior to 2008` = c(table(dt.pre2008$PAT_TYPE)),
                 `2008 and Later` = c(table(dt.post2008$PAT_TYPE)))
t1
write.csv(t1,
          file = "tmp/records_by_pat_type.csv")

# Inpatients (1986 to 2015)----
dt.inpat <- droplevels(subset(midas15,
                              PAT_TYPE %in% c("Inpatinet Before 2008",
                                              "Inpatient")))
gc()

# Patient type by year----
out <- data.table(table(AdmYear = midas15$YEAR,
                        PatType = midas15$PAT_TYPE))
out
summary(out)

p1 <- ggplot(out,
             aes(x = AdmYear,
                 y = N,
                 group = PatType,
                 fill = PatType)) +
  geom_point(size = 3,
             shape = 21) +
  geom_line() +
  theme(plot.title = element_text(hjust = 0.5),
        axis.text.x = element_text(angle = 45,
                                   hjust = 1))
p1
tiff(filename = "tmp/pat_type_year.tiff",
     width = 10,
     height = 6,
     units = "in",
     res = 300,
     compression = "lzw+p")
print(p1)
graphics.off()

# Race by year----
out <- data.table(100*prop.table(table(AdmYear = midas15$YEAR,
                                       Race = midas15$RACE),
                                 1))
out

p1 <- ggplot(out,
             aes(x = AdmYear,
                 y = N,
                 group = Race,
                 fill = Race)) +
  geom_point(size = 3,
             shape = 21) +
  geom_line() +
  theme(plot.title = element_text(hjust = 0.5),
        axis.text.x = element_text(angle = 45,
                                   hjust = 1))
p1

png(filename = "tmp/race_year.png",
    width = 10,
    height = 6,
    units = "in",
    res = 300)
print(p1)
graphics.off()

# Separate diagnostic codes (DX1:DX9)----
dx <- dt.inpat[, .(Patient_ID, DX1, DX2, DX3, DX4, DX5, DX6, DX7, DX8, DX9)]
cnames <- names(dx)

dx.1.3 <- copy(dx)
dx.1.3[, cnames[-1] := lapply(dx.1.3[, cnames[-1],
                                     with = FALSE],
                              substr,
                              start = 1,
                              stop = 3)]
gc()

# AMI as reason for admission (DX1)----
dt.inpat[, ami.dx1 := (dx.1.3$DX1 == "410")]
dt.ami <- subset(dt.inpat,
                 ami.dx1,
                 select = c("Patient_ID",
                            "ADMDAT",
                            "YEAR",
                            "AGE",
                            "RACE",
                            "SEX",
                            "HISPAN",
                            "PRIME"))
setkey(dt.ami, 
       Patient_ID,
       ADMDAT)
dt.ami[, N := 1:.N,
       by = Patient_ID]
dt.ami <- subset(dt.ami,
                 N == 1)

t1 <- table(dt.ami$YEAR)
gc()

rm(dt.ami)
gc()

# 2. Acute CFH----
dt.inpat[, achf.dx1 := (dx$DX1 %in% c("4280",
                                      "42820",
                                      "42821",
                                      "42823",
                                      "42830",
                                      "42831",
                                      "42833",
                                      "42840",
                                      "42841",
                                      "42843"))]
dt.achf <- subset(dt.inpat,
                  achf.dx1,
                  select = c("Patient_ID",
                             "ADMDAT",
                             "YEAR",
                             "AGE",
                             "RACE",
                             "SEX",
                             "HISPAN",
                             "PRIME"))
setkey(dt.achf, 
       Patient_ID,
       ADMDAT)
dt.achf[, N := 1:.N,
        by = Patient_ID]
dt.achf <- subset(dt.achf,
                  N == 1)
gc()

t2 <- table(dt.achf$YEAR)

rm(dt.achf)
gc()

# 3. Stroke----
dt.inpat[, stroke.dx1 := DX1 %in% as.character(c(43301,
                                                 43311,
                                                 43321,
                                                 43331,
                                                 43381,
                                                 43391,
                                                 43401,
                                                 43411,
                                                 43491))]
dt.stroke <- subset(dt.inpat,
                    stroke.dx1,
                    select = c("Patient_ID",
                               "ADMDAT",
                               "YEAR",
                               "AGE",
                               "RACE",
                               "SEX",
                               "HISPAN",
                               "PRIME"))
setkey(dt.stroke, 
       Patient_ID,
       ADMDAT)
dt.stroke[, N := 1:.N,
          by = Patient_ID]
dt.stroke <- subset(dt.stroke,
                    N == 1)
gc()

t3 <- table(dt.stroke$YEAR)

rm(dt.stroke)
gc()

# 4. Atrial Fibrilation----
dt.inpat[, af.dx1 := (DX1 == 42731)]
dt.af <- subset(dt.inpat,
                af.dx1,
                select = c("Patient_ID",
                           "ADMDAT",
                           "YEAR",
                           "AGE",
                           "RACE",
                           "SEX",
                           "HISPAN",
                           "PRIME"))
setkey(dt.af, 
       Patient_ID,
       ADMDAT)
dt.af[, N := 1:.N,
      by = Patient_ID]
dt.af <- subset(dt.af,
                N == 1)
gc()

t4 <- table(dt.af$YEAR)

rm(dt.af)
gc()

# Data for the plot----
dt1 <- data.table(dx = c(rep("AMI", length(t1)),
                         rep("ACHF", length(t2)),
                         rep("Stroke", length(t3)),
                         rep("AF", length(t4))),
                  year = c(names(t1),
                           names(t2),
                           names(t3),
                           names(t4)),
                  counts = c(c(t1),
                             c(t2),
                             c(t3),
                             c(t4)))
dt1

# Plot all inpatinets----
p1 <- ggplot(dt1,
             aes(x = year,
                 y = counts,
                 fill = dx,
                 group = dx)) +
  geom_line(size = 1,
            col = "black") +
  geom_point(size = 3,
             shape = 21) +
  scale_x_discrete("Year of Admission",
                   breaks = 1985:2015) +
  scale_y_continuous("Counts") +
  ggtitle("Change in Number of Admissions from 1985 to 2015 in MIDAS\n First Occurence of the Diagnosis (DX1), Inpatients") +
  guides(colour = guide_legend(title = "DX1:")) +
  theme(axis.text.x = element_text(angle = 45,
                                   hjust = 1),
        plot.title = element_text(hjust = 0.5))
p1

tiff(filename = "tmp/dx1_inpatients.tiff",
     height = 5,
     width = 8,
     units = 'in',
     res = 300,
     compression = "lzw+p")
print(p1)
graphics.off()
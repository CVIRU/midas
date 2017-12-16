# Project: Mismatches in MIDAS records
# Author: Davit Sargsyan   
# Created:  12/15/2017
# Modified: 
#**********************************************************
# Header----
require(data.table)
require(knitr)

# Load MIDAS15
load("E:/MIDAS/midas15_race_corrected.RData")
summary(midas15)

setkey(midas15,
       Patient_ID,
       ADMDAT,
       NEWDTD,
       DSCHDAT,
       patbdte,
       SEX,
       RACE,
       HISPAN)

# Number of patients with mismatched records
# a. Sex
midas15[, sex.1 := SEX != SEX[1],
        by = Patient_ID]

# Number of records that matched the 1st record, per patient
t1 <- data.frame(addmargins(table(midas15$sex.1)))
kable(format(t1, big.mark = ","))
  # |Var1  |Freq       |
  # |:-----|:----------|
  # |FALSE |18,910,814 |
  # |TRUE  |101,653    |
  # |Sum   |19,012,467 |
# NOTE: only 1 NA in SEX

# Number of patients with all records matched to 1st record, per patient
t1.1 <- aggregate(midas15$sex.1,
                  by = list(midas15$Patient_ID),
                  FUN = function(a) {
                    sum(a) > 0
                  })
t1.1 <- data.frame(addmargins(table(t1.1$x)))
kable(format(t1.1, big.mark = ","))
  # |Var1  |Freq      |
  # |:-----|:---------|
  # |FALSE |4,646,722 |
  # |TRUE  |32,649    |
  # |Sum   |4,679,371 |

# b. Race
midas15[, race.1 := RACE != RACE[1],
        by = Patient_ID]

# Number of records that matched the 1st record, per patient
t1 <- data.frame(addmargins(table(midas15$race.1)))
kable(format(t1, big.mark = ","))
  # |Var1  |Freq       |
  # |:-----|:----------|
  # |FALSE |19,010,306 |
  # |TRUE  |2,162      |
  # |Sum   |19,012,468 |

# Number of patients with all records matched to 1st record, per patient
t1.1 <- aggregate(midas15$race.1,
                  by = list(midas15$Patient_ID),
                  FUN = function(a) {
                    sum(a) > 0
                  })
t1.1 <- data.frame(addmargins(table(t1.1$x)))
kable(format(t1.1, big.mark = ","))
  # |Var1  |Freq      |
  # |:-----|:---------|
  # |FALSE |4,678,251 |
  # |TRUE  |1,121     |
  # |Sum   |4,679,372 |

# c. Ethnicity
midas15[, hispan.1 := HISPAN != HISPAN[1],
        by = Patient_ID]

# Number of records that matched the 1st record, per patient
t1 <- data.frame(addmargins(table(midas15$hispan.1)))
kable(format(t1, big.mark = ","))
  # |Var1  |Freq       |
  # |:-----|:----------|
  # |FALSE |15,109,637 |
  # |TRUE  |3,902,831  |
  # |Sum   |19,012,468 |

# Number of patients with all records matched to 1st record, per patient
t1.1 <- aggregate(midas15$hispan.1,
                  by = list(midas15$Patient_ID),
                  FUN = function(a) {
                    sum(a) > 0
                  })
t1.1 <- data.frame(addmargins(table(t1.1$x)))
kable(format(t1.1, big.mark = ","))
  # |Var1  |Freq      |
  # |:-----|:---------|
  # |FALSE |3,714,951 |
  # |TRUE  |964,421   |
  # |Sum   |4,679,372 |

# d. Birthday
midas15[, patbdte.1 := patbdte != patbdte[1],
        by = Patient_ID]

# Number of records that matched the 1st record, per patient
t1 <- data.frame(addmargins(table(midas15$patbdte.1)))
kable(format(t1, big.mark = ","))
  # |Var1  |Freq       |
  # |:-----|:----------|
  # |FALSE |18,717,469 |
  # |TRUE  |294,999    |
  # |Sum   |19,012,468 |

# Number of patients with all records matched to 1st record, per patient
t1.1 <- aggregate(midas15$patbdte.1,
                  by = list(midas15$Patient_ID),
                  FUN = function(a) {
                    sum(a) > 0
                  })
t1.1 <- data.frame(addmargins(table(t1.1$x)))
kable(format(t1.1, big.mark = ","))
  # |Var1  |Freq      |
  # |:-----|:---------|
  # |FALSE |4,587,195 |
  # |TRUE  |92,177    |
  # |Sum   |4,679,372 |

# e. Date of death
midas15[,dead.1 := NEWDTD != NEWDTD[1],
        by = Patient_ID]

# Number of records that matched the 1st record, per patient
t1 <- data.frame(addmargins(table(midas15$dead.1)))
kable(format(t1, big.mark = ","))
  # |Var1  |Freq      |
  # |:-----|:---------|
  # |FALSE |7,102,944 |
  # |TRUE  |10        |
  # |Sum   |7,102,954 |

# Number of patients with all records matched to 1st record, per patient
t1.1 <- aggregate(midas15$dead.1,
                  by = list(midas15$Patient_ID),
                  FUN = function(a) {
                    sum(a) > 0
                  })
t1.1 <- data.frame(addmargins(table(t1.1$x)))
kable(format(t1.1, big.mark = ","))
  # |Var1  |Freq      |
  # |:-----|:---------|
  # |FALSE |1,242,472 |
  # |TRUE  |5         |
  # |Sum   |1,242,477 |
## Project: MIDAS dataset preparation    
### Author: Davit Sargsyan   
### Created: 07/08/2017  

---

## Daily Logs
#### 07/15/2017
* Mapped hospital numbers from 2008-2015 files to 1986-2007 files:   
`midas15_pat_type$HOSP <- as.numeric(substr(x = midas15_pat_type$HOSP, start = 4, stop = 6))`       

#### 07/08/2017
* Exported MIDAS variable PAT_TYPE from SAS for the years 2008 to 2015. The measure was not collected between 1986 and 2007.   
* Imported CSV files (MIDAS and PAT_TYPE) to R and merged.   
* Removed unused variables.    
* Converted and preprocessed variables.   
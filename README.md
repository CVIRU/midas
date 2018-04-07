## Project: MIDAS dataset preparation    
### Author: Davit Sargsyan   
### Created: 07/08/2017  

---

## The International Classification of Diseases (ICD)
**The International Classification of Diseases** (**ICD**) is the standard diagnostic tool for epidemiology, health management and clinical purposes. This includes the analysis of the general health situation of population groups. It is used to monitor the incidence and prevalence of diseases and other health problems, providing a picture of the general health situation of countries and populations.   
   
ICD is used by physicians, nurses, other providers, researchers, health information managers and coders, health information technology workers, policy-makers, insurers and patient organizations to classify diseases and other health problems recorded on many types of health and vital records, including death certificates and health records. In addition to enabling the storage and retrieval of diagnostic information for clinical, epidemiological and quality purposes, these records also provide the basis for the compilation of national mortality and morbidity statistics by WHO Member States.    
   
More information can be found on [this WHO web page](http://www.who.int/classifications/icd/en/).

### Sources:  
1. http://www.icd9data.com/2012/Volume1/default.htm    
2. http://icd9cm.chrisendres.com/index.php?action=procslist   
3. https://en.wikipedia.org/wiki/ICD-9-CM_Volume_3#.2800.29_Procedures_and_interventions.2C_not_elsewhere_classified 

## Daily Logs
### 04/07/2018
* Moved all 'icd'-related code to new project 'shiny.icd'

### 04/04/2018
* Keeping selected diagnoses after switching to the next category (2nd table)    
* Added codes to diagnoses labels in the drop-down menu    
* Reseting Table2 (very rough: must click "Reset", then "Save" again to reset to current Table1 values only)    
* ToDo: improve reset

### 04/03/2018
* Replaced text boxes wit DT table. 
* Download only SELECTED rows (all selected by default)
* Output a map file, i.e. R list with mapped diagnoses 

### 03/31/2018
* Added Shiny app using package *icd*. This is a POC to show that we can easily create lists of ICD codes. Next step is to improve GUI (e.g. allow check-boxes or multi-inputs, print tables using package *DT*, etc), and seamlessly integrate into *icd* workflow for fast data subseting. 
* Added scripts *icd9_app_v1.R*, *app.R* (i.e. *icd9_app_v2.R*) and *package_icd_example.R*. NOTE: app will not run unless it is names *app.R*, hence that will be the name of the most recent version.

### 02/21/2018
* Added simulated processed MIDAS data for a mock ulcerative colitis study

### 02/05/2018
* Added ulcerative colitis counting    
* MIDAS-like data simulation

### 01/17/2018
* New, clean MIDAS15 form Jerry (see *export_midas_from_csv_to_rdata_v3.R*)     
* New tables(*render_table_v2.Rmd*)

### 12/15/2017
* Count of mismathces (*midas_mismatch_v1.R*)

### 10/14/2017
* Recreated MIDAS15 with correct mapping for RACE variable

### 10/13/2017
* MIDAS15 data update: corrected RACE variable coding issue

### 07/15/2017
* Mapped hospital numbers from 2008-2015 files to 1986-2007 files:   
`midas15_pat_type$HOSP <- as.numeric(substr(x = midas15_pat_type$HOSP, start = 4, stop = 6))`       

### 07/08/2017
* Exported MIDAS variable PAT_TYPE from SAS for the years 2008 to 2015. The measure was not collected between 1986 and 2007.   
* Imported CSV files (MIDAS and PAT_TYPE) to R and merged.   
* Removed unused variables.    
* Converted and preprocessed variables.   
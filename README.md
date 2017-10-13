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
#### 07/15/2017
* Mapped hospital numbers from 2008-2015 files to 1986-2007 files:   
`midas15_pat_type$HOSP <- as.numeric(substr(x = midas15_pat_type$HOSP, start = 4, stop = 6))`       

#### 07/08/2017
* Exported MIDAS variable PAT_TYPE from SAS for the years 2008 to 2015. The measure was not collected between 1986 and 2007.   
* Imported CSV files (MIDAS and PAT_TYPE) to R and merged.   
* Removed unused variables.    
* Converted and preprocessed variables.   
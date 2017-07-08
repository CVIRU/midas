/*********************************************************
* Project: Export MIDAS data with patient type variable  *
* Author: Davit Sargsyan                                 *
* Created: 07/08/2017                                    *
**********************************************************/
libname years 'Z:\midaslab\midaslab\From SiruisC\midas\MIDAS_YD\AFLNK_UBDATA';

/* Print column names for each dataset from 2000 onward*/
proc contents 
 data = years.Newall00 
 out = meta (keep=NAME); 
run; 

proc contents 
 data = years.Newall01 
 out = meta (keep=NAME); 
run; 

proc contents 
 data = years.Newall02 
 out = meta (keep=NAME); 
run; 

proc contents 
 data = years.Newall03 
 out = meta (keep=NAME); 
run; 

proc contents 
 data = years.Newall04 
 out = meta (keep=NAME); 
run; 

proc contents 
 data = years.Newall05 
 out = meta (keep=NAME); 
run; 

proc contents 
 data = years.Newall06 
 out = meta (keep=NAME); 
run; 

proc contents 
 data = years.Newall07 
 out = meta (keep=NAME); 
run; 

/* NOTE: first time PAT_TYPE appears! Column #69 */
proc contents 
 data = years.Newall08 
 out = meta (keep=NAME); 
run; 

proc contents 
 data = years.Newall09 
 out = meta (keep=NAME); 
run; 

proc contents 
 data = years.Newall10 
 out = meta (keep=NAME); 
run; 

proc contents 
 data = years.Newall11 
 out = meta (keep=NAME); 
run; 

proc contents 
 data = years.Newall12 
 out = meta (keep=NAME); 
run; 

proc contents 
 data = years.Newall13 
 out = meta (keep=NAME); 
run; 

proc contents 
 data = years.Newall14 
 out = meta (keep=NAME); 
run; 
proc contents 
 data = years.Newall15 
 out = meta (keep=NAME); 
run; 

/***************************************************************************************
* Only datasets for the years 2008 to 2015 contain PAT_TYPE variable                   *
* Export Patient_ID, PAT_TYPE, ADMDAT, HOSP and DIV columns for the years 2008 to 2015 *
* NOTE: HOSP numbers are incompatable with 1986 to 2007 numbers. Ask Jerry.            *
* NOTE: DIV variable is absent in 2008 to 2015 data. Ask Jerry.                        *
***************************************************************************************/
data work.Newall0815;
 set years.Newall08
     years.Newall09
     years.Newall10
     years.Newall11
     years.Newall12
     years.Newall13
     years.Newall14
     years.Newall15
 ;
 keep Patient_ID
      PAT_TYPE
      ADMDAT
      HOSP
      DIV
 ;
run;

proc export data = work.Newall0815
            outfile = "C:\MIDAS\midas_pat_type_2008_2015.csv" 
			dbms = CSV label replace;
 pitnames = YES;
run;


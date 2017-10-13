/*********************************************************
* Project: Export MIDAS                                  *
* Author: Davit Sargsyan                                 *
* Created: 07/08/2017                                    *
**********************************************************/
/*
libname midas 'C:\MIDAS';

%INCLUDE 'C:/MIDAS/MIDAS format.sas';

PROC EXPORT DATA= midas.Midas19862015b 
            OUTFILE= "C:\MIDAS\midas_2015.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;
 */

/*Date: 10/13/2017*/

%INCLUDE 'Z:\midaslab\midaslab\DATA\MIDAS format.sas';
libname midas 'Z:\midaslab\midaslab\DATA';

PROC EXPORT DATA= midas.midas19862015a_race_corrected 
            OUTFILE= "C:\MIDAS\midas_2015_race_corrected.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

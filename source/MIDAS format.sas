
/* libname midas 'Z:\swerdejn\midaslab\DATA';
libname midas 'R:\midaslab\DATA'; */
proc format cntlin=MIDAS.paycd fmtlib library=MIDAS ;
run; 
/*
proc format cntlin=MIDAS.ICD93Dformat fmtlib library=MIDAS ;
run; 

proc format cntlin=MIDAS.ICD95Dformat fmtlib library=MIDAS ;
run;
*/
proc format cntlin=MIDAS.Procformat fmtlib library=MIDAS ;
run;
options fmtsearch = (MIDAS);

proc format;
value YN 1='Yes' 0='No';
/*************************************************************************
*                                                                       *
*---- The following lines set up the formats for state names to         *
*     be associated with the FIPS codes for each state.                 *
*                                                                       *
*************************************************************************/
VALUE statenm   (DEFAULT=18)
  1='ALABAMA     '  2='ALASKA     '  	4='ARIZONA       '  	5='ARKANSAS    '
  6='CALIFORNIA  '  8='COLORADO   '  	9='CONNECTICUT   ' 		10='DELAWARE    '
 11='WASHINGTON, D.C.'              	12='FLORIDA       ' 	13='GEORGIA     '
 15='HAWAII      ' 16='IDAHO      ' 	17='ILLINOIS      ' 	18='INDIANA     '
 19='IOWA        ' 20='KANSAS     ' 	21='KENTUCKY      ' 	22='LOUISIANA   '
 23='MAINE       ' 24='MARYLAND   ' 	25='MASSACHUSETTS ' 	26='MICHIGAN    '
 27='MINNESOTA   ' 28='MISSISSIPPI' 	29='MISSOURI      ' 	30='MONTANA     '
 31='NEBRASKA    ' 32='NEVADA     ' 	33='NEW HAMPSHIRE ' 	34='NEW JERSEY  '
 35='NEW MEXICO  ' 36='NEW YORK   ' 	37='NORTH CAROLINA' 	38='NORTH DAKOTA'
 39='OHIO        ' 40='OKLAHOMA   ' 	41='OREGON        ' 	42='PENNSYLVANIA'
 44='RHODE ISLAND' 45='SOUTH CAROLINA' 	46='SOUTH DAKOTA' 		47='TENNESSEE   '
 48='TEXAS       ' 49='UTAH       ' 	50='VERMONT        ' 	51='VIRGINIA    '
 53='WASHINGTON  ' 54='WEST VIRGINIA ' 	55='WISCONSIN   ' 		56='WYOMING  ' ;
 *************************************************************************
*                                                                       *
*---- The following lines set up the region formats based on state      *
*     names.                                                            *
*                                                                       *
*************************************************************************
                                                                        ;
VALUE $REGION  (DEFAULT=18)
     'ALABAMA       ' , 'FLORIDA       ' , 'GEORGIA       ',
     'KENTUCKY      ' , 'LOUISIANA     ' , 'MISSISSIPPI   ',
     'SOUTH CAROLINA' , 'TENNESSEE     ' , 'TEXAS         ',
     'VIRGINIA      ' , 'WEST VIRGINIA '
                                                           = 'South East'
     'CALIFORNIA    ' , 'OREGON        ' ,  'WASHINGTON    '
                                                        = 'Pacific Coast'
     'NEW JERSEY    ' , 'NEW YORK      ' ,  'PENNSYLVANIA  '
                                                        = 'Mid. Atlantic'
     'WASHINGTON, D.C.'                            = 'Dist. of Columbia';

value MIsite 1='Anterior' 2='Inf/Inferolateral' 3='subEndo' 4='Other/Unspec';
value MI_ST 1='Stroke first' 2='MI first' 3='MI=Stroke' 4='MI only' 5='Stroke only';
value interv 	1='1)Same' 
				2='2)Less than 30days' 
				3='3)Less than 1year' 
				4='4)Less than 2years' 
				5='5)2 years+';
value season	1='1)Spring'
				2='2)Summer'
				3='3)Fall'
				4='4)Winter';
value weekend	1='1)Weekends'
				2='2)Weekday';
value D_place	1='1)Discharge home'
				2='2)Leave against advice'
				3='3)Transfer'
				4='4)Die/Hospice';
				
VALUE $ DCPLACE '1', '2', '3','8'='IN-HOSPITAL' '5'='NURSING HOME' '6'='HOME' OTHER='OTHER';
run;

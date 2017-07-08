

proc format;
value yn .='NO'  1='YES';

value certain 
-99='USER GROUPED'
-9=' '
-1='Reference (Alias)'
.='Reference'
1='Level 1' 
2='Level 2'
3='Level 3'
4='Level 4'
6='Level 6'
7='Level 7'
9='User Regrouped'
88='Alias causing X-link'
99='X-linked'
888='Linked Record Alias'
999=' ';

value regroup 0=' ';

value cert_lev 1='Level 1: Highest Possible'
               2='Level 2: Very High'
			   3='Level 3: High'
			   4='Level 4: Moderate'
			   6='Level 6: Low - Moderate'
			   7='Level 7: Probabilistic Maybe';

value certtime 1='Level 1: Highest Possible'
                2='Level 2: Very High'
			    3='Level 3: High'
			    4='Level 4: Moderate'
			    6='Level 6: Twins ?'
			    7='Level 7: Probabilistic Maybe'
                99='TOTAL';

value prob_cat 0='no match' .5='maybe (rec)' 
               .75='maybe(rec)& detcrit' 
               1='maybe' 1.5="maybe & detcrit"
			   1.75='definite (rec)'
			   1.8='definite (rec) & detcrit'
               2='definite'; 

value results 1='deterministic only' 2='probabilistic only'
              3='deterministic and probabilistic';

VALUE MATCH 1='EXACT MATCH' 
            1.5='SAMHSA spell>=.75 OR JW>=.95'
			1.75='spedis cost<=50'
            2='NICKNAME' 
            3='Fully EMBEDDED'
            3.5='Min of 5 Char string Shared' 
			3.75='Min of 4 Char string Shared'
            4='4 OF 1ST 5 Chars match' 
			4.5='Swapped Name'
            5='Sounds Alike by Dbl Meta, NYSIIS, Soundex'
            5.15='Sounds Alike by Dbl Meta, Soundex'
            5.25='Sounds Alike by Dbl Meta, NYSIIS'
            5.35='Sounds Alike by NYSIIS, Soundex'
            5.45='Sounds Alike by Dbl Meta'
            5.55='Sounds Alike by Soundex'
            5.65='Sounds Alike by NYSIIS'
            6='Initial Match' 
            98='MISSING DATA'
            99='NO SIMILIARITY';

value matchdat 1='Exact Match' 2='2 fields transposed, 3rd matces' 
               3='2 of 3 fields exact positional match'
               98='Missing at least 1 dob' 99='No Match';

value matchssn 1='Exact Match' 2='7 of 9 digits are positional match'
                98='Missing at least 1 SSN' 99='No Match';

value method 0='no match by prob or det'
             1='Det. only'
			 2='Prob only'
			 3='Both det & prob';

value block 0='ssn match'
            1='NYSIIS last name and dob'
			2='NYSIIS firt name, dob'
			3='NYSIIS fn & ln, birth year'
			3.5='NYSIIS nickname & ln, YOB'
			3.6='fn & ln 3 char, DOB similar'
			3.7='fn & ln 2 char, minit, DOB sim'
			4='NYSIIS fn & ln,  birth month'
			4.5='NYSIIS nickname & ln, DayOB'
			5='NYSIIS fn & ln, birth day of month'
			6='NYSIIS fn & ln,  1st 3 SSN digits'
			7='NYSIIS fn & ln,  2nd 3 SSN digits'
			8='NYSIIS fn & ln,  3rd 3 SSN digits'
            9='soundex last name and dob'
			10='soundex first name, dob'
			11='NYSIIS fn & ln & dob year/month'
			12='NYSIIS fn & ln & dob year/day'
			13='NYSIIS fn & ln  dob month/day'
			14='soundex fn & ln & dob year/month'
			15='soundex fn & ln & dob year/day'
			16='soundex fn & ln &  dob month/day'
			17='fn & ln & dob year'
			18='fn & ln & dob day'
			19='fn & ln & dob month'
			20='f,m,l init & complete dob'
			21='f,m,l init & dob year/month'
			22='f,m,l init & dob year/day'
		   23='f,m,l init & dob month/day'
		   24='f,m init & complete dob'
		   25='f,l init & complete dob'
		   26='m,l init & complete dob'
		   27='flex var and fn or ln'
		   88='name only (missing ssn and dob)'
           99='enhanced MN processing';


value delete -1=' '
0='User: KEEP Link' 1='User: DELETE Link' 2='Auto: KEEP Link' 3='Auto: DELETE Link'
 .='Unclassified' 4='User: Undecided';

invalue  in_del ''=-1 'KEEP Link'=0 'DELETE Link'=1 'Unclassified'=. 'Undecided'=4;

value del_a -1=' ' 0='KEEP Link' 1='DELETE Link' 4='Undecided' .='Unclassified';


value linktype 1='Sample linked to Matching'
               2='Sample linked to Sample'
               3='Matching linked to Matching';

value race 1='Caucasian' 2='African American' 3='Hispanic' 4='Asian' 5='Native Am'
           6='Middle Eastern' 7='Other' -9='MISSING';

invalue in_cr 'RETAINED'=1
               'Deleted'=0;

value comp_res 0='Deleted' 1='RETAINED' ;

invalue in_nick 'Add_Nickname'=1;

value nickname  1='Add Nickname' ;

value alias_st 1='Strong' 2='Strong' 3='Moderate' 4='Weak';

value priority  1='Primary' 2-high='Secondary';

value match_fl 1='Exact Match' 1.5='ASM>=.75' 5='Phonetic: Dbl Meta & (Soundex or NYSIIS)' 98='Missing'
               2='<25 miles' 3='25-50 miles' 4='51-100 miles';

value c_core  1='CORE'  2='nonCore';

value link_why 1='Manually reviewed and approved'
			   2='In YELLOW/GREEN cell: all elements exact match'
               3='In YELLOW/GREEN cell: not reviewed, discrepent info'
			   4='Not in YELLOW/GREEN cell: MATCHING CID = SAMPLE CID';

value variant 0='Neither' 1='Info' 2='Current' 3='Both';

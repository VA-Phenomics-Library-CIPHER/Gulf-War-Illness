filename  dr_macro "R:\CSP 585\AnalysisCode\585 Manuscripts\Caseness\CODE\SAS\ClayTightLoopingmacros";

%INCLUDE dr_macro('ARRAY.sas'); 
%INCLUDE dr_macro('DO_OVER.sas'); 
%INCLUDE dr_macro('NUMLIST.sas'); 

%macro importCDC(CDCdomain= );
PROC IMPORT OUT= CDC_&CDCdomain._Test
            DATAFILE= "R:\CSP 585\AnalysisCode\585 Manuscripts\Caseness\CODE\SAS\Tests\Update_2020_12_11_CDC\CDC_domain_checks_final.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="&CDCdomain.$"; 
     GETNAMES=YES;
	 run;
%mend importCDC;

/* variables that can change */
	*missing values;
	%let missing_values= (. .a .b .c .d .e .f .g .h .g);
	*CDC definition: symptoms in domains;
	%let CDCFatigueSymptomList = SMoFatigue ;
	%let CDCMuscSkelSymptomList =  SMoPain SMoMuscl SMoStiff ;
	%let CDCMoodSymptomList =  SMoDReme SMoTFind SMoFDown  SMoDConct SMoMoody  SMoAnxio SMoGetSlp ;

/*Import test cases*/

%importCDC(CDCdomain=Mood);
%importCDC(CDCdomain=Fatigue);
%importCDC(CDCdomain=MuscSkel);
%importCDC(CDCdomain=GWI);
%importCDC(CDCdomain=GWI_Sev);
run;


proc format;
	value l_yesno
		0= "No"
		1= "Yes" 
		. = "Missing"
		;
	run;

%macro calcCDCDomain(CDCdomain= , symptomList = , domainDescript= );
	&CDCdomain._Any=0;
		label &CDCdomain._Any= " &domainDescript Domain: Endorsed at least 1 criteria";
		format &CDCdomain._Any l_yesno.;
	&CDCdomain._Sev=0;
		label &CDCdomain._Sev= " &domainDescript Domain: Endorsed at least 1 criteria as severe";
		format &CDCdomain._Sev l_yesno.;
	&CDCdomain.Rate_NumMiss=0;  /* This variable is to store the number of missing items on severity*/
		label  &CDCdomain.Rate_NumMiss= " &domainDescript Domain: # of items with missing severity rating";
	/* do the work to calculate accurate values for these variables */
	%array (domain_vars, values=&symptomList);
	array &CDCdomain._items(&domain_varsn) %DO_OVER(domain_vars, phrase=?_rev);
	array &CDCdomain._rates(&domain_varsn) %DO_OVER(domain_vars, phrase=?rate_Rev);
	/* Step1 Replace if any item was endorsed*/
		do i=1 to &domain_varsn;
			if &CDCdomain._items[i]=1 then &CDCdomain._Any=1;
			end;
	/*Step2 Identify if any items were endorsed as severe*/
	do i=1 to &domain_varsn;
		if &CDCdomain._rates[i]=3 then &CDCdomain._Sev=1;			
		if &CDCdomain._rates[i] in (&missing_values) then &CDCdomain.Rate_NumMiss= &CDCdomain.Rate_NumMiss+1; 
	 	end;
	 if &CDCdomain.Rate_NumMiss > 0 & &CDCdomain._Any=0	then &CDCdomain._Any= .	; *Any is missing if nothing is endorced and something is blank;
	 if &CDCdomain.Rate_NumMiss > 0 & &CDCdomain._Sev=0	then &CDCdomain._Sev=.	; *Sev is missing if nothing is severe and something is blank;
%mend;

*test each domain;
data CDC_Fatigue_Test1; 
	set CDC_Fatigue_Test;
	%calcCDCDomain(CDCdomain= CDC_Fatigue, symptomList = &CDCFatigueSymptomList , domainDescript= Fatigue);
	run;
proc freq data= CDC_Fatigue_Test1;
	tables CDC_Fatigue_Any*CDC_Fatigue_Any_Gold / MISSING NOCOL NOROW  nopercent;
	tables CDC_Fatigue_Sev*CDC_Fatigue_Sev_Gold / MISSING NOCOL NOROW  nopercent;
run;

/* 6 testcases for CDC Fatigue domain:
	Tests Passed:
		* 6 CDC_Fatigue_Any
		* 6 CDC_Fatigue_Sev
*/

data CDC_MuscSkel_Test1; 
	set CDC_MuscSkel_Test;
	%calcCDCDomain(CDCdomain= CDC_MuscSkel, symptomList = &CDCMuscSkelSymptomList , domainDescript= Musculoskeletal);
run;
proc freq data= CDC_MuscSkel_Test1;
	tables CDC_MuscSkel_Any*CDC_MuscSkel_Any_Gold / MISSING NOCOL NOROW  nopercent;
	tables CDC_MuscSkel_Sev*CDC_MuscSkel_Sev_Gold / MISSING NOCOL NOROW  nopercent;
run;

/* 216 testcases for CDC MuscSkel domain:
	Tests Passed:
		* 216 CDC_MuscSkel_Any
		* 216 CDC_MuscSkel_Sev
*/

data CDC_Mood_Test1; 
	set CDC_Mood_Test;
	%calcCDCDomain(CDCdomain= CDC_Mood, symptomList = &CDCMoodSymptomList , domainDescript= Mood and Cognition);
run;
proc freq data= CDC_Mood_Test1;
	tables CDC_Mood_Any*CDC_Mood_Any_Gold / MISSING NOCOL NOROW  nopercent;
	tables CDC_Mood_Sev*CDC_Mood_Sev_Gold / MISSING NOCOL NOROW  nopercent;
run;

/* 7776 testcases for CDC Mood domain:
	Tests Passed:
		* 7776 CDC_Mood_Any
		* 7776 CDC_Mood_Sev
*/


/* test GWI and GWI Severe */
*CDC_GWI_Test;
*CDC_GWI_Sev_Test;
data CDC_GWI_Test1; set CDC_GWI_Test;
	*Set up variables;
	CDC_GWI=.;
		label CDC_GWI = "Meets the CDC GWI Definition";
		format CDC_GWI l_yesno.;
	*Calculate CDC_GWI;
	%let  CDC_domains = CDC_Fatigue_Any, CDC_MuscSkel_Any, CDC_Mood_Any	;
	CDC_domains_Yes = SUM(&CDC_domains);	 *number of domains that are endorsed as yes;
		label CDC_domains_Yes = "Number of CDC domains endorsed as yes";
	CDC_domains_Miss = NMISS(&CDC_domains);  *number of domains that could not be determined as Y/N ;
		label CDC_domains_Miss = "Number of CDC domains that cannont be determined as yes or no";
	CDC_domains_No = 3 - CDC_domains_Yes - CDC_domains_Miss; *Number of domains that are endorsed as no;
		label CDC_domains_No = "Number of CDC domains endorsed as no";
	if CDC_domains_Yes >= 2 then CDC_GWI=1; * IFF 2 domains marked yes then GWI caseness is yes;
		else if  CDC_domains_No >= 2 then CDC_GWI = 0;	*IFF there are at least 2 No domains, the GWI caseness is no;
		else CDC_GWI = .; *otherwise we don't know enough to decide;
run;

proc freq data= CDC_GWI_Test1;
	tables CDC_GWI*CDC_GWI_Gold / MISSING NOCOL NOROW  nopercent;
run;

/* 27 testcases for CDC GWI :
	Tests Passed:
		* 27 CDC_GWI
*/

data CDC_GWI_Sev_Test1; set CDC_GWI_Sev_Test;
	*Set up variables;
	CDC_GWI_Sev=.;
		label CDC_GWI_Sev = "Meets the CDC GWI Definition, severe";
		format CDC_GWI_Sev CDC_GWI_Sev_Gold l_yesno.;
	*Calculate CDC_GWI_Sev;
	%let  CDC_domains_sev = CDC_Fatigue_Sev, CDC_MuscSkel_Sev, CDC_Mood_Sev	;
	CDC_domains_Yes_Sev = SUM(&CDC_domains_sev);	 *number of domains that are endorsed as severe;
		label CDC_domains_Yes_Sev = "Number of CDC severe domains endorsed as no";
	CDC_domains_Miss_Sev = NMISS(&CDC_domains_sev);  *number of domains that could not be determined as Y/N for severe;
		label CDC_domains_Miss_Sev = "Number of CDC severe domains that cannont be determined as yes or no";
	CDC_domains_No_Sev = 3 - CDC_domains_Yes_Sev - CDC_domains_Miss_Sev; *Number of domains that are endorsed as not severe;
		label CDC_domains_No_Sev = "Number of CDC severe domains endorsed as no";
	if CDC_domains_Yes_Sev >= 2 then CDC_GWI_Sev=1; * IFF 2 domains marked yes then GWI caseness is yes;
		else if  CDC_domains_No_Sev >= 2 then CDC_GWI_Sev = 0;	*IFF there are at least 2 No domains, the GWI caseness is no;
		else CDC_GWI_Sev = .; *otherwise we don't know enough to decide;
run;
proc freq data= CDC_GWI_Sev_Test1;
	tables CDC_GWI_Sev*CDC_GWI_Sev_Gold / MISSING NOCOL NOROW  nopercent;
run;

/* 27 testcases for CDC GWI Severe:
	Tests Passed:
		* 27 CDC_GWI_Sev
*/
*** CDC GWI and CDC GWI Severe test correct;

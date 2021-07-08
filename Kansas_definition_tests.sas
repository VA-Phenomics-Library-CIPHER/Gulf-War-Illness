*Macros setup;
filename  dr_macro "R:\CSP 585\AnalysisCode\585 Manuscripts\Caseness\CODE\SAS\ClayTightLoopingmacros";

%INCLUDE dr_macro('ARRAY.sas'); 
%INCLUDE dr_macro('DO_OVER.sas'); 
%INCLUDE dr_macro('NUMLIST.sas'); 

%macro importKS(KSdomain= );
PROC IMPORT OUT= KS_&KSdomain._Test
            DATAFILE= "R:\CSP 585\AnalysisCode\585 Manuscripts\Caseness\CODE\SAS\Tests\Update_2020_10_20\KS_domain_checks_final.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="&KSdomain.$"; 
     GETNAMES=YES;
%mend importKS;

%importKS(KSdomain = Fatigue)	;
%importKS(KSdomain = Pain)	 	;
%importKS(KSdomain = Mood)		;
%importKS(KSdomain = GI)		;
%importKS(KSdomain = Resp)		;
%importKS(KSdomain = Skin)		;
%importKS(KSdomain = GWI)  		;
%importKS(KSdomain = Excl);
run;


proc format;
	value l_yesno
		0= "No"
		1= "Yes" 
		. = "Missing"
		;
	run;
/* First, test that the conditions are reading in correctly */
%let exclCondList =	 CaBrain CaBrst CaColon CaLung CaPros CaOth 
			DoDM  
			CircHrtAtk CircCAD  CircCHF   
			CircStrk  CircTIA 
			IDHIV IDTB IDHepC
			DoLiver DoLupus
			MHSCZ MHBPD NSMS NSTBI ;
 data KS_Excl_Test;
		set KS_Excl_Test;
		%let missing_values= (. .a .b .c .d .e .f .g .h .g);
		*If exclusionary diagnoses change, edit this list and the labels at the bottom of the page;
		*Changed skin cancer to melanoma only;
		%Array(exclVars, values = &exclCondList);
		array Array_KS_Excl (&exclVarsn) %DO_OVER(exclVars, phrase=?);
		array Array_KS_Excl_yrdx (&exclvarsn) %DO_OVER(exclvars, phrase=?YrDx);
		array Array_KS_Excl_Rev (&exclVarsn) %DO_OVER(exclVars, phrase=?_Rev);
		do i=1 to &exclVarsn;
			Array_KS_Excl_Rev[i]= .;
			if Array_KS_Excl[i] = &no_var then Array_KS_Excl_Rev[i]= 0;
			if Array_KS_Excl[i] = &yes_var then Array_KS_Excl_Rev[i]= 1;	 
			if Array_KS_Excl_yrdx[i] not in (&missing_values) then Array_KS_Excl_Rev[i]=1; *revised exclusion is the original unless a dx year is recorded;
		end;
		KS_Excl=0;
		label KS_Excl = "Has 1 or more exclusion criteria";
		KS_Excl_Nummiss=0;
		label KS_Excl_Nummiss = "Number of missing exclusion items";
		KS_Excl_Count=0;
		label KS_Excl_Count = "Number of exclusion items endorsed as yes";
		do i=1 to &exclVarsn;	
			if Array_KS_Excl_Rev[i]=1 then KS_Excl=1;
			if Array_KS_Excl_Rev[i]=1 then KS_Excl_Count = KS_Excl_Count + 1;
			if Array_KS_Excl_Rev[i] in (&missing_values) then KS_Excl_Nummiss= KS_Excl_Nummiss+1;
		end;
		if KS_Excl=0 & KS_Excl_Nummiss>0 then KS_Excl=.; 
   		format %DO_OVER(exclVars, phrase=?_Rev) l_yesno.;
		format KS_Excl KS_Excl_Gold l_yesno.;
	run;

proc freq data=KS_Excl_Test;
	tables KS_Excl*KS_Excl_Gold / Missing norow nocol nopercent;
	tables KS_Excl_Count * KS_Excl_Count_Gold / Missing norow nocol nopercent;
	tables KS_Excl_NumMiss * KS_Excl_NumMiss_Gold / Missing norow nocol nopercent;
run;

/*The conditions appear to run well*/

/* next, test each domain */

%macro calcKSDomain(KSdomain= , symptomList = , domainDescript= );
	&KSdomain._Any=0;
		label &KSdomain._Any= " &domainDescript Domain: Endorsed at least 1 criteria";
	&KSdomain._Num=0;
		label &KSdomain._Num= " &domainDescript Domain: # of Items endorsed"	;
	&KSdomain._ModSev=0;
		label &KSdomain._ModSev= " &domainDescript Domain: Endorsed at least 1 criteria as moderate or severe";
	&KSdomain.Rate_NumMiss=0;  /* This variable is to store the number of missing items on severity*/
		label  &KSdomain.Rate_NumMiss= " &domainDescript Domain: # of items with missing severity rating";
 	&KSdomain._ModMult=0;
		label &KSdomain._ModMult = " &domainDescript Domain: Meets moderate to severe or multiple criteria";
	/* do the work to calculate accurate values for these variables */
	%array (domain_vars, values=&symptomList);
	array &KSdomain._items(&domain_varsn) %DO_OVER(domain_vars, phrase=?_rev);
	array &KSdomain._rates(&domain_varsn) %DO_OVER(domain_vars, phrase=?rate_Rev);
	/* Step1 a. Replace if any item was endorsed*/
		do i=1 to &domain_varsn;
			if &KSdomain._items[i]=1 then &KSdomain._Any=1;
	/* Step1 b. Count number of items endorsed*/
			if &KSdomain._items[i]=1 then &KSdomain._Num= &KSdomain._Num + 1;
		end;
	/*Step2 Identify if any items were endorsed as moderate or severe*/
	do i=1 to &domain_varsn;
		if &KSdomain._rates[i] in (.b, 2, 3) then &KSdomain._ModSev=1;			
		if &KSdomain._rates[i] in (&missing_values_notb) then &KSdomain.Rate_NumMiss= &KSdomain.Rate_NumMiss+1; 
	 end;
	 /* Step 3.  Does person meet Kansas moderate or multiple Domain */
	 if &KSdomain._Num >1 then &KSdomain._ModMult=1;
	 	else if &KSdomain._ModSev=1 then &KSdomain._ModMult=1;
		else if &KSdomain.Rate_NumMiss=0 then &KSdomain._ModMult=0;
		else &KSdomain._ModMult=.;
%mend;

data KS_Fatigue_Test; 
	set KS_Fatigue_Test;
	%let missing_values= (., .a, .b, .c, .d, .e, .f, .g, .h, .g);
	%let missing_values_notb = (., .a, .c, .d, .e, .f, .g, .h, .g);
	%calcKSDomain(KSdomain= KS_Fatigue, symptomList = SMoFatigue SMoGetSlp SMoRested SMoUnwel, domainDescript= Fatigue);
run;
data KS_Pain_Test; 
	set KS_Pain_Test;
	%let missing_values= (., .a, .b, .c, .d, .e, .f, .g, .h, .g);
	%let missing_values_notb = (., .a, .c, .d, .e, .f, .g, .h, .g);
	%calcKSDomain(KSdomain= KS_Pain, symptomList = SMoPain SMoMuscl SMoHurtOvr, domainDescript= Pain);
run;
data KS_Mood_Test; 
	set KS_Mood_Test;
	%let missing_values= (., .a, .b, .c, .d, .e, .f, .g, .h, .g);
	%let missing_values_notb = (., .a, .c, .d, .e, .f, .g, .h, .g);
	%calcKSDomain(KSdomain= KS_Mood, symptomList = SMoDReme SMoOutbur SMoNumb SMoHeadA SMoSLight SMoTFind SMoFDown  
	SMoDConct  SMoSweat SMoDizzy  SMoLowTol   SMoSmell SMoBlur  SMoShake, 
	domainDescript= Neurological Mood and Cognition);
run;
data KS_GI_Test; 
	set KS_GI_Test;
	%let missing_values= (., .a, .b, .c, .d, .e, .f, .g, .h, .g);
	%let missing_values_notb = (., .a, .c, .d, .e, .f, .g, .h, .g);
	%calcKSDomain(KSdomain= KS_GI, symptomList = SMoDiarr SMoNaus SMoAbdom, domainDescript= Gastrointestinal);
run;
data KS_Resp_Test; 
	set KS_Resp_Test;
	%let missing_values= (., .a, .b, .c, .d, .e, .f, .g, .h, .g);
	%let missing_values_notb = (., .a, .c, .d, .e, .f, .g, .h, .g);
	%calcKSDomain(KSdomain= KS_Resp, symptomList = SMoDBreath SMoFCough SMoWheez, domainDescript= Respiratory);
run;
data KS_Skin_Test; 
	set KS_Skin_Test;
	%let missing_values= (., .a, .b, .c, .d, .e, .f, .g, .h, .g);
	%let missing_values_notb = (., .a, .c, .d, .e, .f, .g, .h, .g);
	%calcKSDomain(KSdomain= KS_Skin, symptomList = SMoRash SMoSkin, domainDescript= Skin) ;
run;

proc freq data=KS_Fatigue_Test;
	tables KS_Fatigue_Any*KS_Fatigue_Any_Gold / Missing norow nocol nopercent;
	tables KS_Fatigue_ModSev*KS_Fatigue_ModSev_Gold / Missing norow nocol nopercent;
	tables KS_Fatigue_Num*KS_Fatigue_Num_Gold / Missing norow nocol nopercent;
	tables KS_FatigueRate_NumMiss*KS_Fatigue_RateNumMiss_Gold / Missing norow nocol nopercent;
	tables KS_Fatigue_ModMult*KS_Fatigue_MultSev_Gold / Missing norow nocol nopercent;
run;
proc freq data=KS_Pain_Test;
	tables KS_Pain_Any*KS_Pain_Any_Gold / Missing norow nocol nopercent;
	tables KS_Pain_ModSev*KS_Pain_ModSev_Gold / Missing norow nocol nopercent;
	tables KS_Pain_Num*KS_Pain_Num_Gold / Missing norow nocol nopercent;
	tables KS_PainRate_NumMiss*KS_Pain_RateNumMiss_Gold / Missing norow nocol nopercent;
	tables KS_Pain_ModMult*KS_Pain_MultSev_Gold / Missing norow nocol nopercent;
run;
proc freq data=KS_Mood_Test;
	tables KS_Mood_Any*KS_Mood_Any_Gold / Missing norow nocol nopercent;
	tables KS_Mood_ModSev*KS_Mood_ModSev_Gold / Missing norow nocol nopercent;
	tables KS_Mood_Num*KS_Mood_Num_Gold / Missing norow nocol nopercent;
	tables KS_MoodRate_NumMiss*KS_Mood_RateNumMiss_Gold / Missing norow nocol nopercent;
	tables KS_Mood_ModMult*KS_Mood_MultSev_Gold / Missing norow nocol nopercent;
run;
proc freq data=KS_GI_Test;
	tables KS_GI_Any*KS_GI_Any_Gold / Missing norow nocol nopercent;
	tables KS_GI_ModSev*KS_GI_ModSev_Gold / Missing norow nocol nopercent;
	tables KS_GI_Num*KS_GI_Num_Gold / Missing norow nocol nopercent;
	tables KS_GIRate_NumMiss*KS_GI_RateNumMiss_Gold / Missing norow nocol nopercent;
	tables KS_GI_ModMult*KS_GI_MultSev_Gold / Missing norow nocol nopercent;
run;
proc freq data=KS_Resp_Test;
	tables KS_Resp_Any*KS_Resp_Any_Gold / Missing norow nocol nopercent;
	tables KS_Resp_ModSev*KS_Resp_ModSev_Gold / Missing norow nocol nopercent;
	tables KS_Resp_Num*KS_Resp_Num_Gold / Missing norow nocol nopercent;
	tables KS_RespRate_NumMiss*KS_Resp_RateNumMiss_Gold / Missing norow nocol nopercent;
	tables KS_Resp_ModMult*KS_Resp_MultSev_Gold / Missing norow nocol nopercent;
run;
proc freq data=KS_Skin_Test;
	tables KS_Skin_Any*KS_Skin_Any_Gold / Missing norow nocol nopercent;
	tables KS_Skin_ModSev*KS_Skin_ModSev_Gold / Missing norow nocol nopercent;
	tables KS_Skin_Num*KS_Skin_Num_Gold / Missing norow nocol nopercent;
	tables KS_SkinRate_NumMiss*KS_Skin_RateNumMiss_Gold / Missing norow nocol nopercent;
	tables KS_Skin_ModMult*KS_Skin_MultSev_Gold / Missing norow nocol nopercent;
run;

/* These match! Only difference is not having missing in ModSev category*/
data KS_GWI_Test1; set KS_GWI_Test;
	KS_GWI_ModMult_SC=.;
		label KS_GWI_ModMult_SC = "Meets the Kansas GWI Symptom Criteria";
	%let  KS_domains = KS_Fatigue_ModMult, KS_Pain_ModMult, KS_Mood_ModMult, KS_GI_ModMult, KS_Resp_ModMult, KS_Skin_ModMult	;
	KS_domains_Yes = SUM(&KS_domains);	 *number of domains that are endorsed as moderate/severe or multiple;
	if KS_domains_Yes = . then KS_domains_Yes = 0; *if all are missing, the sum will be missing, but we want it to be zero;
	label KS_domains_Yes = "Numer of Kansas domains endorsed as yes";
	KS_domains_Miss = NMISS(&KS_domains);  *number of domains that could not be determined as Y/N for moderate/severe or multiple;
	label KS_domains_Miss = "Numer of Kansas domains that cannot be determined as yes or no";
	KS_domains_No = 6 - KS_domains_Yes - KS_domains_Miss; *Number of domains that are endorsed as not moderare/severe or multiple;
	label KS_domains_No = "Numer of Kansas domains endorsed as no";
	if KS_domains_Yes>= 3 then	KS_GWI_ModMult_SC=1; * IFF 3 domains marked yes then GWI caseness is yes;
		else if  KS_domains_No >= 4 then KS_GWI_ModMult_SC = 0;	*IFF there are at least 4 No	domains, the GWI caseness is no;
		else KS_GWI_ModMult_SC = .; *otherwise we don't know enough to decide;
run;
data KS_GWI_Test2; set KS_GWI_Test1;
	KS_GWI =0;
		label KS_GWI = "Kansas Gulf War Illness Caseness Indicator";
		format KS_GWI l_yesno.;
	if KS_Excl = 0 & KS_GWI_ModMult_SC = 1 then KS_GWI = 1;	 *Veterans with no exclusionary criteria who fit the symptoms criteria are marked 1; 
		else if KS_Excl = 1 & KS_GWI_ModMult_SC = 1 then KS_GWI = 0; *Veterans with exclusionary criteria who fit the symptoms criteria are marked 0;
		else if KS_Excl = 1 & KS_GWI_ModMult_SC = 0 then KS_GWI = 0; *Veterans with exclusionary criteria who don't fit the symptoms criteria are marked 0;
		else if KS_Excl = 0 & KS_GWI_ModMult_SC = 0 then KS_GWI = 0; *Veterans with no exclusionary criteria who don't fit the symptoms criteria are marked 0;
		else KS_GWI = . ;											  *All other veterans are marked missing;
run;
proc freq data=KS_GWI_Test2;
	tables KS_GWI*KS_GWI_Gold / Missing norow nocol nopercent;
	tables KS_GWI_ModMult_SC*KS_GWI_SC_Gold / Missing norow nocol nopercent;
run;

/* These match! */

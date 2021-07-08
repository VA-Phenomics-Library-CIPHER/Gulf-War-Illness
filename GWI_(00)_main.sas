
/***************************************************************
 ** This code calculates GWI status and related GWI variables **
 ***************************************************************/

/*To Use:
	0. read file called "readme"
	1. replace path in each filename syntax with the path to the proper files on your machine
	2. be sure to have saved all included files in the same folder and do not change any file names
	3. replace %let statements below with corresponding variable names from your dataset
	4. replace code beneath "Step 1.  Read in the Data" with code to read in data from your dataset
	5. uncomment block at lines 129-139 to test that the code is properly working with your dataset. This will generate a lot of tables when run so be patient.
	6. run this file
	7. save the sas dataset "GWI_PartC2" to use the GWI case status and related variables in future work
*/

*Path setup;

filename syntax "R:\CSP 585\AnalysisCode\585 Manuscripts\Methods for Caseness\ReviseAndResubmit";  *this is the path to the folder where all included files are saved;

*Macros setup;
/* %Do_Over, %Array, and %Numlist Authors: Ted Clay, M.S. and David Katz, M.S. "Please keep, use and pass on the ARRAY and DO_OVER macros with this authorship note. "
		Full documentation with examples appears in SUGI Proceedings, 2006, "Tight Looping With Macro Arrays" by Ted Clay */

%INCLUDE syntax('ARRAY.sas'); 
%INCLUDE syntax('DO_OVER.sas'); 
%INCLUDE syntax('NUMLIST.sas'); 

/*Step 0. Edit 'quick change' pieces of the code
	- Missing values (inlcuding multiple answers)
	- yes/no values
	- mild, moderate, and severe symptom values
	- Kansas definition: exclusionary conditions
	- Symptom variable names
	- Kansas definition: symptoms in domains
	- CDC definition: symptoms in domains */

	*Missing Values;
	%let missing_values= . .a .b .c .d .e .f .g .h .g ;
	%let multiple_answers= .b ;
	%let missing_values_notb = . .a .c .d .e .f .g .h .g ;	 *this doesn't include 'multiple answers', allowing multiple answers to count for moderate to multiple;

	*Yes/No values;
	%let yes_var = 1 ;
	%let no_var = 0 ;

	*Mild/Moderate/Severe symptom values;
	%let mild_var = 0 ;
	%let moderate_var = 1 ;
	%let severe_var = 2;

	*Kansas definition: exclusionary conditions;
	%let exclCondList =   CaBrain CaBrst CaColon CaLung CaPros CaOth 
			DoDM  
			CircHrtAtk CircCAD  CircCHF   
			CircStrk  CircTIA 
			IDHIV IDTB IDHepC
			DoLiver DoLupus
			MHSCZ MHBPD NSMS NSTBI ;
	*all symptoms;
	%let allSymptomsList = SMoFatigue	SMoUnwel	SMoGetSlp	SMoRested	SMoPain	SMoStiff	
	SMoMuscl	SMoHurtOvr	SMoHeadA	SMoDizzy	SMoSLight	SMoBlur	SMoNumb	SMoShake	SMoLowTol	
	SMoSweat	SMoSmell	SMoRash	SMoSkin	SMoDiarr	SMoNaus	SMoAbdom	SMoDBreath	SMoFCough	SMoWheez	
	SMoSThroat	SMoLymph	SMoDConct	SMoDReme	SMoTFind	SMoFDown	SMoOutbur	SMoMoody	SMoAnxio ;

	*Kansas definition: symptoms in domains;
	%let KSFatigueSymptomList = SMoFatigue SMoGetSlp SMoRested SMoUnwel ;
	%let KSPainSymptomList = SMoPain SMoMuscl SMoHurtOvr ;
	%let KSMoodSymptomList = SMoDReme SMoOutbur SMoNumb SMoHeadA SMoSLight SMoTFind SMoFDown  SMoDConct  SMoSweat SMoDizzy  SMoLowTol   SMoSmell SMoBlur  SMoShake   ;
	%let KSGISymptomList = SMoDiarr SMoNaus SMoAbdom  ;
	%let KSRespSymptomList = SMoDBreath SMoFCough SMoWheez ;
	%let KSSkinSymptomList = SMoRash SMoSkin;

	*CDC definition: symptoms in domains;
	%let CDCFatigueSymptomList = SMoFatigue ;
	%let CDCMuscSkelSymptomList =  SMoPain SMoMuscl SMoStiff ;
	%let CDCMoodSymptomList =  SMoDReme SMoTFind SMoFDown  SMoDConct SMoMoody  SMoAnxio SMoGetSlp ;

/**Step 1.  Read in the Data**/
	
	proc sql;
   connect to odbc(dsn='CSP_ProdCSP585');
   CREATE TABLE new AS 
	SELECT * 
	FROM CONNECTION TO ODBC(
   	SELECT *
   		FROM CSP_ProdCSP585.Res.vwTeleformSurveyParent_CombinedLogic
		;
	);
	disconnect from odbc;
	quit;

/*Step 2. Label Variables and Labels-- insert code here if you want to label your data */


************************************;
/* Gulf War Illness specific work */
************************************;

*Creates formats for yesno, rate, and revised rate;
  	%INCLUDE syntax('GWI_(01)_Setup.sas');
run;
*Creates 'symptom'_Rev and 'symptom'Rate_Rev;
*Creates dataset GWI_PartA;
  	%INCLUDE syntax('GWI_(02)_PartA.sas');
run;
/*Kansas Specific*/
*Creates KS_Excl and KS_Excl_Nummiss;
*Creates dataset GWI_PartB1 from GWI_PartA;
  	%INCLUDE syntax('GWI_(03)_KS_PartB1.sas');
run;
*Calculates the 6 KS Domains (Moderate or Multiple);
*Creates dataset GWI_PartB2 from GWI_PartA;
  	%INCLUDE syntax('GWI_(04)_KS_PartB2_Domains.sas');
run;
*Creates the KS Symptom Criteria;
*Creates dataset GWI_PartB3 from GWI_PartB2;
  	%INCLUDE syntax('GWI_(05)_KS_PartB3.sas');
run;
*Calculates KS GWI Caseness;
*Creates dataset GWI_PartB4 from GWI_PartB3;
  	%INCLUDE syntax('GWI_(06)_KS_PartB4.sas');
run;
/*CDC Specific*/
*Calculates the 3 CDC symptom domains, Any and Severe;
*Creates dataset GWI_PartC1 from GWI_PartB4;
	%INCLUDE syntax('GWI_(07)_CDC_PartC1.sas');
run;
*Calculates CDC GWI Caseness: Any and Severe;
*Creates dataset GWI_PartC2 from GWI_PartC1;
  	%INCLUDE syntax('GWI_(08)_CDC_PartC2.sas');
run;


/* * uncomment this whole block to make sure that your symptoms are being properly recoded ;
%macro checkSymptoms(symptomName= );
	proc freq data = GWI_PartC2;
	tables &symptomName * &symptomName._rev /missing;
	run;
	proc freq data = GWI_PartC2;
	tables &symptomName.rate * &symptomName.rate_rev /missing;
	run;
%mend;
%array (symptomsList_test, values=&allSymptomsList);
%DO_OVER(symptomsList_test, phrase=%checkSymptoms(symptomName=?);)  ;	*/
																 

*******************************************************************************
** This describes the code to calculate GWI status and related GWI variables **
*******************************************************************************

This code was originally written for the CSP585 dataset (survey attached) and was adapted for the MVP Gulf War cohort. Because of this, you may need to adapt the code for your use.  This can be done by (1) modifying all of the statements that begin with "%let", (2) replacing the data import step with your own data import step, and (3) adding any labels that you would like to go with your data.  

(1) Edit the %let statements

	- You may wonder: what are these "%let" statements?  They are just a way of pulling the parts of the code that may change to the beginning, so that you can change them once, right at the beginning, to match your dataset and then the code will just work. If your survey looks similar to the CSP585 survey in terms of chronic symptoms and self-reported clinical conditions, you can just replace the variable names we have listed with your variable names.
		- two exceptions, renaming these variables in a preprocessing step is likely the easiest fix for this.: 
			1. We assume that there is a "year diagnosed" variable for each clinical condition. The code assumes that this year told variable is called "<clinicalCondition>YrDx", where <clinicalCondition> is the clinical condition variable name. 
			2. We assume that there is a "symptom rating" variable for each chronic symptom.  The code assumes that this rating is called "<symptom>rate", where <symptom> is the symptom variable name.
		- to do this, replace everything from between the < > signs with the values described inside them. Then delete the '<' and '>' characters.  Do not delete or change anything before the '=' or the ';' at the end. Also do not delete anything after the * on each line, either (these are comments to help you read the code and will not do anything as long as you leave the '*' and ';' characters alone)

The following is a list of the %let statements that should be changed:

	*Missing Values; 
	%let missing_values= <fill in a list here with all missing value indicators. Deliminate list with spaces, not commas.> ; 
	%let multiple_answers= <fill in your indicator (or list of indicators, spaces and no commas) for 'multiple answers'> ;
	%let missing_values_notb = <fill in a list here with all missing value indicators except for the missing value indicator. Deliminate list with spaces, not commas.> ;	 *this doesn't include 'multiple answers', allowing multiple answers to count for moderate to multiple;

	*Yes/No values;
	%let yes_var = <insert single value for yes here> ;
	%let no_var = <insert single value for no here> ;

	*Mild/Moderate/Severe symptom values;
	%let mild_var = <insert single value for mild here> ;
	%let moderate_var = <insert single value for moderate here> ;
	%let severe_var = <insert single value for severe here>;

	*Kansas definition: exclusionary conditions;
	%let exclCondList =   <insert list of exclusionary conditions here. Our team agreed on these conditions: Brain cancer, breast cancer, colon cancer, lung cancer, prostate cancer, other cancer, melanoma, diabetes, heart attack, CAD, CHF, stroke, TIA, HIV, tuberculosis, hepatitis C, liver disease, lupus, schizophrenia, bipolar disorder, multiple sclerosis, and traumatic brain injury. Deliminate list with spaces, not commas.>;
	*all symptoms;
	%let allSymptomsList = <insert list of all chronic symptoms here. Deliminate list with spaces, not commas.> ;

	*Kansas definition: symptoms in domains;
	%let KSFatigueSymptomList = <insert list of chronic symptom for the Kansas Fatigue domain here. Our list was: fatigue, trouble getting to or staying asleep, not feeling rested after sleep, and feeling unwell after exercise. Deliminate list with spaces, not commas.> ;
	%let KSPainSymptomList = <insert list of chronic symptom for the Kansas Fatigue domain here. Our list was: fatigue, trouble getting to or staying asleep, not feeling rested after sleep, and feeling unwell after exercise. Deliminate list with spaces, not commas.> ;
	%let KSMoodSymptomList = <insert list of chronic symptom for the Kansas Neurological/mood/cognitive domain here. Our list was: difficulty remembering recent information, feeling irritable or having angry outbursts, numbness or tingling in extremities, headaches, eyes very sensitive to light, trouble finding words when speaking, feeling down or depressed, difficulty concentrating, night sweats, feeling dizzy, lightheaded, or faint, low tolerance for heat or cold, physical or mental symptoms in response to smells or chemicals, blurred or double vision, and tremors or shaking. Deliminate list with spaces, not commas.> ;
	%let KSGISymptomList = <insert list of chronic symptom for the Kansas Gastrointestinal domain here. Our list was: diarrhea, nausea or upset stomach, abdominal pain or cramping. Deliminate list with spaces, not commas.> ;
	%let KSRespSymptomList = <insert list of chronic symptom for the Kansas Respiratory domain here. Our list was: difficulty breathing or shortness of breath, frequent coughing without a cold, and wheezing in chest. Deliminate list with spaces, not commas.> ;
	%let KSSkinSymptomList = <insert list of chronic symptom for the Kansas Skin domain here. Our list was: skin rashes, and other skin problems. Deliminate list with spaces, not commas.> ;

	*CDC definition: symptoms in domains;
	%let CDCFatigueSymptomList = <insert list of chronic symptom for the CDC Fatigue domain here. Our list was: fatigue. Deliminate list with spaces, not commas.> ;
	%let CDCMuscSkelSymptomList =  <insert list of chronic symptom for the CDC Musculoskeletal domain here. Our list was: pain in joints, pain in muscles, and stiffness in joints. Deliminate list with spaces, not commas.> SMoPain SMoMuscl SMoStiff ;
	%let CDCMoodSymptomList =  <insert list of chronic symptom for the CDC Mood/Cognition domain here. Our list was: difficulty remembering recent information, trouble finding words when speaking, feeling down or depressed, difficulty concentrating, feeling moody, feeling anxious, and difficulty getting to or staying asleep. Deliminate list with spaces, not commas.> ;


(2) Read in your data

To change this one, you can either keep the SQL method (replacing the 'CSP_ProdCSP585' and the path after the "FROM" (starred below) with the location of your data) or you can import it using SAS from any SAS or CSV file.  Just replace everything between the "/**Step 1.  Read in the Data**/" and "/*Step 2. Label Variables and Labels-- insert code here if you want to label your data */" lines with the code to read in your data. Name the data 'new'.

/**Step 1.  Read in the Data**/
	
	proc sql;
   connect to odbc(dsn='CSP_ProdCSP585'); ***** change the bit in quotes ;
   CREATE TABLE new AS 
	SELECT * 
	FROM CONNECTION TO ODBC(
   	SELECT *
   		FROM CSP_ProdCSP585.Res.vwTeleformSurveyParent_CombinedLogic  ***** this is where you can put in your SQL path, change the piece after the "FROM" statement ;
		;
	);
	disconnect from odbc;
	quit;

(3) Label your data

Just fill in any labels that you'd like below the "/*Step 2. Label Variables and Labels-- insert code here if you want to label your data */" comment.  You don't need to do this, we leave this here as an option for those who like labeled data.  We did label our data but have left that out to minimize confusion. See the '01' file for an example of how to label data.

/*Step 2. Label Variables and Labels-- insert code here if you want to label your data */







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
data GWI_PartC1; 
	set GWI_PartB4;
	%calcCDCDomain(CDCdomain= CDC_Fatigue, symptomList = &CDCFatigueSymptomList , domainDescript= Fatigue);
	%calcCDCDomain(CDCdomain= CDC_MuscSkel, symptomList = &CDCMuscSkelSymptomList , domainDescript= Musculoskeletal);
	%calcCDCDomain(CDCdomain= CDC_Mood, symptomList = &CDCMoodSymptomList , domainDescript= Mood and Cognition);
run;

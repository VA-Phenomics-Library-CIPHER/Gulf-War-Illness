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
		if &KSdomain._rates[i] in (.b 2 3) then &KSdomain._ModSev=1;			
		if &KSdomain._rates[i] in (&missing_values_notb) then &KSdomain.Rate_NumMiss= &KSdomain.Rate_NumMiss+1; 
	 end;
	 /* Step 3.  Does person meet Kansas moderate or multiple Domain */
	 if &KSdomain._Num >1 then &KSdomain._ModMult=1;
	 	else if &KSdomain._ModSev=1 then &KSdomain._ModMult=1;
		else if &KSdomain.Rate_NumMiss=0 then &KSdomain._ModMult=0;
		else &KSdomain._ModMult=.;
%mend;
data GWI_PartB2; 
	set GWI_PartB1;
	%calcKSDomain(KSdomain= KS_Fatigue, symptomList = &KSFatigueSymptomList, domainDescript= Fatigue);
	%calcKSDomain(KSdomain= KS_Pain, symptomList = &KSPainSymptomList, domainDescript= Pain);
	%calcKSDomain(KSdomain= KS_Mood, symptomList = &KSMoodSymptomList, domainDescript= Neurological Mood and Cognition);
	%calcKSDomain(KSdomain= KS_GI, symptomList = &KSGISymptomList, domainDescript= Gastrointestinal);
	%calcKSDomain(KSdomain= KS_Resp, symptomList = &KSRespSymptomList, domainDescript= Respiratory);
	%calcKSDomain(KSdomain= KS_Skin, symptomList = &KSSkinSymptomList, domainDescript= Skin) ;
run;

proc format;
		value l_yesno
			&no_var= "No"
			&yes_var= "Yes" 
			. = "Missing"
			;
		value l_Rate
			&mild_var="Mild"
			&moderate_var="Moderate"
			&severe_var="Severe"
			. = "Missing"
			&multiple_answers = "Multiple answers"
			;
		value  l_RevisedRate
			0="No, None"
			1="Yes, Mild"
			2="Yes, Moderate"
			3="Yes, Severe"
			. = "Missing"
			&multiple_answers = "Yes, multiple answers"
			;
		run;

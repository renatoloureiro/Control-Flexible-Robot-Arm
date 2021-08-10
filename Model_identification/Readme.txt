----------------------------------- Read me ----------------------------------------

	To run a simple simulation use 'BasicSim.m'
		It is also able to determine a model using ARMAX for the given input
		and output signal - it is necessary to specify the ARMAX parameters


	To run a simulation to determine the best parameters estimations given 
	a certain test set for evaluate model use 'IdentificationAlgorithm_best.m'
	OUTPUT: - writes information in data_identification.txt
		- writes the best cases for a certain na value in 'best_cases.txt'
		- Create variable 'Data' in matlab workspace where it can be found 
		the following configuration of this struct:
			["name of input signal", frequency, na.nb,nc,nk, FIT]
		  NOTE: it only has the best cases for each na in the loop
		  	Currently the name of the input signal is "PRBS"		
------------------------------------------------------------------------------------
	
	Authors:	Renato Loureiro,	89708
			Pedro Sarnadas,		86673
			Tiago Santos,		87290	
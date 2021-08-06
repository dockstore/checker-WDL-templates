version 1.0

# Author: Ash O'Farrell (UCSC)

import "https://raw.githubusercontent.com/aofarrel/checker-WDL-templates/main/arraycheck_task.wdl" as module1

workflow arraycheck_wf {
	input {
		File SB_nullmodel
		File SB_pheno
		File SB_report
		File SB_report_invnorm
		File local_nullmodel
		File local_pheno
		File local_report
		File local_report_invnorm
	}

	call module1.arraycheck {
		input:
			test = [local_nullmodel, local_pheno, local_report, local_report_invnorm],
			truth = [SB_nullmodel, SB_pheno, SB_report, SB_report_invnorm]
	}

}
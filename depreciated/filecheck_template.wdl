version 1.0

# Author: Ash O'Farrell (UCSC)
#
# This WDL is designed as a template for checker workflows. Make sure to import your WDL as an https:// URI,
# or, if your backend doesn't support imports, copy-paste your entire workflow in here.

import "https://raw.githubusercontent.com/aofarrel/checker-WDL-templates/main/filecheck_task.wdl" as filecheck
# put your wf import here!

workflow filecheck_wf {
	input {
		File SB_report
		File local_report
	}

	call module1.filecheck {
		input:
			test = local_report,
			truth = SB_report
	}

}
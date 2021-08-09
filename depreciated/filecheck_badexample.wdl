version 1.0

# Author: Ash O'Farrell (UCSC)
#
# This WDL is designed to run filecheck on some bogus files. A real checker workflow should instead
# be running the original workflow -- please see filecheck_template.wdl for that!

import "https://raw.githubusercontent.com/aofarrel/checker-WDL-templates/main/filecheck_task.wdl" as module1

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
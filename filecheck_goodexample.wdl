version 1.0

# Author: Ash O'Farrell (UCSC)
#
# This is an example of how to use a checker workflow.

import "https://raw.githubusercontent.com/aofarrel/checker-WDL-templates/main/filecheck_task.wdl" as checker
import "https://raw.githubusercontent.com/aofarrel/goleft-wdl/main/goleft_functions.wdl" as goleft_wf

workflow filecheck_wf {
	input {
		File SB_report
		File local_report
	}

	call goleft_wf.goleft_functions {
			input {
				Array[File] inputBamsOrCrams
				Array[File]? inputIndexes
				File? refGenome
				Boolean forceIndexcov = true
		}
	}

	call checker.filecheck {
		input:
			test = local_report,
			truth = SB_report
	}

}
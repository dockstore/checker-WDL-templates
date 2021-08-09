version 1.0

import "tobechecked.wdl" as check_me
import "arraycheck_task.wdl" as checkmate

# How to use:
# Workflow outputs single Array[File] --> call arraycheck_classic
# Workflow outputs several Files, all of which are required --> call arraycheck_classic
# Workflow outputs optional Array[File] --> call arraycheck_optional
# Workflow outputs several Files, some of which are required --> call arraycheck_classic with select_firsts

# To do:
# Workflow outputs single file

workflow checker {
	input {
		# These should match the inputs of the workflow being checked
		File? optionalInput
		File requiredInput
	}

	call blank

	call check_me.optOuts {
		input:
			optionalInput = optionalInput,
			requiredInput = requiredInput
	}

	call checkmate.arraycheck_classic as nonscatteredChecker {
		input:
			# bizz, bar, foo in that order
			test = [optOuts.required_out, select_first([optOuts.booleanOptional_out, blank.bogus]), select_first([optOuts.singularOptional_out, blank.bogus])],
			truth = [optOuts.required_out, optOuts.required_out]
	}

	#if !(defined(optOuts.scatteredOptional_out)) {
		# output a bogus, then in next task have that bogus be first in select_first?
	#}

	# this defined check does not change the type of scatteredOptional_out from Array[File]? to Array[File]
	# therefore, arraycheck needs to be able to take in Array[File]? for this to work
	# we could then have arraycheck see if the test array is defined and exit out if not, but this wastes time downloading truth array
	if (defined(optOuts.scatteredOptional_out)) {
		call checkmate.arraycheck_optional as scatteredChecker {
			input:
				test = optOuts.scatteredOptional_out,
				truth = [optOuts.required_out, optOuts.required_out]
		}
	}
}

task blank {
	input {
		Int? nada
	}

	command <<<
		touch "dummy_file.txt"
	>>>
	
	output {
		File bogus = "dummy_file.txt"
	}

	runtime {
		#docker: "quay.io/aofarrel/goleft-covstats:circleci-push"
		preemptible: 3
		memory: 2 + "G"
	}
}

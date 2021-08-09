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

	# Run the workflow to be checked
	call check_me.run_example_wf {
		input:
			optionalInput = optionalInput,
			requiredInput = requiredInput
	}

	# Check an array of files, wherein SOME of the files in that array might not be defined
	# Any files that might not be defined need to fall back on a file that does exist, which
	# can be done easily by passing in a bogus file
	call checkmate.arraycheck_classic as nonscatteredChecker {
		input:
			test = [run_example_wf.wf_always, select_first([run_example_wf.wf_never, blank.bogus]), select_first([run_example_wf.wf_sometimesSingle, blank.bogus])],
			truth = [run_example_wf.wf_always, run_example_wf.wf_always]
	}

	# Check an array of files, wherein the ENTIRE array might not be defined
	if (defined(run_example_wf.wf_sometimesScattered)) {
		call checkmate.arraycheck_optional as scatteredChecker {
			input:
				test = run_example_wf.wf_sometimesScattered,
				truth = [run_example_wf.wf_always, run_example_wf.wf_always]
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

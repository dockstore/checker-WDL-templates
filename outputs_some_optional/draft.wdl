version 1.0

import "example_opt.wdl" as check_me
import "../tasks/arraycheck_task.wdl" as checker_array
import "../tasks/filecheck_task.wdl" as checker_file

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

		# These are specific to the checker itself
		File singleTruth
		Array[File] arrayTruth
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
	# can be done easily by passing in a bogus file, which we assume does not have a match
	# in the truth array.
	call checker_array.arraycheck_classic as nonscatteredChecker {
		input:
			test = [run_example_wf.wf_always, select_first([run_example_wf.wf_never, blank.bogus]), select_first([run_example_wf.wf_sometimesSingle, blank.bogus])],
			truth = arrayTruth
	}

	# Check an array of files, wherein the ENTIRE array might not be defined
	if (defined(run_example_wf.wf_sometimesScattered)) {
		call checker_array.arraycheck_optional as scatteredChecker {
			input:
				test = run_example_wf.wf_sometimesScattered,
				truth = arrayTruth
		}
	}

	# Here, we include a check for a single optional file. In the original workflow we implied
	# it is never created, but in practice you can find use for this in files that only created
	# if the user specifies a certain input flag. By including a defined() check beforehand,
	# we avoid actually calling the task unless the test file actually exists, which will save
	# us time and compute credits. Without this defined() check, the task will spin up as the
	# task considers test to be an optional input, but will fail upon execution if test does not
	# exist due to how the task is written.
	if (defined(run_example_wf.wf_never)) {
		call checker_file.filecheck as singleChecker {
			input:
				test = run_example_wf.wf_never,
				truth = singleTruth
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

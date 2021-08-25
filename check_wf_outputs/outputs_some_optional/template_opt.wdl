version 1.0

# Replace the first URL here with the URL of the workflow to be checked.
import "https://raw.githubusercontent.com/dockstore/checker-WDL-templates/debug-terra/check_wf_outputs/outputs_some_optional/parent_opt.wdl" as check_me
import "https://raw.githubusercontent.com/dockstore/checker-WDL-templates/debug-terra/checker_tasks/filecheck_task.wdl" as verify_file
import "https://raw.githubusercontent.com/dockstore/checker-WDL-templates/debug-terra/checker_tasks/arraycheck_task.wdl" as verify_array

workflow checker {
	input {
		# These should match the inputs of the workflow being checked
		File? optionalInput
		File requiredInput

		# These are specific to the checker itself
		File singleTruth
		File magicTruth
		Array[File] arrayTruth
	}

	# Run the workflow to be checked
	call check_me.run_example_wf {
		input:
			optionalInput = optionalInput,
			requiredInput = requiredInput
	}

	# Call extra task to generate a fallback file -- only needed if you have a File? which
	# may or may not exist when this checker workflow is run. See below for more details.
	call fallback

	# Here we run filechecker as a scattered task. One iteration will take a file that does
	# exist, and the other takes a file that does not exist.
	# While this works on some backends, it will fail on Terra.
	#scatter(difficult_word in [run_example_wf.wf_magicword, run_example_wf.wf_nonexistent]) {
	#	call verify_file.filecheck as scatteredSingleCheckerInvalidOnTerra {
	#		input:
	#			test = difficult_word,
	#			truth = magicTruth
	#	}
	#}
	
	# So we tried this instead... but it doesn't work
	scatter(difficult_word in [run_example_wf.wf_magicword, select_first([run_example_wf.wf_nonexistent, fallback.bogus])]) {
		call verify_file.filecheck as scatteredSingleChecker {
			input:
				test = difficult_word,
				truth = magicTruth
		}
	}

	# Neither does this.
	call verify_array.arraycheck_classic as nonscatteredChecker {
		input:
			test = [run_example_wf.wf_always, select_first([run_example_wf.wf_nonexistent, fallback.bogus])]
			truth = arrayTruth
	}

	# Funnily enough, this works, even though wf_never also does not exist
	call verify_array.arraycheck_classic as nonscatteredChecker {
		input:
			test = [run_example_wf.wf_always, select_first([run_example_wf.wf_never, fallback.bogus])]
			truth = arrayTruth
	}

	# And this works too. Again, the file does not exist, and the fallback happens as expected.
	call verify_array.arraycheck_classic as nonscatteredChecker {
		input:
			test = [run_example_wf.wf_always, select_first([run_example_wf.wf_never, fallback.bogus])]
			truth = arrayTruth
	}

}

task fallback {
	input {
		Int? unused
	}

	command <<<
		touch "fallback_file.txt"
	>>>
	
	output {
		File bogus = "fallback_file.txt"
	}

	runtime {
		docker: "quay.io/aofarrel/goleft-covstats:circleci-push"
		preemptible: 3
		memory: 2 + "G"
	}
}

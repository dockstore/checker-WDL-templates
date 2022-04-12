version 1.0

# Copyright 2021 Aisling "Ash" O'Farrell
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#       http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# In summary:
# Workflow outputs single Array[File] --> call arraycheck_classic
# Workflow outputs several Files, all of which are required --> call arraycheck_classic
# Workflow outputs optional Array[File] --> call arraycheck_optional
# Workflow outputs several Files, some of which are required --> call arraycheck_classic with select_first()
# Workflow outputs single File, which is required --> call filecheck
# Workflow outputs optional File --> call filecheck but put in a defined() check before the task call or use select_first()

# Replace the first URL here with the URL of the workflow to be checked.
#import "https://raw.githubusercontent.com/dockstore/checker-WDL-templates/v1.1.0/check_wf_outputs/outputs_some_optional/parent_opt.wdl" as check_me
#import "https://raw.githubusercontent.com/dockstore/checker-WDL-templates/v1.1.0/checker_tasks/filecheck_task.wdl" as verify_file
#import "https://raw.githubusercontent.com/dockstore/checker-WDL-templates/v1.1.0/checker_tasks/arraycheck_task.wdl" as verify_array

# If running this locally, you can import tasks with relative paths, like this:
import "parent_opt.wdl" as check_me
import "../../checker_tasks/filecheck_task.wdl" as verify_file
import "../../checker_tasks/arraycheck_task.wdl" as verify_array


workflow checker {
	input {
		# These should match the inputs of the workflow being checked
		File? optionalInput
		File requiredInput

		# These are specific to the checker itself
		File singleTruth
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

	# template_req.wdl already has examples for checking a single required file, but here,
	# we include a check for a single optional file. In the original workflow we implied
	# it is never created, but in practice you can find use for this in files that only made
	# if the user specifies a certain input flag. By including a defined() check beforehand,
	# we avoid actually calling the task unless the test file actually exists, which will save
	# us time and compute credits. Without this defined() check, the task will spin up as the
	# task considers test to be an optional input, but will fail upon execution if test does not
	# exist due to how the task is written.
	if (defined(run_example_wf.wf_never)) {
		call verify_file.filecheck as singleChecker {
			input:
				test = run_example_wf.wf_never,
				truth = singleTruth
		}
	}

	# Check an array of files, wherein SOME of the files in that array might not be defined,
	# against an array of truth files. singleChecker only used one truth file but
	# this one uses multiple.
	# Any files that might not be defined need to fall back on a file that does exist, which
	# can be done easily by passing in a bogus file via select_first. This bogus file will
	# not have a match in the truth array, so it won't get md5 checked.
	# As mentioned above we could technically get around this using nested defined() but
	# select_first() is generally the better option for arrays.
	call verify_array.arraycheck_classic as nonscatteredChecker {
		input:
			test = [run_example_wf.wf_always, select_first([run_example_wf.wf_never, fallback.bogus]), select_first([run_example_wf.wf_sometimesSingle, fallback.bogus])],
			truth = arrayTruth
	}

	# Check an array of files, wherein the ENTIRE array might not be defined
	# In this example, the output of sometimesScattered is multiple files with the same name
	if (defined(run_example_wf.wf_sometimesScattered)) {
		call verify_array.arraycheck_optional as scatteredChecker {
			input:
				test = run_example_wf.wf_sometimesScattered,
				truth = arrayTruth
		}
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

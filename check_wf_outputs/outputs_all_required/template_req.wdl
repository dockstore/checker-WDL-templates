version 1.0

################################## LICENSE ##################################
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

################################### NOTES ####################################
# If running this locally, you can import tasks with relative paths, like this:
#import "example_req.wdl" as check_me
#import "../tasks/filecheck_task.wdl" as verify_file
#import "../tasks/arraycheck_task.wdl" as verify_array
#
# There is no functional difference between "here's an array of files from
# multiple different tasks" and "here's an array of files that was output 
# from a single task," provided that in both cases ALL files within the array
# AND the array itself are NOT optional. You do not need to know how many
# files are in an array, but none of those files can have type File?.

# Replace the first URL here with the URL of the workflow to be checked.
import "https://raw.githubusercontent.com/dockstore/checker-WDL-templates/v0.99.1/check_wf_outputs/outputs_all_required/parent_req.wdl" as check_me
import "https://raw.githubusercontent.com/dockstore/checker-WDL-templates/v0.99.1/checker_tasks/filecheck_task.wdl" as verify_file
import "https://raw.githubusercontent.com/dockstore/checker-WDL-templates/v0.99.1/checker_tasks/arraycheck_task.wdl" as verify_array

workflow checker {
	input {
		# First set of inputs: The same input(s) as the workflow to be checked
		File file1
		File file2
		File file3

		# Second set of inputs: The truth file(s)
		File singleTruth
		Array[File] truthSet
	}

	# Run the workflow to be checked -- replace this with your workflow's name and inputs
	call check_me.run_req_wf {
		input:
			file1 = file1,
			file2 = file2,
			file3 = file3
	}

	# Check one test file (an output from the workflow to be checked) against one truth file
	# In this case, filenames do not need to match
	call verify_file.filecheck {
		input:
			test = run_req_wf.notScattered_out,
			truth = singleTruth
	}

	# Check an array of test files (output(s) from the workflow to be checked) against array of truth files
	# Filenames of truth and test files must match in order to be checked
	# (ie truth array's foo.txt is checked against test array's foo.txt)
	call verify_array.arraycheck_classic {
		input:
			test = run_req_wf.scattered_out,
			truth = truthSet
	}

}

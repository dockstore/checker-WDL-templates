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
#
# There is no functional difference between "here's an array of files from
# multiple different tasks" and "here's an array of files that was output 
# from a single task," provided that in both cases ALL files within the array
# AND the array itself are NOT optional. You do not need to know how many
# files are in an array, but none of those files can have type File?.
#
# If running this locally, you can import tasks with relative paths, like this:
import "../checker_tasks/filecheck_task.wdl" as verify_file
import "../checker_tasks/arraycheck_task.wdl" as verify_array

# Replace the first URL here with the URL of the workflow to be checked.
#import "https://raw.githubusercontent.com/dockstore/checker-WDL-templates/v1.1.0/checker_tasks/filecheck_task.wdl" as verify_file
#import "https://raw.githubusercontent.com/dockstore/checker-WDL-templates/v1.1.0/checker_tasks/arraycheck_task.wdl" as verify_array


workflow checker {
	input {
		# Don't use this as a template -- the test and truth files are hardcoded just
		# to show off how the RData checker works
		File testRDatafile
		File truthRDatafile
		Array[File] testRDataarray
		Array[File] truthRDataarray
	}

	# Compare 1 RData test file to 1 RData truth file
	call verify_file.filecheck {
		input:
			test = testRDatafile,
			truth = truthRDatafile,
			rdata_check = true
	}

	# Check an array of RData test files against array of RData truth files
	call verify_array.arraycheck_classic {
		input:
			test = testRDataarray,
			truth = truthRDataarray,
			rdata_check = true
	}

}
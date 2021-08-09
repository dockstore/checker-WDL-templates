version 1.0

import "example_req.wdl" as check_me
import "../tasks/arraycheck_task.wdl" as checker_array
import "../tasks/filecheck_task.wdl" as checker_file

# There is no functional difference between "here's an array of files from
# multiple different tasks" and "here's an array of files that was output 
# from a single task," provided that in both cases ALL files within the array
# AND the array itself are NOT optional. You do not need to know how many
# files are in an array, but none of those files can have type File?.

workflow checker {
	input {
		# First set of inputs: The same input(s) as the workflow to be checked
		File file1
		File file2

		# Second set of inputs: The truth file(s)
		File singleTruth
		Array[File] truthSet
	}

	# Run the workflow to be checked
	call check_me.run_req_wf {
		input:
			file1 = file1,
			file2 = file2
	}

	# Check one test file against one truth file
	# In this case, filenames do not need to match
	call checker_file.filecheck {
		input:
			test = run_req_wf.notScattered_out,
			truth = singleTruth
	}

	# Check an array of test files against an array of truth files
	# Filenames of truth and test files must match in order to be checked
	# ie truth array's foo.txt is checked against test array's foo.txt
	call checker_array.arraycheck_classic {
		input:
			test = run_req_wf.scattered_out,
			truth = truthSet
	}

}
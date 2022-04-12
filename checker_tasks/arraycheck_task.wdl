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
# For every file in the test array, we iterate through the truth array and
# try to find a file that matches the truth file. This assumes that file names 
# between the test and truth files match. If a truth file cannot be found for
# a test file, we continue.
# You can set fastfail to exit 1 upon the first mismatch.

task arraycheck_classic {
	# Use this task when ALL files in array exist
	# Optional outputs can be handled with select_first()
	input {
		Array[File] test
		Array[File] truth
		Boolean fastfail = false  # should we exit out upon first mismatch?
		Boolean rdata_check = false  # check with all.equal() fdupon failure; only use with RData files!
		Float tolerance = 0.00000001  # tolerance to use for all.equal(); default is 1.0E-8
	}

	Int test_size = ceil(size(test, "GB"))
	Int truth_size = ceil(size(truth, "GB"))
	Int finalDiskSize = test_size + truth_size + 3

	command <<<
	failed_at_least_once="false"
	touch "report.txt"
	for TEST in ~{sep=' ' test}
	do
		actual_truth=""  # reset name of TRUTH file
		md5sum ${TEST} > sum.txt # md5sum of TEST file
		test_basename="$(basename -- ${TEST})" # basename of TEST file

		for TRUTH in ~{sep=' ' truth}
		do
			truth_basename="$(basename -- ${TRUTH})"
			if [ "${test_basename}" == "${truth_basename}" ]; then
				actual_truth="$TRUTH"
				break
			fi
		done
		if [ "$actual_truth" != "" ]
		then
			if ! echo "$(cut -f1 -d' ' sum.txt)" $actual_truth | md5sum --check
			then
				echo "$TEST does not match expected truth file $TRUTH"
				if [ "~{rdata_check}" = "true" ]; then
					echo "Calling Rscript to check for functional equivalence..."
					if Rscript /opt/rough_equivalence_check.R $TEST $TRUTH ~{tolerance}
					then
						echo "Test file not identical to truth file, but are within ~{tolerance}. PASS"
						echo "$test_basename PASS (non-identical)" | tee -a report.txt
					else
						echo "Test file varies beyond accepted tolerance of ~{tolerance}. FAIL"
						echo "$test_basename FAIL" | tee -a report.txt
						if ~{fastfail}
						then
							exit 1
						else
							failed_at_least_once="true"
						fi
					fi
				else
					echo "$test_basename FAIL" | tee -a report.txt
					if ~{fastfail}
					then
						exit 1
					else
						failed_at_least_once="true"
					fi
				fi
			else
				echo "$test_basename found to pass with sum $(cut -f1 -d' ' sum.txt)"
				echo "$test_basename PASS" | tee -a report.txt
			fi
		else
			echo "A truth file was not found for $test_basename" | tee -a report.txt
		fi
	done

	echo "Finished checking all files in test array." | tee -a report.txt
	if [ "$failed_at_least_once" != "false" ]
	then
		echo "At least one file failed. Returning 1..."
		exit 1
	else
		echo "All files that were checked passed. Returning 0..."
	fi

	>>>

	output {
		File report = "report.txt"
	}

	runtime {
		cpu: 2
		disks: "local-disk " + finalDiskSize + " HDD"
		docker: "quay.io/aofarrel/rchecker@sha256:73142f0f3ac5dd89dfa260a72a5397fbd7cffd9df23e3ce3e800308d6b21964c"
		memory: "2 GB"
		preemptible: 2
	}
}


task arraycheck_optional {
	# Use this task when the ENTIRE array of test files may not exist
	# Ideally this task should never be called if the test array does
	# not exist... put a defined() check before calling this task.
	# Note that disk size is based upon truth array * 2 now!
	# Also note this doesn't support RData checks at the moment.
	input {
		Array[File]? test
		Array[File] truth
		Boolean fastfail = false  # should we exit out upon first mismatch?
	}

	Int truth_size = ceil(size(truth, "GB"))
	Int finalDiskSize = 2*truth_size + 3

	command <<<
	touch "report.txt"
	for TEST in ~{sep=' ' test}
	do
		actual_truth=""  # reset every iteration
		md5sum ${TEST} > sum.txt
		test_basename="$(basename -- ${TEST})"

		for TRUTH in ~{sep=' ' truth}
		do
			truth_basename="$(basename -- ${TRUTH})"
			if [ "${test_basename}" == "${truth_basename}" ]; then
				actual_truth="$TRUTH"
				break
			fi
		done
		if [ "$actual_truth" != "" ]; then
			if ! echo "$(cut -f1 -d' ' sum.txt)" $actual_truth | md5sum --check
			then
				echo "$TEST does not match expected truth file $TRUTH" | tee -a report.txt
				if ~{fastfail}
				then
					exit 1
				fi
			else
				echo "$test_basename found to pass with sum $(cut -f1 -d' ' sum.txt)" 
				echo "$test_basename PASS" | tee -a report.txt
			fi
		else
			echo "A truth file was not found for $test_basename" | tee -a report.txt
		fi
	done

	echo "Finished checking all files in test array." | tee -a report.txt

	>>>

	output {
		File report = "report.txt"
	}

	runtime {
		cpu: 2
		disks: "local-disk " + finalDiskSize + " HDD"
		docker: "quay.io/aofarrel/goleft-covstats:circleci-push"
		memory: "2 GB"
		preemptible: 2
	}
}

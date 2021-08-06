version 1.0

# Author: Ash O'Farrell (UCSC)
# Note that this assumes that file names between the test and truth match

task arraycheck {
	input {
		Array[File] test
		Array[File] truth
		Boolean fastfail = true  # should we exit out upon first mismatch?
	}

	Int test_size = ceil(size(test, "GB"))
	Int truth_size = ceil(size(truth, "GB"))
	Int finalDiskSize = test_size + truth_size + 3

	command <<<
	touch "report.txt"
	for j in ~{sep=' ' test}
	do
		md5sum ${j} > sum.txt
		test_basename="$(basename -- ${j})"

		for i in ~{sep=' ' truth}
		do
			truth_basename="$(basename -- ${i})"
			if [ "${test_basename}" == "${truth_basename}" ]; then
				actual_truth="$i"
				break
			fi
		done

		if ! echo "$(cut -f1 -d' ' sum.txt)" $actual_truth | md5sum --check
		then
			if ~{fastfail}
			then
				exit 1
			fi
		fi
	done

	>>>

	output {
		File report = "report.txt"
	}

	runtime {
		cpu: 2
		disks: "local-disk " + finalDiskSize + " HDD"
		docker: "debian:stretch-slim"
		memory: "2 GB"
		preemptible: 2
	}
}
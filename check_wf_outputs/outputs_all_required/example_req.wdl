version 1.0

task always {
	input {
		File? unused
	}

	command <<<
		touch "foo.txt"
	>>>
	
	output {
		File out_foo = "foo.txt"
	}

	runtime {
		docker: "quay.io/aofarrel/goleft-covstats:circleci-push"
		preemptible: 3
		memory: 2 + "G"
	}
}

workflow run_req_wf {
	input {
		File file1
		File file2
	}

	call always as notScattered

	scatter(a_file in [file1, file2]) {
		call always as scattered {
			input:
				unused = a_file
		}
	}
	output {
		File notScattered_out = notScattered.out_foo
		Array[File] scattered_out = scattered.out_foo
	}

}
version 1.0

task always {
	input {
		File crai
	}
	String base_crai = basename(crai)

	command <<<
		echo "Your input file is: ~{base_crai}" | tee -a ~{base_crai}.txt
	>>>
	
	output {
		File always_exists = glob("*.txt")[0]
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
		File file3
	}

	call always as notScattered {
		input:
			crai = file1
	}

	scatter(a_file in [file2, file3]) {
		call always as scattered {
			input:
				crai = a_file
		}
	}
	output {
		File notScattered_out = notScattered.always_exists
		Array[File] scattered_out = scattered.always_exists
	}

}
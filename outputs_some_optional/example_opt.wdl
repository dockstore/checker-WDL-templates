version 1.0

task always {
	input {
		File? bogus
	}

	command <<<
		touch "foo.txt"
	>>>
	
	output {
		File out_foo = "foo.txt"
	}

	runtime {
		#docker: "quay.io/aofarrel/goleft-covstats:circleci-push"
		preemptible: 3
		memory: 2 + "G"
	}
}

task sometimes {
	input {
		File? bogus
	}
	
	command <<<
		touch "bar.txt"
	>>>
	
	output {
		File out_bar = "bar.txt"
	}

	runtime {
		#docker: "quay.io/aofarrel/goleft-covstats:circleci-push"
		preemptible: 3
		memory: 2 + "G"
	}
}

task never {
	input {
		File? bogus
	}

	command <<<
		touch "bizz.txt"
	>>>
	
	output {
		File out_bizz = "bizz.txt"
	}

	runtime {
		#docker: "quay.io/aofarrel/goleft-covstats:circleci-push"
		preemptible: 3
		memory: 2 + "G"
	}
}

workflow run_example_wf {
	input {
		File? optionalInput
		File requiredInput
	}

	Boolean runOptionalTask = false

	call always

	if(defined(optionalInput)) {
		call sometimes as sometimesSingle

		scatter(someFile in [optionalInput, requiredInput]) {
			call sometimes as sometimesScattered { input: bogus = someFile }
		}
	}

	if(runOptionalTask) {
		call never
	}

	output {
		File wf_always = always.out_foo
		File? wf_sometimesSingle = sometimesSingle.out_bar
		Array[File]? wf_sometimesScattered = sometimesScattered.out_bar
		File? wf_never = never.out_bizz
	}

}
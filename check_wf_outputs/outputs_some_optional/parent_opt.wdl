version 1.0

task always {
	input {
		File? this_input_is_ignored
	}

	command <<<
		echo "Foo!" | tee -a foo.txt
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

task sometimes {
	input {
		File? this_input_is_ignored
	}
	
	command <<<
		echo "Bar!" | tee -a bar.txt
	>>>
	
	output {
		File out_bar = "bar.txt"
	}

	runtime {
		docker: "quay.io/aofarrel/goleft-covstats:circleci-push"
		preemptible: 3
		memory: 2 + "G"
	}
}

task never {
	input {
		File? this_input_is_ignored
	}

	command <<<
		echo "Bizz!" | tee -a bizz.txt
	>>>
	
	output {
		File out_bizz = "bizz.txt"
	}

	runtime {
		docker: "quay.io/aofarrel/goleft-covstats:circleci-push"
		preemptible: 3
		memory: 2 + "G"
	}
}

workflow run_example_wf {
	input {
		File? optionalInput
		File requiredInput
	}

	Boolean runOptionalTask = false # this is hardcoded; users cannot set this to true via json

	call always # foo

	if(defined(optionalInput)) {
		call sometimes as sometimesSingle # bar

		# Yes, this results in outputs with identical filenames -- WDL can handle that!
		scatter(someFile in [optionalInput, requiredInput]) {
			call sometimes as sometimesScattered { input: this_input_is_ignored = someFile }
		}
	}

	if(runOptionalTask) {
		call never # bizz
	}

	output {
		File wf_always = always.out_foo
		File? wf_sometimesSingle = sometimesSingle.out_bar
		Array[File]? wf_sometimesScattered = sometimesScattered.out_bar
		File? wf_never = never.out_bizz
	}

}
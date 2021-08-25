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

task one_is_missing {
	input {
		File? this_input_is_ignored
	}

	command <<<
		echo "Xyzzy!" | tee -a xyzzy.txt
	>>>
	
	output {
		File out_xyzzy = "xyzzy.txt"
		File? out_zzyzx = "zzyzx.txt"
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

	if(runOptionalTask) {
		call never # bizz
	}

	call one_is_missing

	output {
		File wf_always = always.out_foo
		File? wf_sometimesSingle = sometimesSingle.out_bar
		Array[File]? wf_sometimesScattered = sometimesScattered.out_bar
		File? wf_never = never.out_bizz
		File wf_magicword = one_is_missing.out_xyzzy
		File? wf_nonexistent = one_is_missing.out_zzyzx
	}
}
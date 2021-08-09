version 1.0

task needsOptionalInputFile {
	input {
		File? optionalInput
	}
	
	command <<<
		touch "foo.txt"
	>>>
	
	output {
		File foo = "foo.txt"
	}

	runtime {
		#docker: "quay.io/aofarrel/goleft-covstats:circleci-push"
		preemptible: 3
		memory: 2 + "G"
	}
}

task never {
	input {
		Int? bogus
	}

	command <<<
		touch "bar.txt"
	>>>
	
	output {
		File bar = "bar.txt"
	}

	runtime {
		#docker: "quay.io/aofarrel/goleft-covstats:circleci-push"
		preemptible: 3
		memory: 2 + "G"
	}
}

task required {
	input {
		Int? nothing
	}

	command <<<
		touch "bizz.txt"
	>>>
	
	output {
		File bizz = "bizz.txt"
	}

	runtime {
		#docker: "quay.io/aofarrel/goleft-covstats:circleci-push"
		preemptible: 3
		memory: 2 + "G"
	}
}

workflow optOuts {
	input {
		File? optionalInput
		File requiredInput
	}

	Boolean runOptionalTask = false

	call required as req

	if(defined(optionalInput)) {
		call needsOptionalInputFile as opInSingular { input: optionalInput = optionalInput }

		scatter(object in [optionalInput, requiredInput]) {
			call needsOptionalInputFile as opInScattered { input: optionalInput = object }
		}
	}

	if(runOptionalTask) {
		call never as opBool
	}

	output {
		File required_out = req.bizz
		File? booleanOptional_out = opBool.bar
		File? singularOptional_out = opInSingular.foo
		Array[File]? scatteredOptional_out = opInScattered.foo
	}

}
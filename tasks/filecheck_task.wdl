version 1.0

# Author: Ash O'Farrell (UCSC)

# As with arraycheck_optional, this task should never be called if test is
# not defined. We set the truth to File? instead of File in order to account
# for optional ouputs, as WDL can coerce a File into a File? but not a File?
# into a File. In other words, giving test the type File? allows for this
# task to account for optional and required outputs.
# Things are a bit more complicated for arrays, though, hence why that one
# needs two seperate tasks.

task filecheck {
  input {
    File? test
    File truth
    Boolean verbose = true
  }

  Int test_size = ceil(size(test, "GB"))
  Int truth_size = ceil(size(truth, "GB"))
  Int finalDiskSize = test_size + truth_size + 3

  command <<<
    md5sum ~{test} > test.txt
    md5sum ~{truth} > truth.txt
    touch "report.txt"

    if cat ~{truth} | md5sum --check test.txt
    then
      echo "Files pass" | tee -a report.txt
    else
      if ~{verbose}
      then
        echo "Test checksum:" | tee -a report.txt
        cat test.txt | tee -a report.txt
        echo "Truth checksum:" | tee -a report.txt
        cat truth.txt | tee -a report.txt
        echo "-=-=-=-=-=-=-=-=-=-\nContents of test file:" | tee -a report.txt
        cat ~{test} | tee -a report.txt
        echo "-=-=-=-=-=-=-=-=-=-\nContents of truth file:" | tee -a report.txt
        cat ~{truth} | tee -a report.txt
        echo "-=-=-=-=-=-=-=-=-=-\ncmp and diff of files:" | tee -a report.txt
        cmp --verbose test.txt truth.txt | tee -a report.txt
        diff test.txt truth.txt | tee -a report.txt
        diff -w test.txt truth.txt
      else
        echo "Files do not pass md5sum check" | tee -a report.txt
      fi
    fi

  >>>

  output {
    File report = "report.txt"
  }

  runtime {
    cpu: 1
    disks: "local-disk " + finalDiskSize + " HDD"
    docker: "quay.io/aofarrel/goleft-covstats:circleci-push"
    memory: "1 GB"
    preemptible: 2
  }

}
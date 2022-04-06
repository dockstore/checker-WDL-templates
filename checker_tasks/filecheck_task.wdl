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

################################### USAGE ####################################
# 
# Options:
# fail_if_nothing_to_check: Fail if test file is not defined. Default: False.
# rdata_check: If there is an md5sum mismatch, compare the truth and test files
#   using R's all.equal() function. This is important as different backends
#   can give slightly different but functionally equivalent output after
#   certain not-quite-deterministic R functions. Should only be set to true
#   if you are working entirely with RData files. Defaults to false.
# tolerance: If rdata_check is true, this is tolerance to use for all.equal.
#   Defaults to 1.0E-8 (roughly the same as R's built-in default).
# verbose: Give verbose output upon failure. Defaults to false.

task filecheck {
  input {
    File? test
    File truth
    Boolean verbose = false  # give verbose output upon failure
    Boolean fail_if_nothing_to_check = false
    Boolean rdata_check = false
    Float tolerance = 0.00000001 
  }

  Int truth_size = ceil(size(truth, "GB"))
  Int finalDiskSize = 2*truth_size + 3

  command <<<
    # check if test is defined
    if [ "~{test}" ]; then
      echo "Test file $testbase exists."
    else
      echo "No test file found"
      if [ "~{fail_if_nothing_to_check}" = "false" ]; then
        echo "Nothing to do. Exiting gracefully..." 
        exit 0
      else
        echo "Nothing to do. fail_if_nothing_to_check is true. Exiting with error..."
        exit 1
      fi
    fi
    
    testbase=$(basename "~{test}")
    md5sum ~{test} > test.txt
    md5sum ~{truth} > truth.txt
    touch "report.txt"

    if echo "$(cut -f1 -d' ' test.txt)" ~{truth} | md5sum --check; then
      echo "$testbase PASS" | tee -a report.txt
      exit 0
    else
      if [ "~{verbose}" = "true" ]; then
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
        echo "$testbase does not pass md5sum check."
      fi
      if [ "~{rdata_check}" = "true" ]; then
        echo "Calling Rscript to check for functional equivalence..."
        if Rscript /opt/rough_equivalence_check.R ~{test} ~{truth} ~{tolerance}; then
          echo "$testbase not identical to truth file, but is within ~{tolerance}. PASS"
          echo "$testbase PASS (non-identical)" | tee -a report.txt
          exit 0
        else
          echo "$testbase varies beyond accepted tolerance of ~{tolerance}. FAIL"
          echo "FAIL" | tee -a report.txt
          exit 1
        fi
      else
        echo "FAIL" # this one is for stdout
        echo "FAIL" | tee -a report.txt
        exit 1
      fi
    fi

  >>>

  output {
    File report = "report.txt"
    File testmd5 = "test.txt"
    File truthmd5 = "truth.txt"
  }

  runtime {
    cpu: 1
    disks: "local-disk " + finalDiskSize + " HDD"
    docker: "quay.io/aofarrel/rchecker@sha256:73142f0f3ac5dd89dfa260a72a5397fbd7cffd9df23e3ce3e800308d6b21964c"
    memory: "1 GB"
    preemptible: 2
  }

}

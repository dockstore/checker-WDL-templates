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

task filecheck {
  input {
    File? test
    File truth
    Boolean verbose = false  # give verbose output upon failure
    Boolean fail_if_nothing_to_check = false  # fail if test file not defined
    Boolean rdata_check = false  # check with all.equal() upon failure; only use with RData files!
    Float tolerance = 0.00000001  # tolerance to use for all.equal(); default is 1.0E-8
  }

  Int truth_size = ceil(size(truth, "GB"))
  Int finalDiskSize = 2*truth_size + 3

  command <<<
    # check if test is defined
    if [ "~{test}" ]; then
      echo "Test file exists" | tee -a report.txt
    else
      echo "No test file found" | tee -a report.txt
      if [ "~{fail_if_nothing_to_check}" = "false" ]; then
        echo "Nothing to do. Exiting gracefully..." | tee -a report.txt
        exit 0
      else
        echo "Nothing to do. fail_if_nothing_to_check is true. Exiting disgracefully..."  | tee -a report.txt
        exit 1
      fi
    fi
    
    md5sum ~{test} > test.txt
    md5sum ~{truth} > truth.txt
    touch "report.txt"

    if echo "$(cut -f1 -d' ' test.txt)" ~{truth} | md5sum --check; then
      echo "Files pass md5sum check." | tee -a report.txt
      echo "PASS" | tee -a report.txt
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
        echo "Files do not pass md5sum check." | tee -a report.txt
      fi
      if [ "~{rdata_check}" = "true" ]; then
        echo "Calling Rscript to check for functional equivalence..." | tee -a report.txt
        if Rscript /opt/rough_equivalence_check.R ~{test} ~{truth} ~{tolerance}; then
          echo "Test file not identical to truth file, but are within ~{tolerance}." | tee -a report.txt
          echo "PASS" | tee -a report.txt
          exit 0
        else
          echo "Test file varies beyond accepted tolerance of ~{tolerance}. FAIL" | tee -a report.txt
          echo "FAIL" | tee -a report.txt
          exit 1
        fi
      else
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

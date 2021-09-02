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
    Boolean verbose = true
    Boolean fail_if_nothing_to_check = false
  }

  Int truth_size = ceil(size(truth, "GB"))
  Int finalDiskSize =  2*truth_size + 3

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
      echo "Files pass" | tee -a report.txt
      exit 0
    else
      if ~[ "{verbose}" ]; then
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
        exit 1
      else
        echo "Files do not pass md5sum check" | tee -a report.txt
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
    disks: if defined(test) then "local-disk " + finalDiskSize + " HDD" else "local-disk " + truth_size + " HDD"
    docker: "quay.io/aofarrel/goleft-covstats:circleci-push"
    memory: "1 GB"
    preemptible: 2
  }

}

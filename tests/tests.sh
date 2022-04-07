#!/bin/bash

# ███████████████████████████████████ LICENSE ██████████████████████████████████
# Copyright 2022 Aisling "Ash" O'Farrell
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#       http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# ███████████████████████████████████ NOTES ████████████████████████████████████
# Purpose: This is a simple sh file that makes sure I do not break my templates.
#          It is not designed to be a learning resource, but it is relatively
#          simple and you can base your own tests upon it (per the rules of the
#          above license). The first step is to check the syntax of all .wdls in
#          the repository with womtool, which is the same syntax verification
#          used by Cromwell (which is used by Terra). Actual testing of relevent
#          workflows is done with miniwdl, as miniwdl is faster than Cromwell
#          and has much less verbose output.
#
# Requirements: * Python 3.7 or higher (to run miniwdl)
#               * Java (to run womtool)
#               * miniwdl: https://github.com/chanzuckerberg/miniwdl
#               * womtool: https://github.com/broadinstitute/cromwell  
# 

echo "$(date +["%r %m-%d-%y"]) Beginning test of checker workflow templates" > output.txt

echo "Checking syntax..."
echo "$(date +["%r %m-%d-%y"]) Check syntax via womtool" >> output.txt
for file in $(find checker_tasks/ check_task_outputs/ check_wf_outputs/ check_approximately_equals/ -name '*.wdl' -type f -print);
do
	echo ${file} >> output.txt
	java -jar /Applications/womtool-76.jar validate ${file} >> output.txt
done


echo "Checking workflows..."

echo "$(date +["%r %m-%d-%y"]) Run fuzzycheck via miniwdl" >> output.txt
miniwdl run check_approximately_equals/fuzzycheck_RData.wdl \
	testRDatafile=test_data/allele_chr1.RData \
	truthRDatafile=test_data/truths/allele_chr1.RData \
	testRDataarray=test_data/allele_chr1.RData \
	testRDataarray=test_data/allele_chr2.RData \
	truthRDataarray=test_data/truths/allele_chr1.RData \
	truthRDataarray=test_data/truths/allele_chr2.RData

echo "$(date +["%r %m-%d-%y"]) Not checking check_task_outputs, as its inputs are not local..." >> output.txt

echo "$(date +["%r %m-%d-%y"]) Run outputs_all_required base case via miniwdl" >> output.txt
miniwdl run check_wf_outputs/outputs_all_required/parent_req.wdl \
	file1=test_data/allele_chr1.RData \
	file2=test_data/truths/allele_chr1.RData \
	file3=test_data/allele_chr1.RData 

echo "$(date +["%r %m-%d-%y"]) Run outputs_all_required checker case via miniwdl" >> output.txt
miniwdl run check_wf_outputs/outputs_all_required/template_req.wdl \
	file1=test_data/NWD176325.005percent.recab.crai \
	file2=test_data/NWD119836.0005.recab.cram.crai \
	file3=test_data/NWD119836.0005.recab.crai \
	singleTruth=test_data/truths/NWD176325.005percent.recab.crai.txt \
	truthSet=test_data/truths/NWD119836.0005.recab.cram.crai.txt \
	truthSet=test_data/truths/NWD119836.0005.recab.crai.txt

echo "$(date +["%r %m-%d-%y"]) Run outputs_some_optional base case via miniwdl" >> output.txt
miniwdl run check_wf_outputs/outputs_some_optional/parent_opt.wdl \
	optionalInput=test_data/NWD119836.0005.recab.cram.crai \
	requiredInput=test_data/NWD176325.005percent.recab.crai 

echo "$(date +["%r %m-%d-%y"]) Run outputs_some_optional checker case via miniwdl" >> output.txt
miniwdl run check_wf_outputs/outputs_some_optional/template_opt.wdl \
	optionalInput=test_data/NWD119836.0005.recab.cram.crai \
	requiredInput=test_data/NWD176325.005percent.recab.crai \
	singleTruth=test_data/truths/foo.txt \
	arrayTruth=test_data/truths/bar.txt \
	arrayTruth=test_data/truths/second_bar/bar.txt \
	arrayTruth=test_data/truths/foo.txt 



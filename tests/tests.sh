#!/bin/bash

# Using womtool to check the syntax as that is what Terra relies on
# Using miniwdl to actually run the workflows as it is less verbose 

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




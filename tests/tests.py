# Meant to be run from the root directory of the repo.

import subprocess
import datetime
import sys
import os


_failed_ = False

print("[%s] Check syntax via womtool..." % datetime.datetime.now())
for root, dirs, files in os.walk(".", topdown=True):
	for file in files:
		if file.endswith(".wdl"):
			this_wdl = os.path.join(root, file)
			print("[%s] Checking %s..." % (datetime.datetime.now(), this_wdl))
			try:
				subprocess.check_call(["java", "-jar", "/Applications/womtool-76.jar",
				 "validate", "%s" % this_wdl], stdout=subprocess.DEVNULL)
			except subprocess.CalledProcessError as oops:
				# womtool will print more useful stderr to command line
				print("ERROR - womtool returned %s" % oops.returncode)
				_failed_ = True

print("[%s] Finished syntax check." % datetime.datetime.now())
if _failed_ == True:
	print("Syntax errors detected. Not running any further tests.")
	quit()


print("Checking workflows...")
print("Not checking check_task_outputs, as its inputs are not local...")

print("[%s] Run fuzzycheck via miniwdl" % datetime.datetime.now())
try:
	subprocess.check_call(["miniwdl", "run", "check_approximately_equals/fuzzycheck_RData.wdl",
	 "testRDatafile=test_data/allele_chr1.RData",
	 "truthRDatafile=test_data/truths/allele_chr1.RData",
	 "testRDataarray=test_data/allele_chr1.RData",
	 "testRDataarray=test_data/allele_chr2.RData",
	 "truthRDataarray=test_data/truths/allele_chr1.RData",
	 "truthRDataarray=test_data/truths/allele_chr2.RData"],
	 stderr=subprocess.STDOUT)
except subprocess.CalledProcessError as oops:
	print("ERROR - womtool returned %s" % oops.returncode)
	_failed_ = True

print("[%s] Run outputs_all_required base case via miniwdl" % datetime.datetime.now())
try:
	subprocess.check_call(["miniwdl", "run", "check_wf_outputs/outputs_all_required/parent_req.wdl",
	"file1=test_data/allele_chr1.RData",
	"file2=test_data/truths/allele_chr1.RData",
	"file3=test_data/allele_chr1.RData"])
except subprocess.CalledProcessError as oops:
	print("ERROR - womtool returned %s" % oops.returncode)
	_failed_ = True

print("[%s] Run outputs_all_required checker case via miniwdl" % datetime.datetime.now())
try:
	subprocess.check_call(["miniwdl", "run", "check_wf_outputs/outputs_all_required/template_req.wdl",
	"file1=test_data/NWD176325.005percent.recab.crai",
	"file2=test_data/NWD119836.0005.recab.cram.crai",
	"file3=test_data/NWD119836.0005.recab.crai",
	"singleTruth=test_data/truths/NWD176325.005percent.recab.crai.txt",
	"truthSet=test_data/truths/NWD119836.0005.recab.cram.crai.txt",
	"truthSet=test_data/truths/NWD119836.0005.recab.crai.txt"])
except subprocess.CalledProcessError as oops:
	print("ERROR - womtool returned %s" % oops.returncode)
	_failed_ = True

print("[%s] Run outputs_some_optional base case via miniwdl" % datetime.datetime.now())
try:
	subprocess.check_call(["miniwdl", "run", "check_wf_outputs/outputs_some_optional/parent_opt.wdl",
	"optionalInput=test_data/NWD119836.0005.recab.cram.crai",
	"requiredInput=test_data/NWD176325.005percent.recab.crai"])
except subprocess.CalledProcessError as oops:
	print("ERROR - womtool returned %s" % oops.returncode)
	_failed_ = True

print("[%s] Run outputs_some_optional checker case via miniwdl" % datetime.datetime.now())
try:
	subprocess.check_call(["miniwdl", "run", "check_wf_outputs/outputs_some_optional/template_opt.wdl",
	"optionalInput=test_data/NWD119836.0005.recab.cram.crai",
	"requiredInput=test_data/NWD176325.005percent.recab.crai",
	"singleTruth=test_data/truths/foo.txt",
	"arrayTruth=test_data/truths/bar.txt",
	"arrayTruth=test_data/truths/second_bar/bar.txt",
	"arrayTruth=test_data/truths/foo.txt"])
except subprocess.CalledProcessError as oops:
	print("ERROR - womtool returned %s" % oops.returncode)
	_failed_ = True

# clean up miniwdl leftovers
today = "".join[datetime.datetime.now().year, datetime.datetime.now().month, datetime.datetime.now().day]
print(today)

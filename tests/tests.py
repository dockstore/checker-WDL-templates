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


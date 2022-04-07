import subprocess
import sys

thing = subprocess.run(["./tests/tests.sh"])

print(thing.stdout)
print(thing.stderr)
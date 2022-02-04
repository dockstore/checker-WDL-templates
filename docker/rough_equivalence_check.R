sessionInfo()

loadRData <- function(fileName){
    load(fileName)
    get(ls()[ls() != "fileName"])
}

options <- commandArgs(trailingOnly = TRUE)
print(options)

test <- loadRData(options[1])
truth <- loadRData(options[2])
toler <- as.numeric(options[3])

# check to make sure we didn't accidentally load the same file twice
# files should not be equivalent, as they failed an MD5
if(isTRUE(identical(test, truth))) {
    print("WARNING: Outputs are identical, even though they should have failed")
    print("         an MD5 checksum earlier. Consider manually checking the")
    print("         input files of this WDL task to ensure that the test and")
    print("         truth files have been loaded in correctly, and we are not")
    print("         just comparing truth-vs-truth or test-vs-test.")
}

# actual check for them being "close enough"
if(isTRUE(all.equal(test, truth, tolerance=toler))) {
    print("Outputs are not identical, but are mostly equivalent.")
}
else {
    print("Outputs are not within the defined tolerance.")
}

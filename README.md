# checker WDL templates
 Templates for checker WDLs. [Checker workflows](https://docs.dockstore.org/en/develop/advanced-topics/checker-workflows.html) are good practice for reproducibility. Although some developers may prefer an advanced CI/CD solution for their workflows, checker workflows are generally easier to develop and satisfactory for many use cases. Of course, checker workflows can be part of a more advanced CI/CD solution -- feel free to build upon these.

 Be aware that checker workflows traditionally use https imports. DNAnexus does not support these imports, but you can still use checker workflows by placing the checker component into your existing workflow file.

## What's in here?
* filecheck: Template for checking a single test file against a single truth file.

* arraycheck: Template for checking each file in a test array against its matching file in a truth array. You can set `fastfail` to `True` if you want to exit on the first md5 mismatch, otherwise all mismatches will be reported. This makes the following assumptions:
    * Both arrays are the same length
    * The truth and test arrays have matching filenames -- ie, file.txt in the truth array will be checked against file.txt in the test array
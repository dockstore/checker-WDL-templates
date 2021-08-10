# checker WDL templates
 Templates for checker WDLs. [Checker workflows](https://docs.dockstore.org/en/develop/advanced-topics/checker-workflows.html) are good practice for reproducibility. Although some developers may prefer an advanced CI/CD solution for their workflows, checker workflows are generally easier to develop and satisfactory for many use cases. Of course, checker workflows can be part of a more advanced CI/CD solution -- feel free to build upon these.

 Be aware that checker workflows traditionally use https imports. DNAnexus does not support these imports, but you can still use checker workflows by placing the checker component into your existing workflow file.

## How to use this repo
 First of all, make sure your WDL has workflow level outputs. This allows for the workflow to be called as an entire workflow, rather than having to write out every task call a second time.

 It is recommended to start with `outputs_all_required/template_req.wdl` if you have never written a checker workflow before. It is the most simple example, providing two types of checks: Checking a single file against another single file, and checking an array of test files against an array of truth files. Use this folder if *all* of your workflow-level outputs are accounted for, ie, none of them are optional. It is okay if you have an optional task-level output; all that is getting checked are the workflow-level outputs.

 The actual checker tasks are pulled from the `tasks/` folder, which you can read to learn how to develop checkers of your own. They are as follows:

 * filecheck: Template for checking a single test file against a single truth file.

 * arraycheck: Template for checking each file in a test array against its matching file in a truth array. You can set `fastfail` to `True` if you want to exit on the first md5 mismatch, otherwise all mismatches will be reported. This makes the following assumptions:
    * Both arrays are the same length
    * The truth and test arrays have matching filenames -- ie, file.txt in the truth array will be checked against file.txt in the test array

 Many workflows have optional outputs, which greatly complicate the process of creating modular checker workflows. This is what the `outputs_some_optional/` folder is for.

 Advanced users may wish to check not just workflow-level outputs, but task-level intermediate files too. This will require calling the tasks of the imported workflow rather than the entire workflow itself. An example of this can be seen in `call_as_tasks/`

## depreciated/
Old drafts which might get reused later...
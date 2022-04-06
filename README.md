# Checker WDL templates
 Templates for checker WDLs. [Checker workflows](https://docs.dockstore.org/en/develop/advanced-topics/checker-workflows.html) are good practice for reproducibility. Although some developers may prefer an advanced CI/CD solution for their workflows, checker workflows are generally easier to develop and satisfactory for many use cases. Of course, checker workflows can be part of a more advanced CI/CD solution -- feel free to build upon these.  
 
 Generally speaking, a checker workflow compares the contents of a test file against a truth file. This repo supports comparing RData files to check for almost-but-not-quite equivalence, which can be useful as otherwise deterministic outputs may vary slightly depending on which backend a workflow is executed upon. Non-RData files are checked with a simple md5sum.
 
## The actual checker tasks
 The actual checker tasks that this repos' template workflows (see below) are pulled from the `checker_tasks/` folder, which you can read to learn how to develop checkers of your own. They are as follows:

 * filecheck: Template for checking a single test file against a single truth file.

 * arraycheck: Template for checking each file in a test array against its matching file in a truth array. You can set `exit_upon_warning` to `True` if you want to exit on the first md5 mismatch, otherwise all mismatches will be reported. This makes the following assumptions:
    * Both arrays are the same length
    * The truth and test arrays have matching filenames -- ie, file.txt in the truth array will be checked against file.txt in the test array
 
 Arraycheck uses its own Docker image to check for equivalence in RData files. That images's Dockerfile and the Rscript [can be found here](https://github.com/aofarrel/Stuart-WDL/tree/main/docker).

## How to use this repo to check workflow-level outputs (ie, final outputs)
 First of all, make sure your WDL has [workflow level outputs](https://github.com/openwdl/wdl/blob/main/versions/1.0/SPEC.md#outputs). This allows for the workflow to be called as an entire workflow, rather than having to write out every task call a second time.
 
 There are two folders in `check_wf_outputs/`, one where the parent workflow's outputs will always exist, and one where some of the outputs are considered optional outputs. You can run the parent workflows with the provided parent*.wdl and parent*.json files. The actual checker workflows start with the word `template`.
 
 It is recommended to start with `check_wf_outputs/outputs_all_required/template_req.wdl` if you have never written a checker workflow before. It is the most simple example, providing two types of checks: Checking a single file against another single file, and checking an array of test files against an array of truth files. Use this folder if *all* of your workflow-level outputs are accounted for, ie, none of them are optional. It is okay if you have an optional task-level output; all that is getting checked are the workflow-level outputs.
 
 Many workflows have optional outputs, which greatly complicate the process of creating modular checker workflows. This is what the `check_wf_outputs/outputs_some_optional/` folder is for.

## How to use this repo to check task-level outputs (ie, intermediate outputs)
 Developers may wish to check not just workflow-level outputs, but task-level intermediate files too. This can be useful not just for ensure reproducibility but can also be a good way to debug a pipeline. This will require calling the *tasks* of the imported workflow rather than the entire workflow itself. An example of this can be seen in `check_task_outputs/` folder. Note that this is based on a "real" workflow, and will take much longer to execute than most of the other repos in this folder.

## How to check RData files for approximate equivalence
 An example workflow can be found in `check_approximately_equals/` for this use case. You can combine this with either the task-level or workflow-level checkers above.

## Notes on https imports
 * Checker workflows traditionally use https imports. DNAstack does not support these imports, but you can still use checker workflows by placing the checker component into your existing workflow file. 
 * Some backends support local imports (ie, ./folder/to_import.wdl instead of https://somewebsite.com/folder/to_import.wdl) but https imports tend to be a bit more reliable and less prone to erroring.
 * It is **strongly recommended** that if you choose to import these tasks directly in your checker WDL, you import from a specific tagged commit, instead of pulling from main, because main could change at any time.

## Test data
 All data in this repo was either created from scratch or are based upon 1000 Genomes data.


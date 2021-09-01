# Checker WDL templates
 Templates for checker WDLs. [Checker workflows](https://docs.dockstore.org/en/develop/advanced-topics/checker-workflows.html) are good practice for reproducibility. Although some developers may prefer an advanced CI/CD solution for their workflows, checker workflows are generally easier to develop and satisfactory for many use cases. Of course, checker workflows can be part of a more advanced CI/CD solution -- feel free to build upon these.

 Be aware that checker workflows traditionally use https imports. DNAstack does not support these imports, but you can still use checker workflows by placing the checker component into your existing workflow file.

## How to use this repo
 First of all, make sure your WDL has [workflow level outputs](https://github.com/openwdl/wdl/blob/main/versions/1.0/SPEC.md#outputs). This allows for the workflow to be called as an entire workflow, rather than having to write out every task call a second time. For the sake of simplicity, this repo refers to the workflow getting checked as the *parent workflow* and the one doing the actual checking as the *checker workflow.* See below for guidance on the right kind of checker to use for your specific parent workflow, but generally speaking, most simple workflows would be well served by the template in `check_wf_outputs/outputs_all_required/`

 The actual checker tasks are pulled from the `checker_tasks/` folder, which you can read to learn how to develop checkers of your own. They are as follows:

 * filecheck: Template for checking a single test file against a single truth file.

 * arraycheck: Template for checking each file in a test array against its matching file in a truth array. You can set `fastfail` to `True` if you want to exit on the first md5 mismatch, otherwise all mismatches will be reported. This makes the following assumptions:
    * Both arrays are the same length
    * The truth and test arrays have matching filenames -- ie, file.txt in the truth array will be checked against file.txt in the test array
 
### Checking workflow-level outputs
 There are two folders in `check_wf_outputs/`, one where the parent workflow's outputs will always exist, and one where some of the outputs are considered optional outputs. You can run the parent workflows with the provided parent*.wdl and parent*.json files. The actual checkers start with the word template.
 
 It is recommended to start with `check_wf_outputs/outputs_all_required/template_req.wdl` if you have never written a checker workflow before. It is the most simple example, providing two types of checks: Checking a single file against another single file, and checking an array of test files against an array of truth files. Use this folder if *all* of your workflow-level outputs are accounted for, ie, none of them are optional. It is okay if you have an optional task-level output; all that is getting checked are the workflow-level outputs.
 
 Many workflows have optional outputs, which greatly complicate the process of creating modular checker workflows. This is what the `check_wf_outputs/outputs_some_optional/` folder is for.
 
### Checking task-level outputs
 Advanced users may wish to check not just workflow-level outputs, but task-level intermediate files too. This will require calling the tasks of the imported workflow rather than the entire workflow itself. An example of this can be seen in `check_task_outputs/` folder. Note that this is based on a "real" workflow, and will take much longer to execute than most of the other repos in this folder.

### Test data
 All data in this repo was either created from scratch or are based upon 1000 Genomes data.


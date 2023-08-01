# Terraform Utility scripts

The scripts in this directory were made to augment SZs development and
deployment of it's terraform plans.

They all rely on scaffolding provided by `direnv` and the hirearchy of
`.envrc` files in the repo which set context relevant environment
variables which the scripts here interact with to create a cohesive and
streamlined workflow.

## Typical workflow

Just like working with 'vanilla' terraform, the process follows:

```plaintext
      +----------------------+-------------------------+
      V                      | [mostly non-production] |
    init -> plan -> apply -> | plan-destroy -> apply   |
              ^       |      +-------------------------+
              +-------+
```

With some subtle differences and defaults which are sensible to SZ's
process, along with persistent logging.

## SZ's workflow

1. `init` - the first step:
   * Initializes logging timestamp (aka `tf0`)
   * Preprocess template files (all _sz.*.sz_tmpl files)
   * Run `terraform init`
   * Log output into `_logs` sub-directory.
2. `plan` - The 'brain':
   * Run `terraform plan` with support for `TF_TARGET`
     and `TF_TARGET_DESTORY` environment variable.
   * Generate a `tfplan` file for `apply` action.
   * Log output into `_logs` sub-directory.
3. `apply` - The heavy lifting:
   * Always reads the `tfplan` file.
   * Used for either _building_ or _destroying_.
   * Log output into `_logs` sub-directory.
4. `plan-destroy` - Sensible destory planning:
   * Initializes logging timestamp (aka `tf0`)
   * Always layout the plan
   * Always logged
   * Supports `TF_TARGET_DESTROY`

## Concepts

* `direnv`'s `.envrc` sets-up the following envrionment variables:
  * SZ_TF_NAME
  * SZ_GCP_PROJECT
  * SZ_GCP_PROJECT_ID
  * TF_LOG, TF_LOG_PATH
  * TF_VAR_PLAN_PATH="_.tmp.${SZ_TF_NAME}.tfplan"
  * TF_VAR_OUT="-out ${TF_VAR_PLAN_PATH}"
  * TF_VAR_FILE_CLI="-var-file="
  * TF_VAR_FILE_CLI=""

* `tf-init` pre-processes template files `_sz.*.sz_tmpl`.  
  it is required first and foremost by `_sz.init.tf.sz_tmpl` which
  generates the platform initialization code based on the environment
  set by `direnv` - making sure you are always working with correct
  gcloud environment.
  All processed files will have the name pattern `_.gen.*`. Please note
  that any file begining with `_.` (that's an underscore and a dot) are
  ignored via `.gitignore`

* All planning is written to a persistent plan
  (`_.tmp.<tf-plan-name>.tfplan`), whether it's deploying changes, new
  components or destroying, the tfplan must be generated, along with the
  log files.

* Logging - Each tf call is logged in 3 parallel locations:
  * `_logs/0_0_lastrun.log` - the last `tf` run.
  * `_logs/0_<action>` - the latest run of a terraform action (plan,
    init, etc...). The rationale here is that all actions of a complete
    workflow will be easily accessible regardless of timestamps.
  * `_logs/yyyymmddHHmmss_<action>` - same as above, only timestamped.
    This allows grouping operations that ran together in sequence,
    breaking out to a separate sequences (by `tf0`) that will not
    overwrite previous runs.

* `less-tf` - less with sensible defaults to review latest `tf` run
  results. If no logs file is specifcied, `_logs/0_0_lastrun.log` will
  be opened.

## Reference of Scripts

* `tf`:  
  executes `terraform` while preseving logs including ANSI coloring.

* `tf0`:  
  same as `tf`, however it will reset the logging timestamp.

* `tf-init`:
  perform `init` step.

* `tf-plan` or `tfp` or `tf0-plan`
  perform `plan` step. `tf0-plan` resets timestamp.

* `tf-plan-destroy` or `tfpd`
  Perform `plan` step for destruction.

* `tf-apply` or `tfa`:  
  Apply after `plan` step. Unlike `terraform plan` this will not stop to
  ask for permission, it is based on the preserved planned-state
  supplied by `tf-plan` (above).

* `tf-extract`:
  Extracts current state as a json of pairs of names and ids. For use
  with `tf-import`.

* `tf-import`:
  Given a json files of name/id pairs, generate an import script for
  the existing state. This can be used as a non-binary state file.  
  An example to create such a script from the latest succesful `tf-apply`:

  > ```bash
  > tf-import _logs/0_9_last_state_ids.json > import-state.sh
  > ```

## General utility scripts

Documentaion still pending for the following:

* `switch-dbg-tf-on`
* `less-tf`
* `clear-tf-env`
* `clear-tf-env-targets`
* `clear-tf-end-vars`
* `get-tf-env`
* `get-tf-env-plan`

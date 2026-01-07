# cloud-orchestration-reusable-workflows
Repo containing reusable GH workflows for the cloud orchestration release pipeline

## Repo contents

### `./make`

`make` folder contains makefile extensions that can be copied to the end repo and imported from the main Makefile

* `license.mk` contains makefile targets to update copyrights and third party notices in the repo

## Testing the changes

This repo has testing workflows that are triggered on a PR when a relevant reusable workflow file is changed. For the tests to work properly, the source branch of the PR should be in the same repo (not in a user's forked repo).

Automated tests exist for the following reusable workflows:
* `fork-sync-reusable.yml`
* `fork-ci-reusable.yml`

When the logic of these workflows is changed, please add corresponding changes to the test workflows:
* `test-fork-ci-callee.yml`
* `test-fork-ci-dispatcher.yml`
* `test-fork-sync.yml`

### Fork CI tests:
These tests use the `cloud-orchestration-reusable-workflows` repo as a sandbox and create test branches / tags / PRs, and are [synchronized](https://github.com/Mellanox/cloud-orchestration-reusable-workflows/blob/main/.github/workflows/test-fork-ci-dispatcher.yml#L26) to avoid race conditions.
The repo has a dummy `master` branch which is a copy of the corresponding branch of the [Network Operator's repo](https://github.com/Mellanox/network-operator). This is done to avoid testing clutter in the main repo. If needed, the branch can be updated.

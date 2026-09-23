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

## Dependabot pull requests

The `dependabot-auto-merge-reusable.yml` workflow merges non-draft Dependabot pull requests that target the caller repository's current default branch. Before merging, it waits until every pull request check outside its own auto-merge job has completed successfully or been skipped, verifies that the checked head SHA has not changed, and confirms that the pull request has no merge conflicts. Pull requests with unsuccessful checks or conflicts are left open.

Set the optional `target-branch` input to process a branch other than the caller repository's default branch:

```yaml
jobs:
  dependabot-auto-merge:
    uses: Mellanox/cloud-orchestration-reusable-workflows/.github/workflows/dependabot-auto-merge-reusable.yml@main
    with:
      target-branch: release-26.7
```

The scheduled trigger is important: it revisits eligible pull requests whose checks outlast the initial workflow run.

Add a caller workflow to the consuming repository:

```yaml
name: Dependabot Auto-Merge

on:
  pull_request:
    types:
      - opened
      - reopened
      - synchronize
      - ready_for_review
  schedule:
    - cron: "*/10 * * * *"
  workflow_dispatch:

permissions:
  actions: read
  checks: read
  contents: write
  pull-requests: write
  statuses: read

jobs:
  dependabot-auto-merge:
    uses: Mellanox/cloud-orchestration-reusable-workflows/.github/workflows/dependabot-auto-merge-reusable.yml@main
```

The reusable workflow uses the caller's `GITHUB_TOKEN` by default. Callers can pass a GitHub App or personal access token as the optional `gh-token` secret when merges must trigger additional workflow runs. The caller's permissions are the upper bound for a called workflow, so all five permissions shown above are required.

### Fork CI tests:
These tests use the `cloud-orchestration-reusable-workflows` repo as a sandbox and create test branches / tags / PRs, and are [synchronized](https://github.com/Mellanox/cloud-orchestration-reusable-workflows/blob/main/.github/workflows/test-fork-ci-dispatcher.yml#L26) to avoid race conditions.
The repo has a dummy `master` branch which is a copy of the corresponding branch of the [Network Operator's repo](https://github.com/Mellanox/network-operator). This is done to avoid testing clutter in the main repo. If needed, the branch can be updated.

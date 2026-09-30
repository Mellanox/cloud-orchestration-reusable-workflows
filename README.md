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

## Component build and test workflows

`go-ci-reusable.yml` runs a required build followed by independent lint, test,
and validation jobs. Each job checks out the caller repository and uses
`go-check-reusable.yml` for Go setup, prerequisites, command execution, and optional
Coveralls upload. Go 1.27.x, Task 3.x, and golangci-lint v2.14.0 are selected
centrally in `go-check-reusable.yml`.
Callers do not supply tool-version inputs. Commands run with Bash
`errexit` and `pipefail`; repository Makefiles/Taskfiles own envtest setup,
generation, and package selection.

The workflow exports `GOLANGCILINT_VERSION`. Make-based consumers must honor it
with a conditional assignment (`GOLANGCILINT_VERSION ?= ...`) and include the
version in their installed binary path. This lets local builds keep a fallback
while CI follows the central version. Consumers using a different variable name
or a Taskfile must adapt their linter installation to honor this variable; the
workflow does not override arbitrary repository commands. Tool installation must
also inherit the selected Go toolchain rather than forcing the go.mod minimum.

```yaml
name: Build, Test, Lint
on: [push, pull_request]
permissions:
  contents: read
jobs:
  ci:
    uses: Mellanox/cloud-orchestration-reusable-workflows/.github/workflows/go-ci-reusable.yml@main
    with:
      test-command: make unit-test
      coverage-file: cover.out
      validate-command: |
        go mod tidy
        git diff --exit-code
```

The default build and lint commands are `make build` and `make lint`. Empty lint,
test, or validation commands skip that job. `coverage-file` names an output of
`test-command`, so tests need not run again to upload coverage. `coverage-format`
is `golang` (default) or `lcov`; a missing/empty file or unsupported format fails.
Uploads use the caller's automatic `GITHUB_TOKEN`; no inherited secrets are needed.

Both Go workflows accept `runner` (default `ubuntu-latest`), `apt-packages`
(space-separated names), `install-task` (boolean, default false),
`fetch-depth` (default 1), and `timeout-minutes` (default 30, per job). Go CI
applies these to all its jobs. For job-specific prerequisites or a different
job graph, call `go-check-reusable.yml` directly with `command`.
Commands are executable caller configuration and must not incorporate untrusted
PR titles, branch names, or other event text.

`image-build-reusable.yml` verifies images with Buildx and never pushes or logs
into a registry. It accepts `dockerfile`, `context`, `platforms` (default
`linux/amd64`), newline-separated `build-args`, `runner`, and `timeout-minutes`.
It checks out full history for build-time version calculation. Makefile-specific
image flags must be supplied explicitly through these inputs. Release image
publication continues to use its existing workflows.

`codeql-reusable.yml` accepts `language` (default `go`), `queries` (default
`+security-and-quality`), `runner`, `timeout-minutes`, and `build-command`.
An empty build command uses CodeQL autobuild. The calling job must grant
`actions: read`, `contents: read`, and `security-events: write`. Triggers,
branch filters, schedules, and language matrices remain with the caller.

### Migration and validation

Merge the shared workflows before callers reference them on `main`. To exercise
consumer PRs before that merge, temporarily point their reusable calls at the
published candidate commit. Nested Go checks use a relative workflow reference,
so they resolve from the same commit as the Go CI workflow.

The init-container pilot maps build/lint/test/go-check to Go CI and build-image
to the image workflow. Spectrum-X uses the same Go CI workflow, adding its
existing `make generate` and `make manifests` validation. Both upload the
coverage from their existing `make unit-test` invocation and use shared CodeQL.
Their license workflows are already reusable.

Check required status contexts when migrating: the new caller and nested job
names replace the previous standalone checks, and the separate coverage job is
removed. Preserve caller triggers and test coverage, and verify hosted PR runs
(including Coveralls and CodeQL) before changing required checks.

`test-component-ci.yml` exercises the Go workflow with real build/test/validation
commands and verifies the image workflow without publishing. Run actionlint on
new shared workflows and consumer callers before submitting changes.

## Central Go builder images

The root `Dockerfile` is the Dependabot source for `BASE_IMAGE_GO_BUILDER`
(Debian) and `BASE_IMAGE_GO_BUILDER_ALPINE` (Alpine). Existing daily Docker
updates propose new tags. After merge, `sync-dockerfile-images.yml` opens a
follow-up PR updating `go-builder-images-reusable.yml`; merge that PR to roll
out the selected images. Release branches retain their own policy.

`fork-ci-reusable.yml` and `image-build-reusable.yml` inject both build arguments.
They call the resolver with a relative workflow reference, so the images come
from the same reusable-workflow revision. Other image publishing workflows
should call `go-builder-images-reusable.yml` and pass its `standard` and `alpine`
outputs to the matching Docker build arguments. Callers do not specify versions.

Components keep their existing standalone Dockerfile defaults as fallbacks;
managed CI overrides them. Downstream forks change only NVIDIA-owned Dockerfiles.
For manual or external CI builds, retrieve the builder URL from this repository's
root Dockerfile at the desired policy ref and supply
`--build-arg BASE_IMAGE_GO_BUILDER=<url>` (or the Alpine argument).
Never use the distroless runtime image as a compiler image.

NIC Configuration Operator and Spectrum-X GitLab STIG pipelines resolve
`BASE_IMAGE_GO_BUILDER` from the published resolver YAML once per pipeline,
then pass it to all image jobs through a dotenv artifact. This keeps GitHub
and GitLab builds on the same selection after the synchronization PR merges.

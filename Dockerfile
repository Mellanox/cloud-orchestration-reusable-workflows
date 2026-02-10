# This is a dummy Dockerfile for getting dependabot PRs for version updates
FROM nvcr.io/nvstaging/doca/doca:3.2.1-full-rt-host AS BASE_IMAGE_DOCA_FULL_RT_HOST
FROM nvcr.io/nvstaging/doca/doca:3.2.1-base-rt-host AS BASE_IMAGE_DOCA_BASE_RT_HOST
FROM nvcr.io/nvidia/distroless/go:v4.0.1-dev AS BASE_IMAGE_GO_DISTROLESS_DEV
FROM nvcr.io/nvidia/distroless/go:v4.0.1 AS BASE_IMAGE_GO_DISTROLESS

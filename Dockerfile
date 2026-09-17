# This is a dummy Dockerfile for getting dependabot PRs for version updates
FROM nvcr.io/nvstaging/doca/doca:full-rt-3.6.0041-host-dev AS BASE_IMAGE_DOCA_FULL_RT_HOST
FROM nvcr.io/nvstaging/doca/doca:base-rt-3.6.0041-host-dev AS BASE_IMAGE_DOCA_BASE_RT_HOST
FROM nvcr.io/nvstaging/doca/doca:devel-3.6.0041-host-dev AS BASE_IMAGE_DOCA_DEVEL_HOST
FROM nvcr.io/nvidia/distroless/go:v4.1.4-dev AS BASE_IMAGE_GO_DISTROLESS_DEV
FROM nvcr.io/nvidia/distroless/go:v4.1.4 AS BASE_IMAGE_GO_DISTROLESS

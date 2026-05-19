# This is a dummy Dockerfile for getting dependabot PRs for version updates
FROM nvcr.io/nvstaging/doca/doca:full-rt-3.4.0105-host-dev AS BASE_IMAGE_DOCA_FULL_RT_HOST
FROM nvcr.io/nvstaging/doca/doca:base-rt-3.4.0105-host-dev AS BASE_IMAGE_DOCA_BASE_RT_HOST
FROM nvcr.io/nvidia/distroless/go:v4.0.6-dev AS BASE_IMAGE_GO_DISTROLESS_DEV
FROM nvcr.io/nvidia/distroless/go:v4.0.6 AS BASE_IMAGE_GO_DISTROLESS

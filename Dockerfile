# This is a dummy Dockerfile for getting dependabot PRs for version updates
FROM nvcr.io/nvidia/doca/doca:3.1.0-full-rt-host AS BASE_IMAGE_DOCA_FULL_RT_HOST
FROM nvcr.io/nvidia/distroless/go:v3.2.1-dev AS BASE_IMAGE_GO_DISTROLESS_DEV
FROM nvcr.io/nvidia/distroless/go:v3.2.1 AS BASE_IMAGE_GO_DISTROLESS
# Copyright 2026 NVIDIA CORPORATION & AFFILIATES
# SPDX-License-Identifier: Apache-2.0
ARG BASE_IMAGE_GO_BUILDER
ARG BASE_IMAGE_GO_BUILDER_ALPINE
FROM ${BASE_IMAGE_GO_BUILDER} AS standard
RUN go version > /standard-version
FROM ${BASE_IMAGE_GO_BUILDER_ALPINE} AS alpine
RUN go version > /alpine-version
FROM alpine:3
COPY --from=standard /standard-version /standard-version
COPY --from=alpine /alpine-version /alpine-version
ARG MESSAGE
RUN test "$MESSAGE" = reusable-ci

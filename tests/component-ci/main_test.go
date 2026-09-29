// Copyright 2026 NVIDIA CORPORATION & AFFILIATES
// SPDX-License-Identifier: Apache-2.0

package main

import "testing"

func TestMessage(t *testing.T) {
	if got := message(); got != "reusable-ci" {
		t.Fatalf("unexpected message: %q", got)
	}
}

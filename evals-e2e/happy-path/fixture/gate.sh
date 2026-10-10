#!/bin/sh
# Full test suite. Records the last result in .gate-result for the eval graders.
if node --test; then echo green > .gate-result; else echo red > .gate-result; exit 1; fi

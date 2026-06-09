#!/bin/bash
echo "<context_paths>"
find . -type d \( -name .git -o -name node_modules \) -prune \
  -o -type d -name "_*" -prune -exec find {} \; \
  -o -name "_*" -print | sort
echo "</context_paths>"

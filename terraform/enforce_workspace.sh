#!/bin/bash

# Get the current workspace
workspace=$(terraform workspace show)

# Check if the workspace is "default"
if [ "$workspace" == "default" ]; then
  echo "Error: You must select a workspace before running 'terraform apply'."
  exit 1
fi
#!/bin/bash

org="$1"
repo="$2"
workflow_name="$3"

echo "Deleting |$workflow_name| in $org/$repo"

gh run list --limit 500 --workflow "$workflow_name" --json databaseId |
    jq -r '.[] | .databaseId' |
    xargs -I{} gh run delete {}

echo "Done."

echo "🤡 - Getting start..."

# owner/repo syntax
user=$1
repo=$2

temp_file="workflow_runs.payload"
rm -rf $temp_file

echo "Fetching workflows..."
echo $(gh api /repos/$user/$repo/actions/runs --paginate | jq '{count: .total_count, runs: [.workflow_runs[] | select(.status=="completed") | {id, conclusion, created_at}]}' | jq -s 'sort_by(.created_at) | reverse | .[:10]') | jq '.' > $temp_file

ids_to_delete=$(cat "$temp_file" | jq -r '.[].id')

if [ "$ids_to_delete" = "" ]
then
	echo "No recent workflows found. Exiting..."
	exit 0
fi

echo "Removing the 10 most recent workflows..."
for id in $ids_to_delete; do
	echo "Processing workflow $id"
	echo -n | gh api --method DELETE /repos/$user/$repo/actions/runs/$id --input -
	echo "Workflow run with ID $id deleted successfully!"
done

rm -rf $temp_file
echo -e "\n\nFinished the workflow run cleaning process"
exit 0

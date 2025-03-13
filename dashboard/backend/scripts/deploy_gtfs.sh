#!/bin/bash
set -e
pwd
cd ../gtfs_builder
npm i
node .

# FILE="/app/gtfs_builder/out/README.md"
# ERROR_URL="https://omus.tmt.gob.pe/api/GenerateGTFS/render-markdown"

# # Extract error count
# ERROR_COUNT=$(grep -E '\*\*With error\*\*: [0-9]+' "$FILE" | awk '{print $NF}')

# # Check if errors exist
# if [[ "$ERROR_COUNT" != "0" ]]; then
#     echo "Errors found ($ERROR_COUNT), check details at: $ERROR_URL"
#     exit 1
# fi

ls
cp -rf ./out/gtfs/* ../gtfs/

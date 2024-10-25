#!/bin/bash

# List of station IDs
station_ids=(
    "66481540d0de6700b0425508"
    "66481541d0de6700b042550a"
    "66481541d0de6700b042550c"
    "66481540d0de6700b0425504"
    "66481541d0de6700b042554a"
    "66481541d0de6700b042555d"
    "66481541d0de6700b0425560"
    "66481541d0de6700b042556e"
    "66481541d0de6700b042557d"
    "66481541d0de6700b042558c"
    "667ec96969a2532da4c63189"
)

# Base URL of the endpoint
base_url="https://tudata.info/api/v1/station"
api_key=""  # Ensure this value remains up-to-date

# Initialize an empty JSON array in memory
merged_data='[]'

# Function to fetch station data and merge it in memory
fetch_station_info() {
    local station_id=$1
    local url="$base_url/$station_id/info"

    echo "Fetching data for station ID: $station_id"
    # Fetch the station data
    response=$(curl --location -s "$url" --header "x-api-key: $api_key")

    if [ $? -eq 0 ]; then
        echo "Merging data for station ID: $station_id"
        # Merge the fetched JSON into the in-memory JSON array, flattening nested lists
        merged_data=$(echo "$merged_data" | jq ". + [$response | .[]]")
    else
        echo "Failed to fetch data for station ID: $station_id"
    fi
}

# Iterate over all station IDs and download/merge JSON data in memory
for id in "${station_ids[@]}"; do
    fetch_station_info "$id"
done

# Save the final merged JSON data to a file
echo "$merged_data" > ./assets/merged_stations.json

echo "All stations have been processed and merged into stations/merged_stations.json."

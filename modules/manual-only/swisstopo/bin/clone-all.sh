#!/usr/bin/env bash

set -e

ORGS=(swissgeo geoadmin)

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "Starting repository cloning process..."
echo ""

for ORG in "${ORGS[@]}"; do
    echo -e "${YELLOW}Processing organization: $ORG${NC}"

    # Create organization directory if it doesn't exist
    mkdir -p "$ORG"
    cd "$ORG"

    # Fetch all repositories for the organization using gh
    echo "Fetching repositories from $ORG..."
    repos=$(gh repo list "$ORG" --limit 1000 --json nameWithOwner --jq '.[].nameWithOwner')

    if [ -z "$repos" ]; then
        echo -e "${RED}No repositories found or error fetching repos${NC}"
        cd ..
        continue
    fi

    # Clone each repository
    while IFS= read -r repo_full_name; do
        if [ -n "$repo_full_name" ]; then
            repo_name=$(basename "$repo_full_name")

            if [ -d "$repo_name" ]; then
                echo -e "${GREEN}✓${NC} $repo_name already exists, skipping..."
            else
                echo -e "Cloning $repo_name..."
                if gh repo clone "$repo_full_name" 2>&1 | grep -q "Cloning\|already exists"; then
                    echo -e "${GREEN}✓${NC} Successfully cloned $repo_name"
                else
                    echo -e "${RED}✗${NC} Failed to clone $repo_name"
                fi
            fi
        fi
    done <<< "$repos"

    cd ..
    echo -e "${GREEN}Finished processing $ORG${NC}"
    echo ""
done

echo -e "${GREEN}All repositories cloned successfully!${NC}"

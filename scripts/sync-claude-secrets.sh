#!/bin/bash

# Check if credentials file exists
CREDENTIALS_FILE="$HOME/.claude/.credentials.json"
if [ ! -f "$CREDENTIALS_FILE" ]; then
    echo "Error: Credentials file not found at $CREDENTIALS_FILE"
    exit 1
fi

# Check if repository argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <repository1,repository2,...>"
    echo "Example: $0 owner/repo1,owner/repo2"
    exit 1
fi

# Read credentials from JSON file
ACCESS_TOKEN=$(jq -r '.claudeAiOauth.accessToken' "$CREDENTIALS_FILE")
REFRESH_TOKEN=$(jq -r '.claudeAiOauth.refreshToken' "$CREDENTIALS_FILE")
EXPIRES_AT=$(jq -r '.claudeAiOauth.expiresAt' "$CREDENTIALS_FILE")

# Check if jq successfully extracted values
if [ "$ACCESS_TOKEN" = "null" ] || [ -z "$ACCESS_TOKEN" ]; then
    echo "Error: Could not read accessToken from credentials file"
    exit 1
fi

if [ "$REFRESH_TOKEN" = "null" ] || [ -z "$REFRESH_TOKEN" ]; then
    echo "Error: Could not read refreshToken from credentials file"
    exit 1
fi

if [ "$EXPIRES_AT" = "null" ] || [ -z "$EXPIRES_AT" ]; then
    echo "Error: Could not read expiresAt from credentials file"
    exit 1
fi

# Split repositories by comma
IFS=',' read -ra REPOS <<< "$1"

# Set secrets for each repository
for repo in "${REPOS[@]}"; do
    # Trim whitespace
    repo=$(echo "$repo" | xargs)
    
    echo "Setting secrets for repository: $repo"
    
    # Set CLAUDE_ACCESS_TOKEN
    echo "$ACCESS_TOKEN" | gh secret set CLAUDE_ACCESS_TOKEN --repo "$repo"
    if [ $? -eq 0 ]; then
        echo "✓ CLAUDE_ACCESS_TOKEN set successfully"
    else
        echo "✗ Failed to set CLAUDE_ACCESS_TOKEN"
    fi
    
    # Set CLAUDE_REFRESH_TOKEN
    echo "$REFRESH_TOKEN" | gh secret set CLAUDE_REFRESH_TOKEN --repo "$repo"
    if [ $? -eq 0 ]; then
        echo "✓ CLAUDE_REFRESH_TOKEN set successfully"
    else
        echo "✗ Failed to set CLAUDE_REFRESH_TOKEN"
    fi
    
    # Set CLAUDE_EXPIRES_AT
    echo "$EXPIRES_AT" | gh secret set CLAUDE_EXPIRES_AT --repo "$repo"
    if [ $? -eq 0 ]; then
        echo "✓ CLAUDE_EXPIRES_AT set successfully"
    else
        echo "✗ Failed to set CLAUDE_EXPIRES_AT"
    fi
    
    echo "---"
done

echo "Done!"
#!/bin/bash

# Set the new app name
NEW_APP_NAME="焦慮戳戳戳"

# Path to the project.pbxproj file
PROJECT_FILE="panictrack.xcodeproj/project.pbxproj"

# Add INFOPLIST_KEY_CFBundleDisplayName to both Debug and Release configurations
sed -i '' 's/GENERATE_INFOPLIST_FILE = YES;/GENERATE_INFOPLIST_FILE = YES;\n\t\t\t\tINFOPLIST_KEY_CFBundleDisplayName = "'"$NEW_APP_NAME"'";/g' "$PROJECT_FILE"

echo "App name updated to: $NEW_APP_NAME"

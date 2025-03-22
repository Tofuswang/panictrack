#!/bin/bash

# Path to the project.pbxproj file
PROJECT_FILE="panictrack.xcodeproj/project.pbxproj"

# Remove any INFOPLIST_FILE entries that might be causing conflicts
sed -i '' 's/INFOPLIST_FILE = panictrack\/Info.plist;//g' "$PROJECT_FILE"

echo "Fixed Info.plist conflict"

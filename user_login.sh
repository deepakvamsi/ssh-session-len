#!/bin/bash

# Specify the username for which you want to check SSH session time
USERNAME="ubuntu"
START_DATE=$(date -d "7 days ago" +"%Y-%m-%d")
# Use the last command to get login/logout information for the specified user
SESSION_INFO=$(last -i -s "$START_DATE"| grep "$USERNAME")
TOTAL_DURATION=0

echo "SshLoggedip, LoginTime($(date +"%Z")), SesionDuration(hrs:mins)"
# Loop through each line of session information
while read -r line; do
    # Extract session details
    STATUS=$(echo "$line" | awk '{print $8}')
    HOSTNAME=$(echo "$line" | awk '{print $3}')
    LOGIN_TIME=$(echo "$line" | awk '{print $5, $6, $7}')
    LOGOUT_TIME=$(echo "$line" | awk '{print $9, $10, $11}')

    # Calculate session duration if logged out
    if [ "$STATUS" != "still" ]; then
        # Convert login and logout times to timestamps for calculation
        LOGIN_TIMESTAMP=$(date -d "$LOGIN_TIME" +%s)
        LOGOUT_TIMESTAMP=$(date -d "$LOGOUT_TIME" +%s)
        # Calculate session duration in seconds
        SESSION_DURATION=$((LOGOUT_TIMESTAMP - LOGIN_TIMESTAMP))
        # Convert session duration to HH:MM:SS format
        SESSION_DURATION_HMS=$(date -u -d @"$SESSION_DURATION" +'%H:%M:%S')
	TOTAL_DURATION=$((TOTAL_DURATION + SESSION_DURATION))
        # Display session details
        echo "$HOSTNAME, $LOGIN_TIME,$SESSION_DURATION_HMS"
    fi
done <<< "$SESSION_INFO"

echo "Total system usage via ssh: $(date -u -d @"$TOTAL_DURATION" +'%H:%M:%S')"

#!/bin/bash

# FilmsUpdater Plex App/Script for Filebot:
# To be used for Filebot AMC Scripts as: --def exec="/home/userName/scripts/updatePlex.sh"
# Filebot Automated Media Center: https://www.filebot.net/forums/viewtopic.php?t=215

# The script allows you to independantly logout of your main Plex account without refreshing the PlexToken everytime.
# More info: https://forums.plex.tv/t/how-to-request-a-x-plex-token-token-for-your-app/84551

# Register your FilmsUpdater App/Script with Plex:
# The below code will register your FilmsUpdater script as a Plex App with its own PlexToken.
# Use this once only to generate unique Plex token.

# Run this in Terminal: (Can be run in one copy-paste, remove the #'s)
# curl -X "POST" "https://plex.tv/users/sign_in.json" \
#     -H "X-Plex-Version: 1.0.0" \
#     -H "X-Plex-Product: FilmsUpdater" \
#     -H "X-Plex-Client-Identifier: 4444-s-444" \
#     -H "Content-Type: application/x-www-form-urlencoded; charset=utf-8" \
#     --data-urlencode "user[password]=YOUR_PASSWORD" \
#     --data-urlencode "user[login]=YOUR_USERNAME"
#
# Output in terminal, look for: "authentication_token" this is your unique plexToken for FilmsUpdater.

# Plex Media Server URL Commands
# https://support.plex.tv/articles/201638786-plex-media-server-url-commands
# Updates all libraries: curl "http://[PMS_IP_Address]:32400/library/sections/all/refresh?X-Plex-Token=YourTokenGoesHere"
# Updates one library "12": curl "http://[PMS_IP_Address]:32400/library/sections/12/refresh?X-Plex-Token=YourTokenGoesHere"

# Step 1:
# Finding an authentication token / X-Plex-Token
# https://support.plex.tv/articles/204059436-finding-an-authentication-token-x-plex-token/

# Step 2:
# Listing Defined Libraries
# A list of Libraries with details for each Library is available:
# Run this in browser: http://[PMS_IP_Address]:32400/library/sections?X-Plex-Token=YourTokenGoesHere

# Step 3:
# Setting up: the updatePlex.sh
# Change the scripts permission to 755, so it makes it executable by you.
# Run these 2 commands in terminal:

# Go to folder: cd ~/scripts
# Make it executable: chmod +x updatePlex.sh
# Get full path enter: readlink -f updatePlex.sh

# Step 4:
# Test it, use full path: sh /home/userName/scripts/updatePlex.sh

# Step 5:
# Filebot intergration: --def exec="/home/userName/scripts/updatePlex.sh"

# "authentication_token" (plexToken)
plexToken="YourTokenGoesHere"
# Plex Server URL with port
serverHost="http://[PMS_IP_Address]:32400"
Films4K=4
FilmsHD=10
FilmsSD=12
# Films HD:
curl "$serverHost/library/sections/$FilmsHD/refresh?X-Plex-Token=$plexToken"
# Films SD:
curl "$serverHost/library/sections/$FilmsSD/refresh?X-Plex-Token=$plexToken"
# Films 4K:
curl "$serverHost/library/sections/$Films4K/refresh?X-Plex-Token=$plexToken"

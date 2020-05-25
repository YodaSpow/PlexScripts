#!/bin/bash

# Rclone upload script with optional Slack notification upon move completion (if something is moved)
#
# Recommended for use via cron
# 2AM: 0 02 * * * /home/userName/scripts/rclone-upload-with-notification.sh > /dev/null 2>&1
#
# Make a cron time: https://crontab.guru
# More info: https://askubuntu.com/questions/216692/where-is-the-user-crontab-stored

# Configuring Oauth for Google Drive: https://kb.ultraseedbox.com/display/DOC/Configuring+Oauth+for+Google+Drive
# rclone - Rclone Mount using Systemd: https://kb.ultraseedbox.com/display/DOC/rclone+-+Rclone+Mount+using+Systemd
# rclone setup: https://kb.ultraseedbox.com/display/DOC/rclone+-+Installation+and+Introduction

# MergeFS setup: https://kb.ultraseedbox.com/display/DOC/rclone+-+Rclone+VFS+and+MergerFS+Setup
# Slack webhook documentation: https://api.slack.com/messaging/webhooks
# -----------------------------------------------------------------------------

# Both NEED to be set:
SOURCE_DIR="$HOME/Stuff/Local/yourMediaFolder/"
DESTINATION_DIR="$HOME/Stuff/Mount/yourMediaFolder/"

# Update this with your Slack webhook:
SLACK_WEBHOOK_URL=""

LOCK_FILE="$HOME/rclone-upload.lock"
LOG_FILE="$HOME/rclone-upload.log"

# DO NOT EDIT BELOW THIS LINE UNLESS YOU KNOW WHAT YOU'RE DOING
# -----------------------------------------------------------------------------

trap 'rm -f $LOCK_FILE; exit 0' SIGINT SIGTERM
if [ -e "$LOCK_FILE" ]
then
  echo "$0 is already running."
  exit
else
  touch "$LOCK_FILE"

  rclone_move() {
    rclone_command=$(
      "$HOME"/bin/rclone move -vP \
      --config="$HOME"/.config/rclone/rclone.conf \
      --drive-chunk-size 64M \
      --use-mmap \
      --drive-stop-on-upload-limit \
      --delete-empty-src-dirs \
      --exclude=".*{/**,}" \
      --fast-list \
      --log-file="$LOG_FILE" \
      --stats=9999m \
      --tpslimit=5 \
      --transfers=2 \
      --checkers=4 \
      --bwlimit=30M \
      "$SOURCE_DIR" "$DESTINATION_DIR" 2>&1
    )
    # "--stats=9999m" mitigates early stats output
    # "2>&1" ensures error output when running via command line
    echo "$rclone_command"
  }
  rclone_move

  if [ "$SLACK_WEBHOOK_URL" != "" ]; then

    rclone_sani_command="$(echo $rclone_command | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g')" # Remove all escape sequences

    # Notifications assume following rclone ouput:
    # Transferred: 0 / 0 Bytes, -, 0 Bytes/s, ETA - Errors: 0 Checks: 0 / 0, - Transferred: 0 / 0, - Elapsed time: 0.0s

    transferred_amount=${rclone_sani_command#*Transferred: }
    transferred_amount=${transferred_amount%% /*}

    send_notification() {
      output_transferred_main=${rclone_sani_command#*Transferred: }
      output_transferred_main=${output_transferred_main% Errors*}
      output_errors=${rclone_sani_command#*Errors: }
      output_errors=${output_errors% Checks*}
      output_checks=${rclone_sani_command#*Checks: }
      output_checks=${output_checks% Transferred*}
      output_transferred=${rclone_sani_command##*Transferred: }
      output_transferred=${output_transferred% Elapsed*}
      output_elapsed=${rclone_sani_command##*Elapsed time: }

      notification_data='{
        "text": "*Upload Task: Success!*",
        "color": "#36a64f",
        "fields": [
          {
            "name": "Transferred",
            "value": "'"$output_transferred_main"'"
          },
          {
            "name": "Errors",
            "value": "'"$output_errors"'"
          },
          {
            "name": "Checks",
            "value": "'"$output_checks"'"
          },
          {
            "name": "Transferred",
            "value": "'"$output_transferred"'"
          },
          {
            "name": "Elapsed time",
            "value": "'"$output_elapsed"'"
          }
        ],
        "thumbnail": {
          "url": null
        }
      }'

      /usr/local/bin/curl -X POST -H "Content-Type: application/json" --data "$notification_data" $SLACK_WEBHOOK_URL
    }

    if [ "$transferred_amount" != "0" ]; then
      send_notification
    fi

  fi

  rm -f "$LOCK_FILE"
  trap - SIGINT SIGTERM
  exit
fi

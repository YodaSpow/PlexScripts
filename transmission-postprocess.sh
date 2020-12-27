#!/bin/bash

export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_CTYPE="en_US.UTF-8"

TORRENT_PATH="$TR_TORRENT_DIR/$TR_TORRENT_NAME"
TORRENT_NAME="$TR_TORRENT_NAME"
TORRENT_LABEL="N/A"

# Subtitle language
SUBLANG=en, pt
SKIP_EXTRACT=n
MUSIC=n

# rclone for moving files to gdrive
RCLONE_DIR="yourMediaFolder"

filebot -script /opt/filebot/scripts/amc.groovy \
--output "$HOME/MergerFS" \
-non-strict --encoding utf8 --log all --log-file amc-transmission.log --action copy --conflict auto \
--def artwork=false ut_kind=multi --def ignore="Sonarr|Radarr|SickChill" --def ut_label=Movie "ut_dir=$TORRENT_PATH" "ut_title=$TORRENT_NAME" subtitles=$SUBLANG \
--def "movieFormat={vf =~ /2160p/ ? '$RCLONE_DIR/Films 4K' : fn =~ /3D|3d|HSBS|3dhsbs|H-SBS|3dhou|H-OU/ ? '$RCLONE_DIR/Films 3D' : vf =~ /1080p/ ? '$RCLONE_DIR/Films HD/1080p' : vf =~ /720p/ ? '$RCLONE_DIR/Films HD/720p' : vf =~ /576p/ ? '$RCLONE_DIR/Films SD/576p' : vf =~ /480p/ ? '$RCLONE_DIR/Films SD/480p' : vf =~ /360p/ ? '$RCLONE_DIR/Films SD/360p' : vf =~ /240p/ ? '$RCLONE_DIR/Films SD/240p' : '$RCLONE_DIR/Films SD/root'}/{n} ({y})/{n} ({y}) - {allOf{match}{s3d}{hd}{vc}{vf} join ' '}{' - pt'+pi}{'.'+lang}" \
--def music=n --def unsorted=y --def unsortedFormat="$HOME/Stuff/Unsorted/{fn =~ /2160p|4K|4k|UHD/ ? 'UHD-2160p/' : fn =~ /1080p/ ? 'HD-1080p' : fn =~ /720p/ ? 'HD-720p' : 'SD'}/{fn.before(/S\d{2}E\d{2}/).upperInitial().space(' ')} - {fn.match(/S\d{2}E\d{2}/).upper()} - {fn.after(/S\d{2}E\d{2}/).stripReleaseInfo().upperInitial().space(' ')} [{allOf{match}{s3d}{hd}{vc}{source}{vf}{('-')}{af}{ac}{channels}{n.findMatch(group) ? null : '- '+group} join ' '}].{ext}" --def exec="/home/userName/scripts/updatePlex.sh" \
extractFolder="$HOME/files/_extracted" music=$MUSIC skipExtract=$SKIP_EXTRACT &

#!/bin/zsh
# Script to record video from camera with audio and create diary note for Obsidian in markdown
# It uses videosnap for macos https://github.com/matthutchinson/videosnap/. You need to install it and have it in your path
# It was done for macos, but if videosnap and ffmpeg and obsidian are installed, it should work in any system
# Author: Sebastian Garcia, eldraco@gmail.com


# Trap CTRL-C because is the only way to stop videosnap
trap ctrl_c INT

function ctrl_c() {
        echo "Converting the video to mp4 with good compresion"
        # Original video is 1280x720
        # Crop to get the face mainly and decrease size of video
        ffmpeg -hide_banner -loglevel quiet -i $PREVIDEONAME -filter:v "crop=640:480:320:120" temp.mp4
        # Doing this twice reduces the size but not so much the quality, not sure why
        ffmpeg -hide_banner -loglevel quiet -i temp.mp4 $VIDEONAME 
        rm temp.mp4
}

FILENAME="diary-video-"$(date +'%Y-%m-%d--%H.%M.%S')
# Example path for your obsidian capsule
OBSIDIANPATH="PATH-to-CAPSULE-FOLDER"
OBSIDIANFILE=$OBSIDIANPATH"Personal/Diary/"$FILENAME".md"
PREVIDEONAME=$FILENAME".mov"
VIDEONAME=$FILENAME".mp4"


if [ ! -d $OBSIDIANPATH ]; then
    echo "Obsidian capsule folder does not exist"
    exit 1
fi

echo "Storing diary entry in $OBSIDIANFILE"

# Create file content first
echo "# Diary" > $OBSIDIANFILE
echo -n "\n\n\n" >> $OBSIDIANFILE
echo "# Video" >> $OBSIDIANFILE
echo "![["$VIDEONAME"]]" >> $OBSIDIANFILE

# Record video
echo "Reconding a video diary on $VIDEONAME"
videosnap -p High $PREVIDEONAME

# If the conversion worked
if [ $? -eq 0 ]; then
    # If the video is there and is not empty
    if [ -s $VIDEONAME ]; then
    rm $PREVIDEONAME
    mv $VIDEONAME $OBSIDIANPATH"/Media/"
    fi
else
    echo "Some command failed"
fi


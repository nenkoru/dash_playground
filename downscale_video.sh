#!/bin/bash

INPUT="$1"
OUTPUT="stream.mpd"

if [ -z "$INPUT" ]; then
    echo "Usage: $0 input_video"
    exit 1
fi

# Detect video height
HEIGHT=$(ffprobe -v error -select_streams v:0 \
-show_entries stream=height -of csv=p=0 "$INPUT")

# Resolution ladder (name height width bitrate)
LADDER="
360 640 800k
480 854 1200k
720 1280 1500k
1080 1920 3000k
1440 2560 6000k
2160 3840 12000k
2880 5120 20000k
4320 7680 40000k
"

# Determine valid outputs
COUNT=0
FILTER=""
MAPS=""
INDEX=0

for r in $LADDER; do
    if [ $((INDEX%3)) -eq 0 ]; then
        RH=$r
    elif [ $((INDEX%3)) -eq 1 ]; then
        RW=$r
    else
        RB=$r

        if [ "$HEIGHT" -ge "$RH" ]; then
            COUNT=$((COUNT+1))
            RESLIST="$RESLIST $RH:$RW:$RB"
        fi
    fi
    INDEX=$((INDEX+1))
done

# Reverse order (largest → smallest)
REVLIST=$(echo $RESLIST | tr ' ' '\n' | tac)

# Build filter_complex split
FILTER="[0:v]split=$COUNT"
i=0
for item in $REVLIST; do
    FILTER="${FILTER}[v$i]"
    i=$((i+1))
done
FILTER="${FILTER};"

# Build scale filters
i=0
MAP_INDEX=0
for item in $REVLIST; do
    H=$(echo $item | cut -d: -f1)
    W=$(echo $item | cut -d: -f2)
    B=$(echo $item | cut -d: -f3)

    FILTER="${FILTER}[v$i]scale=${W}:${H}[vs$i];"
    MAPS="$MAPS -map [vs$i] -c:v:$MAP_INDEX libx264 -b:v:$MAP_INDEX $B"
    MAP_INDEX=$((MAP_INDEX+1))
    i=$((i+1))
done

# Run ffmpeg
ffmpeg -i "$INPUT" \
-filter_complex "$FILTER" \
$MAPS \
-map 0:a? -c:a aac -b:a 128k \
-use_timeline 1 \
-use_template 1 \
-adaptation_sets "id=0,streams=v id=1,streams=a" \
-seg_duration 4 \
-f dash "$OUTPUT"

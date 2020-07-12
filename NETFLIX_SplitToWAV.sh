#!/bin/bash


# ---- USAGE ---- #
# Only one arg as inpt (arg1). Requires to be a Quicktime.mov asset. Script will split all audio streams embedded in the quicktime asset,
# while preserving audio streams groups. 
usage() {
ARG1=$1
ARG2=$2
local ISSUE=$1
echo "
$0
arg1: must be an access path (cygwin/linux syntax) to a valid quicktime.mov(.MOV) files containing one or multiple audio streams (along with or without video stream).
ISSUE: $ISSUE
"
exit
}

# ----- set input ----
MOVFILE=$1
echo "MOVFILE:$MOVFILE"

# translate cigwin/powix path syntax to windows syntax( needs to be removed if using FFMPEG MacOS or Linux binaries)
MOVFILE_DISKNAME=$(echo "$MOVFILE" | sed "s/\/cygdrive\/\([a-z]\)\/.*/\1/" | tr "[:lower:]" "[:upper:]")
MOVFILE_DISKNAME="$MOVFILE_DISKNAME"":"
MOVFILE_WINPATH=$(echo "$MOVFILE" | sed "s/\/cygdrive\/[a-z]/$MOVFILE_DISKNAME/" )
echo "MOVFILE_WINPATH:$MOVFILE_WINPATH"

# ----- validate input ------
# arg1 must be given
[[ $MOVFILE == "" ]] && usage "No audio file given" || echo "first arg: $MOVFILE"
# access path needs to have proper extension .mov or .MOV
MOVFILE_EXT=$(echo "$MOVFILE" | sed "s/.*\/.*\.\([a-zA-Z]*\)$/\1/")
[[ $MOVFILE_EXT != "mov" ]] && [[ $WAV1_EXT != "MOV" ]] && usage "The file extension $MOVFILE is not mov or MOV"
# access path needs to lead to a proper existing .mov || .MOV file
[ -f $MOVFILE ] && echo || usage "The file $MOVFILE doesn't seem to exist"
# Quicktime assets needs to have at least one audio streams.
MOVFILE_NbSTREAMS=$(ffprobe -loglevel -8 -show_entries stream=codec_type "$MOVFILE_WINPATH" | grep "audio" | sed "s/.*=\(.*\)/\1/" | tr -d "\r" | grep -o "audio" | wc -l)
echo "number of streams: $MOVFILE_NbSTREAMS"
[ $MOVFILE_NbSTREAMS -lt 1 ] && usage "movie: $MOVFILE. No audio stream detected in the asset. At least one audio streams needs to be embedded among the .mov(.MOV) files" 

# ------ FFMPEG process ------
# split all audio streams as multiple outpot interlaced .wav files(codec: pcm_s24le)
for ch in $(seq 1 1 $MOVFILE_NbSTREAMS)
 do 
 ((index=ch-1))
 echo $index
 ffmpeg -i "$MOVFILE_WINPATH" -map 0:a:$index -c:a pcm_s24le "$MOVFILE_WINPATH"_stream$ch.wav
done

exit




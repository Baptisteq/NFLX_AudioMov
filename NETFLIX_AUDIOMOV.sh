#!/bin/bash


# ---- USAGE ---- #
# arg1 arg2 are given path (cywgwin/posix syntax) to 51 interleaved PCM.wav audio files. and arg2 is optional, if used must be a given path (cywgwin/posix syntax) to 20 interleaved PCM.wav audio files
usage() {
ARG1=$1
ARG2=$2
local ISSUE=$1
echo "
$0
arg1: must be an access path (cygwin/linux syntax) to a .wav files containing either a 5.1 PCM audio strem or a stereo PCM audio stream.
arg2 is an optionnal access. If given it must be an access path (cygwin/linux syntax) to a .wav files containing a stereo PCM audio stream 
ISSUE: $ISSUE
"
exit
}
# set args 1 & 2:
WAVFILE1=$1
WAVFILE2=$2

# Validation:
# arg1 must be given
[[ $WAVFILE1 = "" ]] && usage "No audio file given" || echo "first arg: $WAVFILE1"
# arg1 must be a valid access path to a .wav file
WAV1_EXT=$(echo "$WAVFILE1" | sed "s/.*\/.*\.\([a-zA-Z]*\)$/\1/")
[[ $WAV1_EXT != "wav" ]] && [[ $WAV1_EXT != "WAV" ]] && usage "The file extension $WAVFILE1 is not wav or WAV"
[ -f $WAVFILE1 ] && echo || usage "The file $WAVFILE1 doesn't seem to exist"



# path windows compatible
  WAVFILE1_DISKNAME=$(echo "$WAVFILE1" | sed "s/\/cygdrive\/\([a-z]\)\/.*/\1/" | tr "[:lower:]" "[:upper:]")
  WAVFILE1_DISKNAME="$WAVFILE1_DISKNAME"":"
  WAVFILE1_WINPATH=$(echo "$WAVFILE1" | sed "s/\/cygdrive\/[a-z]/$WAVFILE1_DISKNAME/" )
  echo "Winpath syntax of the first arg file access path is: $WAVFILE1_WINPATH"
  
# the wav file needs to contain a 5.1 audio stream or a stereo audio stream. PCM
# detect number of stream (it should be one as only the first audio stream will be used
WAV1_NbSTREAMS=$(ffprobe -loglevel -8 -show_entries format=nb_streams "$WAVFILE1_WINPATH" | grep "nb_streams=" | sed "s/[^0-9]//g" | tr -d "\r")
echo "number of streams: $WAV1_NbSTREAMS"
[ $WAV1_NbSTREAMS -gt 1 ] && usage "first audio file $WAVFILE1. Number of streams are greater than one. (only one audio stream expected either 5.1 or Stereo)." 

# detect audio codec of the first audio stream.
WAV1_CODEC=$(ffprobe -loglevel -8 -select_streams a:0 -show_entries stream "$WAVFILE1_WINPATH" | grep "codec_name=" | sed "s/codec_name=//"| tr -d "\r")
echo "first audio stream codec: $WAV1_CODEC"
[[ $WAV1_CODEC != "pcm_s24le" ]] && [[ $WAV1_CODEC != "pcm_s24be" ]] && usage "first audio file $WAVFILE1. Codec $WAV1_CODEC doesn't match expected ones (either pcm_s24le or pcms24_be."

# detect audio channel count of the first audio stream.
WAV1_FORMAT=$(ffprobe -loglevel -8 -select_streams a:0 -show_entries stream "$WAVFILE1_WINPATH" | grep "channels=" | sed "s/[^0-9]//g"| tr -d "\r"  )
echo "first audio stream channels count: $WAV1_FORMAT"
[ $WAV1_FORMAT != 2 ] && [ $WAV1_FORMAT != 6 ] && usage "first audio file $WAVFILE1. channels number ($WAV1_FORMAT). Doesn't match expected channels count (either 6 or 2)."

# detect total number of samples in first audio stream.
WAV1_SAMPLCOUNT=$(ffprobe -loglevel -8 -select_streams a:0 -show_entries stream "$WAVFILE1_WINPATH" | grep "duration_ts=" | sed "s/[^0-9]//g"| tr -d "\r" )
echo "first audio stream total count of samples: $WAV1_SAMPLCOUNT"

# arg2 is opt, if given:
# arg2 must be a valid access path to a .wav file
# arg1 must be a valid access path to a .wav file
WAV2_EXT=$(echo "$WAVFILE2" | sed "s/.*\/.*\.\([a-zA-Z]*\)$/\1/")
[[ $WAV2_EXT != "wav" ]] && [[ $WAV2_EXT != "WAV" ]] && usage "The file extension $WAVFILE2 is not wav or WAV"
[ -f $WAVFILE2 ] && echo || usage "The file $WAVFILE1 doesn't seem to exist"

# path windows compatible
  WAVFILE2_DISKNAME=$(echo "$WAVFILE2" | sed "s/\/cygdrive\/\([a-z]\)\/.*/\1/" | tr "[:lower:]" "[:upper:]")
  WAVFILE2_DISKNAME="$WAVFILE2_DISKNAME"":"
  WAVFILE2_WINPATH=$(echo "$WAVFILE2" | sed "s/\/cygdrive\/[a-z]/$WAVFILE2_DISKNAME/" )
  echo "
  Winpath syntax of the first arg file access path is: $WAVFILE2_WINPATH"
  
# if first wavefile is a 5.1 audio the wav file needs to contain a stereo audio stream (vice versa). PCM
# detect number of stream (it should be one as only the first audio stream will be used
WAV2_NbSTREAMS=$(ffprobe -loglevel -8 -show_entries format=nb_streams "$WAVFILE2_WINPATH" | grep "nb_streams=" | sed "s/[^0-9]//g" | tr -d "\r")
echo "number of streams: $WAV1_NbSTREAMS"
[ $WAV2_NbSTREAMS -gt 1 ] && usage "second audio file $WAVFILE2. Number of streams are greater than one. (only one audio stream expected either 5.1 or Stereo)." 

# detect audio codec of the first audio stream.
WAV2_CODEC=$(ffprobe -loglevel -8 -select_streams a:0 -show_entries stream "$WAVFILE2_WINPATH" | grep "codec_name=" | sed "s/codec_name=//"| tr -d "\r")
echo "second audio stream codec: $WAV2_CODEC"
[[ $WAV2_CODEC != "pcm_s24le" ]] && [[ $WAV2_CODEC != "pcm_s24be" ]] && usage "second audio file $WAVFILE2. Codec $WAV2_CODEC doesn't match expected ones (either pcm_s24le or pcms24_be."

# detect audio channel count of the first audio stream.
WAV2_FORMAT=$(ffprobe -loglevel -8 -select_streams a:0 -show_entries stream "$WAVFILE2_WINPATH" | grep "channels=" | sed "s/[^0-9]//g"| tr -d "\r"  )
echo "second audio stream channels count: $WAV2_FORMAT"

if [ $WAV1_FORMAT = 6 ]; then
  [ $WAV2_FORMAT != 2 ] && usage "first file has 6 channels (presumably 5.1 LRCLFELSRS). Second file doesn't have 2 channels (stereo) as expected."
  elif [ $WAV1_FORMAT = 2 ]; then
  [ $WAV2_FORMAT != 6 ] && usage "first file has 2 channels (presumably stereo). Second file doesn't have 6 channels (5.1) as expected."
fi

# detect total number of samples in first audio stream.
WAV2_SAMPLCOUNT=$(ffprobe -loglevel -8 -select_streams a:0 -show_entries stream "$WAVFILE2_WINPATH" | grep "duration_ts=" | sed "s/[^0-9]//g"| tr -d "\r" )
echo "second audio stream total count of samples: $WAV2_SAMPLCOUNT"

# number of samples of one track must be exactly identical to the first argument file

[ $WAV1_SAMPLCOUNT != $WAV2_SAMPLCOUNT ] && usage "$first audio file: $WAVFILE1 ($WAV1_SAMPLCOUNT samples) 
and second audio file: $WAVFILE2 ($WAV2_SAMPLCOUNT samples)
don't share the identical sample count value. Both audio assets need to be stricly synchronised by samples lenght." || TWOVALIDMIX="True"


#-----FFMPEG PROCESS----#
# if two audio assets are given. identify the 5.1 mix and identify the 2.0 mix.
echo "two valid mix ?: $TWOVALIDMIX"

if [[ $TWOVALIDMIX == "True" ]]; then
  [ $WAV1_FORMAT = 6 ] && SNDMIX="$WAVFILE1_WINPATH" && LRMIX="$WAVFILE2_WINPATH"
  [ $WAV1_FORMAT = 2 ] && SNDMIX="$WAVFILE2_WINPATH" && LRMIX="$WAVFILE1_WINPATH"
fi

echo "
51m mix is: $SNDMIX
20 mix is: $LRMIX"



ffmpeg -i "$SNDMIX" -i "$LRMIX" -filter_complex \
"[0:a]channelsplit=channel_layout=5.1; \
[1:a]channelsplit=channel_layout=stereo" -c:a pcm_s24le output.mov
# ffmpeg -i in.mp3 -filter_complex "[0:a]channelsplit=channel_layout=stereo" output.mka


exit


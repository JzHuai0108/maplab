#!/bin/bash
# In docker, "catkin make opencv3_catkin" often encounters error
# "# connect to 151.101.228.133 port 443 failed: Connection refused" in
# downloading files like boostdesc_bgm_hd.i and vgg_generated_64.i.
# The current approach is to download them manually and put to the proper folder.

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 </path/to/maplab_ws>" 
    exit 1
fi
MAPLAB_WS=$1
if [[ ! -d "$MAPLAB_WS" ]]; then
  echo "$MAPLAB_WS does not exist!"
  exit 2 
fi

VGG_COMMIT="fccf7cd6a4b12079f73bbfb21745f9babcd4eb1d"
VGG_NAMES=(vgg_generated_48.i \
vgg_generated_64.i \
vgg_generated_80.i \
vgg_generated_120.i)

BOOSTDESC_COMMIT="34e4206aef44d50e6bbcd0ab06354b52e7466d26"
BOOSTDESC_NAMES=(boostdesc_bgm.i \
boostdesc_bgm_bi.i \
boostdesc_bgm_hd.i \
boostdesc_binboost_064.i \
boostdesc_binboost_128.i \
boostdesc_binboost_256.i \
boostdesc_lbgm.i)

COMPLETED_FILES=0

download_xfeatures2d_file() {
COMMIT=$1
FILENAME=$2
OUTPUT_DIR="$MAPLAB_WS/build/opencv3_catkin/opencv3_src/build/downloads/xfeatures2d"
FILEPATH="$OUTPUT_DIR/$FILENAME"
FILEURL="https://raw.githubusercontent.com/opencv/opencv_3rdparty/$COMMIT/$FILENAME"
if [[ -f "$FILEPATH" ]]; then
  echo "$FILEPATH exists and saves downloading!"
  COMPLETED_FILES=$(( $COMPLETED_FILES+1 ))
else
  CMD="wget $FILEURL -P $OUTPUT_DIR --connect-timeout=20 --waitretry=0 --retry-connrefused --no-dns-cache"
  echo $CMD
  $CMD
  if [[ $? -ne 0 ]]; then 
    echo "Failed to download $FILEURL"
  else 
    COMPLETED_FILES=$(( $COMPLETED_FILES+1 ))
  fi
fi
}

for (( j = 0; j < ${#VGG_NAMES[@]}; j++ )); do
  download_xfeatures2d_file $VGG_COMMIT ${VGG_NAMES[$j]}
done

for (( j = 0; j < ${#BOOSTDESC_NAMES[@]}; j++ )); do
  download_xfeatures2d_file $BOOSTDESC_COMMIT ${BOOSTDESC_NAMES[$j]}
done

EXPECTED_FILES=$(( ${#VGG_NAMES[@]}+${#BOOSTDESC_NAMES[@]} ))
if [[ $COMPLETED_FILES -ne $EXPECTED_FILES ]]; then 
  echo "Error: Only downloaded $COMPLETED_FILES out of $EXPECTED_FILES vgg and boostdesc files!"
  exit 1
else 
  echo "Finished downloading $EXPECTED_FILES vgg and boostdesc files!"
  exit 0
fi

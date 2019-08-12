#!/bin/bash
 
# sourcehost: choose a mirror in your proximity!
HOST=ftp2.de.debian.org;
 
# destination directory
OUTPUT_FOLDER=
 
# Debian version(s) to mirror
DIST=buster
 
# architecture
ARCH=armhf

# Start parsing options
while getopts "h?o:s:d:a" opt; do
  case "$opt" in
  h|\?)
      echo "the following flags are required: -o <path/to/external/drive>"
      echo "the following flags are optional: -s <host> -d <distribution> -a <architecture>"
      break
      ;;
  o)  echo "setting output folder: " $OPTARG
      OUTPUT_FOLDER=$OPTARG
      ;;
  s)  echo "setting host: " $OPTARG
      HOST=$OPTARG
      ;;
  d)  echo "setting distribution: " $OPTARG
      DIST=$OPTARG
      ;;
  a)  echo "setting architecture " $OPTARG
      ARCH=$OPTARG
      ;;
  esac
done


# If the output path or version are not set, abort
if [ -z "$OUTPUT_FOLDER" ]
then 
  echo " "
  echo "error: path to external drive not set: use -o"
  echo " "
  exit
fi

mkdir $OUTPUT_FOLDER/debian

debmirror ${OUTPUT_FOLDER}/debian \
 --progress \
 --nosource \
 --host=${HOST} \
 --root=/debian \
 --dist=${DIST} \
 --section=main,contrib,non-free,main/debian-installer \
 --i18n \
 --arch=${ARCH} \
 --method=rsync \
 --state-cache-days=10000 \
 --retry-rsync-packages=0 \
 --passive \
 --keyring /usr/share/keyrings/debian-archive-keyring.gpg \
 --keyring /usr/share/keyrings/debian-archive-buster-stable.gpg \
 --keyring /usr/share/keyrings/debian-archive-buster-security-automatic.gpg \
 --keyring /usr/share/keyrings/debian-archive-buster-automatic.gpg \
 --keyring /usr/share/keyrings/debian-keyring.gpg \
 --keyring /usr/share/keyrings/debian-maintainers.gpg \
 --keyring /usr/share/keyrings/debian-nonupload.gpg \
 --keyring /usr/share/keyrings/debian-role-keys.gpg \
 $VERBOSE

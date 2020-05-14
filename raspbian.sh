#!/bin/bash

# make temporary directory
mkdir -p /tmp/raspbian_setup

# download pgp packet library and utiltiy
git clone --recurse-submodules git@github.com:summitto/pgp-key-generation.git /tmp/raspbian_setup/pgp-key-generation
git clone --recurse-submodules git@github.com:summitto/pgp-packet-library.git /tmp/raspbian_setup/pgp-packet-library

# download raspbian image
IMAGE_NAME="2019-07-10-raspbian-buster-lite"
DIST="buster"
curl http://director.downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2019-07-12/$IMAGE_NAME.zip -C - -s -o /tmp/raspbian_setup/$IMAGE_NAME.zip

# verify that correct image was downloaded
if [[ "$(sha256sum /tmp/raspbian_setup/$IMAGE_NAME.zip | while read -a array; do echo "${array[0]}" ; done)" != "9e5cf24ce483bb96e7736ea75ca422e3560e7b455eee63dd28f66fa1825db70e" ]]
then 
  echo "downloaded raspbian image failed checksum verification, exiting..."
  exit 1
fi

# unzip downloaded zipped image
unzip /tmp/raspbian_setup/$IMAGE_NAME.zip -d /tmp/raspbian_setup/


# download boost image
BOOST_DOT_VERSION="1.72.0"
BOOST_VERSION="1_72_0"

curl https://dl.bintray.com/boostorg/release/${BOOST_DOT_VERSION}/source/boost_${BOOST_VERSION}.tar.bz2 -L -C - -o -s /tmp/boost_$BOOST_VERSION.tar.bz2

# verify that correct file was downloaded
if [[ "$(sha256sum /tmp/boost_${BOOST_VERSION}.tar.bz2 | while read -a array; do echo "${array[0]}" ; done)" != "59c9b274bc451cf91a9ba1dd2c7fdcaf5d60b1b3aa83f2c9fa143417cc660722" ]]
then 
  echo "downloaded boost file failed checksum verification, exiting..."
  exit 1
fi

# extract partition table information of the image
while read -a array; do 
  # extract sector size
  if [[ "${array[0]}" == "Units:" ]]
  then          
    SECTOR_START="${array[5]}";
  fi
  
  if [[ "${array[0]}" == *"$IMAGE_NAME.img2" ]]
  then          
    SECTOR_SIZE="${array[1]}";
  fi
done <<< $(fdisk -l /tmp/raspbian_setup/$IMAGE_NAME.img) # using process substitution to access variables from outside while loop

# mount raspbian image
mkdir -p $IMAGE_NAME
sudo mount -o loop,offset=$(($SECTOR_START*$SECTOR_SIZE)) /tmp/raspbian_setup/$IMAGE_NAME.img $IMAGE_NAME

# move pgp libraries to pi
sudo mv /tmp/raspbian_setup/pgp-key-generation $IMAGE_NAME/home/pi
sudo mv /tmp/raspbian_setup/pgp-packet-library $IMAGE_NAME/home/pi

# extract the boost libraries to pi
tar --bzip2 -xf /tmp/boost_${BOOST_VERSION}.tar.bz2 -C $IMAGE_NAME/home/pi

# Replace existing apt sources by local source list
echo "deb file:///mnt/usb/debian/ $DIST main contrib non-free" | sudo tee $IMAGE_NAME/etc/apt/sources.list > /dev/null

# copy startup script to pi
cp start.sh $IMAGE_NAME/home/pi/

# ensure .gnupg folder exists
echo "" >> $IMAGE_NAME/home/pi/.bashrc
echo "mkdir -p ~/ramdisk/.gnupg" >> $IMAGE_NAME/home/pi/.bashrc

# create ramdisk at startup
mkdir -p $IMAGE_NAME/home/pi/ramdisk
echo "tmpfs       /home/pi/ramdisk tmpfs   nodev,nosuid,noexec,nodiratime,size=512M   0 0" | sudo tee -a $IMAGE_NAME/etc/fstab > /dev/null

# allow external drive to be mounted by user
sudo mkdir -p $IMAGE_NAME/mnt/usb
echo "/dev/sda1   /mnt/usb ext4   noauto,user,nodev,nosuid,noexec,nodiratime   0 0" | sudo tee -a $IMAGE_NAME/etc/fstab > /dev/null

# give ramdisk and start script the same permissions as the pi home folder
USERNAME=$(stat -c "%U" $IMAGE_NAME/home/pi)
chown -R ${USERNAME} $IMAGE_NAME/home/pi/ramdisk
chown ${USERNAME} $IMAGE_NAME/home/pi/start.sh

# unmount image
sudo umount $IMAGE_NAME
rmdir $IMAGE_NAME

echo ""
echo "Now please open another terminal while your sd card is not inserted and (1) run lsblk (2) insert your sd card (3) run lsblk again." 
echo ""
read -p "Insert the device name which just appeared. E.g. mmcblk0 or sdb1: "  DEVICE_NAME

# Make sure the user knows what he/she is doing
read -p "We will now format your sd card, are you sure you want to continue? (y) " res
if [[ "$res" != "y" ]]
then 
  echo " "
  echo "exiting"
  exit 1
fi

# unmount sd card
while read -a array; do 
  if [[ "${array[0]}" == *"$DEVICE_NAME"* ]]
  then
    echo "${array[6]}"
    sudo umount "${array[6]}"
  fi
done <<< $(lsblk) # using process substitution to access variables from outside while loop

sudo dd bs=4M if=/tmp/raspbian_setup/$IMAGE_NAME.img of=/dev/$DEVICE_NAME status=progress conv=fsync

echo "Congratulations! You may now take out your sd card"

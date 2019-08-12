mount /mnt/usb
sudo apt -y install /mnt/usb/debian/pool/main/d/debian-keyring/debian-keyring_2019.02.25_all.deb
sudo apt -y install /mnt/usb/debian/pool/main/d/debian-archive-keyring/debian-archive-keyring_2019.1_all.deb
sudo apt -y update --fix-missing
sudo apt -y upgrade
sudo apt -y install cmake libboost-dev libcrypto++-dev git libsodium-dev libboost-program-options-dev

# remove existing gnupg folder
rm -rf ~/.gnupg

# create symlink to ramdisk
ln -fs ~/ramdisk/.gnupg ~/.gnupg

# build pgp library and utility
mkdir -p ~/pgp-packet-library/build
cd ~/pgp-packet-library/build && cmake .. && make && sudo make install
mkdir -p ~/pgp-key-generation/build
cd ~/pgp-key-generation/build && cmake .. && make


mount /mnt/usb
sudo apt -y install /mnt/usb/debian/pool/main/d/debian-keyring/debian-keyring_2019.02.25_all.deb
sudo apt -y install /mnt/usb/debian/pool/main/d/debian-archive-keyring/debian-archive-keyring_2019.1_all.deb
sudo apt -y update --fix-missing
sudo apt -y upgrade
sudo apt -y install cmake libcrypto++-dev git libsodium-dev g++-8 gcc-8

# set the default compiler version
sudo update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++-8 100
sudo update-alternatives --install /usr/bin/cc cc /usr/bin/gcc-8 100

# install boost
BOOST_VERSION="1_72_0"
cd ~/boost_${BOOST_VERSION}
./bootstrap.sh
./b2 install

# because there is a mismatch between the gpg-agent version installed on
# Raspbian Buster (= 2.2.12-1+rpi1) and the gpg-agent version (= 2.2.12-1)
# which is required by scdaemon, we force install this package manually
dpkg --force-all -i /mnt/usb/debian/pool/main/g/gnupg2/scdaemon_2.2.12-1_armhf.deb

# remove existing gnupg folder
rm -rf ~/.gnupg

# create symlink to ramdisk
ln -fs ~/ramdisk/.gnupg ~/.gnupg

# ensure permissions are set correctly
find ~/ramdisk/ -type d -print0 | xargs -0 chmod 700
find ~/ramdisk/ -type f -print0 | xargs -0 chmod 600

# build pgp library and utility
mkdir -p ~/pgp-packet-library/build
cd ~/pgp-packet-library/build && cmake .. && make && sudo make install
mkdir -p ~/pgp-key-generation/build
cd ~/pgp-key-generation/build && cmake .. && make

# add build directories to path
export "~/pgp-key-generation/build/generate_derived_key:~/pgp-key-generation/build/extend_key_expiry:$PATH"

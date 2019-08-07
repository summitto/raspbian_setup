# Initial raspbian setup

1. Install debmirror

    sudo apt install debmirror  

2. Download debian mirror to an external drive formatted to a file system
   supported by your raspberry pi in order to get offline access to all
   packages.  

    ./download_deb_mirror.sh -o /path/to/external/drive  

3. Download Raspbian and flash the SD card with the image

    ./raspbian.sh  

4. Power on and login to Raspberry Pi

5. Adjust keyboard settings to your liking (probably XKBLAYOUT=us
   XKBVARIANT=intl) in:  

    /etc/default/keyboard  

6. Execute start script to install all required packages

    chmod +x start.sh && ./start.sh

# Upgrading to new debian version

Follow steps 1, 2 and 5, using the new debian version instead of "buster".
Additionally, run:  

    sudo apt full-upgrade  

# Further reading

https://www.tobanet.de/dokuwiki/debian:debmirror  

https://www.debian.org/mirror/ftpmirror  

https://help.ubuntu.com/community/AptGet/Offline/Repository  


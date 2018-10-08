#!/bin/bash

set -eu

source /etc/os-release

# Check we're on Raspbian Stretch (Debian 9)

if [ $VERSION_ID -eq 9 ]; then
    echo -ne "\nYou are running Raspbian Stretch. Starting Astro Pi setup"
    sleep 0.2
    echo -n "."
    sleep 0.2
    echo -n "."
    sleep 0.2
    echo -n "."
else
    echo -e "\nYou seem to be using {$PRETTY_NAME}. This installer is for Raspbian Stretch. Please download Raspbian Stretch from the Raspberry Pi website http://rpf.io/raspbian"
    exit 1
fi

# Check we're on desktop or lite

chromium=`dpkg -l | grep chromium | wc -l`
if [ $chromium -gt 0 ]; then
    desktop=true
    echo -ne "\n\nIt looks like you are running Raspbian Desktop.\n"
else
    desktop=false
    echo -ne "\n\nIt looks like you are running Raspbian Lite.\n"
fi

# Check if git was already installed

git=`dpkg -l | grep "ii  git" | wc -l`
if [ $git -gt 0 ]; then
    git_installed=true
else
    git_installed=false
fi

# Update and install apt packages

echo -ne "\nUpdating and upgrading your apt packages"

sudo apt-get -qq update
echo -n "."
sudo apt-get -qqy upgrade
echo -n "."
sudo apt-get -qqy dist-upgrade
echo -n "."
sudo apt-get -y install \
    zip wget tree git \
    sense-hat i2c-tools libatlas3-base \
    python3 python3-pip python3-gpiozero python3-rpi.gpio python3-pygame \
    python3-picamera python3-colorzero python3-gdal \
    libhdf5-100 libharfbuzz0b libwebp6 libtiff5 libjasper1 libilmbase12 \
    libopenexr22 libgstreamer1.0-0 libavcodec57 libavformat57 libavutil55 \
    libswscale4 libgtk-3-0 libpangocairo-1.0-0 libpango-1.0-0 libatk1.0-0 \
    libcairo-gobject2 libcairo2 libgdk-pixbuf2.0-0 \
    > /dev/null

# Clone this repo to have

git clone -q https://github.com/astro-pi/astro-pi-stretch-installer


# Remove git if it wasn't installed before

if ! $git_installed; then
    sudo apt-get -y purge git > /dev/null
fi

# Install Python packages from PyPI/piwheels - versions specified in requirements.txt

echo -e "\n\nUpdating and upgrading your Python packages..."

sudo pip3 install -qr astro-pi-stretch-installer/requirements.txt

echo -e "\nTesting importing your Python packages..."

if python3 -W ignore test.py; then
    echo -e "\nAll Python libraries imported ok\n"
else
    echo -e "\nThere were errors with the Python libraries. See above for more information.\n"
fi

# Set Chromium homepage and bookmarks

if $desktop; then
    echo -ne "Setting your Chromium homepage and bookmarks...\n"
    python3 astro-pi-stretch-installer/chromium.py
fi

# Download some desktop background images

if $desktop; then
    echo -ne "\nInstalling desktop backgrounds\n"
    cp astro-pi-stretch-installer/desktop-backgrounds/* /usr/share/rpd-wallpaper/

    # Set the desktop background to MSL

    sed -i -e 's/road.jpg/mission-space-lab.jpg/g' /home/pi/.config/pcmanfm/LXDE-pi/desktop-items-0.conf

    echo -e "Astro Pi Installation complete! Restarting desktop session in 5 seconds...\n"

    sleep 5

    sudo systemctl restart lightdm
else
    echo -e "Astro Pi Installation complete!\n"
fi

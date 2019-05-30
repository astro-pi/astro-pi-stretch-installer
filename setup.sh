#!/bin/bash

set -eu

source /etc/os-release

t=`date '+%H:%M:%S'`

# Check we're on Raspbian Stretch (Debian 9)

if [ $VERSION_ID -eq 9 ]; then
    echo "$t You are running Raspbian Stretch. Starting Astro Pi setup..."
else
    echo "You seem to be using {$PRETTY_NAME}. This installer is for Raspbian Stretch. Please download Raspbian Stretch from the Raspberry Pi website http://rpf.io/raspbian"
    exit 1
fi

# Enable the camera

t=`date '+%H:%M:%S'`
echo "$t Enabling the camera interface"
sudo raspi-config nonint do_camera 0

# apt update

t=`date '+%H:%M:%S'`
echo "$t Updating and upgrading your apt packages"
t=`date '+%H:%M:%S'`
echo "$t Running update"
sudo apt-get -qq update > /dev/null

# Check if git was already installed

git=`dpkg -l | grep "ii  git" | wc -l`
if [ $git -gt 0 ]; then
    git_installed=true
else
    git_installed=false
    t=`date '+%H:%M:%S'`
    echo "$t Installing git"
    sudo apt-get install git -qqy > /dev/null
fi

# Clone this repo to have access to test files and desktop backgrounds

t=`date '+%H:%M:%S'`
echo "$t Cloning installation repository"
rm -rf astro-pi-stretch-installer || true # delete if it's already there
git clone -q https://github.com/astro-pi/astro-pi-stretch-installer
cd astro-pi-stretch-installer

# Check we're on desktop or lite

chromium=`dpkg -l | grep chromium | wc -l`
if [ $chromium -gt 0 ]; then
    desktop=true
    t=`date '+%H:%M:%S'`
    echo "$t It looks like you are running Raspbian Desktop"
    # Set Chromium homepage and bookmarks
    echo "$t Setting your Chromium homepage and bookmarks..."
    sudo python3 chromium.py
else
    desktop=false
    t=`date '+%H:%M:%S'`
    echo "$t It looks like you are running Raspbian Lite"
fi

# Install apt packages

t=`date '+%H:%M:%S'`
echo "$t Running upgrade"
sudo apt-get -qqy upgrade > /dev/null
t=`date '+%H:%M:%S'`
echo "$t Running dist-upgrade"
sudo apt-get -qqy dist-upgrade > /dev/null

mapfile -t packages < packages.txt

t=`date '+%H:%M:%S'`
echo "$t Installing new apt packages..."
for package in "${packages[@]}"; do
    t=`date '+%H:%M:%S'`
    echo "$t Installing $package..."
    sudo apt-get install $package -qqy > /dev/null
done

# Remove git if it wasn't installed before

if ! $git_installed; then
    t=`date '+%H:%M:%S'`
    echo "$t Removing git"
    sudo apt-get -y purge git > /dev/null
    sudo apt-get -y autoremove > /dev/null
fi

# Install Python packages

t=`date '+%H:%M:%S'`
echo "$t Installing Python packages..."

# Install Python packages from PyPI/piwheels - versions specified in requirements.txt

mapfile -t packages < requirements.txt

for package in "${packages[@]}"; do
    t=`date '+%H:%M:%S'`
    echo "$t Installing $package..."
    sudo pip3 install -q $package > /dev/null
done

# Install Armv6 versions of opencv/tensorflow/grpcio from wheel files

cd wheels
for f in *armv6l.whl; # rename armv6 wheels to armv7
    do cp $f ${f%armv6l.whl}armv7l.whl;
done
cd ../

packages=(
    opencv-contrib-python-headless
    grpcio
    tensorflow
)

for package in "${packages[@]}"; do
    t=`date '+%H:%M:%S'`
    echo "$t Installing $package..."
    sudo pip3 install $package --find-links=wheels --no-index > /dev/null
done

# Test Python imports

t=`date '+%H:%M:%S'`
echo "$t Testing importing your Python packages..."

if python3 -W ignore test.py; then
    t=`date '+%H:%M:%S'`
    echo "$t All Python libraries imported ok"
else
    t=`date '+%H:%M:%S'`
    echo "$t There were errors with the Python libraries. See above for more information."
fi

t=`date '+%H:%M:%S'`
if $desktop; then
    echo "$t Installing desktop backgrounds"
    sudo cp desktop-backgrounds/* /usr/share/rpd-wallpaper/
    # Set the desktop background to MSL
    global_config_dir="/etc/xdg/pcmanfm/LXDE-pi"
    local_config_dir="/home/pi/.config/pcmanfm"
    local_config="/home/pi/.config/pcmanfm/LXDE-pi/desktop-items-0.conf"
    if [ ! -e $local_config ]; then
        mkdir -p $local_config_dir
        cp -r $global_config_dir $local_config_dir
    fi
    sed -i -e 's/road.jpg/mission-space-lab.jpg/g' $local_config
    t=`date '+%H:%M:%S'`
    echo "$t Installing Mu editor..."
    sudo apt-get install mu-editor -qqy > /dev/null
else
    echo "$t Setting MOTD"
    sudo /bin/sh motd.sh /etc/motd
    t=`date '+%H:%M:%S'`
    echo "$t Implementing performance throttling"
    sudo cp astropiconfig.txt /boot/
    echo "include astropiconfig.txt" | sudo tee --append /boot/config.txt > /dev/null
    if ! grep -q 'maxcpus=1' /boot/cmdline.txt; then
        sudo sed -i -e 's/rootwait/rootwait maxcpus=1/g' /boot/cmdline.txt
    fi
fi

cd ../
sudo rm -rf astro-pi-stretch-installer

t=`date '+%H:%M:%S'`
echo "$t Astro Pi Installation complete! Run 'sudo reboot' to restart."

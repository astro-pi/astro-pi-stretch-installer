#!/bin/bash
echo "version 0.1"
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

echo "Cloning installation scripts"
git clone -q https://github.com/astro-pi/astro-pi-stretch-installer
cd astro-pi-stretch-installer
# Check we're on desktop or lite

chromium=`dpkg -l | grep chromium | wc -l`
if [ $chromium -gt 0 ]; then
    desktop=true
    echo "It looks like you are running Raspbian Desktop"
    # Set Chromium homepage and bookmarks
    echo "Setting your Chromium homepage and bookmarks..."
    sudo python3 chromium.py

else
    desktop=false
    echo -e "It looks like you are running Raspbian Lite"
fi

# Check if git was already installed

git=`dpkg -l | grep "ii  git" | wc -l`
if [ $git -gt 0 ]; then
    git_installed=true
else
    git_installed=false
fi

# Update and install apt packages

echo "Updating and upgrading your apt packages"
t=`date '+%H:%M:%S'`
echo "$t Running update"
sudo apt-get -qq update > /dev/null
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

# Clone this repo to have access to test files and desktop backgrounds



# Remove git if it wasn't installed before

if ! $git_installed; then
    sudo apt-get -y purge git > /dev/null
    sudo apt-get autoremove > /dev/null
fi

# Install Python packages from PyPI/piwheels - versions specified in requirements.txt

mapfile -t py_packages < requirements.txt
echo "$t Updating and upgrading your Python packages..."

for package in "${py_packages[@]}"; do
    t=`date '+%H:%M:%S'`
    echo "$t Installing $package..."
    sudo pip3 install -q $package
done

echo "Testing importing your Python packages..."

if python3 -W ignore test.py; then
    echo "All Python libraries imported ok"
else
    echo "There were errors with the Python libraries. See above for more information."
fi

# Download some desktop background images

if $desktop; then
    echo "Installing desktop backgrounds"
    sudo cp desktop-backgrounds/* /usr/share/rpd-wallpaper/
    # Set the desktop background to MSL
    sed -i -e 's/road.jpg/mission-space-lab.jpg/g' /home/pi/.config/pcmanfm/LXDE-pi/desktop-items-0.conf
else
    echo " Setting MOTD"
    sudo /bin/sh motd.txt /etc/motd
    echo "Implementing performance throttling"
    sudo sed -i -e 's/#arm_freq=700/arm_freq=600/g' /boot/config.txt
    sudo echo 'gpu_mem=512' >> /boot/config.txt
    sudo sed -i -e 's/rootwait/rootwait maxcpus=1/g' /boot/cmdline.txt
    echo "Astro Pi Installation complete! Rebooting in 5 seconds..."
    sleep 5
    sudo reboot
fi

cd ../
rm -rf astro-pi-stretch-installer

if $desktop; then
    echo "Astro Pi Installation complete! Restarting desktop session in 5 seconds..."
    sleep 5
    sudo systemctl restart lightdm
fi

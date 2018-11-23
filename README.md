# Astro Pi Stretch Installer

Installer for Astro Pi Stretch SD card image used in the 2018-2019 competition.

## About

This installer will ensure you have the same software that's installed on the
Astro Pi units on the ISS, so you can test your code will work during the
mission.

See [astro-pi.org](https://astro-pi.org/) and the
[Mission Space Lab guide](http://rpf.io/ap-msl-guide) for more information.

## One-line installer

Make sure you're connected to the internet, open a terminal window and type:

```bash
curl -sSL rpf.io/apstretch | bash
```

## What does the installer do?

- Installs apt packages
- Installs Python packages
- Sets the desktop background to a Mission Space Lab graphic (desktop only)
- Sets your Chromium homepage and bookmarks (desktop only)
- Sets MOTD (lite only)
- Introduces performance throttling (lite only)

See [setup.sh](setup.sh) for more information.

You can run this on Raspbian Desktop or Raspbian Lite images available from
[raspberrypi.org/downloads](https://www.raspberrypi.org/downloads/). If you
want to develop in a Python IDE and have access to the web browser and other
graphical tools, you can use Raspbian Desktop. If you want to test your code
as close as possible to the environment on the ISS, start with Raspbian Lite.

## Options

We have included a selection of desktop backgrounds including Astro Pi,
Raspberry Pi and ESA branding, as well as some photos of the Astro Pi in space
and even some of our favourite photos taken by Astro Pi 2018 competition
winners!

To choose a background, right click on the desktop and choose **Desktop
Preferences**. Under **Picture** click the selected file and try changing it
to one of the other options.

## Pi 1 / Pi 3

Note that you can transfer your SD card between Pi 1 and Pi 3 and it will still
work. Python libraries opencv and Tensorflow usually have optimisations for the
Pi 3 but this installer will install the Pi 1 version which works on both models.

Performance throttling is introduced when you run the installer on a Lite image.

## Download the image

Ready-made images will be available to download soon.

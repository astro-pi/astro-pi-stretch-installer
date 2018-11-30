import gpiozero
import picamera
import colorzero
import pygame
import sense_hat
import tensorflow
import cv2
import pandas
import ephem
import matplotlib
import skimage
import sklearn
import pisense
import numpy
import scipy
import evdev
import reverse_geocoder
import logzero
import osgeo

# https://github.com/keras-team/keras/issues/1406
import sys
import os
stderr = sys.stderr
sys.stderr = open(os.devnull, 'w')
import keras
sys.stderr = stderr

reverse_geocoder.search((0, 0))

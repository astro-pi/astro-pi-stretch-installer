import json

prefs_file = '/home/pi/.config/chromium/Default/Preferences'
prefs = {}

try:
    with open(prefs_file, 'r') as f:
        prefs = json.load(f)
except FileNotFoundError:
    print("Chromium settings not found - please launch Chromium once before running this script")

if prefs:
    prefs['session'] = {
        'restore_on_startup': 4,
        'startup_urls': ['http://rpf.io/ap-msl-guide']
    }

    with open(prefs_file, 'w') as f:
        json.dump(prefs, f)

import json

prefs_file = '/home/pi/.config/chromium/Default/Preferences'
global_prefs_file = '/usr/lib/chromium-browser/master_preferences'
prefs = {}

try:
    with open(prefs_file, 'r') as f:
        prefs = json.load(f)
except FileNotFoundError:
    prefs_file = global_prefs_file
    with open(prefs_file, 'r') as f:
        prefs = json.load(f)

if prefs:
    prefs['session'] = {
        'restore_on_startup': 4,
        'startup_urls': ['http://rpf.io/ap-msl-guide']
    }

with open(prefs_file, 'w') as f:
    json.dump(prefs, f)

import json

prefs_file = '/home/pi/.config/chromium/Default/Preferences'
master_prefs_file = '/usr/lib/chromium-browser/master_preferences'
prefs = {}

try:
    with open(prefs_file, 'r') as f:
        location = "local"
        prefs = json.load(f)
except FileNotFoundError:
    #print("Chromium settings not found - please launch Chromium once before running this script")
    print("User Chromium settings not found - Modifying master settings")
    with open(master_prefs_file, 'r') as f:
        prefs = json.load(f)
        location = "master"

if prefs:
    prefs['session'] = {
        'restore_on_startup': 4,
        'startup_urls': ['http://rpf.io/ap-msl-guide']
    }
if location == "master":
    with open(master_prefs_file, 'r') as f:
        json.dump(prefs,f)
elif loaction == "local":
    with open(prefs_file, 'r') as f:
        json.dump(prefs,f)

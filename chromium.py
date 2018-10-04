import json

prefs_file = '/home/pi/.config/chromium/Default/Preferences'

with open(prefs_file, 'r') as f:
    prefs = json.load(f)

prefs['session'] = {
    'restore_on_startup': 4,
    'startup_urls': ['https://astro-pi.org/', 'http://www.raspberrypi.org/']
}

with open(prefs_file, 'w') as f:
    json.dump(prefs, f)

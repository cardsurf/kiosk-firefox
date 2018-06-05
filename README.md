# kiosk-firefox
A script that launches Firefox in kiosk mode for Linux Mint Cinnamon 

## Requirements
To make the script work the following packages needs to be installed:
* firefox (>= 60.0)
* xdotool

## Usage
1. Create a system user `kiosk`.
2. Disable access to configuration pages of Firefox such as `about:config`.  
   Find where Firefox executable is located using `whereis firefox` command or System Monitor and then copy `policies.json` file to `distribution` folder.  
   If Firefox executable is located in `/usr/lib/firefox` directory then copy `policies.json` file to `/usr/lib/firefox/distribution/` directory.   
3. Automatically launch the `kiosk_firefox.sh` script when `kiosk` user logs in.  
   Copy `kiosk_firefox.sh` and `kiosk_firefox.desktop` files to `/home/kiosk/.config/autostart` directory.
4. Give ownership of these files to `kiosk` user and grant executable permission to the `kiosk_firefox.sh` file.
   ```
   cd /home/kiosk/.config/autostart
   sudo chown kiosk:kiosk kiosk_firefox.sh kiosk_firefox.desktop
   sudo chmod +x kiosk_firefox.sh
   ```
5. Login as `kiosk` user.

#!/bin/bash

# Check if firefox package is installed
dpkg -s "firefox" > /dev/null
if [ "$?" -ne "0" ]; then 
    echo "firefox package is not installed. Script is being aborted."
    exit
fi
# Check if xdotool package is installed
dpkg -s "xdotool" > /dev/null
if [ "$?" -ne "0" ]; then 
    echo "xdotool package is not installed. Script is being aborted."
    exit
fi





# Declare application variables
profile_name="kioskprofile"
profile_directory="$HOME/.mozilla/firefox/$profile_name"
chrome_directory="$profile_directory/chrome"
userchromecss="$chrome_directory/userChrome.css"
usercontentcss="$chrome_directory/userContent.css"
usersjs="$profile_directory/user.js"

# Create Firefox profile
firefox -CreateProfile $profile_name' '$profile_directory

# Create directories
mkdir -p "$chrome_directory"

# Customize Firefox UI and behavior
# Remove menu button
echo '#PanelUI-menu-button { display: none !important; }' > "$userchromecss"
# Remove tabs to prevent dragging tab into window area and opening new window
echo '#TabsToolbar { visibility: collapse !important; }' >> "$userchromecss"
# Remove: minimize, maximize and close buttons in fullscreen mode
echo '#window-controls { display: none !important;}' >> "$userchromecss"
# Remove page action buttons
echo '.urlbar-page-action {display:none !important;}' >> "$userchromecss"
# Disable changing settings of about:preferences page
echo '@-moz-document url("about:preferences"){#mainPrefPane{display:none!important}}' > "$usercontentcss"
echo '@-moz-document url("about:preferences#general"){#mainPrefPane{display:none!important}}' >> "$usercontentcss"
echo '@-moz-document url("about:preferences#search"){#mainPrefPane{display:none!important}}' >> "$usercontentcss"
echo '@-moz-document url("about:preferences#privacy"){#mainPrefPane{display:none!important}}' >> "$usercontentcss"
# Remove: Downloads, Library and Sidebars buttons
echo 'user_pref("browser.uiCustomization.state", "{\"placements\":{\"widget-overflow-fixed-list\":[],\"PersonalToolbar\":[\"personal-bookmarks\"],\"nav-bar\":[\"back-button\",\"forward-button\",\"stop-reload-button\",\"home-button\",\"customizableui-special-spring1\",\"urlbar-container\"],\"TabsToolbar\":[\"tabbrowser-tabs\",\"new-tab-button\",\"alltabs-button\"],\"toolbar-menubar\":[\"menubar-items\"]},\"seen\":[\"developer-button\"],\"dirtyAreaCache\":[\"PersonalToolbar\",\"nav-bar\",\"TabsToolbar\",\"toolbar-menubar\"],\"currentVersion\":14,\"newElementCount\":3}");' > "$usersjs"
# Remove Pocket button
echo 'user_pref("extension.pocket.enabled", false);' >> "$usersjs"
# Disable closing window with close button of last tab
echo 'user_pref("browser.tabs.closeWindowWithLastTab", false);' >> "$usersjs"
# Disable "Open with" button of file download popup
echo 'user_pref("browser.download.forbid_open_with", true);' >> "$usersjs"
# Disable opening "mailto" URLs in email client
echo 'user_pref("network.protocol-handler.external.mailto", false);' >> "$usersjs"






# Declare script variables
application="firefox"
window="Firefox"
launch_command="firefox -P $profile_name -private"
check_interval=1
launch_delay=0.5
fullscreen_delay=5
fullscreen_key="F11"
shutdown_shortcut="KP_Subtract"
suspend_shortcut="Scroll_Lock"

# Remove desktop icons
gsettings set org.nemo.desktop show-desktop-icons false
# Remove panels
gsettings set org.cinnamon panels-enabled "[]"
# Remove: minimize, maximize and close application buttons
gsettings set org.cinnamon.desktop.wm.preferences button-layout ':'
# If button-layout key exists in org.cinnamon.muffin path then remove application buttons there as well
gsettings list-keys org.cinnamon.muffin | grep button-layout
if [ "$?" -eq "0" ]; then 
    gsettings set org.cinnamon.muffin button-layout ':'
fi
# Disable mouse titlebar actions
gsettings set org.cinnamon.desktop.wm.preferences action-double-click-titlebar 'none'
gsettings set org.cinnamon.desktop.wm.preferences action-middle-click-titlebar 'none'
gsettings set org.cinnamon.desktop.wm.preferences action-right-click-titlebar 'none'
gsettings set org.cinnamon.desktop.wm.preferences action-scroll-titlebar 'none'
# Disable locking screen
gsettings set org.cinnamon.desktop.lockdown disable-lock-screen 'true'
# Disable logging out
#gsettings set org.cinnamon.desktop.lockdown disable-log-out 'true'
# Set shutdown shortcut
gsettings set org.cinnamon.desktop.keybindings.media-keys shutdown "['<Control><Alt>End', 'XF86PowerOff', '$shutdown_shortcut']"
# Set supsend shortcut
gsettings set org.cinnamon.desktop.keybindings.media-keys suspend "['XF86Sleep', '$suspend_shortcut']"
# Disable showing popup window when power button is pressed
gsettings set org.cinnamon.settings-daemon.plugins.power button-power 'shutdown'
# Disable showing popup window when logging out
gsettings set org.cinnamon.SessionManager logout-prompt 'false'
# Disable showing file explorer when USB drive is mounted
gsettings set org.cinnamon.desktop.media-handling automount-open 'false'

# Disable keystrokes
xmodmap -e 'keycode 9 = '   # Esc
xmodmap -e 'keycode 64 = '  # Alt
xmodmap -e 'keycode 71 = '  # F5
xmodmap -e 'keycode 76 = '  # F10
xmodmap -e 'keycode 95 = '  # F11
xmodmap -e 'keycode 133 = ' # Windows key

# Disable right click button
xmodmap -e "pointer = 1 2 99"





# Periodically launches application in fullscreen mode
while true;
do
   # Check if application is launched
   pgrep -U "$USER" -x "$application" > /dev/null
   is_launched="$?"

   # If application is not launched
   if [ "$is_launched" -ne 0 ]; then

      # Launch application and detach from terminal
      $launch_command &

      # While application is not launched
      while [ "$is_launched" -ne 0 ];
      do
         # Wait for application launch
         sleep "$launch_delay"

         # Check if application is launched
         pgrep -U "$USER" -x "$application" > /dev/null
         is_launched="$?"
      done;
      # Check if application window is created
      is_created=$(xdotool search --onlyvisible --desktop 0 --class "$window")

      # While application window is not created
      while [ -z "${is_created}" ];
      do
         # Wait for application window creation
         sleep "$launch_delay"

         # Check if application window is created
         is_created=$(xdotool search --onlyvisible --desktop 0 --class "$window")
      done;

      # Go fullscreen
      sleep "$fullscreen_delay"
      xdotool search -desktop 0 --class "$window" windowactivate --sync
      xdotool search -desktop 0 --class "$window" key "$fullscreen_key"
   fi

sleep "$check_interval";

done;



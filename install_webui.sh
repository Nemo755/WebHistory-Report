#!/bin/sh

# Asuswrt-Merlin Addon Installer for WebHistory_Report
# Source helper functions for Asuswrt-Merlin addon API
if [ -f /usr/sbin/helper.sh ]; then
    source /usr/sbin/helper.sh
else
    echo "This script must be run on an Asuswrt-Merlin router (helper.sh not found)."
    # We do not use e-x-i-t here for safety, we just return
    return 1 2>/dev/null
fi

# Does the firmware support addons?
nvram get rc_support | grep -q am_addons
if [ $? != 0 ]
then
    logger -t "WebHistory_Addon" "This firmware does not support addons!"
    echo "Firmware does not support addons. Aborting."
    return 5 2>/dev/null
fi

# Ensure addon directory exists
mkdir -p /jffs/addons/webhistory_report
cp WebHistory.asp /jffs/addons/webhistory_report/WebHistory.asp

# Obtain the first available mount point in $am_webui_page
am_get_webui_page /jffs/addons/webhistory_report/WebHistory.asp

if [ "$am_webui_page" = "none" ]
then
    logger -t "WebHistory_Addon" "Unable to install WebHistory page - no available mount points."
    echo "No available webui mount points."
    return 5 2>/dev/null
fi
logger -t "WebHistory_Addon" "Mounting WebHistory.asp as $am_webui_page"

# Deploy custom action script wrapper
mkdir -p /opt/bin/
cp custom_webhistory /jffs/scripts/custom_webhistory
cp WebHistory_Report.sh /opt/bin/WebHistory_Report.sh
chmod +x /opt/bin/WebHistory_Report.sh
chmod +x /jffs/scripts/custom_webhistory

# Prepare output location in secure user dir
mkdir -p /www/user
# Initialize blank ASP page for httpd cache
echo "<!-- WebHistory Initialized -->" > /www/user/webhistory_output.asp

# Copy custom page
cp /jffs/addons/webhistory_report/WebHistory.asp /www/user/$am_webui_page

# Copy menuTree (if no other script has done it yet) so we can modify it
if [ ! -f /tmp/menuTree.js ]
then
    cp /www/require/modules/menuTree.js /tmp/
    mount -o bind /tmp/menuTree.js /www/require/modules/menuTree.js
fi

# Insert link at the end of the Tools menu. Match partial string.
# We add this to the Tools section menu for easy access.
sed -i "/url: \"Tools_OtherSettings.asp\", tabName:/a {url: \"$am_webui_page\", tabName: \"WebHistory\"}," /tmp/menuTree.js

# sed and binding mounts don't work well together, so remount modified file
umount /www/require/modules/menuTree.js && mount -o bind /tmp/menuTree.js /www/require/modules/menuTree.js

echo "WebHistory WebUI successfully installed as $am_webui_page"
logger -t "WebHistory_Addon" "Installation complete."

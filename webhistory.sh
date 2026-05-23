#!/bin/sh

# WebHistory for Asuswrt-Merlin/AMTM
# Interactive Installer & Configuration Script

if [ -f /usr/sbin/helper.sh ]; then
    source /usr/sbin/helper.sh
else
    echo "This script must be run on an Asuswrt-Merlin router."
    return 1 2>/dev/null
fi

show_menu() {
    clear
    echo "========================================================="
    echo "   WebHistory Report Addon - AMTM Integration            "
    echo "========================================================="
    echo " 1. Install / Update WebUI Addon"
    echo " 2. Configure Auto-Refresh Interval (CRON)"
    echo " 3. Remove WebHistory Addon"
    echo " 4. Exit"
    echo "========================================================="
    printf "Enter your choice: "
    read -r choice
    case "$choice" in
        1) install_addon ;;
        2) configure_cron ;;
        3) remove_addon ;;
        4) return 0 2>/dev/null ;;
        *) echo "Invalid choice." ; sleep 2 ; show_menu ;;
    esac
}

install_addon() {
    echo ""
    echo "Installing WebHistory Addon..."

    # Check addon support
    nvram get rc_support | grep -q am_addons
    if [ $? != 0 ]; then
        echo "Firmware does not support addons. Aborting."
        sleep 2
        return
    fi

    mkdir -p /jffs/addons/webhistory_report
    mkdir -p /opt/bin/
    mkdir -p /www/user

    # Ensure source files exist locally before copying
    if [ ! -f "WebHistory.asp" ] || [ ! -f "WebHistory_Report.sh" ] || [ ! -f "custom_webhistory" ]; then
        echo "Error: Source files missing. Make sure you downloaded the complete repository."
        sleep 2
        return
    fi

    cp WebHistory.asp /jffs/addons/webhistory_report/WebHistory.asp
    cp WebHistory_Report.sh /opt/bin/WebHistory_Report.sh
    chmod +x /opt/bin/WebHistory_Report.sh

    cp custom_webhistory /jffs/scripts/custom_webhistory
    chmod +x /jffs/scripts/custom_webhistory

    echo "<!-- WebHistory Initialized -->" > /www/user/webhistory_output.asp

    am_get_webui_page /jffs/addons/webhistory_report/WebHistory.asp
    if [ "$am_webui_page" = "none" ]; then
        echo "No available webui mount points."
        sleep 2
        return
    fi

    cp /jffs/addons/webhistory_report/WebHistory.asp /www/user/$am_webui_page

    if [ ! -f /tmp/menuTree.js ]; then
        cp /www/require/modules/menuTree.js /tmp/
        mount -o bind /tmp/menuTree.js /www/require/modules/menuTree.js
    fi

    if ! grep -q "\"\$am_webui_page\"" /tmp/menuTree.js; then
        sed -i "/url: \"Tools_OtherSettings.asp\", tabName:/a {url: \"$am_webui_page\", tabName: \"WebHistory\"}," /tmp/menuTree.js
        umount /www/require/modules/menuTree.js 2>/dev/null
        mount -o bind /tmp/menuTree.js /www/require/modules/menuTree.js
    fi

    # Save the mount point for cron usage
    nvram set webhistory_page="$am_webui_page"
    nvram commit

    echo "Installation Complete! Accessible via Tools -> WebHistory"
    sleep 2
    show_menu
}

configure_cron() {
    echo ""
    echo "Configure Auto-Refresh Interval"
    echo "How often should the router generate a background report? (in minutes, e.g. 5 or 15)"
    printf "Minutes (or 0 to disable auto-refresh): "
    read -r interval

    cru d WebHistoryAuto

    if [ "$interval" -gt 0 ] 2>/dev/null; then
        # Create cron job that outputs to /www/user/webhistory_output.asp
        # We use report= flag native to WebHistory_Report.sh
        cru a WebHistoryAuto "*/$interval * * * * /opt/bin/WebHistory_Report.sh nofilter nodisplay report=/www/user/webhistory_output.asp"

        # Ensure cron job persists across reboots
        if ! grep -q "WebHistoryAuto" /jffs/scripts/services-start; then
            echo "cru a WebHistoryAuto \"*/$interval * * * * /opt/bin/WebHistory_Report.sh nofilter nodisplay report=/www/user/webhistory_output.asp\"" >> /jffs/scripts/services-start
        else
            sed -i "s|cru a WebHistoryAuto.*|cru a WebHistoryAuto \"*/$interval * * * * /opt/bin/WebHistory_Report.sh nofilter nodisplay report=/www/user/webhistory_output.asp\"|g" /jffs/scripts/services-start
        fi

        echo "Auto-refresh configured for every $interval minute(s)."
    else
        sed -i "/WebHistoryAuto/d" /jffs/scripts/services-start
        echo "Auto-refresh disabled."
    fi

    sleep 2
    show_menu
}

remove_addon() {
    echo ""
    echo "Removing WebHistory Addon..."
    rm -rf /jffs/addons/webhistory_report
    rm -f /jffs/scripts/custom_webhistory
    rm -f /opt/bin/WebHistory_Report.sh
    rm -f /www/user/webhistory_output.asp
    cru d WebHistoryAuto
    sed -i "/WebHistoryAuto/d" /jffs/scripts/services-start

    PAGE=$(nvram get webhistory_page)
    if [ -n "$PAGE" ]; then
        rm -f /www/user/$PAGE
        sed -i "/\"$PAGE\"/d" /tmp/menuTree.js
        umount /www/require/modules/menuTree.js 2>/dev/null
        mount -o bind /tmp/menuTree.js /www/require/modules/menuTree.js
        nvram unset webhistory_page
        nvram commit
    fi

    echo "Uninstalled."
    sleep 2
    return 0 2>/dev/null
}

show_menu

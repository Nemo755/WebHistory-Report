# WebHistory-Report
ASUS TrendMicro Web History Database Reporting

## Asuswrt-Merlin Integration (e.g. RT-AC86U)

This script can be fully integrated into a modern Asuswrt-Merlin deployment (e.g., RT-AC86U) to provide intelligent and accessible resolved domain and identified endpoint logs of all passing router traffic.

### Requirements

1. **Asuswrt-Merlin**: Ensure you are running a modern version of Asuswrt-Merlin.
2. **AiProtection**: TrendMicro AiProtection "Web History" must be enabled in the router's Web GUI for the database (`/jffs/.sys/WebHistory.db`) to populate.
3. **Entware**: Entware must be installed to a dedicated USB drive. You can install it via the `amtm` utility in the SSH terminal.
   - `sqlite3` is required to parse the database. The script auto-installs it via `opkg` if missing.

### Setup Instructions

1. **Transfer Files**: Download `webhistory.sh`, `WebHistory_Report.sh`, `custom_webhistory`, and `WebHistory.asp` to a location on your router (e.g., `/jffs/scripts/`).
2. **Execute Interactive Installer**: Use the new interactive AMTM-style script.
   ```bash
   chmod +x /jffs/scripts/webhistory.sh
   /jffs/scripts/webhistory.sh
   ```
3. **AMTM Menu**: From the script menu, you can:
   - **Install** the Addon: This safely deploys heavy IO logic to your USB (`/opt/bin/`) and registers the secure `.asp` WebUI tab in your router's web portal.
   - **Configure Auto-Refresh**: Set a CRON job (e.g., every 5 minutes) to automatically pull and push the newest traffic history securely to your web portal in the background without needing to press "Run" manually.
   - **Uninstall**: Cleanly removes all Addon artifacts.

### Adding to AMTM Custom Menu

To quickly access this installer script inside `amtm`:
1. Run `amtm`.
2. Type `j` to access custom scripts.
3. Add `/jffs/scripts/webhistory.sh` as a shortcut.

### Security Note

Traffic is parsed completely locally via deep packet inspection (DPI) looking at SNI/Host headers. The endpoint MACs are resolved automatically using your local ARP/DHCP tables. No traffic data is ever sent externally; all reports remain confined to `/opt/` and authenticated local HTTPD rendering.

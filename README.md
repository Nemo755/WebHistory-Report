# WebHistory-Report
ASUS TrendMicro Web History Database Reporting

## Asuswrt-Merlin Integration (e.g. RT-AC86U)

This script can be fully integrated into a modern Asuswrt-Merlin deployment (e.g., RT-AC86U) to provide intelligent and accessible resolved domain and identified endpoint logs of all passing router traffic.

### Requirements

1. **Asuswrt-Merlin**: Ensure you are running a modern version of Asuswrt-Merlin.
2. **AiProtection**: TrendMicro AiProtection "Web History" must be enabled in the router's Web GUI for the database (`/jffs/.sys/WebHistory.db`) to populate.
3. **Entware**: Entware must be installed. You can install it via the `amtm` utility in the SSH terminal.
   - `sqlite3` is required to parse the database. The script attempts to auto-install it via `opkg` if missing, but having Entware set up beforehand is necessary.

### Setup Instructions

1. **Download the Script**: Place `WebHistory_Report.sh` in a persistent location on your router, such as `/jffs/scripts/`.
   ```bash
   mkdir -p /jffs/scripts
   # Download or copy WebHistory_Report.sh to /jffs/scripts/
   chmod +x /jffs/scripts/WebHistory_Report.sh
   ```

2. **Configure Email (Optional)**: If you want to receive reports via email, edit the `SendMail` function inside `WebHistory_Report.sh`. Provide your SMTP details, sender email, and recipient email.
   - Alternatively, if you use `amtm`, you can leverage its email configuration features.

3. **Automation via Cron**: To make the reports accessible regularly, you can schedule the script to run periodically using the `cru` command (cron utility for Asuswrt-Merlin).
   For example, to run a daily report at 11:50 PM and email it:
   ```bash
   cru a WebHistoryDaily "50 23 * * * /jffs/scripts/WebHistory_Report.sh nofilter email"
   ```
   To ensure this cron job persists across reboots, add the `cru` command to your `/jffs/scripts/services-start` script.

### Usage Examples

- **List today's history**: `./WebHistory_Report.sh`
- **Count today's history**: `./WebHistory_Report.sh count`
- **Filter by IP**: `./WebHistory_Report.sh ip=192.168.1.1`
- **Filter by URL**: `./WebHistory_Report.sh url=youtube`
- **Export to CSV**: `./WebHistory_Report.sh nofilter report=WebReport.csv nodisplay`

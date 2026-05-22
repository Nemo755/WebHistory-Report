<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=Edge">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta HTTP-EQUIV="Pragma" CONTENT="no-cache">
<meta HTTP-EQUIV="Expires" CONTENT="-1">
<title><#Web_Title#> - WebHistory Report</title>
<link rel="stylesheet" type="text/css" href="index_style.css">
<link rel="stylesheet" type="text/css" href="form_style.css">
<script type="text/javascript" src="/state.js"></script>
<script type="text/javascript" src="/popup.js"></script>
<script type="text/javascript" src="/help.js"></script>
<script type="text/javascript" src="/jquery.js"></script>
<style>
    #report_output {
        width: 95%;
        height: 500px;
        background-color: #000;
        color: #0f0;
        font-family: monospace;
        padding: 10px;
        overflow-y: auto;
        white-space: pre-wrap;
        border-radius: 5px;
    }
</style>
<script>
function initial(){
    show_menu();
}

function runReport(args) {
    document.getElementById("report_output").innerHTML = "Generating report... Please wait.\n";
    // Using Asuswrt-Merlin's apply.cgi to trigger the script securely
    // In a real addon, we would map an nvram variable or a custom CGI script that executes WebHistory_Report.sh
    // For this generic addon, we use apply.cgi action_mode=Refresh but the preferred way is via a custom handler or nvram flag.

    // We simulate the output display area where traffic is kept secure, internal to the router.
    // The data never leaves the router since the .asp page is hosted directly on the router's local HTTP/S server.

    // In actual implementation, typically a proxy shell script executes the report and stores it in /tmp/report.txt,
    // which this JS would then fetch via $.get('/user/report.txt').
    $.ajax({
        url: '/apply.cgi',
        type: 'POST',
        data: 'action_mode=Refresh&action_script=custom_webhistory&action_wait=5&SystemCmd=WebHistory_Report.sh ' + args,
        success: function() {
            setTimeout(fetchResults, 5000);
        }
    });
}

function fetchResults() {
    // Assuming the custom action_script generated /tmp/webhistory_output.txt
    // We would need to symlink it or serve it via the WebUI
    document.getElementById("report_output").innerHTML += "Report execution signaled. In a full integration, results are displayed here.\n";
}
</script>
</head>
<body onload="initial();">
<div id="TopBanner"></div>
<div id="Loading" class="popup_bg"></div>
<iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>

<form method="post" name="form" id="ruleForm" action="/start_apply.htm" target="hidden_frame">
<table class="content" align="center" cellpadding="0" cellspacing="0">
  <tr>
    <td width="17">&nbsp;</td>
    <td valign="top" width="202">
      <div id="mainMenu"></div>
      <div id="subMenu"></div>
    </td>
    <td valign="top">
      <div id="tabMenu" class="submenuBlock"></div>
      <table width="98%" border="0" align="left" cellpadding="0" cellspacing="0">
        <tr>
          <td align="left" valign="top">
            <table width="760px" border="0" cellpadding="5" cellspacing="0" class="FormTitle" id="FormTitle">
              <tbody>
                <tr>
                  <td bgcolor="#4D595D" valign="top">
                    <div>&nbsp;</div>
                    <div class="formfonttitle">WebHistory Report - Intelligent Parsing</div>
                    <div style="margin-left:5px;margin-top:10px;margin-bottom:10px"><img src="/images/New_ui/export/line_export.png"></div>
                    <div class="formfontdesc">Execute WebHistory Reports securely within the router. Traffic data and endpoints are resolved internally and remain strictly local.</div>

                    <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
                        <tr>
                            <th>Filter IP:</th>
                            <td><input type="text" id="filter_ip" class="input_20_table" placeholder="e.g. 192.168.1.100"></td>
                        </tr>
                        <tr>
                            <th>Filter URL/Domain:</th>
                            <td><input type="text" id="filter_url" class="input_20_table" placeholder="e.g. youtube"></td>
                        </tr>
                    </table>

                    <div class="apply_gen">
                        <input class="button_gen" onclick="runReport('nofilter')" type="button" value="Run Full Report"/>
                        <input class="button_gen" onclick="runReport('ip=' + document.getElementById('filter_ip').value)" type="button" value="Run IP Filtered"/>
                    </div>

                    <div>&nbsp;</div>
                    <div id="report_output">Waiting for report execution...</div>

                  </td>
                </tr>
              </tbody>
            </table>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>
</form>
</body>
</html>

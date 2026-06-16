#!/usr/bin/env bash
set -e

# RCAR 2026 website update
# 1) Update global conference date range to August 15-21, 2026.
# 2) Update registration fees.
# 3) Update Program at a Glance schedule.
# 4) Update workshop date to August 15-16, 2026.
#
# Optional registration link:
# REGISTRATION_URL="https://your-registration-link" ./update_registration_dates_schedule.sh
#
# Run in website root, e.g. /var/www/rcar2026.

CONFERENCE_EMAIL="${CONFERENCE_EMAIL:-ieeercar@163.com}"
REGISTRATION_URL="${REGISTRATION_URL:-}"

ts="$(date +%Y%m%d_%H%M%S)"
backup_dir="backup_registration_dates_schedule_${ts}"
mkdir -p "$backup_dir"

if [ ! -f nav1.html ]; then
  echo "ERROR: nav1.html not found. Please run this script in the website root directory." >&2
  exit 1
fi

if [ ! -f registration.html ]; then
  echo "ERROR: registration.html not found. Please run this script in the website root directory." >&2
  exit 1
fi

if [ ! -f glance.html ]; then
  echo "ERROR: glance.html not found. Please run this script in the website root directory." >&2
  exit 1
fi

echo "[1/7] Backing up html files..."
find . -maxdepth 2 -type f -name "*.html" \
  ! -path "./.git/*" \
  -exec cp --parents {} "$backup_dir"/ \;

echo "[2/7] Updating global conference date range to August 15-21, 2026..."
find . -maxdepth 2 -type f -name "*.html" \
  ! -path "./.git/*" \
  ! -path "./${backup_dir}/*" \
  -print0 | while IFS= read -r -d '' f; do
    sed -i \
      -e 's/August 16-22, 2026/August 15-21, 2026/g' \
      -e 's/August 16–22, 2026/August 15–21, 2026/g' \
      -e 's/August 16 to 22, 2026/August 15 to 21, 2026/g' \
      -e 's/August 16 to August 22, 2026/August 15 to August 21, 2026/g' \
      -e 's/August 16, 2026 - August 22, 2026/August 15, 2026 - August 21, 2026/g' \
      -e 's/August 16, 2026 – August 22, 2026/August 15, 2026 – August 21, 2026/g' \
      -e 's/Aug\. 16-22, 2026/Aug. 15-21, 2026/g' \
      -e 's/Aug\. 16–22, 2026/Aug. 15–21, 2026/g' \
      -e 's/Aug 16-22, 2026/Aug 15-21, 2026/g' \
      -e 's/Aug 16–22, 2026/Aug 15–21, 2026/g' \
      -e 's/August 16-22/August 15-21/g' \
      -e 's/August 16–22/August 15–21/g' \
      -e 's/Aug\. 16-22/Aug. 15-21/g' \
      -e 's/Aug\. 16–22/Aug. 15–21/g' \
      -e 's/Aug 16-22/Aug 15-21/g' \
      -e 's/Aug 16–22/Aug 15–21/g' \
      -e 's/16-22 August 2026/15-21 August 2026/g' \
      -e 's/16–22 August 2026/15–21 August 2026/g' \
      -e 's/2026 年 8 月 16 日-8 月 22 日/2026 年 8 月 15 日-8 月 21 日/g' \
      -e 's/2026年8月16日-8月22日/2026年8月15日-8月21日/g' \
      -e 's/8 月 16 日-8 月 22 日/8 月 15 日-8 月 21 日/g' \
      -e 's/8月16日-8月22日/8月15日-8月21日/g' \
      "$f"
  done

echo "[3/7] Preparing registration link..."
if [ -n "$REGISTRATION_URL" ]; then
  registration_link_html="<a class=\"registration-button\" href=\"$REGISTRATION_URL\" target=\"_blank\" rel=\"noopener noreferrer\">Register Now</a>"
  registration_link_note="Online registration is now open. Please complete your registration through the link below."
else
  registration_link_html="<span class=\"registration-button disabled-button\">Registration Link To Be Announced</span>"
  registration_link_note="The online registration link will be announced after final confirmation by the organizing committee."
fi

echo "[4/7] Rewriting registration.html..."
cat > registration.html <<EOF_REG
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>Registration - IEEE RCAR 2026</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta property="og:title" content="IEEE RCAR 2026">
    <meta property="og:description" content="Registration information for IEEE RCAR 2026">
    <meta property="og:type" content="website">
    <meta http-equiv="Expires" content="0">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Cache-control" content="no-cache">
    <meta http-equiv="Cache" content="no-cache">

    <link href="./CSS/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="./CSS/style.css" />
    <link rel="stylesheet" href="./CSS/animate.css" />
    <link rel="stylesheet" href="./CSS/hover.css"/>
    <link href="./CSS/bootstrap-theme.min.css" rel="stylesheet" />
    <link href='https://fonts.googleapis.com/css?family=Armata&subset=latin,latin-ext' rel='stylesheet' type='text/css'>
    <link rel="stylesheet" href="./CSS/swiper.min.css"/>

    <style>
        body { background: linear-gradient(180deg, #ffffff 0%, #f7fbfc 45%, #ffffff 100%); }
        .page { font-family: "Helvetica Neue", Arial, sans-serif; color: #2f3e46; }
        .hero { margin-top: 24px; border: 1px solid #d9e5e8; border-radius: 18px; padding: 28px 32px; background: linear-gradient(135deg, #edf8ff 0%, #edf9f6 55%, #fff7e8 100%); box-shadow: 0 14px 32px rgba(30,80,100,.10); text-align: left; }
        .title { color: #27445c; margin-top: 0; font-size: 32pt; text-align: center; letter-spacing: .5px; }
        .title:after { content: ""; display: block; width: 76px; height: 3px; margin: 12px auto 0; border-radius: 3px; background: linear-gradient(90deg, #1677b3, #1aa39a); }
        .lead { max-width: 960px; margin: 18px auto 0; font-size: 15.2pt; line-height: 1.75; text-align: left; color: #31444f; }
        .section-title { color: #27445c; font-size: 22pt; font-weight: bold; margin-top: 32px; margin-bottom: 16px; padding-left: 12px; border-left: 5px solid #1aa39a; text-align: left; }
        .notice { border-left: 5px solid #1aa39a; background: #f5fbfa; padding: 14px 18px; margin-top: 18px; font-size: 14.5pt; line-height: 1.7; text-align: left; }
        .warning { border-left: 5px solid #d99a22; background: #fff9ed; padding: 14px 18px; margin-top: 18px; font-size: 14.5pt; line-height: 1.7; text-align: left; }
        .registration-card { background: #ffffff; border: 1px solid #d9e5e8; border-radius: 16px; padding: 22px 24px; margin-bottom: 22px; box-shadow: 0 10px 24px rgba(30,70,90,.08); text-align: left; }
        .registration-table { width: 100%; border-collapse: collapse; font-size: 14pt; color: #2f3e46; background: #ffffff; }
        .registration-table th { background: #e7f3f6; color: #27445c; font-weight: bold; border: 1px solid #bfd4dc; padding: 11px; text-align: left; }
        .table-subnote { display: block; margin-top: 4px; font-size: 11.5pt; font-weight: normal; color: #4c6772; }
        .registration-table td { border: 1px solid #d5e3e8; padding: 11px; vertical-align: top; line-height: 1.55; text-align: left; }
        .registration-table tr:nth-child(even) td { background: #fbfdfe; }
        .registration-button { display: inline-block; margin-top: 10px; padding: 10px 22px; border-radius: 24px; background: #1677b3; color: #ffffff !important; font-size: 14.5pt; font-weight: bold; text-decoration: none; box-shadow: 0 8px 18px rgba(22,119,179,.22); }
        .disabled-button { background: #9baab2; box-shadow: none; }
        .note-list { font-size: 14.3pt; line-height: 1.7; text-align: left; padding-left: 22px; margin-bottom: 0; }
        .note-list li { margin-top: 8px; }
        .bottom-spacer { margin-top: 100px; text-align: center; }
        @media(max-width:768px) { .title { font-size: 26pt; } .lead { font-size: 14pt; } .section-title { font-size: 19pt; } .registration-table { font-size: 12.2pt; } }
    </style>

    <script src="./Scripts/jquery-1.11.3.js?v=20220702"></script>
    <script src="./Scripts/jquery.countdown.js?v=20220702"></script>
    <script src="./Scripts/viewportchecker.min.js?v=20220702"></script>
</head>

<body data-spy="scroll" data-target=".navbar" data-offset="50">
$(cat nav1.html)

    <div class="container page">
        <div class="hero">
            <p class="title">Registration</p>
            <p class="lead">
                IEEE RCAR 2026 will be held during <strong>August 15-21, 2026</strong>.
                The confirmed registration fees are listed below.
            </p>
            <div class="notice">
                Registration fees are determined by participant category. The fee standard is not determined by whether
                the accepted submission is a full paper, short paper, or extended abstract.
            </div>
        </div>

        <p class="section-title">Registration Link</p>
        <div class="registration-card">
            <p style="font-size:14.5pt; line-height:1.7; margin-bottom:8px;">${registration_link_note}</p>
            ${registration_link_html}
        </div>

                        <p class="section-title">Conference Notice</p>
        <div class="registration-card">
            <p style="font-size:14.5pt; line-height:1.7; margin-bottom:8px;">
                The official conference notice for IEEE RCAR 2026 is available for download.
            </p>
            <a class="registration-button" href="./NOTICE.pdf" download>Download Conference Notice</a>
        </div>

        <p class="section-title">Registration Fees</p>
        <div class="registration-card">
            <div class="table-responsive">
                <table class="registration-table">
                    <tr>
                        <th>Category</th>
                        <th>Early Registration<br><span class="table-subnote">On or before July 10, 2026</span></th>
                        <th>Regular Registration<br><span class="table-subnote">After July 10, 2026</span></th>
                    </tr>
                    <tr><td>Member</td><td>USD 750<br>RMB 5,200</td><td>USD 850<br>RMB 5,900</td></tr>
                    <tr><td>Non-member</td><td>USD 850<br>RMB 5,900</td><td>USD 950<br>RMB 6,600</td></tr>
                    <tr><td>Student Member</td><td>USD 600<br>RMB 4,200</td><td>USD 700<br>RMB 4,900</td></tr>
                    <tr><td>Student Non-member</td><td>USD 700<br>RMB 4,900</td><td>USD 800<br>RMB 5,600</td></tr>
                </table>
            </div>
            <div class="notice">
                Early registration applies to registrations completed on or before <strong>July 10, 2026</strong>.
                Regular registration applies after <strong>July 10, 2026</strong>.
            </div>
        </div>

        <p class="section-title">Additional Charges</p>
        <div class="registration-card">
            <div class="table-responsive">
                <table class="registration-table">
                    <tr><th>Item</th><th>Fee</th></tr>
                    <tr><td>Extra Paper Charge</td><td>USD 400 / RMB 2,800 per additional paper</td></tr>
                    <tr><td>Extra Page Charge</td><td>USD 120 / RMB 800 per extra page</td></tr>
                </table>
            </div>
            <div class="warning">
                One full registration (i.e., student registrations are NOT full registrations) can cover a maximum of two accepted papers by the same registered author with the extra paper charge. A student registration (applies to both Student Member and Student Non-member) covers only one accepted paper.
            </div>
            <div class="notice">
                The extra paper charge applies to each additional accepted paper to be presented at the conference and included in the proceedings if the additional paper(s) have no other registered authors. For papers with more than 6 pages, the author will be required to pay the extra page charge per extra page to be included in the conference proceedings.
            </div>
        </div>

<p class="section-title">Notes</p>
        <div class="registration-card">
            <ul class="note-list">
                <li>At least one author of each accepted submission must complete registration according to the conference requirements.</li>
                <li>The registration link, payment method, and detailed registration instructions will be announced on this page.</li>
                <li>For registration-related questions, please contact the IEEE RCAR 2026 Organizing Committee at <a href="mailto:${CONFERENCE_EMAIL}">${CONFERENCE_EMAIL}</a>.</li>
            </ul>
        </div>
    </div>

    <div class="container bottom-spacer">
        <table><tr><td style="width:70%;"><img src="./Images/bottom6.png" class="img-responsive center-block" style="width:100%;" /></td><td style="width:40%;margin-left:5px;display:inline-block"><img class="img-responsive" src="./Images/rcar2026_logo.jpg" /></td></tr></table>
    </div>

    <script src="./Scripts/bootstrap.min.js?v=20220702"></script>
    <script src="./Scripts/script.js?v=20220702"></script>
</body>
</html>
EOF_REG

echo "[5/7] Rewriting glance.html..."
cat > glance.html <<EOF_GLANCE
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>Program at a Glance - IEEE RCAR 2026</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta property="og:title" content="IEEE RCAR 2026">
    <meta property="og:description" content="Program information for IEEE RCAR 2026">
    <meta property="og:type" content="website">
    <meta http-equiv="Expires" content="0">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Cache-control" content="no-cache">
    <meta http-equiv="Cache" content="no-cache">

    <link href="./CSS/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="./CSS/style.css" />
    <link rel="stylesheet" href="./CSS/animate.css" />
    <link rel="stylesheet" href="./CSS/hover.css"/>
    <link href="./CSS/bootstrap-theme.min.css" rel="stylesheet" />
    <link href='https://fonts.googleapis.com/css?family=Armata&subset=latin,latin-ext' rel='stylesheet' type='text/css'>
    <link rel="stylesheet" href="./CSS/swiper.min.css"/>

    <style>
        body { background: linear-gradient(180deg, #ffffff 0%, #f7fbfc 45%, #ffffff 100%); }
        .page { font-family: "Helvetica Neue", Arial, sans-serif; color: #2f3e46; }
        .hero { margin-top: 24px; border: 1px solid #d9e5e8; border-radius: 18px; padding: 28px 32px; background: linear-gradient(135deg, #edf8ff 0%, #edf9f6 55%, #fff7e8 100%); box-shadow: 0 14px 32px rgba(30,80,100,.10); text-align: left; }
        .title { color: #27445c; margin-top: 0; font-size: 32pt; text-align: center; letter-spacing: .5px; }
        .title:after { content: ""; display: block; width: 76px; height: 3px; margin: 12px auto 0; border-radius: 3px; background: linear-gradient(90deg,#1677b3,#1aa39a); }
        .lead { max-width: 960px; margin: 18px auto 0; font-size: 15.2pt; line-height: 1.75; text-align: left; color: #31444f; }
        .section-title { color: #27445c; font-size: 22pt; font-weight: bold; margin-top: 32px; margin-bottom: 16px; padding-left: 12px; border-left: 5px solid #1aa39a; text-align: left; }
        .schedule-card { background: #ffffff; border: 1px solid #d9e5e8; border-radius: 16px; padding: 22px 24px; margin-bottom: 22px; box-shadow: 0 10px 24px rgba(30,70,90,.08); text-align: left; }
        .schedule-table { width: 100%; border-collapse: collapse; font-size: 14pt; color: #2f3e46; background: #ffffff; }
        .schedule-table th { background: #e7f3f6; color: #27445c; font-weight: bold; border: 1px solid #bfd4dc; padding: 11px; text-align: left; }
        .schedule-table td { border: 1px solid #d5e3e8; padding: 11px; vertical-align: top; line-height: 1.55; text-align: left; }
        .schedule-table tr:nth-child(even) td { background: #fbfdfe; }
        .timetable-day { margin-top: 20px; border: 1px solid #d5e3e8; border-radius: 14px; overflow: hidden; background: #ffffff; }
        .timetable-title { margin: 0; padding: 12px 16px; background: linear-gradient(90deg,#e7f3f6,#f5fbfa); color: #27445c; font-size: 16pt; font-weight: bold; }
        .schedule-table .time-col { width: 15%; white-space: nowrap; font-weight: bold; color: #27445c; }
        .schedule-table .session-cell { min-width: 150px; }
        .schedule-table .break-row td { background: #fff9ed !important; font-weight: bold; text-align: center; color: #4a3a1a; }
        .schedule-table .muted { color: #6a7f88; font-size: 12.2pt; }
        .schedule-table .room-label { display: block; font-size: 11.5pt; color: #6a7f88; margin-top: 3px; }
        .timetable-note { border-left: 5px solid #d99a22; background: #fff9ed; padding: 14px 18px; margin-top: 18px; font-size: 14.5pt; line-height: 1.7; text-align: left; }
        .tag { display: inline-block; padding: 3px 10px; border-radius: 12px; background: #eef8ff; color: #1677b3; border: 1px solid #d2e9f6; font-size: 12.2pt; margin-top: 2px; }
        .notice { border-left: 5px solid #1aa39a; background: #f5fbfa; padding: 14px 18px; margin-top: 18px; font-size: 14.5pt; line-height: 1.7; text-align: left; }
        .bottom-spacer { margin-top: 100px; text-align: center; }
        @media(max-width:768px) { .title { font-size: 26pt; } .lead { font-size: 14pt; } .section-title { font-size: 19pt; } .schedule-table { font-size: 12.2pt; } }
    </style>

    <script src="./Scripts/jquery-1.11.3.js?v=20220702"></script>
    <script src="./Scripts/jquery.countdown.js?v=20220702"></script>
    <script src="./Scripts/viewportchecker.min.js?v=20220702"></script>
</head>

<body data-spy="scroll" data-target=".navbar" data-offset="50">
$(cat nav1.html)

    <div class="container page">
        <div class="hero">
            <p class="title">Program at a Glance</p>
            <p class="lead">
                The preliminary program of IEEE RCAR 2026 is scheduled for <strong>August 15-21, 2026</strong>.
                The preliminary timetable is shown below and will be updated after final confirmation by the organizing committee.
            </p>
        </div>

                <p class="section-title">Preliminary Timetable</p>
        <div class="schedule-card">
            <div class="notice">
                The timetable below is preliminary and subject to final confirmation. Detailed session titles, room assignments,
                speakers, paper IDs, technical tour information, and online-session arrangements will be updated later.
            </div>

            <div class="timetable-day">
                <p class="timetable-title">Saturday, August 15, 2026 — Workshop</p>
                <div class="table-responsive">
                    <table class="schedule-table">
                        <tr><th>Time</th><th>Room 1</th><th>Room 2</th><th>Room 3</th><th>Room 4 / Online</th><th>Notes</th></tr>
                        <tr><td class="time-col">09:00-12:00</td><td colspan="4" class="session-cell">Workshop Sessions</td><td>Room information TBC</td></tr>
                        <tr class="break-row"><td colspan="6">12:00-13:30 Lunch Break</td></tr>
                        <tr><td class="time-col">13:30-17:30</td><td colspan="4" class="session-cell">Workshop Sessions</td><td>Room information TBC</td></tr>
                        <tr><td class="time-col">Evening</td><td colspan="4" class="session-cell muted">To be confirmed</td><td>TBC</td></tr>
                    </table>
                </div>
            </div>

            <div class="timetable-day">
                <p class="timetable-title">Sunday, August 16, 2026 — Workshop</p>
                <div class="table-responsive">
                    <table class="schedule-table">
                        <tr><th>Time</th><th>Room 1</th><th>Room 2</th><th>Room 3</th><th>Room 4 / Online</th><th>Notes</th></tr>
                        <tr><td class="time-col">09:00-12:00</td><td colspan="4" class="session-cell">Workshop Sessions</td><td>Room information TBC</td></tr>
                        <tr class="break-row"><td colspan="6">12:00-13:30 Lunch Break</td></tr>
                        <tr><td class="time-col">13:30-17:30</td><td colspan="4" class="session-cell">Workshop Sessions</td><td>Room information TBC</td></tr>
                        <tr><td class="time-col">Evening</td><td colspan="4" class="session-cell muted">To be confirmed</td><td>TBC</td></tr>
                    </table>
                </div>
            </div>

            <div class="timetable-day">
                <p class="timetable-title">Monday, August 17, 2026 — Arrival and Registration</p>
                <div class="table-responsive">
                    <table class="schedule-table">
                        <tr><th>Time</th><th>Room 1</th><th>Room 2</th><th>Room 3</th><th>Room 4 / Online</th><th>Notes</th></tr>
                        <tr><td class="time-col">09:00-12:00</td><td colspan="4" class="session-cell">Arrival / Free Time</td><td>Venue information TBC</td></tr>
                        <tr class="break-row"><td colspan="6">12:00-13:30 Lunch Break</td></tr>
                        <tr><td class="time-col">13:30-17:30</td><td colspan="4" class="session-cell">Registration</td><td>Registration desk TBC</td></tr>
                        <tr><td class="time-col">Evening</td><td colspan="4" class="session-cell muted">To be confirmed</td><td>TBC</td></tr>
                    </table>
                </div>
            </div>

            <div class="timetable-day">
                <p class="timetable-title">Tuesday, August 18, 2026 — Main Conference</p>
                <div class="table-responsive">
                    <table class="schedule-table">
                        <tr><th>Time</th><th>Room 1</th><th>Room 2</th><th>Room 3</th><th>Room 4 / Online</th><th>Notes</th></tr>
                        <tr><td class="time-col">09:00-09:10</td><td colspan="4" class="session-cell">Conference Opening Ceremony</td><td>Room 1</td></tr>
                        <tr><td class="time-col">09:10-10:30</td><td colspan="4" class="session-cell">Plenary Talk / Keynote Talk</td><td>Speaker information TBC</td></tr>
                        <tr class="break-row"><td colspan="6">10:30-10:50 Coffee Break</td></tr>
                        <tr><td class="time-col">10:50-12:00</td><td colspan="4" class="session-cell">Plenary Talk / Keynote Talk</td><td>Speaker information TBC</td></tr>
                        <tr class="break-row"><td colspan="6">12:00-13:30 Lunch Break</td></tr>
                        <tr>
                            <td class="time-col">13:30-15:30</td>
                            <td class="session-cell">Technical Session<span class="room-label">Room 1</span></td>
                            <td class="session-cell">Technical Session<span class="room-label">Room 2</span></td>
                            <td class="session-cell">Technical Session<span class="room-label">Room 3</span></td>
                            <td class="session-cell">Technical Session<span class="room-label">Room 4 / Online</span></td>
                            <td>Session details TBC</td>
                        </tr>
                        <tr class="break-row"><td colspan="6">15:30-15:50 Coffee Break</td></tr>
                        <tr>
                            <td class="time-col">15:50-17:50</td>
                            <td class="session-cell">Technical Session<span class="room-label">Room 1</span></td>
                            <td class="session-cell">Technical Session<span class="room-label">Room 2</span></td>
                            <td class="session-cell">Technical Session<span class="room-label">Room 3</span></td>
                            <td class="session-cell">Technical Session<span class="room-label">Room 4 / Online</span></td>
                            <td>Session details TBC</td>
                        </tr>
                        <tr><td class="time-col">18:30-20:30</td><td colspan="4" class="session-cell">Conference Banquet</td><td>Location TBC</td></tr>
                    </table>
                </div>
            </div>

            <div class="timetable-day">
                <p class="timetable-title">Wednesday, August 19, 2026 — Main Conference</p>
                <div class="table-responsive">
                    <table class="schedule-table">
                        <tr><th>Time</th><th>Room 1</th><th>Room 2</th><th>Room 3</th><th>Room 4 / Online</th><th>Notes</th></tr>
                        <tr><td class="time-col">09:00-10:30</td><td colspan="4" class="session-cell">Plenary Talk / Keynote Talk</td><td>Speaker information TBC</td></tr>
                        <tr class="break-row"><td colspan="6">10:30-10:50 Coffee Break</td></tr>
                        <tr><td class="time-col">10:50-12:00</td><td colspan="4" class="session-cell">Plenary Talk / Keynote Talk</td><td>Speaker information TBC</td></tr>
                        <tr class="break-row"><td colspan="6">12:00-13:30 Lunch Break</td></tr>
                        <tr>
                            <td class="time-col">13:30-15:30</td>
                            <td class="session-cell">Technical Session<span class="room-label">Room 1</span></td>
                            <td class="session-cell">Technical Session<span class="room-label">Room 2</span></td>
                            <td class="session-cell">Technical Session<span class="room-label">Room 3</span></td>
                            <td class="session-cell">Technical Session<span class="room-label">Room 4 / Online</span></td>
                            <td>Session details TBC</td>
                        </tr>
                        <tr class="break-row"><td colspan="6">15:30-15:50 Coffee Break</td></tr>
                        <tr>
                            <td class="time-col">15:50-17:50</td>
                            <td class="session-cell">Technical Session<span class="room-label">Room 1</span></td>
                            <td class="session-cell">Technical Session<span class="room-label">Room 2</span></td>
                            <td class="session-cell">Technical Session<span class="room-label">Room 3</span></td>
                            <td class="session-cell">Technical Session<span class="room-label">Room 4 / Online</span></td>
                            <td>Session details TBC</td>
                        </tr>
                        <tr><td class="time-col">Evening</td><td colspan="4" class="session-cell muted">To be confirmed</td><td>TBC</td></tr>
                    </table>
                </div>
            </div>

            <div class="timetable-day">
                <p class="timetable-title">Thursday, August 20, 2026 — Technical Tour / Online Sessions</p>
                <div class="table-responsive">
                    <table class="schedule-table">
                        <tr><th>Time</th><th>Room 1</th><th>Room 2</th><th>Room 3</th><th>Room 4 / Online</th><th>Notes</th></tr>
                        <tr><td class="time-col">09:00-12:00</td><td colspan="3" class="session-cell">Technical Tour</td><td class="session-cell">Online Session</td><td>Arrangement TBC</td></tr>
                        <tr class="break-row"><td colspan="6">12:00-13:30 Lunch Break</td></tr>
                        <tr><td class="time-col">13:30-17:30</td><td colspan="3" class="session-cell">Technical Tour</td><td class="session-cell">Online Session</td><td>Arrangement TBC</td></tr>
                        <tr><td class="time-col">Evening</td><td colspan="3" class="session-cell muted">To be confirmed</td><td class="session-cell">Online Session</td><td>TBC</td></tr>
                    </table>
                </div>
            </div>

            <div class="timetable-day">
                <p class="timetable-title">Friday, August 21, 2026 — Online Sessions and Departure</p>
                <div class="table-responsive">
                    <table class="schedule-table">
                        <tr><th>Time</th><th>Room 1</th><th>Room 2</th><th>Room 3</th><th>Room 4 / Online</th><th>Notes</th></tr>
                        <tr><td class="time-col">09:00-12:00</td><td colspan="3" class="session-cell muted">Departure / Free Time</td><td class="session-cell">Online Session</td><td>Arrangement TBC</td></tr>
                        <tr class="break-row"><td colspan="6">12:00-13:30 Lunch Break</td></tr>
                        <tr><td class="time-col">13:30-15:30</td><td colspan="3" class="session-cell">Departure</td><td class="session-cell">Online Session</td><td>Arrangement TBC</td></tr>
                    </table>
                </div>
            </div>

            <div class="timetable-note">
                This timetable follows the day-by-day program-at-a-glance format. The final program may be adjusted according to paper acceptance, session grouping, speaker availability, venue arrangement, and online-session requirements.
            </div>
        </div>
    </div>

    <div class="container bottom-spacer">
        <table><tr><td style="width:70%;"><img src="./Images/bottom6.png" class="img-responsive center-block" style="width:100%;" /></td><td style="width:40%;margin-left:5px;display:inline-block"><img class="img-responsive" src="./Images/rcar2026_logo.jpg" /></td></tr></table>
    </div>

    <script src="./Scripts/bootstrap.min.js?v=20220702"></script>
    <script src="./Scripts/script.js?v=20220702"></script>
</body>
</html>
EOF_GLANCE

echo "[6/7] Updating workshop.html if present..."
if [ -f workshop.html ]; then
  # Keep it compact; rewrite only if the file exists.
  cat > workshop.html <<EOF_WORKSHOP
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>Workshop - IEEE RCAR 2026</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="./CSS/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="./CSS/style.css" />
    <link rel="stylesheet" href="./CSS/animate.css" />
    <link rel="stylesheet" href="./CSS/hover.css"/>
    <link href="./CSS/bootstrap-theme.min.css" rel="stylesheet" />
    <style>
        body { background: linear-gradient(180deg,#ffffff 0%,#f7fbfc 45%,#ffffff 100%); }
        .page { font-family:"Helvetica Neue",Arial,sans-serif; color:#2f3e46; }
        .hero { margin-top:24px; border:1px solid #d9e5e8; border-radius:18px; padding:30px 34px; background:linear-gradient(135deg,#edf8ff 0%,#edf9f6 55%,#fff7e8 100%); box-shadow:0 14px 32px rgba(30,80,100,.10); text-align:left; }
        .title { color:#27445c; margin-top:0; font-size:32pt; text-align:center; letter-spacing:.5px; }
        .title:after { content:""; display:block; width:76px; height:3px; margin:12px auto 0; border-radius:3px; background:linear-gradient(90deg,#1677b3,#1aa39a); }
        .lead { max-width:960px; margin:18px auto 0; font-size:15.2pt; line-height:1.75; text-align:left; color:#31444f; }
        .notice { border-left:5px solid #1aa39a; background:#f5fbfa; padding:14px 18px; margin-top:18px; font-size:14.5pt; line-height:1.7; text-align:left; }
        .bottom-spacer { margin-top:100px; text-align:center; }
    </style>
    <script src="./Scripts/jquery-1.11.3.js?v=20220702"></script>
    <script src="./Scripts/bootstrap.min.js?v=20220702"></script>
</head>
<body data-spy="scroll" data-target=".navbar" data-offset="50">
$(cat nav1.html)
    <div class="container page">
        <div class="hero">
            <p class="title">Workshop</p>
            <p class="lead">The IEEE RCAR 2026 workshop is scheduled for <strong>August 15-16, 2026</strong>. Detailed workshop topics, speakers, and registration information will be announced after final confirmation.</p>
            <div class="notice">Please refer to future official announcements for the confirmed workshop arrangement.</div>
        </div>
    </div>
    <div class="container bottom-spacer"><table><tr><td style="width:70%;"><img src="./Images/bottom6.png" class="img-responsive center-block" style="width:100%;" /></td><td style="width:40%;margin-left:5px;display:inline-block"><img class="img-responsive" src="./Images/rcar2026_logo.jpg" /></td></tr></table></div>
    <script src="./Scripts/script.js?v=20220702"></script>
</body>
</html>
EOF_WORKSHOP
fi

echo "[7/7] Checks..."

echo "---- registration fees ----"
grep -n "USD 750\|RMB 5,200\|USD 950\|RMB 6,600\|Extra Paper Charge\|USD 400\|RMB 2,800\|Extra Page Charge\|USD 120\|RMB 800" registration.html || true

echo ""
echo "---- schedule ----"
grep -n "August 15, 2026\|August 16, 2026\|August 17, 2026\|August 18, 2026\|August 19, 2026\|August 20, 2026\|August 21, 2026\|Technical tour\|Online session\|Conference banquet" glance.html || true

echo ""
echo "---- old conference date ranges still remaining ----"
if grep -Rni --exclude-dir=".git" --exclude-dir="$backup_dir" \
  "August 16-22, 2026\|August 16–22, 2026\|Aug\. 16-22, 2026\|Aug\. 16–22, 2026\|Aug 16-22, 2026\|Aug 16–22, 2026\|8月16日-8月22日\|8 月 16 日-8 月 22 日" \
  .; then
  echo "WARNING: old date range still remains above. Please inspect."
else
  echo "OK: no old August 16-22 date range found in active html files."
fi

echo ""
echo "Done. Backup directory: $backup_dir"

if [ -z "$REGISTRATION_URL" ]; then
  echo ""
  echo "NOTE: Registration URL was not provided."
  echo "When the link is ready, rerun with:"
  echo "REGISTRATION_URL=\"https://your-registration-link\" ./update_registration_dates_schedule.sh"
fi

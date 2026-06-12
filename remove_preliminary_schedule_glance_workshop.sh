#!/usr/bin/env bash
set -e

# RCAR 2026: temporarily remove detailed preliminary schedule.
#
# Reason:
# The previously published preliminary schedule is no longer stable.
# The meeting room / conference date arrangement may be revised, so the website should not
# show a detailed day-by-day program until the organizing committee confirms it.
#
# What this script does:
# 1) Rewrites glance.html into a clean "Program schedule to be announced" page.
# 2) Rewrites workshop.html into a clean "Workshop information to be announced" page.
# 3) Does NOT change the global conference date on the homepage or other pages.
#
# Run in the website root directory, e.g. /var/www/rcar2026.

CONFERENCE_EMAIL="${CONFERENCE_EMAIL:-ieeercar@163.com}"

ts="$(date +%Y%m%d_%H%M%S)"
backup_dir="backup_remove_preliminary_schedule_${ts}"
mkdir -p "$backup_dir"

cp glance.html workshop.html nav1.html "$backup_dir"/ 2>/dev/null || true

echo "[1/4] Preparing navbar..."

cat > /tmp/rcar_nav_fixed.html <<'EOF_NAV'
<nav class="navbar navbar-custom navbar-static-top">
    <div class="container_fluid">
        <div class="navbar-header">
            <button class="navbar-toggle" data-toggle="collapse" data-target="#navbar">
                <span></span>
            </button>
            <a href="index.html" class="navbar-brand navbar-left align-self-center mx-auto">
                <p class="align-self-center mx-auto" style="color:rgb(0, 140, 255);margin-left:5px;margin-bottom:10px;font-size:22pt;">IEEE RCAR 2026</p>
            </a>
        </div>

        <div class="collapse navbar-collapse" style="margin-right:2%" id="navbar">
            <ul class="nav navbar-nav navbar-right" style="font-size:11.5pt;">
                <li><a href="index.html" style="padding-left:10px;padding-right:10px;">Home</a></li>
                <li><a href="commitee.html" style="padding-left:10px;padding-right:10px;">Committee</a></li>

                <li class="dropdown">
                    <a href="#" data-toggle="dropdown" style="padding-left:10px;padding-right:10px;">Program&nbsp;<span class="caret"></span></a>
                    <ul class="dropdown-menu">
                        <li><a style="font-size:12pt;" href="glance.html">Program at a Glance</a></li>
                        <li><a style="font-size:12pt;" href="plenary.html">Plenary Speakers</a></li>
                        <li><a style="font-size:12pt;" href="keynote.html">Keynote Speakers</a></li>
                        <li><a style="font-size:12pt;" href="workshop.html">Workshop</a></li>
                    </ul>
                </li>

                <li><a href="CFP.html" style="padding-left:10px;padding-right:10px;">Call for Papers</a></li>

                <li class="dropdown">
                    <a href="#" data-toggle="dropdown" style="padding-left:10px;padding-right:10px;">Submission&nbsp;<span class="caret"></span></a>
                    <ul class="dropdown-menu">
                        <li><a style="font-size:12pt;" href="init_sub.html">Initial Submission</a></li>
                        <li><a style="font-size:12pt;" href="final_sub.html">Final Submission</a></li>
                    </ul>
                </li>

                <li><a href="registration.html" style="padding-left:10px;padding-right:10px;">Registration</a></li>

                <li class="dropdown">
                    <a href="#" data-toggle="dropdown" style="padding-left:10px;padding-right:10px;">Accommodation&nbsp;<span class="caret"></span></a>
                    <ul class="dropdown-menu">
                        <li><a style="font-size:12pt;" href="accommodation.html">Accommodation</a></li>
                        <li><a style="font-size:12pt;" href="transportation.html">Transportation</a></li>
                    </ul>
                </li>

                <li><a href="venue.html" style="padding-left:10px;padding-right:10px;">Venue</a></li>
                <li><a href="history.html" style="padding-left:10px;padding-right:10px;">History</a></li>
                <li><a href="contact.html" style="padding-left:10px;padding-right:10px;">Contact</a></li>
            </ul>
        </div>
    </div>
</nav>
EOF_NAV

cp /tmp/rcar_nav_fixed.html nav1.html

echo "[2/4] Rewriting glance.html..."

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
        .program-page { font-family: "Helvetica Neue", Arial, sans-serif; color:#2f3e46; }
        .program-hero {
            margin-top: 24px;
            border: 1px solid #d9e5e8;
            border-radius: 18px;
            padding: 30px 34px;
            background: linear-gradient(135deg, #edf8ff 0%, #edf9f6 55%, #fff7e8 100%);
            box-shadow: 0 14px 32px rgba(30,80,100,0.10);
            text-align: left;
        }
        .program-title {
            color: #27445c;
            margin-top: 0;
            font-size: 32pt;
            text-align: center;
            letter-spacing: 0.5px;
        }
        .program-title:after {
            content: "";
            display: block;
            width: 76px;
            height: 3px;
            margin: 12px auto 0 auto;
            border-radius: 3px;
            background: linear-gradient(90deg, #1677b3, #1aa39a);
        }
        .program-lead {
            max-width: 960px;
            margin: 18px auto 0 auto;
            font-size: 15.2pt;
            line-height: 1.75;
            text-align: left;
            color: #31444f;
        }
        .notice-box {
            border-left: 5px solid #1aa39a;
            background: #f5fbfa;
            padding: 14px 18px;
            margin-top: 18px;
            font-size: 14.5pt;
            line-height: 1.7;
            text-align: left;
        }
        .warning-box {
            border-left: 5px solid #d99a22;
            background: #fff9ed;
            padding: 14px 18px;
            margin-top: 18px;
            font-size: 14.5pt;
            line-height: 1.7;
            text-align: left;
        }
        .section-title {
            color: #27445c;
            font-size: 22pt;
            font-weight: bold;
            margin-top: 32px;
            margin-bottom: 16px;
            padding-left: 12px;
            border-left: 5px solid #1aa39a;
            text-align: left;
        }
        .status-card {
            background: #ffffff;
            border: 1px solid #d9e5e8;
            border-radius: 16px;
            padding: 22px 24px;
            box-shadow: 0 10px 24px rgba(30,70,90,.08);
            text-align: left;
        }
        .status-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 14pt;
            color: #2f3e46;
            background: #ffffff;
        }
        .status-table th {
            background: #e7f3f6;
            color: #27445c;
            font-weight: bold;
            border: 1px solid #bfd4dc;
            padding: 10px;
            text-align: left;
        }
        .status-table td {
            border: 1px solid #d5e3e8;
            padding: 10px;
            vertical-align: top;
            line-height: 1.55;
            text-align: left;
        }
        .tag-tbc {
            display: inline-block;
            padding: 3px 10px;
            border-radius: 12px;
            background: #fff7e8;
            color: #9a6a10;
            border: 1px solid #ead39a;
            font-size: 12pt;
        }
        .bottom-spacer { margin-top:100px; text-align:center; }
        @media(max-width:768px) {
            .program-title { font-size:26pt; }
            .program-lead { font-size:14pt; }
            .section-title { font-size:19pt; }
            .status-table { font-size:12.5pt; }
        }
    </style>

    <script src="./Scripts/jquery-1.11.3.js?v=20220702"></script>
    <script src="./Scripts/jquery.countdown.js?v=20220702"></script>
    <script src="./Scripts/viewportchecker.min.js?v=20220702"></script>
</head>

<body data-spy="scroll" data-target=".navbar" data-offset="50">
$(cat /tmp/rcar_nav_fixed.html)

    <div class="container program-page">
        <div class="program-hero">
            <p class="program-title">Program at a Glance</p>
            <p class="program-lead">
                The detailed program schedule of IEEE RCAR 2026 is currently being updated. The previous preliminary
                day-by-day schedule has been removed temporarily because the meeting-room arrangement and related conference
                schedule details are still under final confirmation.
            </p>
            <div class="warning-box">
                Please do not refer to any earlier preliminary schedule as the final conference program. The final program,
                including registration time, workshops, technical sessions, banquet, and local program arrangements, will be
                announced after confirmation by the organizing committee.
            </div>
        </div>

        <p class="section-title">Current Program Status</p>
        <div class="status-card">
            <div class="table-responsive">
                <table class="status-table">
                    <tr>
                        <th>Item</th>
                        <th>Status</th>
                    </tr>
                    <tr>
                        <td>Detailed conference program</td>
                        <td><span class="tag-tbc">To be announced</span></td>
                    </tr>
                    <tr>
                        <td>Workshop schedule</td>
                        <td><span class="tag-tbc">To be confirmed</span></td>
                    </tr>
                    <tr>
                        <td>Registration schedule</td>
                        <td><span class="tag-tbc">To be confirmed</span></td>
                    </tr>
                    <tr>
                        <td>Technical sessions and presentations</td>
                        <td><span class="tag-tbc">To be announced</span></td>
                    </tr>
                    <tr>
                        <td>Banquet and local program</td>
                        <td><span class="tag-tbc">To be confirmed</span></td>
                    </tr>
                </table>
            </div>

            <div class="notice-box">
                For program-related questions, please contact the IEEE RCAR 2026 Organizing Committee at
                <a href="mailto:${CONFERENCE_EMAIL}">${CONFERENCE_EMAIL}</a>.
            </div>
        </div>
    </div>

    <div class="container bottom-spacer">
        <table>
            <tr>
                <td style="width:70%;"><img src="./Images/bottom6.png" class="img-responsive center-block" style="width:100%;" /></td>
                <td style="width:40%;margin-left:5px;display:inline-block"><img class="img-responsive" src="./Images/rcar2026_logo.jpg" /></td>
            </tr>
        </table>
    </div>

    <script src="./Scripts/bootstrap.min.js?v=20220702"></script>
    <script src="./Scripts/script.js?v=20220702"></script>
</body>
</html>
EOF_GLANCE

echo "[3/4] Rewriting workshop.html..."

cat > workshop.html <<EOF_WORKSHOP
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>Workshop - IEEE RCAR 2026</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta property="og:title" content="IEEE RCAR 2026">
    <meta property="og:description" content="Workshop information for IEEE RCAR 2026">
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
        .workshop-page { font-family: "Helvetica Neue", Arial, sans-serif; color:#2f3e46; }
        .workshop-hero {
            margin-top: 24px;
            border: 1px solid #d9e5e8;
            border-radius: 18px;
            padding: 30px 34px;
            background: linear-gradient(135deg, #edf8ff 0%, #edf9f6 55%, #fff7e8 100%);
            box-shadow: 0 14px 32px rgba(30,80,100,0.10);
            text-align: left;
        }
        .workshop-title {
            color:#27445c;
            margin-top:0;
            font-size:32pt;
            text-align:center;
            letter-spacing:.5px;
        }
        .workshop-title:after {
            content:"";
            display:block;
            width:76px;
            height:3px;
            margin:12px auto 0;
            border-radius:3px;
            background:linear-gradient(90deg,#1677b3,#1aa39a);
        }
        .workshop-lead {
            max-width:960px;
            margin:18px auto 0;
            font-size:15.2pt;
            line-height:1.75;
            text-align:left;
            color:#31444f;
        }
        .notice-box {
            border-left:5px solid #d99a22;
            background:#fff9ed;
            padding:14px 18px;
            margin-top:18px;
            font-size:14.5pt;
            line-height:1.7;
            text-align:left;
        }
        .bottom-spacer { margin-top:100px; text-align:center; }
        @media(max-width:768px) {
            .workshop-title { font-size:26pt; }
            .workshop-lead { font-size:14pt; }
        }
    </style>

    <script src="./Scripts/jquery-1.11.3.js?v=20220702"></script>
    <script src="./Scripts/jquery.countdown.js?v=20220702"></script>
    <script src="./Scripts/viewportchecker.min.js?v=20220702"></script>
</head>

<body data-spy="scroll" data-target=".navbar" data-offset="50">
$(cat /tmp/rcar_nav_fixed.html)

    <div class="container workshop-page">
        <div class="workshop-hero">
            <p class="workshop-title">Workshop</p>
            <p class="workshop-lead">
                Workshop information for IEEE RCAR 2026 is currently under review. The workshop date, format, topics,
                registration method, and detailed program will be announced after final confirmation by the organizing committee.
            </p>
            <div class="notice-box">
                The previous tentative workshop schedule has been removed temporarily. Please refer to future official
                announcements for the confirmed workshop arrangement.
            </div>
        </div>
    </div>

    <div class="container bottom-spacer">
        <table>
            <tr>
                <td style="width:70%;"><img src="./Images/bottom6.png" class="img-responsive center-block" style="width:100%;" /></td>
                <td style="width:40%;margin-left:5px;display:inline-block"><img class="img-responsive" src="./Images/rcar2026_logo.jpg" /></td>
            </tr>
        </table>
    </div>

    <script src="./Scripts/bootstrap.min.js?v=20220702"></script>
    <script src="./Scripts/script.js?v=20220702"></script>
</body>
</html>
EOF_WORKSHOP

echo "[4/4] Checks..."

echo "---- removed old explicit schedule dates from glance/workshop ----"
if grep -Rni "August 16, 2026\|August 17, 2026\|August 18, 2026\|August 19, 2026\|August 20, 2026\|August 21, 2026\|August 22, 2026\|pre-conference workshop\|Marine Park one-day" glance.html workshop.html; then
    echo "WARNING: some old schedule text still appears above. Please inspect."
else
    echo "OK: no old detailed day-by-day schedule remains in glance.html or workshop.html."
fi

echo ""
echo "---- new status text ----"
grep -n "currently being updated\|To be announced\|under review\|removed temporarily" glance.html workshop.html || true

echo ""
echo "Done. Backup directory: $backup_dir"

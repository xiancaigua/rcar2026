#!/usr/bin/env bash
set -e

# RCAR 2026: rewrite venue.html.
# Keep Transportation reference and the two Savoy image cards.
# Remove old card-style Getting to the Venue blocks.

CONFERENCE_EMAIL="${CONFERENCE_EMAIL:-ieeercar@163.com}"
ts="$(date +%Y%m%d_%H%M%S)"
backup_dir="backup_venue_keep_reference_images_${ts}"
mkdir -p "$backup_dir"

if [ ! -f venue.html ]; then
  echo "ERROR: venue.html not found. Run this in the website root directory." >&2
  exit 1
fi
if [ ! -f nav1.html ]; then
  echo "ERROR: nav1.html not found. Run this in the website root directory." >&2
  exit 1
fi

cp venue.html nav1.html "$backup_dir"/ 2>/dev/null || true

cat > venue.html <<HTML_EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>Venue - IEEE RCAR 2026</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta property="og:title" content="IEEE RCAR 2026">
    <meta property="og:description" content="Venue information for IEEE RCAR 2026">
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
        .venue-page { font-family: "Helvetica Neue", Arial, sans-serif; color: #2f3e46; }
        .hero { margin-top:24px; border:1px solid #d9e5e8; border-radius:18px; overflow:hidden; background:#fff; box-shadow:0 14px 32px rgba(30,80,100,.10); }
        .hero-img { width:100%; height:390px; object-fit:cover; display:block; }
        .hero-body { padding:28px 32px; background:linear-gradient(135deg,#edf8ff 0%,#edf9f6 55%,#fff7e8 100%); text-align:left; }
        .title { color:#27445c; margin-top:0; font-size:32pt; text-align:center; letter-spacing:.5px; }
        .title:after { content:""; display:block; width:76px; height:3px; margin:12px auto 0; border-radius:3px; background:linear-gradient(90deg,#1677b3,#1aa39a); }
        .lead { max-width:980px; margin:18px auto 0; font-size:15.2pt; line-height:1.75; text-align:left; color:#31444f; }
        .section-title { color:#27445c; font-size:22pt; font-weight:bold; margin-top:32px; margin-bottom:16px; padding-left:12px; border-left:5px solid #1aa39a; text-align:left; }
        .info-card { background:#fff; border:1px solid #d9e5e8; border-radius:16px; padding:22px 24px; margin-bottom:22px; box-shadow:0 10px 24px rgba(30,70,90,.08); text-align:left; }
        .venue-detail { font-size:15pt; line-height:1.75; color:#2f3e46; text-align:left; margin-bottom:8px; }
        .venue-detail strong { color:#27445c; }
        .map-wrapper { border:1px solid #d9e5e8; border-radius:16px; overflow:hidden; background:#fff; box-shadow:0 10px 24px rgba(30,70,90,.08); margin-bottom:22px; }
        .map-wrapper iframe { width:100%; height:430px; border:0; display:block; }
        .access-list { font-size:14.8pt; line-height:1.8; color:#2f3e46; padding-left:22px; margin-bottom:0; text-align:left; }
        .access-list li { margin-top:8px; }
        .source-note { font-size:13.2pt; line-height:1.55; color:#66757d; text-align:left; margin-top:14px; margin-bottom:0; }
        .image-card { border-radius:16px; overflow:hidden; box-shadow:0 10px 24px rgba(30,70,90,.12); background:#fff; margin-top:10px; margin-bottom:22px; }
        .image-card img { width:100%; height:270px; object-fit:cover; display:block; }
        .image-caption { padding:12px 16px; font-size:13.5pt; color:#4a5960; text-align:left; background:#fff; }
        .entry-notice { border-left:6px solid #d99a22; background:#fff9ed; border-radius:14px; padding:18px 22px; margin-top:24px; margin-bottom:24px; box-shadow:0 8px 22px rgba(90,70,30,.08); text-align:left; }
        .entry-notice-title { color:#27445c; font-size:19pt; font-weight:bold; margin:0 0 8px 0; }
        .entry-notice-text { font-size:14.5pt; line-height:1.7; color:#2f3e46; margin-bottom:0; text-align:left; }
        .notice { border-left:5px solid #1aa39a; background:#f5fbfa; padding:14px 18px; margin-top:18px; font-size:14.5pt; line-height:1.7; text-align:left; }
        .bottom-spacer { margin-top:100px; text-align:center; }
        @media(max-width:768px) {
            .title { font-size:26pt; }
            .lead { font-size:14pt; }
            .section-title { font-size:19pt; }
            .hero-img { height:250px; }
            .map-wrapper iframe { height:320px; }
            .image-card img { height:210px; }
            .entry-notice-title { font-size:17pt; }
            .entry-notice-text { font-size:13.5pt; }
        }
    </style>

    <script src="./Scripts/jquery-1.11.3.js?v=20220702"></script>
    <script src="./Scripts/jquery.countdown.js?v=20220702"></script>
    <script src="./Scripts/viewportchecker.min.js?v=20220702"></script>
</head>

<body data-spy="scroll" data-target=".navbar" data-offset="50">
$(cat nav1.html)

    <div class="container venue-page">
        <div class="hero">
            <img class="hero-img" src="./Images/savoy_conference_room.png" alt="Savoy Seychelles Resort and Spa venue">
            <div class="hero-body">
                <p class="title">Venue</p>
                <p class="lead">
                    IEEE RCAR 2026 will be held at <strong>Savoy Seychelles Resort &amp; Spa</strong>, Beau Vallon, Mahé, Seychelles.
                    The conference venue room is <strong>AMIRANTES BALLROOM</strong>.
                </p>
            </div>
        </div>

        <div class="entry-notice">
            <p class="entry-notice-title">Important Entry Requirement: Seychelles Travel Authorisation</p>
            <p class="entry-notice-text">
                Although no visa is generally required for visitors to Seychelles, <strong>all travellers are required to apply
                for a Travel Authorisation (TA) before travelling to Seychelles</strong>. Participants may apply online through the
                <a href="https://seychelles.govtas.com/en" target="_blank" rel="noopener noreferrer">Seychelles Electronic Border System</a>
                or the Seychelles E-Border app before departure.
            </p>
        </div>

        <p class="section-title">Venue Information</p>
        <div class="info-card">
            <p class="venue-detail"><strong>Venue:</strong> Savoy Seychelles Resort &amp; Spa</p>
            <p class="venue-detail"><strong>Conference Room:</strong> AMIRANTES BALLROOM</p>
            <p class="venue-detail"><strong>Address:</strong> Beau Vallon, Mahé, Seychelles</p>
            <p class="venue-detail"><strong>Website:</strong> <a href="https://savoy.sc/about/" target="_blank" rel="noopener noreferrer">https://savoy.sc/about/</a></p>
        </div>

        <p class="section-title">Access to Venue</p>
        <div class="map-wrapper">
            <iframe
                src="https://www.google.com/maps?q=Savoy%20Seychelles%20Resort%20%26%20Spa%2C%20Beau%20Vallon%2C%20Mah%C3%A9%2C%20Seychelles&output=embed"
                loading="lazy"
                allowfullscreen
                referrerpolicy="no-referrer-when-downgrade">
            </iframe>
        </div>

        <div class="info-card">
            <p class="venue-detail"><strong>From Seychelles International Airport (SEZ)</strong></p>
            <ul class="access-list">
                <li><strong>By Taxi:</strong> approximately 45 minutes to Savoy Seychelles Resort &amp; Spa, depending on traffic and local road conditions.</li>
                <li><strong>By Car:</strong> participants using rental cars should check the latest route through Google Maps or other navigation services before departure.</li>
                <li><strong>By Public Bus:</strong> public bus services are accessible outside the airport. Participants should check bus-card and luggage rules before using public buses.</li>
            </ul>

            <p class="source-note">
                Transportation reference:
                <a href="https://seychellesairports.sc/travel-connections/transportation" target="_blank" rel="noopener noreferrer">
                    Seychelles International Airport - Transportation
                </a>.
            </p>
        </div>

        <div class="row">
            <div class="col-md-6">
                <div class="image-card">
                    <img src="./Images/savoy_pool_resort.png" alt="Savoy Seychelles resort view">
                    <div class="image-caption">Savoy Seychelles Resort &amp; Spa, Beau Vallon, Mahé.</div>
                </div>
            </div>

            <div class="col-md-6">
                <div class="image-card">
                    <img src="./Images/savoy_beach_garden.png" alt="Savoy Seychelles hotel environment">
                    <div class="image-caption">Hotel environment and beachfront resort setting.</div>
                </div>
            </div>
        </div>

        <div class="notice">
            Participants are responsible for arranging their own airport-to-hotel transportation unless otherwise announced by the organizing committee.
            For venue-related questions, please contact the IEEE RCAR 2026 Organizing Committee at
            <a href="mailto:${CONFERENCE_EMAIL}">${CONFERENCE_EMAIL}</a>.
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
HTML_EOF

echo "==== Checks ===="
echo "---- Required kept content ----"
grep -n "Transportation reference\|Seychelles International Airport - Transportation\|savoy_pool_resort.png\|savoy_beach_garden.png\|Savoy Seychelles Resort & Spa, Beau Vallon, Mahé\|Hotel environment and beachfront resort setting" venue.html || true

echo ""
echo "---- Required venue/map/access content ----"
grep -n "AMIRANTES BALLROOM\|Access to Venue\|By Taxi\|approximately 45 minutes\|google.com/maps" venue.html || true

echo ""
echo "---- Removed old card-style transport headings ----"
if grep -n "Taxi Services</strong>\|transport-option\|Getting to the Venue" venue.html; then
    echo "WARNING: old card-style transport content may still exist. Please inspect lines above."
    exit 1
else
    echo "OK: old card-style transport headings removed."
fi

echo ""
echo "Done. Backup directory: $backup_dir"

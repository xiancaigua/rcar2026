#!/usr/bin/env bash
set -e

# RCAR 2026: add airport-to-hotel/venue transportation guidance.
#
# Public-facing update:
# - Add "Getting from Seychelles International Airport to Savoy Seychelles Resort & Spa"
#   to transportation.html.
# - Add "Getting to the Venue" to venue.html.
# - Optionally also add a short transfer panel to accommodation.html.
# - Keep conference shuttle as To be confirmed, but no longer leave the page with only that vague card.
#
# Run this script in the website root directory, e.g. /var/www/rcar2026.

ts="$(date +%Y%m%d_%H%M%S)"
backup_dir="backup_airport_to_savoy_${ts}"
mkdir -p "$backup_dir"
cp transportation.html venue.html accommodation.html "$backup_dir"/ 2>/dev/null || true

CONFERENCE_EMAIL="${CONFERENCE_EMAIL:-ieeercar@163.com}"

if [ ! -f transportation.html ]; then
    echo "ERROR: transportation.html not found. Please create transportation.html first." >&2
    exit 1
fi

cat > /tmp/airport_to_savoy_css.txt <<'EOF_CSS'
        .airport-transfer-panel {
            border: 1px solid #d9e5e8;
            border-radius: 16px;
            padding: 22px 24px;
            margin-top: 24px;
            margin-bottom: 24px;
            background: linear-gradient(135deg, #ffffff 0%, #edf8ff 100%);
            box-shadow: 0 10px 24px rgba(30, 70, 90, 0.08);
            text-align: left;
        }
        .airport-transfer-title {
            color: #27445c;
            font-size: 22pt;
            font-weight: bold;
            margin-top: 0;
            margin-bottom: 14px;
            padding-left: 12px;
            border-left: 5px solid #1aa39a;
            text-align: left;
        }
        .airport-transfer-text {
            font-size: 15pt;
            line-height: 1.75;
            color: #2f3e46;
            text-align: left;
        }
        .airport-transfer-grid {
            margin-top: 12px;
        }
        .airport-transfer-card {
            background: #ffffff;
            border: 1px solid #d9e5e8;
            border-radius: 12px;
            padding: 15px 16px;
            margin-top: 12px;
            min-height: 138px;
            box-shadow: 0 6px 16px rgba(30, 80, 100, 0.06);
            text-align: left;
        }
        .airport-transfer-card strong {
            display: block;
            color: #27445c;
            font-size: 15pt;
            margin-bottom: 6px;
        }
        .airport-transfer-card span {
            display: block;
            color: #4a5960;
            font-size: 13.5pt;
            line-height: 1.55;
        }
        .airport-transfer-note {
            border-left: 5px solid #d99a22;
            background: #fff9ed;
            padding: 13px 16px;
            margin-top: 16px;
            font-size: 14pt;
            line-height: 1.65;
            color: #2f3e46;
            text-align: left;
        }
        @media (max-width: 768px) {
            .airport-transfer-title { font-size: 19pt; }
            .airport-transfer-text { font-size: 14pt; }
            .airport-transfer-card { min-height: 0; }
        }
EOF_CSS

cat > /tmp/airport_to_savoy_block.html <<EOF_BLOCK
<!-- RCAR_AIRPORT_TO_SAVOY_START -->
<div class="container airport-transfer-panel" id="airport-to-savoy">
    <p class="airport-transfer-title">Getting from the Airport to the Conference Hotel / Venue</p>
    <p class="airport-transfer-text">
        The conference hotel and venue is <strong>Savoy Seychelles Resort &amp; Spa</strong>, located in Beau Vallon, Mahé.
        Most international participants will arrive at <strong>Seychelles International Airport (SEZ)</strong>.
        The transfer from the airport to Savoy Seychelles Resort &amp; Spa is approximately <strong>45 minutes by car</strong>,
        depending on traffic and local road conditions.
    </p>

    <div class="row airport-transfer-grid">
        <div class="col-md-3 col-sm-6">
            <div class="airport-transfer-card">
                <strong>Taxi</strong>
                <span>Participants may take a taxi from the airport arrival area to Savoy Seychelles Resort &amp; Spa. This is usually the most direct option for individual travelers with luggage.</span>
            </div>
        </div>
        <div class="col-md-3 col-sm-6">
            <div class="airport-transfer-card">
                <strong>Hotel-arranged Transfer</strong>
                <span>Participants may contact the hotel or booking channel in advance to ask whether airport transfer service can be arranged. Availability and price depend on the hotel policy.</span>
            </div>
        </div>
        <div class="col-md-3 col-sm-6">
            <div class="airport-transfer-card">
                <strong>Pre-booked Private Transfer</strong>
                <span>Private transfer is recommended for groups, late arrivals, or participants carrying large luggage. Please confirm pickup time, meeting point, and fare before arrival.</span>
            </div>
        </div>
        <div class="col-md-3 col-sm-6">
            <div class="airport-transfer-card">
                <strong>Conference Shuttle</strong>
                <span>To be confirmed. The organizing committee will announce shuttle information if a conference shuttle service is arranged.</span>
            </div>
        </div>
    </div>

    <div class="airport-transfer-note">
        Participants should not assume that airport transfer or hotel-to-venue transportation is included in the registration fee
        unless explicitly announced by the organizing committee. For transportation-related questions, please contact
        <a href="mailto:${CONFERENCE_EMAIL}">${CONFERENCE_EMAIL}</a>.
    </div>
</div>
<!-- RCAR_AIRPORT_TO_SAVOY_END -->
EOF_BLOCK

add_css_if_missing() {
    f="$1"
    [ -f "$f" ] || return 0

    if grep -q "airport-transfer-panel" "$f"; then
        return 0
    fi

    if grep -q "</style>" "$f"; then
        awk '
            FNR==NR {
                css = css $0 ORS
                next
            }
            /<\/style>/ && !inserted {
                printf "%s", css
                inserted = 1
            }
            { print }
        ' /tmp/airport_to_savoy_css.txt "$f" > "$f.tmp" && mv "$f.tmp" "$f"
    else
        awk '
            FNR==NR {
                css = css $0 ORS
                next
            }
            /<\/head>/ && !inserted {
                print "    <style>"
                printf "%s", css
                print "    </style>"
                inserted = 1
            }
            { print }
        ' /tmp/airport_to_savoy_css.txt "$f" > "$f.tmp" && mv "$f.tmp" "$f"
    fi
}

insert_after_nav_or_top() {
    f="$1"
    [ -f "$f" ] || return 0

    sed -i '/<!-- RCAR_AIRPORT_TO_SAVOY_START -->/,/<!-- RCAR_AIRPORT_TO_SAVOY_END -->/d' "$f"

    awk '
        FNR==NR {
            block = block $0 ORS
            next
        }

        /<\/nav>/ && !inserted {
            print
            printf "%s", block
            inserted = 1
            next
        }

        /<include src="nav1.html"><\/include>/ && !inserted {
            print
            printf "%s", block
            inserted = 1
            next
        }

        /<include src='\''nav1.html'\''><\/include>/ && !inserted {
            print
            printf "%s", block
            inserted = 1
            next
        }

        /<div class="container/ && !inserted {
            printf "%s", block
            inserted = 1
        }

        { print }
    ' /tmp/airport_to_savoy_block.html "$f" > "$f.tmp" && mv "$f.tmp" "$f"
}

insert_before_conference_local_transportation() {
    f="$1"
    [ -f "$f" ] || return 0

    sed -i '/<!-- RCAR_AIRPORT_TO_SAVOY_START -->/,/<!-- RCAR_AIRPORT_TO_SAVOY_END -->/d' "$f"

    awk '
        FNR==NR {
            block = block $0 ORS
            next
        }

        /Conference Local Transportation/ && !inserted {
            printf "%s", block
            inserted = 1
        }

        { print }
    ' /tmp/airport_to_savoy_block.html "$f" > "$f.tmp" && mv "$f.tmp" "$f"
}

echo "[1/4] Updating transportation.html..."
add_css_if_missing transportation.html
if grep -q "Conference Local Transportation" transportation.html; then
    insert_before_conference_local_transportation transportation.html
else
    insert_after_nav_or_top transportation.html
fi

echo "[2/4] Updating venue.html if present..."
if [ -f venue.html ]; then
    add_css_if_missing venue.html
    insert_after_nav_or_top venue.html
fi

echo "[3/4] Updating accommodation.html if present..."
if [ -f accommodation.html ]; then
    add_css_if_missing accommodation.html
    sed -i '/<!-- RCAR_AIRPORT_TO_SAVOY_START -->/,/<!-- RCAR_AIRPORT_TO_SAVOY_END -->/d' accommodation.html
    # Add near the existing Transportation note if it exists; otherwise insert after nav/top.
    if grep -q "For airport transfer, local transportation" accommodation.html; then
        awk '
            FNR==NR {
                block = block $0 ORS
                next
            }
            /For airport transfer, local transportation/ && !inserted {
                printf "%s", block
                inserted = 1
            }
            { print }
        ' /tmp/airport_to_savoy_block.html accommodation.html > accommodation.html.tmp && mv accommodation.html.tmp accommodation.html
    else
        insert_after_nav_or_top accommodation.html
    fi
fi

echo "[4/4] Checks..."
grep -R "Getting from the Airport to the Conference Hotel\|45 minutes by car\|Savoy Seychelles Resort" -n transportation.html venue.html accommodation.html 2>/dev/null || true
echo "Done. Backup directory: $backup_dir"

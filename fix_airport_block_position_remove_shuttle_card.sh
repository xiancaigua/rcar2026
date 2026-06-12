#!/usr/bin/env bash
set -e

# RCAR 2026: fix Airport Transportation block placement and remove standalone Conference Shuttle card.
#
# What this script does:
# 1) Removes the existing RCAR_AIRPORT_TO_SAVOY block wherever it was inserted.
# 2) Re-adds the block in the correct lower position:
#    - venue.html: after the Venue hero section, before Venue Overview
#    - transportation.html: before Conference Local Transportation, or after page title if that anchor is absent
#    - accommodation.html: before the transportation note, or after the main accommodation hero if that anchor is absent
# 3) Removes the standalone "Conference Shuttle" card.
# 4) Keeps "Conference Shuttle: To be confirmed by the organizing committee" only inside the yellow note box.
#
# Run this script in /var/www/rcar2026.

CONFERENCE_EMAIL="${CONFERENCE_EMAIL:-ieeercar@163.com}"

ts="$(date +%Y%m%d_%H%M%S)"
backup_dir="backup_airport_block_reposition_${ts}"
mkdir -p "$backup_dir"
cp venue.html transportation.html accommodation.html "$backup_dir"/ 2>/dev/null || true

cat > /tmp/rcar_airport_block_fixed.html <<EOF_BLOCK
<!-- RCAR_AIRPORT_TO_SAVOY_START -->
<div class="container airport-transfer-panel" id="airport-to-savoy">
    <p class="airport-transfer-title">Airport Transportation</p>
    <p class="airport-transfer-text">
        The conference hotel and venue is <strong>Savoy Seychelles Resort &amp; Spa</strong>, located in Beau Vallon, Mahé.
        Most international participants will arrive at <strong>Seychelles International Airport (SEZ)</strong>.
        The transfer from the airport to Savoy Seychelles Resort &amp; Spa is approximately <strong>45 minutes by car</strong>,
        depending on traffic and local road conditions.
    </p>

    <div class="row airport-transfer-grid">
        <div class="col-md-4 col-sm-6">
            <div class="airport-transfer-card">
                <strong>Taxi</strong>
                <span>Participants may take a taxi from the airport arrival area to Savoy Seychelles Resort &amp; Spa. This is usually the most direct option for individual travelers with luggage.</span>
            </div>
        </div>
        <div class="col-md-4 col-sm-6">
            <div class="airport-transfer-card">
                <strong>Hotel-arranged Transfer</strong>
                <span>Participants may contact the hotel or booking channel in advance to ask whether airport transfer service can be arranged. Availability and price depend on the hotel policy.</span>
            </div>
        </div>
        <div class="col-md-4 col-sm-12">
            <div class="airport-transfer-card">
                <strong>Pre-booked Private Transfer</strong>
                <span>Private transfer is recommended for groups, late arrivals, or participants carrying large luggage. Please confirm pickup time, meeting point, and fare before arrival.</span>
            </div>
        </div>
    </div>

    <div class="airport-transfer-note">
        <strong>Conference Shuttle:</strong> To be confirmed by the organizing committee.
        <br><br>
        Participants should not assume that airport transfer or hotel-to-venue transportation is included in the registration fee
        unless explicitly announced by the organizing committee. For transportation-related questions, please contact
        <a href="mailto:${CONFERENCE_EMAIL}">${CONFERENCE_EMAIL}</a>.
    </div>
</div>
<!-- RCAR_AIRPORT_TO_SAVOY_END -->
EOF_BLOCK

cat > /tmp/rcar_airport_block_css.txt <<'EOF_CSS'
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

add_css_if_missing() {
    f="$1"
    [ -f "$f" ] || return 0

    if grep -q "airport-transfer-panel" "$f"; then
        return 0
    fi

    if grep -q "</style>" "$f"; then
        awk '
            FNR==NR { css = css $0 ORS; next }
            /<\/style>/ && !inserted {
                printf "%s", css
                inserted = 1
            }
            { print }
        ' /tmp/rcar_airport_block_css.txt "$f" > "$f.tmp" && mv "$f.tmp" "$f"
    else
        awk '
            FNR==NR { css = css $0 ORS; next }
            /<\/head>/ && !inserted {
                print "    <style>"
                printf "%s", css
                print "    </style>"
                inserted = 1
            }
            { print }
        ' /tmp/rcar_airport_block_css.txt "$f" > "$f.tmp" && mv "$f.tmp" "$f"
    fi
}

remove_old_block() {
    f="$1"
    [ -f "$f" ] || return 0

    sed -i '/<!-- RCAR_AIRPORT_TO_SAVOY_START -->/,/<!-- RCAR_AIRPORT_TO_SAVOY_END -->/d' "$f"
}

insert_before_pattern() {
    f="$1"
    pattern="$2"
    [ -f "$f" ] || return 0

    awk -v pat="$pattern" '
        FNR==NR {
            block = block $0 ORS
            next
        }

        $0 ~ pat && !inserted {
            printf "%s", block
            inserted = 1
        }

        { print }

        END {
            if (!inserted) {
                # Nothing here; caller can handle fallback if needed.
            }
        }
    ' /tmp/rcar_airport_block_fixed.html "$f" > "$f.tmp" && mv "$f.tmp" "$f"
}

insert_after_nav_fallback() {
    f="$1"
    [ -f "$f" ] || return 0

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

        { print }
    ' /tmp/rcar_airport_block_fixed.html "$f" > "$f.tmp" && mv "$f.tmp" "$f"
}

echo "[1/4] Fixing venue.html..."
if [ -f venue.html ]; then
    remove_old_block venue.html
    add_css_if_missing venue.html

    # Insert below the hero section by placing it before "Venue Overview".
    if grep -q "Venue Overview" venue.html; then
        insert_before_pattern venue.html "Venue Overview"
    else
        insert_after_nav_fallback venue.html
    fi
fi

echo "[2/4] Fixing transportation.html..."
if [ -f transportation.html ]; then
    remove_old_block transportation.html
    add_css_if_missing transportation.html

    # Put it above Conference Local Transportation, not at the very top.
    if grep -q "Conference Local Transportation" transportation.html; then
        insert_before_pattern transportation.html "Conference Local Transportation"
    else
        insert_after_nav_fallback transportation.html
    fi
fi

echo "[3/4] Fixing accommodation.html..."
if [ -f accommodation.html ]; then
    remove_old_block accommodation.html
    add_css_if_missing accommodation.html

    # Put it lower on the page, near the existing Transportation note if possible.
    if grep -q "For airport transfer, local transportation" accommodation.html; then
        insert_before_pattern accommodation.html "For airport transfer, local transportation"
    elif grep -q "Booking Instructions" accommodation.html; then
        insert_before_pattern accommodation.html "Booking Instructions"
    else
        insert_after_nav_fallback accommodation.html
    fi
fi

echo "[4/4] Checks..."

echo "---- airport block positions ----"
grep -n "RCAR_AIRPORT_TO_SAVOY_START\|Airport Transportation\|Conference Shuttle" venue.html transportation.html accommodation.html 2>/dev/null || true

echo "---- ensure block is not inside nav in venue.html ----"
if awk '
    /<nav class="navbar navbar-custom navbar-static-top">/ { in_nav=1 }
    in_nav && /RCAR_AIRPORT_TO_SAVOY_START/ { bad=1 }
    /<\/nav>/ && in_nav { in_nav=0 }
    END { exit bad ? 1 : 0 }
' venue.html; then
    echo "OK: airport block is not inside venue navbar."
else
    echo "ERROR: airport block is still inside venue navbar. Please inspect venue.html." >&2
    exit 1
fi

echo "---- standalone Conference Shuttle card check ----"
if grep -R '<strong>Conference Shuttle</strong>' -n venue.html transportation.html accommodation.html 2>/dev/null; then
    echo "ERROR: standalone Conference Shuttle card still exists." >&2
    exit 1
else
    echo "OK: no standalone Conference Shuttle card."
fi

echo "Done. Backup directory: $backup_dir"

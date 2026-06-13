#!/usr/bin/env bash
set -e

# RCAR 2026: update venue.html Google Map to show route from airport to venue.
#
# Goal:
# - Make the embedded Google Map show both:
#   1) Seychelles International Airport (SEZ)
#   2) Savoy Seychelles Resort & Spa
# - Keep the existing Transportation reference and hotel images.
# - Do not rewrite the whole page.
#
# Run in website root, e.g. /var/www/rcar2026.

ts="$(date +%Y%m%d_%H%M%S)"
backup_dir="backup_venue_airport_route_map_${ts}"
mkdir -p "$backup_dir"

if [ ! -f venue.html ]; then
    echo "ERROR: venue.html not found. Please run this script in the website root directory." >&2
    exit 1
fi

cp venue.html "$backup_dir"/

echo "[1/4] Updating Google Map iframe to airport-to-venue route..."

python3 - <<'PY'
from pathlib import Path
import re

path = Path("venue.html")
html = path.read_text(encoding="utf-8")

route_src = "https://www.google.com/maps?saddr=Seychelles%20International%20Airport%20(SEZ)&daddr=Savoy%20Seychelles%20Resort%20%26%20Spa%2C%20Beau%20Vallon%2C%20Mah%C3%A9%2C%20Seychelles&dirflg=d&output=embed"

pattern = re.compile(r'(<iframe\b[^>]*?\bsrc=")(https://www\.google\.com/maps[^"]*)(")', re.S)

def repl(m):
    return m.group(1) + route_src + m.group(3)

new_html, count = pattern.subn(repl, html, count=1)

if count == 0:
    map_block = (
        '\n        <div class="map-wrapper">\n'
        '            <iframe\n'
        f'                src="{route_src}"\n'
        '                loading="lazy"\n'
        '                allowfullscreen\n'
        '                referrerpolicy="no-referrer-when-downgrade">\n'
        '            </iframe>\n'
        '        </div>\n'
    )
    heading = '<p class="section-title">Access to Venue</p>'
    if heading in html:
        new_html = html.replace(heading, heading + map_block, 1)
    else:
        marker = '<div class="notice">'
        new_html = html.replace(marker, '<p class="section-title">Access to Venue</p>' + map_block + marker, 1)

path.write_text(new_html, encoding="utf-8")
PY

echo "[2/4] Adding short route-intro text before the map..."

python3 - <<'PY'
from pathlib import Path

path = Path("venue.html")
html = path.read_text(encoding="utf-8")

intro = (
    '\n        <div class="info-card route-intro-card">\n'
    '            <p class="venue-detail">\n'
    '                The map below shows the route from <strong>Seychelles International Airport (SEZ)</strong>\n'
    '                to <strong>Savoy Seychelles Resort &amp; Spa</strong>.\n'
    '            </p>\n'
    '        </div>\n\n'
)

if "The map below shows the route from" not in html:
    html = html.replace(
        '<div class="map-wrapper">',
        intro + '        <div class="map-wrapper">',
        1
    )

path.write_text(html, encoding="utf-8")
PY

echo "[3/4] Verifying preserved content..."

echo "---- route map iframe ----"
grep -n "saddr=Seychelles%20International%20Airport\|daddr=Savoy%20Seychelles%20Resort" venue.html || true

echo ""
echo "---- preserved reference and images ----"
grep -n "Transportation reference\|Seychelles International Airport - Transportation\|savoy_pool_resort.png\|savoy_beach_garden.png" venue.html || true

echo ""
echo "---- old single-place map should be gone ----"
if grep -n 'maps?q=Savoy%20Seychelles%20Resort' venue.html; then
    echo "WARNING: old single-place map still exists. Please inspect the line above."
    exit 1
else
    echo "OK: old single-place map removed."
fi

echo "[4/4] Done. Backup directory: $backup_dir"

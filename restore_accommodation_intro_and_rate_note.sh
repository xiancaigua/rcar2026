#!/usr/bin/env bash
set -e

# RCAR 2026: restore the two short accommodation intro sentences.
#
# Restores:
# 1) The opening sentence:
#    "The following hotel information is provided for IEEE RCAR 2026 participants during the conference period August 16-22, 2026."
#
# 2) The rate explanation:
#    "Rates are listed per room per night. The double-occupancy rate is based on two adults sharing one room;
#     the single-occupancy rate is based on one adult occupying one room. Breakfast is included unless otherwise stated."
#
# Run in website root, e.g. /var/www/rcar2026.

ts="$(date +%Y%m%d_%H%M%S)"
backup_dir="backup_restore_accommodation_intro_${ts}"
mkdir -p "$backup_dir"

if [ ! -f accommodation.html ]; then
    echo "ERROR: accommodation.html not found. Please run this script in the website root directory." >&2
    exit 1
fi

cp accommodation.html "$backup_dir"/

echo "[1/3] Removing duplicated old rate-explanation notice if present..."

# Remove any previous notice block containing the rate explanation to avoid duplicates.
awk '
    /<div class="notice">/ {
        block = $0 ORS
        depth = gsub(/<div/, "<div", $0) - gsub(/<\/div>/, "</div>", $0)
        hit = (tolower($0) ~ /rates are listed per room per night/)

        while (depth > 0 && getline > 0) {
            block = block $0 ORS
            if (tolower($0) ~ /rates are listed per room per night/) hit = 1
            depth += gsub(/<div/, "<div", $0)
            depth -= gsub(/<\/div>/, "</div>", $0)
        }

        if (!hit) printf "%s", block
        next
    }
    { print }
' accommodation.html > accommodation.html.tmp && mv accommodation.html.tmp accommodation.html

echo "[2/3] Restoring opening sentence and rate explanation in the hero section..."

awk '
    BEGIN {
        in_hero = 0
        replacing_lead = 0
        done = 0
    }

    /<div class="hero">/ {
        in_hero = 1
        print
        next
    }

    in_hero && !done && /<p class="lead">/ {
        print "            <p class=\"lead\">"
        print "                The following hotel information is provided for IEEE RCAR 2026 participants during the conference period"
        print "                <strong>August 16-22, 2026</strong>."
        print "            </p>"
        print ""
        print "            <div class=\"notice\">"
        print "                Rates are listed per room per night. The double-occupancy rate is based on two adults sharing one room;"
        print "                the single-occupancy rate is based on one adult occupying one room. Breakfast is included unless otherwise stated."
        print "            </div>"
        replacing_lead = 1
        done = 1
        next
    }

    replacing_lead {
        if ($0 ~ /<\/p>/) {
            replacing_lead = 0
        }
        next
    }

    in_hero && /<\/div>/ {
        # keep normal printing; this does not need exact hero-depth tracking
        print
        next
    }

    { print }
' accommodation.html > accommodation.html.tmp && mv accommodation.html.tmp accommodation.html

echo "[3/3] Checks..."

grep -n "The following hotel information is provided\|Rates are listed per room per night\|August 16-22, 2026" accommodation.html || true

echo ""
echo "Done. Backup directory: $backup_dir"

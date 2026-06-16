#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-/var/www/rcar2026}"
cd "$ROOT"

if [ ! -f "registration.html" ]; then
  echo "ERROR: registration.html not found in $ROOT" >&2
  exit 1
fi

if [ ! -f "NOTICE.pdf" ]; then
  echo "ERROR: NOTICE.pdf not found in $ROOT" >&2
  echo "Expected file path: $ROOT/NOTICE.pdf" >&2
  exit 1
fi

ts="$(date +%Y%m%d_%H%M%S)"
backup_dir="backup_notice_registration_${ts}"
mkdir -p "$backup_dir"

cp -p registration.html "$backup_dir/registration.html"
if [ -f update_registration_dates_schedule.sh ]; then
  cp -p update_registration_dates_schedule.sh "$backup_dir/update_registration_dates_schedule.sh"
fi

# Make sure the PDF can be served by the web server.
chmod 644 NOTICE.pdf

python3 <<'PY'
from pathlib import Path

NOTICE_BLOCK = '''        <p class="section-title">Conference Notice</p>
        <div class="registration-card">
            <p style="font-size:14.5pt; line-height:1.7; margin-bottom:8px;">
                The official conference notice for IEEE RCAR 2026 is available for download.
            </p>
            <a class="registration-button" href="./NOTICE.pdf" download>Download Conference Notice</a>
        </div>'''

def insert_notice_block(text: str, path: str) -> str:
    # If the section already exists, replace it instead of inserting another copy.
    start_marker = '<p class="section-title">Conference Notice</p>'
    end_marker = '<p class="section-title">Registration Fees</p>'

    start = text.find(start_marker)
    end = text.find(end_marker)

    if end == -1:
        raise RuntimeError(f"{path}: could not find Registration Fees section.")

    if start != -1 and start < end:
        return text[:start] + NOTICE_BLOCK.rstrip() + "\n\n        " + text[end:]

    return text[:end] + NOTICE_BLOCK.rstrip() + "\n\n        " + text[end:]

def patch(path: str) -> bool:
    p = Path(path)
    if not p.exists():
        return False

    text = p.read_text(encoding="utf-8")
    text = insert_notice_block(text, path)
    p.write_text(text, encoding="utf-8")
    return True

changed = []
for path in ["registration.html", "update_registration_dates_schedule.sh"]:
    if patch(path):
        changed.append(path)

print("Patched:", ", ".join(changed))
PY

echo
echo "Backup saved to: $backup_dir"
echo "NOTICE.pdf download URL should be:"
echo "https://rcar2026.org/NOTICE.pdf"
echo
echo "Registration page:"
echo "https://rcar2026.org/registration.html"

if command -v git >/dev/null 2>&1; then
  echo
  echo "Git diff:"
  git diff -- registration.html update_registration_dates_schedule.sh || true
fi

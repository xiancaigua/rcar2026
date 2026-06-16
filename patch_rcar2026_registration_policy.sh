#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.}"
cd "$ROOT"

if [ ! -f "registration.html" ]; then
  echo "ERROR: registration.html not found. Run this script in the RCAR 2026 website root directory, or pass the website root as the first argument." >&2
  exit 1
fi

ts="$(date +%Y%m%d_%H%M%S)"
backup_dir="backup_registration_policy_${ts}"
mkdir -p "$backup_dir"

cp -p "registration.html" "$backup_dir/registration.html"
if [ -f "update_registration_dates_schedule.sh" ]; then
  cp -p "update_registration_dates_schedule.sh" "$backup_dir/update_registration_dates_schedule.sh"
fi

python3 <<'PY'
from pathlib import Path
import sys

CSS_MARKER = '        .registration-table th { background: #e7f3f6; color: #27445c; font-weight: bold; border: 1px solid #bfd4dc; padding: 11px; text-align: left; }\n'
CSS_ADD = '        .table-subnote { display: block; margin-top: 4px; font-size: 11.5pt; font-weight: normal; color: #4c6772; }\n'

FEES_BLOCK = '''        <p class="section-title">Registration Fees</p>
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
        </div>'''

CHARGES_BLOCK = '''        <p class="section-title">Additional Charges</p>
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
        </div>'''

def replace_between(text, start_marker, end_marker, new_block, path):
    start = text.find(start_marker)
    if start == -1:
        raise RuntimeError(f"{path}: start marker not found: {start_marker}")
    end = text.find(end_marker, start + len(start_marker))
    if end == -1:
        raise RuntimeError(f"{path}: end marker not found: {end_marker}")
    return text[:start] + new_block.rstrip() + "\n\n" + text[end:]

def ensure_css(text, path):
    if ".table-subnote" not in text:
        if CSS_MARKER in text:
            text = text.replace(CSS_MARKER, CSS_MARKER + CSS_ADD, 1)
        else:
            print(f"WARN: {path}: CSS marker not found; table-subnote class was not inserted.", file=sys.stderr)
    return text

def patch(path):
    p = Path(path)
    if not p.exists():
        return False

    text = p.read_text(encoding="utf-8")
    text = ensure_css(text, path)

    text = replace_between(
        text,
        '<p class="section-title">Registration Fees</p>',
        '<p class="section-title">Additional Charges</p>',
        FEES_BLOCK,
        path
    )

    text = replace_between(
        text,
        '<p class="section-title">Additional Charges</p>',
        '<p class="section-title">Notes</p>',
        CHARGES_BLOCK,
        path
    )

    p.write_text(text, encoding="utf-8")
    return True

changed = []
for path in ("registration.html", "update_registration_dates_schedule.sh"):
    if patch(path):
        changed.append(path)

print("Patched: " + ", ".join(changed))
PY

echo "Backup saved to: ${backup_dir}"

if command -v git >/dev/null 2>&1; then
  echo
  echo "Git diff:"
  git diff -- registration.html update_registration_dates_schedule.sh || true
fi

#!/usr/bin/env python3
"""Validate an exported workshop layout and add it to the calendar catalog."""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('layout', type=Path)
parser.add_argument('--check-only', action='store_true')
parser.add_argument('--replace', action='store_true', help='Explicitly replace an existing day; creates .bak files.')
args = parser.parse_args()
project = Path(__file__).resolve().parents[1]
source = args.layout.expanduser().resolve()
godot = os.environ.get('GODOT_BIN', '/Applications/Godot.app/Contents/MacOS/Godot')
with tempfile.TemporaryDirectory(prefix='yearbound-layout-') as scratch:
    subprocess.run([godot, '--headless', '--path', str(project), '--editor', '--import', '--quit', '--log-file', str(Path(scratch)/'import.log')], check=True)
    completed = subprocess.run([godot, '--headless', '--path', str(project), '--log-file', str(Path(scratch)/'check.log'), '--script', 'tools/check_layout.gd', '--', str(source)])
    if completed.returncode:
        raise SystemExit('Layout was not installed: validation failed.')
if args.check_only:
    raise SystemExit(0)
stage = json.loads(source.read_text())
target = project/'content'/'stages'/f"{stage['id']}.json"
catalog_path = project/'content'/'catalog.json'
if target.exists() and not args.replace:
    raise SystemExit(f"{stage['id']} already exists. Choose a different date, or explicitly use --replace.")
catalog = json.loads(catalog_path.read_text())
if stage['id'] not in catalog['stages']:
    catalog['stages'].append(stage['id'])
# Featured remains the six reference days; every catalog date appears in the calendar.
def atomic_write(path, value):
    tmp = path.with_suffix(path.suffix+'.tmp')
    tmp.write_text(json.dumps(value, indent=2)+'\n')
    if path.exists():
        shutil.copy2(path, str(path)+'.bak')
    os.replace(tmp, path)
atomic_write(target, stage)
atomic_write(catalog_path, catalog)
print(f"Installed {stage['id']} — {stage['title']}. Rebuild the app to include this day.")

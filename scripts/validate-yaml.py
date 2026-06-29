#!/usr/bin/env python3
from pathlib import Path
import sys, yaml

ok = True
for path in list(Path('manifests').rglob('*.yaml')) + list(Path('platform').rglob('*.yaml')) + list(Path('gitops').rglob('*.yaml')):
    try:
        docs = list(yaml.safe_load_all(path.read_text()))
        print(f"OK {path} ({len([d for d in docs if d])} docs)")
    except Exception as e:
        ok = False
        print(f"FAIL {path}: {e}", file=sys.stderr)
if not ok:
    sys.exit(1)

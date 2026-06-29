#!/usr/bin/env python3
import json
import sys
from pathlib import Path

if len(sys.argv) != 2:
    print("Usage: render_inventory.py terraform-output.json", file=sys.stderr)
    sys.exit(1)

data = json.loads(Path(sys.argv[1]).read_text())
inv = data["node_inventory"]["value"]
cp = inv["control_plane"]
workers = inv["workers"]

print("[server]")
print(f'{cp["name"]} ansible_host={cp["public_ip"]} private_ip={cp["private_ip"]}')
print()
print("[agents]")
for w in workers:
    print(f'{w["name"]} ansible_host={w["public_ip"]} private_ip={w["private_ip"]}')
print()
print("[k3s_cluster:children]")
print("server")
print("agents")

#!/usr/bin/env python3
"""Compile explicit per-day room blueprints into normal game/editor stage JSON.

No seeded geometry, shared room recipes, stretching or automatic spike filling.
Each blueprint contains the complete authored blocks, hazards and route checks.
"""
from pathlib import Path
import argparse
import copy
import json

ROOT = Path(__file__).resolve().parents[1]
FIELDS = ("platforms", "hazards", "zones", "motes", "checkpoints", "decorations", "signs")

def compile_day(layout, current):
    stage = copy.deepcopy(current)
    for field in FIELDS:
        stage[field] = []
    route, rooms = [], []
    for section in layout["sections"]:
        ox, oy = section["origin"]
        for field in FIELDS:
            for original in section[field]:
                item = copy.deepcopy(original)
                if isinstance(item, list):
                    item[0] += ox; item[1] += oy
                else:
                    item["x"] += ox; item["y"] += oy
                    if "floor_y" in item: item["floor_y"] += oy
                if field == "platforms" and item["kind"] == "crumble":
                    for x in range(0, item["w"], 48):
                        tile = copy.deepcopy(item); tile["x"] += x; tile["w"] = 48
                        stage[field].append(tile)
                else:
                    stage[field].append(item)
        start = len(route)
        for original in section["route"]:
            item = copy.deepcopy(original)
            item["at"][0] += ox; item["at"][1] += oy
            item["room"] = len(rooms)
            for key in ("gate_x", "shaft_x"):
                if key in item: item[key] += ox
            route.append(item)
        rooms.append({"name": section["name"], "lesson": section["lesson"],
                      "from_x": ox, "to_x": ox + section["width"],
                      "start": route[start]["at"], "end": route[-1]["at"]})
    stage.update({key: layout[key] for key in ("length", "spawn", "goal", "world_top")})
    stage["abilities"] = ["charge_dash"]
    if layout.get("journey"):
        stage["journey_regions"] = [{"name": room["name"], "x":room["origin"][0], "y":room["origin"][1], "w":room["width"], **room["visual"]} for room in layout["sections"]]
        stage["secret_areas"] = layout.get("secret_areas", [])
    if "scenery" in layout:
        stage["scenery"] = copy.deepcopy(layout["scenery"])
    stage["editor_version"] = 2
    stage["layout_revision"] = layout.get("revision", 13)
    stage["description"] = layout["intent"]
    stage["design"] = {"identity": layout["identity"], "blueprint": f"res://content/layouts/{stage['id']}.json",
                       "intent": layout["intent"], "opening": rooms[0]["lesson"]}
    if "boss" in stage and "phases" not in stage["boss"]:
        stage["boss"]["arena_x"] = layout["sections"][-1]["origin"][0]
        # The final arena remains the familiar 1280 px-wide survival fight.
        stage["length"] = stage["boss"]["arena_x"] + 1296
        stage["goal"] = [stage["length"] - 96, 624]
    spikes = [h for h in stage["hazards"] if h["type"] == "bramble"]
    previous = current.get("challenge", {})
    stage["challenge"] = {"revision": 2, "original_length": previous.get("original_length", current["length"]),
                          "extension_start": 0, "rooms": rooms, "route": route,
                          "spike_placements": len(spikes), "visible_spikes": sum(int((h["h"] if h["direction"] in ("left", "right") else h["w"]) / 12) for h in spikes),
                          "vertical_travel": max(p["at"][1] for p in route) - min(p["at"][1] for p in route),
                          "intent": layout["intent"]}
    return stage

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("days", nargs="*", help="Dates to compile; omit for all authored days.")
    parser.add_argument("--write", action="store_true", help="Write compiled stages. Default is a dry run.")
    parser.add_argument("--check", action="store_true", help="Fail if compiled stage JSON or the report is stale.")
    args = parser.parse_args()
    if args.check and args.write: parser.error("Choose --check or --write, not both.")
    available = {p.stem for p in (ROOT / "content/layouts").glob("*.json")}
    if set(args.days) - available: parser.error("Unknown blueprint dates: " + ", ".join(sorted(set(args.days) - available)))
    report = []
    for path in sorted((ROOT / "content/layouts").glob("*.json")):
        if args.days and path.stem not in args.days: continue
        target = ROOT / "content/stages" / path.name
        current = json.loads(target.read_text())
        stage = compile_day(json.loads(path.read_text()), current)
        if args.check and stage != current: parser.error(f"{path.stem} has uncompiled blueprint changes")
        if args.write: target.write_text(json.dumps(stage, indent=2, ensure_ascii=False) + "\n")
        c = stage["challenge"]
        report.append({"id": stage["id"], "identity": stage["design"]["identity"], "length": stage["length"],
                       "spike_placements": c["spike_placements"], "vertical_travel": c["vertical_travel"],
                       "sections": len(c["rooms"]), "actions": sorted(set(p["action"] for p in c["route"]))})
    if args.write and not args.days:
        (ROOT / "content/challenge_report.json").write_text(json.dumps(report, indent=2) + "\n")
    if args.check and not args.days and report != json.loads((ROOT / "content/challenge_report.json").read_text()):
        parser.error("The challenge report is stale; compile all blueprints with --write")
    for item in report: print(json.dumps(item))

if __name__ == "__main__": main()

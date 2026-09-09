# Layout workshop · 0.14.0

Open **Yearbound.app → Layout workshop** on the title screen. The editor is built into the desktop game; you do not need Godot or any coding tools. Its first launch opens a small editable block garden. **New** gives you an empty day with a flat block floor. **Copy a sample day…** opens an editable copy of any of the 41 playable stages.

## Make a layout

1. Choose a terrain brush and drag across the grid. Every terrain unit is **48 × 48 pixels**. A normal held jump rises a little over two blocks.
2. Use **Rectangle** for platforms, walls, large areas or environmental zones. **Right-drag** erases; the eraser also works in rectangle mode. Erase both floor rows to create a pit.
3. Place **Start**, **Exit** and **Lantern** markers in empty cells directly above stable terrain. Sunmotes are optional. Use the Spikes arrow to choose floor, wall or ceiling teeth; their visible half-cell is dangerous.
4. Set the title, month/day, seasonal appearance, length and music sketch at the top. Dates cover the full June–May year. Changing the date does not force a theme; future days can have their own combinations.
5. Set **Charge dash: On/Off** for the layout. New days and the starter enable it. Playtest uses your current Dash Lab tuning, including the original default profile with horizontal multiplier 1.5, and the same rebindable game controls. Select **Height** to add room for climbs.
6. Click **Playtest**, or press **F5**. The layout runs with the actual player controller, collisions, hazards and checkpoints. **Esc/F5** or the on-screen Editor button returns to the same editable layout. **R** retries at a test checkpoint; **P** pauses. Reaching the exit shows a test completion screen.
7. Choose **Save layout…**, select a folder and save the `.yearbound.json` file. Send that file back when you want the layout incorporated into Yearbound as a day.

Playtesting does not overwrite campaign saves, completion records or the campaign checkpoint. Exporting a layout does not replace a built-in day. You can open the exported JSON in the workshop and continue editing it later.

## Controls

| Action | Control |
|---|---|
| Paint | Left-drag |
| Erase | Right-drag, or Eraser brush |
| Brush / rectangle | B / G |
| Pan | Space + left-drag, or middle-drag |
| Move sideways | Scroll, left/right arrows, or click the overview |
| Move vertically | Shift + scroll, up/down arrows, Space-drag, or click vertically in the overview |
| Set vertical space | Height menu: 15, 31, 47, 63 or 79 rows |
| Enable dash | Charge dash: On/Off above the canvas |
| Spike direction | Spikes arrow beside Current: up/right/down/left |
| Zoom | − / + buttons, or Command/Ctrl + scroll |
| Reset view | Fit |
| Undo / redo | Command/Ctrl Z / Shift Z; toolbar; Ctrl Y |
| Save current export | Command/Ctrl S |
| Save as | Save layout… or Command/Ctrl Shift S |
| Open | Command/Ctrl O |
| Playtest / return | F5; Esc returns from a test |

The editor is designed for mouse and keyboard. The game itself retains keyboard and controller input.

## Brushes and scope

Grass, stone, timber, hay, logs, ice, springs and crumbling blocks all use the same square grid. Horizontal and vertical lift brushes travel two blocks from their authored positions. Adjacent lift cells with identical settings move as a group. Crumble cells fall independently.

Trees and flowers are background decoration. The canvas shows simple placement symbols for these props; playtesting renders the full seasonal art. Wind pushes right, updrafts lift upward, and currents carry the player downstream. Paint these zones in the air above the terrain; rectangle mode creates larger regions. The grid is an editing guide, not an overlay during play.

Copies of sample stages preserve their existing moving hazards, signs, boss patterns, music and decorations. The first editor does not expose custom boss-pattern scripting, a sign-text inspector, arbitrary force or lift tuning, custom image/audio imports, or moving-hazard creation. Those remain available through the JSON/source pipeline. All 41 installed music tracks and six seasonal palettes can be selected in the UI. Map-specific atlas references, individual room cells, atmosphere and specialized props survive copying, editing and export; view the finished scenery in Playtest. New blank days choose the next unfinished date, currently 1 July. See JUNE_02_08.md and JUNE_09_17.md for the June designs.

Layouts span 27–2048 columns and 15–79 rows. Extra height grows upward from the existing floor (negative world Y), and the game camera follows climbs and descents. Shrinking height refuses to discard content. The overview shows the full route and current viewport in both dimensions. Extending a day continues a grass floor when there is one at its end. Shortening trims that floor and moves the exit, but refuses to discard other out-of-bounds content; erase or relocate those objects first. The editor checks marker support and collisions before playtesting. It does not prove every jump is reachable or balance a stage automatically.

## Drafts and sharing

**Open layouts folder** opens the local workshop folder. The active draft is saved there automatically, separate from campaign progress. Starting a new layout, copying a sample or opening another file archives the previous draft with a timestamp. The last draft is recovered when the workshop is reopened after restarting the app. Writes use a temporary file and retain a `.bak` copy when replacing a file.

Draft storage on macOS is inside `~/Library/Application Support/Godot/app_userdata/Yearbound/layouts/`. Use **Save layout…** to choose an easy-to-find export location such as Documents. The exported JSON includes the date, title, theme, music reference, geometry, markers, hazards and decorations. There are no extra editor-only binary files to send.

## Incorporating a day in the source project

The export is the game's stage format. Its `grid_size` is 48 and `editor_version` is 1. Contiguous equivalent cells are grouped into collision rectangles for efficiency; their dimensions remain whole numbers of square blocks. Drawing is clipped to the visible portion of long terrain runs. Crumble cells keep independent collision bodies.

From the editable Yearbound source folder:

```sh
python3 tools/install_layout.py /absolute/path/to/06-18-my-day.yearbound.json --check-only
python3 tools/install_layout.py /absolute/path/to/06-18-my-day.yearbound.json
python3 tools/validate_content.py
python3 tools/build_macos.py
```

The installer uses the same structural and playable-marker validation as the editor, copies the file to `content/stages/MM-DD.json`, and adds the date to `content/catalog.json`. It preserves the monthly featured shortcuts; the added day becomes available on the calendar. Existing dates require an explicit `--replace`, which creates backup files. The Mac tool defaults to `/Applications/Godot.app/Contents/MacOS/Godot`; set `GODOT_BIN` for another installed executable.

Install into the source project, then rebuild the app. This is also the process to use when a layout is sent back for incorporation and further decoration, music or gameplay tuning.

## The rebuilt sample layouts

All 41 rebuilt samples can be copied and playtested. Their authored platform tracks, timed lightning, local falling ice and underwater checkpoints survive save/open and compilation. Detailed track paths and hazard timing remain JSON settings. Blank layouts start without another day’s design annotations. See [AUTHORED_DAYS.md](AUTHORED_DAYS.md) before recompiling a day whose baked layout you have edited in the workshop.

The five-place June environments, optional-area vine covers and five-arena boss survive sample copying and export. Their detailed parameters are edited in JSON. See [JUNE_CHAPTER.md](JUNE_CHAPTER.md).

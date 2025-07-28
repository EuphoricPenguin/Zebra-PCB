<div align="center">
  <img src="asset/icon.png" width="150" alt="ZebraBV Logo"/>
  <h1>ZebraBV</h1>
</div>

ZebraBV, based on OpenBoardView, is a fork of a fork that adds UX enhancements and support for building to Windows via MSYS2. ZebraBV is directly based on a fork by slimeinacloak that adds support for XZZ's .pcb file format. ZebraBV is developed chiefly using DeepSeek and should not be considered stable software.

### Features

- Annotations (per board database file)
- Part and pin sizes better represented
- Better outlining of irregular objects (such as connectors)
- Drag and drop
- Recently used file history
- Non-orthagonally orientated caps/resistors/diodes now drawn more realistically
- Adjustable DPI (for working on 2K/4K screens)
- Works with multiple concurrent instances

### Prerequisites

#### Windows

`pacman -sY`

`pacman [insert deps here]`

`./build.sh`

### Usage

- Ctrl-O: Open file select dialog

- w/a/s/d: pan viewport over board
- x: Reset zoom and center
- Mouse scroll, -/=: Zoom out/in
- Mouse click-hold-drag, Numeric pad up/down/left/right: pan viewport over board
- Numeric pad +/-: zoom board
- Numeric pad 5: Reset zoom and center
- Space, Middle mouse click: Flip board
- R/./Numpad-Del: Rotate clockwise
- ,/Numpad-Ins: Rotate counter-clockwise

- /, Ctrl-F: Search
- ESC: Clear search results and selected parts

- p: Toggle pin display
- m: Mirror board across Y-axis

- L: Show net list
- K: Show part list

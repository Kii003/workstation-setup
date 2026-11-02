# Hammerspoon

[Hammerspoon](https://www.hammerspoon.org) automates macOS with Lua — hotkeys, window layouts, reacting to Wi-Fi/USB/microphone events, and so on.

Put your `init.lua` in this folder. `setup.sh` then links it to `~/.hammerspoon/init.lua`, and `scripts/snapshot.sh` copies it back here if you edited it in place.

After the first launch: System Settings → Privacy & Security → Accessibility → allow Hammerspoon.

Example ideas:
- Pause music automatically while your microphone is in use (calls)
- Hotkey to arrange your editor, terminal and browser side by side
- Switch audio output when headphones connect

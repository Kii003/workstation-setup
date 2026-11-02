# AutoHotkey

[AutoHotkey v2](https://www.autohotkey.com) automates Windows: hotkeys, text expansion, window tricks. It's the Windows counterpart to Hammerspoon on macOS.

Put your script here as `main.ahk`. `setup.ps1` links it into your Startup folder so it runs at sign-in, and `scripts/snapshot.ps1` copies it back here if you edited it in place.

Example `main.ahk`:

```ahk
#Requires AutoHotkey v2.0
; Ctrl+Alt+T: open Windows Terminal
^!t::Run "wt.exe"
; Type ;mail to insert your email address
::;mail::you@example.com
```

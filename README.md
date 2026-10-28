# Canvas Stickers

**One keystroke, one sticker.** Map your own SVG stickers to keyboard shortcuts and paste them onto browser-based canvas apps that accept SVG, such as FigJam, tldraw and Excalidraw, without leaving the keyboard to dig through a menu or a library.

It ships with eight starter stickers on `Shift + Alt + numpad` keys. Originally built for FigJam on Windows, which is where it's most tested.

## What it does

Reviewing a board, running a retro or marking up a flow means placing the same few markers again and again. This is a small [AutoHotkey v2](https://www.autohotkey.com/) script that maps keyboard shortcuts to SVG files and pastes them into the canvas you're looking at. The starter set:

| Shortcut | Sticker |
|---|---|
| Shift + Alt + Numpad 1 | ✅ Green check |
| Shift + Alt + Numpad 2 | ❌ Red X |
| Shift + Alt + Numpad 3 | ⚠️ Yellow warning |
| Shift + Alt + Numpad 4 | ➡️ Arrow right |
| Shift + Alt + Numpad 5 | ⬅️ Arrow left |
| Shift + Alt + Numpad 6 | ⬇️ Arrow down |
| Shift + Alt + Numpad 7 | ↔️ Arrow both ways |
| Shift + Alt + Numpad 8 | ⭐ Gold star |

- **Bring your own stickers.** Drop any SVG into `svg\` and map it to a key with one line (see [Customizing](#customizing)).
- **Vectors, not screenshots.** In FigJam the stickers arrive as vector shapes: crisp at any zoom, transparent background, and no white "image border" card.
- **Your clipboard is preserved.** Whatever you had copied is put back about two seconds after each paste.
- **Only where you want it.** The keys do nothing outside a browser, and they beep without pasting in tabs whose title doesn't match your list (FigJam, Figma, tldraw, Excalidraw by default).
- **Works with NumLock on or off.**

## Where it works

| App | Result | Status |
|---|---|---|
| FigJam (browser) | Vector shapes, transparent, no border | Tested |
| tldraw | Transparent image | Tested |
| Excalidraw | Transparent image | Tested |
| Figma Design (browser) | Should behave like FigJam | Not yet tested |
| Other canvas apps | Works if the app accepts pasted SVG; otherwise switch to PNG mode (see [Settings](#settings)) | Try it |

Tested on Windows 10 with Chrome and AutoHotkey 2.0.31. Edge, Firefox and Brave are enabled in the script but untested. The Figma desktop app is not supported out of the box (see [Customizing](#customizing)).

## Requirements

- Windows 10 or 11
- [AutoHotkey **v2**](https://www.autohotkey.com/) (not v1)
- Chrome, Edge, Firefox or Brave
- A keyboard with a numeric keypad (or remap the keys, see [Customizing](#customizing))

## Install

1. **Install AutoHotkey v2.** Download it from [autohotkey.com](https://www.autohotkey.com/), or run:

   ```
   winget install --id AutoHotkey.AutoHotkey --exact --scope user
   ```

2. **Download this repository** (Code → Download ZIP) and extract it to a permanent folder, for example `C:\Tools\canvas-stickers`. Keep the folder structure: the script looks for `svg\` and `png\` next to itself.
3. **Double-click `canvas-stickers.ahk`.** A green **H** appears in the system tray.
4. **Optional: start it with Windows.** Press `Win + R`, type `shell:startup`, and put a shortcut to `canvas-stickers.ahk` in that folder.

## Use

1. Open a board in your browser.
2. Click an empty spot on the canvas so you're not typing in a text box.
3. Press `Shift + Alt + Numpad 1`.

The sticker is pasted in the middle of your view, the same place a normal `Ctrl + V` lands. Drag it where you want it.

## Settings

Open `canvas-stickers.ahk` in a text editor. The settings are at the top:

```ahk
AllowedTitles := ["FigJam", "Figma", "tldraw", "Excalidraw"]
PasteFormat := "svg"
ClipboardRestoreDelay := 1800
```

- **`AllowedTitles`**: the hotkeys only fire when the browser tab's title contains one of these words. Add your board's name or another app.
- **`PasteFormat`**: `"svg"` (default) pastes vector markup. Use `"png"` for apps that paste SVG as text: it pastes a 192 × 192 transparent PNG instead, using the included PowerShell helper.
- **`ClipboardRestoreDelay`**: milliseconds to wait before restoring your clipboard. Raise it if pastes fail now and then.

Save the file, then right-click the tray **H** and choose **Reload Script**.

## Customizing

- **Change an icon's look.** Edit the file in `svg\` (and re-export `png\` at 160–256 px with a transparent background if you use PNG mode). Keep the same filename.
- **Add a sticker.** Put `my-icon.svg` (and `my-icon.png`) in the folders, then add a line inside the `#HotIf` block:

  ```ahk
  +!Numpad9::
  +!NumpadPgUp::PasteSticker("my-icon")
  ```

- **No numpad?** Replace the hotkeys with other keys, for example `^!1::PasteSticker("green-check")` for `Ctrl + Alt + 1`. Check that the combination isn't already taken by another tool such as PowerToys.
- **Another browser or the Figma desktop app.** Add its executable to the `#HotIf` line, for example `|| WinActive("ahk_exe Figma.exe")`.

## How it works

Each shortcut runs one function that:

1. checks the active window is a browser tab with an allowed title,
2. saves your clipboard,
3. puts the sticker on the clipboard (the SVG file's text, or in PNG mode both a PNG and a bitmap version),
4. waits for you to release Shift and Alt, then sends `Ctrl + V`,
5. restores your original clipboard.

Canvas apps like FigJam recognize SVG markup on the clipboard and convert it into shapes, which is why the stickers come in as vectors without the image border FigJam adds to pasted pictures.

## Troubleshooting

- **Nothing happens.** Check the green **H** is in the tray, the board tab is active, and its title contains a word from `AllowedTitles`. A short beep means the title didn't match.
- **The code appears as text.** That app doesn't accept pasted SVG. Set `PasteFormat := "png"`.
- **Pasted into a text box.** Press `Escape`, click an empty spot on the canvas, and try again.
- **"PowerShell helper failed" (PNG mode).** Run the helper yourself to see the error:

  ```
  powershell -NoProfile -STA -ExecutionPolicy Bypass -File .\set-sticker-clipboard.ps1 -ImagePath .\png\green-check.png
  ```

  The script uses `-ExecutionPolicy Bypass` for this one helper only. Don't change your machine-wide execution policy.

## On a Mac?

This script is Windows-only (AutoHotkey doesn't run on macOS), but the idea ports easily, because SVG mode only does two things: put an SVG file's text on the clipboard, then press paste. The `svg\` folder works as-is. Untested starting points:

- **[Hammerspoon](https://www.hammerspoon.org/)** (free): a few lines of Lua in `~/.hammerspoon/init.lua` per sticker:

  ```lua
  hs.hotkey.bind({"shift", "alt"}, "pad1", function()
    local saved = hs.pasteboard.getContents()
    local f = io.open(os.getenv("HOME") .. "/canvas-stickers/svg/green-check.svg")
    hs.pasteboard.setContents(f:read("*a")); f:close()
    hs.eventtap.keyStroke({"cmd"}, "v")
    hs.timer.doAfter(1.8, function() hs.pasteboard.setContents(saved) end)
  end)
  ```

  This restores text clipboards only, and doesn't check which app or tab is active.
- **Keyboard Maestro** or **BetterTouchTool** (paid): a macro with "Set clipboard to text from file" followed by "Type ⌘V".

Contributions of a tested Mac version are welcome.

## Limitations

- Stickers are pasted shapes or images, not FigJam's native stamps or connectors.
- The sticker lands in the middle of your view, not at the mouse. FigJam's right-click **Paste** places it at the cursor, but its menu changes when you right-click over an object, so it isn't reliable for a hotkey.
- While a paste is in progress, a copy of your previous clipboard is held in the script's memory. Avoid triggering it while you have sensitive data copied.

## Files

| Path | Purpose |
|---|---|
| `canvas-stickers.ahk` | The hotkeys and settings |
| `set-sticker-clipboard.ps1` | PNG mode helper: puts a PNG and a bitmap on the clipboard |
| `svg\` | Eight editable vector stickers (pasted in SVG mode) |
| `png\` | The same stickers as 192 × 192 transparent PNGs (pasted in PNG mode) |

## License

[MIT](LICENSE) © 2026 Gruntworks Agency. FigJam and Figma are trademarks of Figma, Inc.; this project is not affiliated with or endorsed by Figma.

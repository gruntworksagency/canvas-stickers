#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreadsPerHotkey 1

; Canvas Stickers
; Press Shift + Alt + a numpad key to paste an SVG sticker into the active canvas tab.
; Keep this script next to the svg and png folders (and set-sticker-clipboard.ps1 for PNG mode).

; ---------------------------------------------------------------------------
; Settings
; ---------------------------------------------------------------------------

; The hotkeys only work in browser tabs whose title contains one of these
; (case-insensitive). Add your own board names or other canvas apps here.
AllowedTitles := ["FigJam", "Figma", "tldraw", "Excalidraw"]

; "svg" pastes vector markup: FigJam/Figma turn it into vector shapes with a
; transparent background and no image border; tldraw and Excalidraw turn it into an image.
; "png" pastes a 192 x 192 transparent image, for apps that paste SVG as plain text.
PasteFormat := "svg"

; How long to wait after pasting before restoring your previous clipboard.
; If pastes fail intermittently, increase this to 2500-3500 ms.
ClipboardRestoreDelay := 1800

; ---------------------------------------------------------------------------
; Hotkeys
; ---------------------------------------------------------------------------

; With NumLock on, Windows turns Shift + Numpad1 into Shift + NumpadEnd and so on,
; so each sticker is bound to both forms of its key.
#HotIf WinActive("ahk_exe chrome.exe") || WinActive("ahk_exe msedge.exe") || WinActive("ahk_exe firefox.exe") || WinActive("ahk_exe brave.exe")
+!Numpad1::
+!NumpadEnd::PasteSticker("green-check")
+!Numpad2::
+!NumpadDown::PasteSticker("red-x")
+!Numpad3::
+!NumpadPgDn::PasteSticker("yellow-warning")
+!Numpad4::
+!NumpadLeft::PasteSticker("arrow-right")
+!Numpad5::
+!NumpadClear::PasteSticker("arrow-left")
+!Numpad6::
+!NumpadRight::PasteSticker("arrow-down")
+!Numpad7::
+!NumpadHome::PasteSticker("arrow-both")
+!Numpad8::
+!NumpadUp::PasteSticker("gold-star")
#HotIf

; ---------------------------------------------------------------------------

PasteSticker(stickerName) {
    ; Guard against pasting stickers in unrelated browser tabs.
    if !TitleAllowed(WinGetTitle("A")) {
        SoundBeep(700, 80)
        return
    }

    savedClipboard := ClipboardAll()
    try {
        A_Clipboard := ""
        if (PasteFormat = "png")
            SetPngClipboard(stickerName)
        else
            SetSvgClipboard(stickerName)

        ; Releasing the shortcut before simulated Ctrl+V avoids modifier conflicts
        ; (Ctrl+Shift+V would paste differently).
        KeyWait "Shift"
        KeyWait "Alt"
        SendEvent "^v"

        ; Give the browser time to consume clipboard data before restoring it.
        Sleep ClipboardRestoreDelay
    }
    catch as err {
        MsgBox "Sticker insertion failed:`n" err.Message
    }
    finally {
        A_Clipboard := savedClipboard
    }
}

TitleAllowed(windowTitle) {
    for title in AllowedTitles {
        if InStr(windowTitle, title)
            return true
    }
    return false
}

SetSvgClipboard(stickerName) {
    svgPath := A_ScriptDir "\svg\" stickerName ".svg"
    if !FileExist(svgPath)
        throw Error("Sticker file missing.`n" svgPath)
    A_Clipboard := FileRead(svgPath, "UTF-8")
    if !ClipWait(2)
        throw Error("No SVG appeared on the clipboard.")
}

SetPngClipboard(stickerName) {
    imagePath := A_ScriptDir "\png\" stickerName ".png"
    helperPath := A_ScriptDir "\set-sticker-clipboard.ps1"
    if !FileExist(imagePath) || !FileExist(helperPath)
        throw Error("Sticker file or PowerShell helper missing.`n" imagePath)
    command := 'powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -File "' helperPath '" -ImagePath "' imagePath '"'
    exitCode := RunWait(command, , "Hide")
    if (exitCode != 0)
        throw Error("PowerShell helper failed (exit code " exitCode ").")
    if !ClipWait(2, 1)
        throw Error("No image appeared on the clipboard.")
}

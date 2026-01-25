;@Ahk2Exe-SetName ClipType
;@Ahk2Exe-SetDescription ClipType - Professional Clipboard Injector
;@Ahk2Exe-SetVersion 1.0.0
;@Ahk2Exe-SetCopyright Copyright (c) 2026 Ahmed Samy
;@Ahk2Exe-SetCompanyName Ahmed Samy
;@Ahk2Exe-SetOrigFilename ClipType.exe
#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon
Persistent

; ==============================================================================
;  ClipType - Professional Clipboard Injector
;  Version: 3.2.0 (Line Ending Fix)
;  License: MIT
;  Author: Ahmed Samy
; ==============================================================================

; --- Auto-Elevate to Admin ---
if (!A_IsAdmin) {
    try {
        Run("*RunAs `"" . A_ScriptFullPath . "`"")
    } catch {
        MsgBox("Failed to run as Administrator. Some features may not work.", "ClipType", 16)
    }
    ExitApp()
}

; --- Global Variables ---
Global AppName := "ClipType"
Global Version := "1.0"
Global IniFile := A_ScriptDir . "\settings.ini"
Global StopTyping := False
Global IsPaused := False

; --- Settings Variables ---
Global CurrentLang := "EN"
Global TypingDelay := 50
Global UserHotkey := "^+v"
Global AutoStart := 0
Global PlaySounds := 1
Global TrimSpaces := 0

; --- GUI Control Variables ---
Global MyGui := ""
Global Ctrl_Delay := ""
Global Ctrl_Hotkey := ""
Global Ctrl_Start := ""
Global Ctrl_Sound := ""
Global Ctrl_Trim := ""

; --- Main Execution ---
try {
    LoadSettings()
    Global Lang := Map()
    SetupLanguage()
    InitTrayMenu()
    UpdateHotkey(UserHotkey, False)
} catch as err {
    MsgBox("Critical Startup Error:`n" . err.Message, "ClipType Error", 16)
    ExitApp()
}

; ==============================================================================
;  Core Logic
; ==============================================================================

InjectClipboard(hk := "") {
    Global StopTyping
    
    if (hk = "Tray") {
        if (PlaySounds) {
            SoundBeep(750, 100)
            Sleep(500)
            SoundBeep(750, 100)
        }
        Sleep(2000)
    }

    if (IsPaused) {
        if (PlaySounds) {
            SoundBeep(200, 150)
        }
        return
    }

    ClipContent := A_Clipboard
    if (ClipContent = "") {
        if (PlaySounds) {
            SoundBeep(500, 150)
        }
        return
    }

    ; --- Feature: Trim Whitespace ---
    if (TrimSpaces) {
        ClipContent := Trim(ClipContent, " `t`r`n")
    }

    ; --- FIX: Normalize Line Endings ---
    ; Windows uses CRLF (`r`n). Loop Parse treats `r` as a char and `n` as a char.
    ; This causes double Enter presses. We replace CRLF with just LF (`n).
    ClipContent := StrReplace(ClipContent, "`r`n", "`n")

    if (PlaySounds) {
        SoundBeep(1000, 100)
    }

    StopTyping := False
    
    Loop Parse, ClipContent {
        if (StopTyping) {
            if (PlaySounds) {
                SoundBeep(300, 300)
            }
            break
        }
        
        SendEvent("{Raw}" . A_LoopField)
        Sleep(TypingDelay)
    }

    if (!StopTyping and PlaySounds) {
        SoundBeep(1500, 100)
    }
}

#HotIf !StopTyping
~Esc:: {
    Global StopTyping := True
}
#HotIf

; ==============================================================================
;  GUI Logic
; ==============================================================================

ShowGui(*) {
    Global MyGui, Ctrl_Delay, Ctrl_Hotkey, Ctrl_Start, Ctrl_Sound, Ctrl_Trim
    
    try {
        MyGui.Destroy()
    }

    MyGui := Gui(, AppName . " - Settings")
    MyGui.Opt("+AlwaysOnTop")
    MyGui.SetFont("s10", "Segoe UI")

    ; Language
    MyGui.Add("GroupBox", "w300 h60 Section", Lang["Gui_Lang"])
    RadioEn := MyGui.Add("Radio", "xs+10 ys+25 Group", "English")
    RadioAr := MyGui.Add("Radio", "x+20 yp", "العربية")
    
    if (CurrentLang = "AR") {
        RadioAr.Value := 1
    } else {
        RadioEn.Value := 1
    }
        
    RadioEn.OnEvent("Click", (*) => ChangeLang("EN"))
    RadioAr.OnEvent("Click", (*) => ChangeLang("AR"))

    ; Delay (Edit + UpDown)
    MyGui.Add("Text", "xm y+20", Lang["Gui_Delay"])
    Ctrl_Delay := MyGui.Add("Edit", "w300 Number", TypingDelay)
    MyGui.Add("UpDown", "Range0-1000", TypingDelay)

    ; Hotkey
    MyGui.Add("Text", "xm y+20", Lang["Gui_Hotkey"])
    Ctrl_Hotkey := MyGui.Add("Hotkey", "w300", UserHotkey)

    ; Checkboxes
    Ctrl_Trim := MyGui.Add("Checkbox", "xm y+20", Lang["Gui_Trim"])
    Ctrl_Trim.Value := TrimSpaces

    Ctrl_Start := MyGui.Add("Checkbox", "xm y+20", Lang["Gui_Startup"])
    Ctrl_Start.Value := AutoStart
    
    Ctrl_Sound := MyGui.Add("Checkbox", "x+20 yp", Lang["Gui_Sound"])
    Ctrl_Sound.Value := PlaySounds

    ; Buttons
    BtnSave := MyGui.Add("Button", "w100 xm+50 y+30 Default", Lang["Btn_Save"])
    BtnSave.OnEvent("Click", SaveAndClose)
    
    BtnCancel := MyGui.Add("Button", "w100 x+20 yp", Lang["Btn_Cancel"])
    BtnCancel.OnEvent("Click", (*) => MyGui.Destroy())

    MyGui.Show()
}

SaveAndClose(*) {
    Global TypingDelay, PlaySounds, UserHotkey, AutoStart, TrimSpaces
    Global Ctrl_Delay, Ctrl_Hotkey, Ctrl_Start, Ctrl_Sound, Ctrl_Trim, MyGui

    SavedDelay := Ctrl_Delay.Value
    SavedHk := Ctrl_Hotkey.Value
    SavedStart := Ctrl_Start.Value
    SavedSound := Ctrl_Sound.Value
    SavedTrim := Ctrl_Trim.Value

    if (SavedHk = "") {
        MsgBox(Lang["Msg_InvalidHk"], "Error", 16)
        return
    }

    ; Save Settings
    IniWrite(CurrentLang, IniFile, "Settings", "Language")
    IniWrite(SavedDelay, IniFile, "Settings", "Delay")
    IniWrite(SavedHk, IniFile, "Settings", "Hotkey")
    IniWrite(SavedStart, IniFile, "Settings", "AutoStart")
    IniWrite(SavedSound, IniFile, "Settings", "Sounds")
    IniWrite(SavedTrim, IniFile, "Settings", "TrimSpaces")

    ; Update Globals
    TypingDelay := SavedDelay
    PlaySounds := SavedSound
    TrimSpaces := SavedTrim
    
    if (UpdateHotkey(SavedHk, True)) {
        ManageStartup(SavedStart)
        MyGui.Destroy()
        if (PlaySounds) {
            SoundBeep(1200, 100)
        }
    }
}

ChangeLang(NewLang) {
    Global CurrentLang := NewLang
    IniWrite(CurrentLang, IniFile, "Settings", "Language")
    SetupLanguage()
    InitTrayMenu()
    ShowGui()
}

TogglePause(*) {
    Global IsPaused := !IsPaused
    InitTrayMenu()
}

; ==============================================================================
;  Helpers
; ==============================================================================

InitTrayMenu() {
    Tray := A_TrayMenu
    Tray.Delete()
    
    StatusIcon := IsPaused ? "Shell32.dll" : "Shell32.dll"
    IconNum := IsPaused ? 110 : 2
    
    StatusText := IsPaused ? Lang["Status_Paused"] : Lang["Status_Ready"]
    A_IconTip := AppName . " (" . StatusText . ")"
    
    if (!A_IsCompiled) {
        TraySetIcon(StatusIcon, IconNum)
    }

    A_IconHidden := False 

    Tray.Add(Lang["Tray_TypeNow"], (*) => InjectClipboard("Tray"))
    Tray.Add()
    Tray.Add(Lang["Tray_Settings"], ShowGui)
    Tray.Add(Lang["Tray_Pause"], TogglePause)
    
    if (IsPaused) {
        Tray.Check(Lang["Tray_Pause"])
    } else {
        Tray.Uncheck(Lang["Tray_Pause"])
    }

    Tray.Add(Lang["Tray_Exit"], (*) => ExitApp())
    Tray.Default := Lang["Tray_Settings"]
    Tray.ClickCount := 1
}

UpdateHotkey(NewHk, ShowError := True) {
    try {
        if (UserHotkey != "" and UserHotkey != NewHk) {
            try {
                Hotkey(UserHotkey, "Off")
            }
        }
        
        Hotkey(NewHk, InjectClipboard, "On")
        Global UserHotkey := NewHk
        return True
    } catch {
        if (ShowError) {
            if (PlaySounds) {
                SoundBeep(200, 300)
            }
            MsgBox(Lang["Msg_HkFail"] . "`n(" . NewHk . ")", "Hotkey Error", 16)
            if (!WinExist(AppName . " - Settings")) {
                ShowGui()
            }
        }
        return False
    }
}

ManageStartup(ShouldStart) {
    ShortcutPath := A_Startup . "\" . AppName . ".lnk"
    if (ShouldStart) {
        if (!FileExist(ShortcutPath)) {
            FileCreateShortcut(A_ScriptFullPath, ShortcutPath)
        }
    } else {
        if (FileExist(ShortcutPath)) {
            FileDelete(ShortcutPath)
        }
    }
}

LoadSettings() {
    Global
    CurrentLang := IniRead(IniFile, "Settings", "Language", "EN")
    TypingDelay := IniRead(IniFile, "Settings", "Delay", 50)
    UserHotkey := IniRead(IniFile, "Settings", "Hotkey", "^+v")
    AutoStart := IniRead(IniFile, "Settings", "AutoStart", 0)
    PlaySounds := IniRead(IniFile, "Settings", "Sounds", 1)
    TrimSpaces := IniRead(IniFile, "Settings", "TrimSpaces", 0)
}

SetupLanguage() {
    if (CurrentLang = "AR") {
        Lang["Tray_TypeNow"] := "كتابة الحافظة الآن"
        Lang["Tray_Settings"] := "الإعدادات"
        Lang["Tray_Pause"] := "إيقاف مؤقت"
        Lang["Tray_Exit"] := "خروج"
        Lang["Gui_Lang"] := "اللغة / Language"
        Lang["Gui_Delay"] := "سرعة الكتابة (مللي ثانية):"
        Lang["Gui_Hotkey"] := "اختصار لوحة المفاتيح:"
        Lang["Gui_Trim"] := "حذف المسافات الزائدة (من الأطراف)"
        Lang["Gui_Startup"] := "تشغيل مع ويندوز (Admin)"
        Lang["Gui_Sound"] := "تفعيل الأصوات"
        Lang["Btn_Save"] := "حفظ"
        Lang["Btn_Cancel"] := "إلغاء"
        Lang["Msg_InvalidHk"] := "الرجاء اختيار اختصار صحيح!"
        Lang["Msg_HkFail"] := "فشل تفعيل الاختصار! محجوز لبرنامج آخر."
        Lang["Status_Paused"] := "متوقف"
        Lang["Status_Ready"] := "جاهز"
    } else {
        Lang["Tray_TypeNow"] := "Type Clipboard Now"
        Lang["Tray_Settings"] := "Settings"
        Lang["Tray_Pause"] := "Pause / Resume"
        Lang["Tray_Exit"] := "Exit"
        Lang["Gui_Lang"] := "Language"
        Lang["Gui_Delay"] := "Typing Delay (ms):"
        Lang["Gui_Hotkey"] := "Keyboard Shortcut:"
        Lang["Gui_Trim"] := "Trim Leading/Trailing Whitespace"
        Lang["Gui_Startup"] := "Start with Windows (Admin)"
        Lang["Gui_Sound"] := "Enable Sounds"
        Lang["Btn_Save"] := "Save"
        Lang["Btn_Cancel"] := "Cancel"
        Lang["Msg_InvalidHk"] := "Please set a valid hotkey!"
        Lang["Msg_HkFail"] := "Failed to register hotkey! Used by another app."
        Lang["Status_Paused"] := "Paused"
        Lang["Status_Ready"] := "Ready"
    }
}
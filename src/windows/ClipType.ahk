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
;  Global Variables
; ==============================================================================
Global AppName := "ClipType"
Global Version := "3.5.0"
Global IniFile := A_ScriptDir . "\settings.ini"
Global StopTyping := False
Global IsPaused := False

; --- Settings Variables ---
Global CurrentLang := "EN"
Global TypingDelay := 50
Global MaxDelay := 150
Global UseRandom := 0
Global UserHotkey := "^+v"
Global AutoStart := 0
Global PlaySounds := 1
Global TrimSpaces := 0
Global RunAsAdmin := 0
Global SecureWipe := 0
Global SmartPunct := 0

; --- GUI Control Variables ---
Global MyGui := ""
Global Ctrl_Delay := ""
Global Ctrl_MaxDelay := ""
Global Ctrl_Hotkey := ""
Global Ctrl_Lang := ""
Global Ctrl_Random := ""
Global Ctrl_Start := ""
Global Ctrl_Sound := ""
Global Ctrl_Trim := ""
Global Ctrl_Admin := ""
Global Ctrl_Wipe := ""
Global Ctrl_Smart := ""

; ==============================================================================
;  Main Execution & Startup Logic
; ==============================================================================
try {
    LoadSettings()
    Global Lang := Map()
    SetupLanguage()
    
    if (RunAsAdmin and !A_IsAdmin) {
        try {
            Run("*RunAs `"" . A_ScriptFullPath . "`"")
            ExitApp()
        } catch {
            MsgBox(Lang["Msg_AdminFail"], AppName, 48)
            RunAsAdmin := 0
        }
    }

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

    if (TrimSpaces) {
        ClipContent := Trim(ClipContent, " `t`r`n")
    }

    ClipContent := StrReplace(ClipContent, "`r`n", "`n")

    if (PlaySounds) {
        SoundBeep(1000, 100)
    }

    StopTyping := False
    
    TargetWin := WinExist("A")
    
    Loop Parse, ClipContent {
        if (StopTyping) {
            if (PlaySounds) {
                SoundBeep(300, 300)
            }
            break
        }
        
        if (WinExist("A") != TargetWin) {
            StopTyping := True
            if (PlaySounds) {
                SoundBeep(250, 400)
            }
            break
        }
        
        SendEvent("{Text}" . A_LoopField)
        
        IsPunct := (A_LoopField = "." or A_LoopField = "," or A_LoopField = "?" or A_LoopField = "!" or A_LoopField = ":")
        
        if (SmartPunct and IsPunct) {
            Sleep(400)
        } else if (UseRandom and MaxDelay > TypingDelay) {
            Sleep(Random(TypingDelay, MaxDelay))
        } else {
            Sleep(TypingDelay)
        }
    }

    if (!StopTyping) {
        if (PlaySounds) {
            SoundBeep(1500, 100)
        }
        if (SecureWipe) {
            A_Clipboard := ""
        }
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
    Global MyGui, Ctrl_Delay, Ctrl_MaxDelay, Ctrl_Hotkey, Ctrl_Lang
    Global Ctrl_Random, Ctrl_Start, Ctrl_Sound, Ctrl_Trim, Ctrl_Admin, Ctrl_Wipe, Ctrl_Smart
    
    try {
        MyGui.Destroy()
    }

    MyGui := Gui(, AppName . " - Settings")
    MyGui.Opt("+AlwaysOnTop")
    MyGui.SetFont("s10", "Segoe UI")

    MyGui.Add("Text", "xm y+10", Lang["Gui_Lang"])
    LangOptions := ["English", "العربية"]
    LangChoice := (CurrentLang = "AR") ? 2 : 1
    Ctrl_Lang := MyGui.Add("DropDownList", "w320 Choose" . LangChoice, LangOptions)
    Ctrl_Lang.OnEvent("Change", (*) => ChangeLang(Ctrl_Lang.Value == 2 ? "AR" : "EN"))

    MyGui.Add("Text", "xm y+15", Lang["Gui_Delay"])
    Ctrl_Delay := MyGui.Add("Edit", "w320 Number", TypingDelay)
    MyGui.Add("UpDown", "Range0-2000", TypingDelay)

    MyGui.Add("Text", "xm y+15", Lang["Gui_MaxDelay"])
    Ctrl_MaxDelay := MyGui.Add("Edit", "w320 Number", MaxDelay)
    MyGui.Add("UpDown", "Range0-5000", MaxDelay)

    MyGui.Add("Text", "xm y+15", Lang["Gui_Hotkey"])
    Ctrl_Hotkey := MyGui.Add("Hotkey", "w320", UserHotkey)

    Ctrl_Random := MyGui.Add("Checkbox", "xm y+20", Lang["Gui_Random"])
    Ctrl_Random.Value := UseRandom
    Ctrl_MaxDelay.Enabled := UseRandom
    Ctrl_Random.OnEvent("Click", (*) => Ctrl_MaxDelay.Enabled := Ctrl_Random.Value)

    Ctrl_Smart := MyGui.Add("Checkbox", "xm y+10", Lang["Gui_Smart"])
    Ctrl_Smart.Value := SmartPunct

    Ctrl_Trim := MyGui.Add("Checkbox", "xm y+10", Lang["Gui_Trim"])
    Ctrl_Trim.Value := TrimSpaces

    Ctrl_Wipe := MyGui.Add("Checkbox", "xm y+10", Lang["Gui_Wipe"])
    Ctrl_Wipe.Value := SecureWipe

    Ctrl_Admin := MyGui.Add("Checkbox", "xm y+10", Lang["Gui_Admin"])
    Ctrl_Admin.Value := RunAsAdmin

    Ctrl_Start := MyGui.Add("Checkbox", "xm y+10", Lang["Gui_Startup"])
    Ctrl_Start.Value := AutoStart
    
    Ctrl_Sound := MyGui.Add("Checkbox", "xm y+10", Lang["Gui_Sound"])
    Ctrl_Sound.Value := PlaySounds

    BtnSave := MyGui.Add("Button", "w100 xm+60 y+25 Default", Lang["Btn_Save"])
    BtnSave.OnEvent("Click", SaveAndClose)
    
    BtnCancel := MyGui.Add("Button", "w100 x+20 yp", Lang["Btn_Cancel"])
    BtnCancel.OnEvent("Click", (*) => MyGui.Destroy())

    MyGui.Show()
}

SaveAndClose(*) {
    Global TypingDelay, MaxDelay, PlaySounds, UserHotkey, AutoStart, TrimSpaces, UseRandom, RunAsAdmin, SecureWipe, SmartPunct
    Global Ctrl_Delay, Ctrl_MaxDelay, Ctrl_Hotkey, Ctrl_Start, Ctrl_Sound, Ctrl_Trim, Ctrl_Random, Ctrl_Admin, Ctrl_Wipe, Ctrl_Smart, MyGui

    SavedDelay := Ctrl_Delay.Value
    SavedMax := Ctrl_MaxDelay.Value
    SavedHk := Ctrl_Hotkey.Value
    SavedStart := Ctrl_Start.Value
    SavedSound := Ctrl_Sound.Value
    SavedTrim := Ctrl_Trim.Value
    SavedRand := Ctrl_Random.Value
    SavedAdmin := Ctrl_Admin.Value
    SavedWipe := Ctrl_Wipe.Value
    SavedSmart := Ctrl_Smart.Value

    if (SavedHk = "") {
        MsgBox(Lang["Msg_InvalidHk"], AppName, 16)
        return
    }

    IniWrite(SavedDelay, IniFile, "Settings", "Delay")
    IniWrite(SavedMax, IniFile, "Settings", "MaxDelay")
    IniWrite(SavedHk, IniFile, "Settings", "Hotkey")
    IniWrite(SavedSound, IniFile, "Settings", "Sounds")
    IniWrite(SavedTrim, IniFile, "Settings", "TrimSpaces")
    IniWrite(SavedRand, IniFile, "Settings", "UseRandom")
    IniWrite(SavedAdmin, IniFile, "Settings", "RunAsAdmin")
    IniWrite(SavedWipe, IniFile, "Settings", "SecureWipe")
    IniWrite(SavedSmart, IniFile, "Settings", "SmartPunct")

    TypingDelay := SavedDelay
    MaxDelay := SavedMax
    PlaySounds := SavedSound
    TrimSpaces := SavedTrim
    UseRandom := SavedRand
    RunAsAdmin := SavedAdmin
    SecureWipe := SavedWipe
    SmartPunct := SavedSmart
    AutoStart := SavedStart
    
    if (UpdateHotkey(SavedHk, True)) {
        ManageStartup(SavedStart)
        MyGui.Destroy()
        if (PlaySounds) {
            SoundBeep(1200, 100)
        }
        
        if (SavedAdmin and SavedStart) {
            MsgBox(Lang["Msg_AdminStartupWarn"], AppName, 48)
        } else if (SavedAdmin and !A_IsAdmin) {
            MsgBox(Lang["Msg_RestartAdmin"], AppName, 64)
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
    Tray := A_TrayMenu
    
    StatusIcon := IsPaused ? "Shell32.dll" : "Shell32.dll"
    IconNum := IsPaused ? 110 : 2
    if (!A_IsCompiled) {
        TraySetIcon(StatusIcon, IconNum)
    }

    StatusText := IsPaused ? Lang["Status_Paused"] : Lang["Status_Ready"]
    A_IconTip := AppName . " (" . StatusText . ")"

    if (IsPaused) {
        Tray.Check(Lang["Tray_Pause"])
    } else {
        Tray.Uncheck(Lang["Tray_Pause"])
    }
}

; ==============================================================================
;  Helpers
; ==============================================================================
InitTrayMenu() {
    Tray := A_TrayMenu
    Tray.Delete()
    
    StatusIcon := IsPaused ? "Shell32.dll" : "Shell32.dll"
    IconNum := IsPaused ? 110 : 2
    if (!A_IsCompiled) {
        TraySetIcon(StatusIcon, IconNum)
    }

    StatusText := IsPaused ? Lang["Status_Paused"] : Lang["Status_Ready"]
    A_IconTip := AppName . " (" . StatusText . ")"
    A_IconHidden := False 

    Tray.Add(Lang["Tray_TypeNow"], (*) => InjectClipboard("Tray"))
    Tray.Add()
    Tray.Add(Lang["Tray_Settings"], ShowGui)
    Tray.Add(Lang["Tray_Pause"], TogglePause)
    
    if (IsPaused) {
        Tray.Check(Lang["Tray_Pause"])
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
    } catch as err {
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

CheckStartup() {
    try {
        RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Run", AppName)
        return 1
    } catch {
        return 0
    }
}

ManageStartup(ShouldStart) {
    RegKey := "HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
    if (ShouldStart) {
        RegWrite("`"" . A_ScriptFullPath . "`"", "REG_SZ", RegKey, AppName)
    } else {
        try {
            RegDelete(RegKey, AppName)
        }
    }
}

LoadSettings() {
    Global
    CurrentLang := IniRead(IniFile, "Settings", "Language", "EN")
    TypingDelay := IniRead(IniFile, "Settings", "Delay", 50)
    MaxDelay := IniRead(IniFile, "Settings", "MaxDelay", 150)
    UserHotkey := IniRead(IniFile, "Settings", "Hotkey", "^+v")
    PlaySounds := IniRead(IniFile, "Settings", "Sounds", 1)
    TrimSpaces := IniRead(IniFile, "Settings", "TrimSpaces", 0)
    UseRandom := IniRead(IniFile, "Settings", "UseRandom", 0)
    RunAsAdmin := IniRead(IniFile, "Settings", "RunAsAdmin", 0)
    SecureWipe := IniRead(IniFile, "Settings", "SecureWipe", 0)
    SmartPunct := IniRead(IniFile, "Settings", "SmartPunct", 0)
    AutoStart := CheckStartup()
}

SetupLanguage() {
    if (CurrentLang = "AR") {
        Lang["Tray_TypeNow"] := "كتابة الحافظة الآن"
        Lang["Tray_Settings"] := "الإعدادات"
        Lang["Tray_Pause"] := "إيقاف مؤقت"
        Lang["Tray_Exit"] := "خروج"
        Lang["Gui_Lang"] := "لغة الواجهة / Language:"
        Lang["Gui_Delay"] := "سرعة الكتابة الأساسية (مللي ثانية):"
        Lang["Gui_MaxDelay"] := "أقصى تأخير (للكتابة العشوائية):"
        Lang["Gui_Hotkey"] := "اختصار لوحة المفاتيح:"
        Lang["Gui_Random"] := "تفعيل الكتابة العشوائية (تخطي حماية الروبوتات)"
        Lang["Gui_Smart"] := "توقف بشري ذكي عند علامات الترقيم (Smart Punctuation)"
        Lang["Gui_Trim"] := "حذف المسافات الزائدة (من الأطراف)"
        Lang["Gui_Wipe"] := "مسح الحافظة أمنياً بعد الانتهاء (Secure Wipe)"
        Lang["Gui_Admin"] := "تشغيل كمسؤول (للكتابة داخل البرامج المحمية)"
        Lang["Gui_Startup"] := "تشغيل مع بداية الويندوز (ريجستري)"
        Lang["Gui_Sound"] := "تفعيل الأصوات"
        Lang["Btn_Save"] := "حف&ظ"
        Lang["Btn_Cancel"] := "إل&غاء"
        Lang["Msg_InvalidHk"] := "الرجاء اختيار اختصار صحيح!"
        Lang["Msg_HkFail"] := "فشل تفعيل الاختصار! محجوز لبرنامج آخر."
        Lang["Msg_AdminFail"] := "فشل التشغيل كمسؤول. البرنامج هيشتغل بصلاحيات عادية ومش هيقدر يكتب في البرامج المحمية."
        Lang["Msg_RestartAdmin"] := "تم حفظ الإعدادات. يرجى إعادة تشغيل البرنامج لتطبيق صلاحيات المسؤول."
        Lang["Msg_AdminStartupWarn"] := "تحذير: تفعيل التشغيل كمسؤول مع التشغيل التلقائي هيخلي شاشة تأكيد الصلاحيات (UAC) تظهرلك كل مرة تفتح فيها الويندوز."
        Lang["Status_Paused"] := "متوقف"
        Lang["Status_Ready"] := "جاهز"
    } else {
        Lang["Tray_TypeNow"] := "Type Clipboard Now"
        Lang["Tray_Settings"] := "Settings"
        Lang["Tray_Pause"] := "Pause / Resume"
        Lang["Tray_Exit"] := "Exit"
        Lang["Gui_Lang"] := "Interface Language:"
        Lang["Gui_Delay"] := "Base Typing Delay (ms):"
        Lang["Gui_MaxDelay"] := "Max Delay (For Randomized Typing):"
        Lang["Gui_Hotkey"] := "Keyboard Shortcut:"
        Lang["Gui_Random"] := "Enable Randomized Typing (Anti-Bot Bypass)"
        Lang["Gui_Smart"] := "Smart Punctuation Delay (Human-like pauses)"
        Lang["Gui_Trim"] := "Trim Leading/Trailing Whitespace"
        Lang["Gui_Wipe"] := "Secure Wipe (Clear clipboard after typing)"
        Lang["Gui_Admin"] := "Run as Admin (To type inside elevated apps)"
        Lang["Gui_Startup"] := "Start with Windows (Registry)"
        Lang["Gui_Sound"] := "Enable Sounds"
        Lang["Btn_Save"] := "&Save"
        Lang["Btn_Cancel"] := "&Cancel"
        Lang["Msg_InvalidHk"] := "Please set a valid hotkey!"
        Lang["Msg_HkFail"] := "Failed to register hotkey! Used by another app."
        Lang["Msg_AdminFail"] := "Failed to elevate. ClipType will run normally but won't type inside Admin-level windows."
        Lang["Msg_RestartAdmin"] := "Settings saved. Please restart the app to apply Admin privileges."
        Lang["Msg_AdminStartupWarn"] := "Warning: Enabling Run as Admin with Windows Startup will trigger a UAC prompt every time you boot your PC."
        Lang["Status_Paused"] := "Paused"
        Lang["Status_Ready"] := "Ready"
    }
}
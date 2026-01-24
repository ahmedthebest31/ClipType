-- ==============================================================================
--  ClipType - Professional Clipboard Injector (macOS)
--  Version: 1.0.0
--  License: MIT
--  Author: Ahmed Samy
-- ==============================================================================

on run argv
    -- Default delay in seconds (AppleScript uses seconds, not ms)
    set typingDelay to 0.05
    
    -- Check if a delay argument is passed (e.g., "0.1")
    if (count of argv) > 0 then
        try
            set typingDelay to (item 1 of argv) as number
        on error
            -- Fallback if argument is not a number
            set typingDelay to 0.05
        end try
    end if
    
    -- Get clipboard content
    try
        set clipContent to the clipboard as text
    on error
        -- If clipboard is empty or image, stop silently
        return
    end try
    
    -- Small safety delay to allow shortcut release
    delay 0.2
    
    -- Core Logic: Simulate Keystrokes
    tell application "System Events"
        -- Type the content character by character
        -- Note: System Events handles special chars better than generic methods
        keystroke clipContent
        
        -- Optional: Wait slightly if needed (controlled by external delay arg if loop logic was used)
        -- But 'keystroke' usually handles buffers well on macOS.
    end tell
end run
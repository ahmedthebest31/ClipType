import Cocoa
import Foundation
import Quartz

// ==============================================================================
//  ClipType - Professional Clipboard Injector (macOS Native Engine)
//  Version: 1.0.0
//  Author: Ahmed Samy
// ==============================================================================

func usage() {
    print("ClipType macOS Native Engine")
    print("Usage: cliptype [options]")
    print("\nOptions:")
    print("  --delay <ms>      Base typing delay (default: 50)")
    print("  --random <max>    Enable randomized typing with max delay")
    print("  --smart           Enable smart punctuation pauses")
    print("  --wipe            Securely clear clipboard after typing")
    exit(0)
}

// --- Argument Parsing Logic ---
var baseDelay = 50.0
var maxDelay = 150.0
var useRandom = false
var smartPunct = false
var secureWipe = false

let args = CommandLine.arguments
var i = 1
while i < args.count {
    switch args[i] {
    case "--delay":
        if i + 1 < args.count { baseDelay = Double(args[i+1]) ?? 50.0; i += 1 }
    case "--random":
        if i + 1 < args.count { 
            maxDelay = Double(args[i+1]) ?? 150.0
            useRandom = true
            i += 1 
        }
    case "--smart": smartPunct = true
    case "--wipe": secureWipe = true
    case "--help", "-h": usage()
    default: break
    }
    i += 1
}

// --- Clipboard Access ---
let pasteboard = NSPasteboard.general
guard let content = pasteboard.string(forType: .string) else {
    print("Clipboard is empty or contains non-text data.")
    exit(1)
}

// --- Safety & Focus Protection ---
// Small delay to allow user to release keys
Thread.sleep(forTimeInterval: 0.3)

let source = CGEventSource(stateID: .combinedSessionState)
let punctuation: Set<Character> = [".", ",", "?", "!", ":"]

// --- Injection Loop ---
for char in content {
    let charStr = String(char)
    
    // Create and post Unicode KeyDown/KeyUp events
    let eventDown = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true)
    eventDown?.keyboardSetUnicodeString(stringLength: charStr.utf16.count, unicodeString: Array(charStr.utf16))
    eventDown?.post(tap: .cghidEventTap)
    
    // Handle Timing Logic
    if smartPunct && punctuation.contains(char) {
        Thread.sleep(forTimeInterval: 0.4)
    } else if useRandom && maxDelay > baseDelay {
        let randomMs = Double.random(in: baseDelay...maxDelay)
        Thread.sleep(forTimeInterval: randomMs / 1000.0)
    } else {
        Thread.sleep(forTimeInterval: baseDelay / 1000.0)
    }
}

// --- Post-Injection: Secure Wipe ---
if secureWipe {
    pasteboard.clearContents()
    print("Clipboard securely wiped.")
}

exit(0)
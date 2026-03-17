# Control Input

**Take back your microphone.**

A lightweight macOS menu bar utility that lets you instantly switch audio input devices — and keep them switched.

---

## The Problem

You are on a call. Your AirPods Max are playing music. macOS, without asking, silently hijacks your audio input to the AirPods mic. Your voice now sounds like you are talking through a tunnel, your colleagues are confused, and you are digging through System Settings to fix something that should not have broken in the first place.

This happens every time.

## The Fix

Control Input lives in your menu bar. One click to see every audio input device on your system. One click to switch. Or set a preferred device and never think about it again — Control Input will automatically revert your input whenever something tries to take over.

No dock icon. No window in your way. Just quiet, reliable control over something macOS should have gotten right.

---

## Features

### One-Click Switching
Every available audio input device appears in your menu bar. Built-in microphone, Bluetooth headset, USB interface — switch between them instantly.

### Auto-Switch
Set a preferred input device. When macOS silently changes your input — connecting AirPods, plugging in a display — Control Input switches it back. Automatically.

### Thoughtful Details
- **Device-type icons** distinguish built-in, Bluetooth, and external devices at a glance
- **Appearance settings** with System, Light, and Dark themes
- **Launch at Login** so it is always ready
- **No dock icon** — it stays out of your way entirely

---

## Get Started

### Download

Grab the latest release from the [Releases](../../releases) page. Drag Control Input to your Applications folder and open it. That's it.

### Build from Source

```bash
git clone https://github.com/emmagine79/control-input.git
cd control-input
open ControlInput.xcodeproj
```

Build and run from Xcode. Requires Xcode 15 or later.

---

## Requirements

- macOS 14 Sonoma or later
- Apple Silicon or Intel Mac

---

## Built With

- **SwiftUI** — MenuBarExtra with `.window` style, `@Observable`
- **CoreAudio** — real-time audio device enumeration and switching
- **ServiceManagement** — SMAppService for launch-at-login

---

## License

Released under the [MIT License](LICENSE).

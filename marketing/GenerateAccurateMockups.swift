#!/usr/bin/env swift
// Generates marketing mockups that match the actual app appearance.
// Uses light theme with frosted glass aesthetic matching real macOS vibrancy.

import Cocoa
import CoreText

// MARK: - Helpers

func createBitmap(width: Int, height: Int) -> (CGContext, NSBitmapImageRep)? {
    guard let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: width, pixelsHigh: height,
        bitsPerSample: 8, samplesPerPixel: 4,
        hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0, bitsPerPixel: 0
    ) else { return nil }
    rep.size = NSSize(width: width, height: height)
    guard let gfx = NSGraphicsContext(bitmapImageRep: rep) else { return nil }
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = gfx
    return (gfx.cgContext, rep)
}

func save(_ rep: NSBitmapImageRep, to path: String) {
    NSGraphicsContext.restoreGraphicsState()
    guard let png = rep.representation(using: .png, properties: [:]) else { return }
    try! png.write(to: URL(fileURLWithPath: path))
    print("Wrote \(path)")
}

func text(_ ctx: CGContext, _ str: String, x: CGFloat, y: CGFloat,
          size: CGFloat, weight: NSFont.Weight, color: CGColor, centered: Bool = false) {
    let font = NSFont.systemFont(ofSize: size, weight: weight)
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor(cgColor: color) ?? .black,
    ]
    let as_ = NSAttributedString(string: str, attributes: attrs)
    let line = CTLineCreateWithAttributedString(as_)
    let bounds = CTLineGetBoundsWithOptions(line, .useOpticalBounds)
    let dx = centered ? x - bounds.width / 2 : x
    ctx.saveGState()
    ctx.textPosition = CGPoint(x: dx, y: y)
    CTLineDraw(line, ctx)
    ctx.restoreGState()
}

func textWidth(_ str: String, size: CGFloat, weight: NSFont.Weight) -> CGFloat {
    let font = NSFont.systemFont(ofSize: size, weight: weight)
    let attrs: [NSAttributedString.Key: Any] = [.font: font]
    let as_ = NSAttributedString(string: str, attributes: attrs)
    let line = CTLineCreateWithAttributedString(as_)
    return CTLineGetBoundsWithOptions(line, .useOpticalBounds).width
}

// MARK: - Colors (matching real app light theme)

let darkBg = CGColor(srgbRed: 0.08, green: 0.10, blue: 0.16, alpha: 1.0)
let panelBg = CGColor(srgbRed: 0.95, green: 0.95, blue: 0.96, alpha: 1.0)
let hoverBg = CGColor(srgbRed: 0.25, green: 0.52, blue: 0.96, alpha: 1.0)
let textPrimary = CGColor(srgbRed: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
let textSecondary = CGColor(srgbRed: 0.55, green: 0.55, blue: 0.58, alpha: 1.0)
let textOnBlue = CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 1.0)
let accentPink = CGColor(srgbRed: 0.85, green: 0.35, blue: 0.55, alpha: 1.0)
let iconGray = CGColor(srgbRed: 0.50, green: 0.50, blue: 0.53, alpha: 1.0)
let dividerColor = CGColor(srgbRed: 0.82, green: 0.82, blue: 0.84, alpha: 1.0)
let subtleTeal = CGColor(srgbRed: 0.45, green: 0.70, blue: 0.82, alpha: 1.0)

// MARK: - Popover mockup drawing

func drawPopover(ctx: CGContext, x: CGFloat, y: CGFloat, w: CGFloat, scale: CGFloat) {
    let panelH = 290 * scale
    let cornerR = 12 * scale
    let rowH = 40 * scale
    let padX = 14 * scale
    let padY = 12 * scale
    let iconSize = 16 * scale
    let fontSize = 15 * scale
    let smallFont = 11 * scale

    // Panel shadow
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -3 * scale), blur: 20 * scale,
                   color: CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 0.25))
    let panelRect = CGRect(x: x, y: y, width: w, height: panelH)
    let panelPath = CGPath(roundedRect: panelRect, cornerWidth: cornerR, cornerHeight: cornerR, transform: nil)
    ctx.setFillColor(panelBg)
    ctx.addPath(panelPath)
    ctx.fillPath()
    ctx.restoreGState()

    // Panel fill (again, on top of shadow)
    ctx.saveGState()
    ctx.addPath(panelPath)
    ctx.clip()
    ctx.setFillColor(panelBg)
    ctx.fill(panelRect)

    // --- Header ---
    let headerY = y + panelH - padY - 14 * scale
    text(ctx, "INPUT DEVICES", x: x + padX + 2 * scale, y: headerY,
         size: smallFont, weight: .semibold, color: textSecondary)

    // --- Device rows ---
    let devices: [(icon: String, name: String, isHovered: Bool, isActive: Bool)] = [
        ("headphones", "Awesome AirPods Max", true, false),
        ("mic.fill", "USB PnP Sound Device", false, false),
        ("mic", "Aggregate Device", false, true),
    ]

    var rowY = headerY - 8 * scale

    for (_, device) in devices.enumerated() {
        rowY -= rowH

        let rowRect = CGRect(x: x + 6 * scale, y: rowY, width: w - 12 * scale, height: rowH - 2 * scale)
        let rowPath = CGPath(roundedRect: rowRect, cornerWidth: 6 * scale, cornerHeight: 6 * scale, transform: nil)

        if device.isHovered {
            ctx.setFillColor(hoverBg)
            ctx.addPath(rowPath)
            ctx.fillPath()
        }

        let textColor = device.isHovered ? textOnBlue : textPrimary
        let icnColor = device.isHovered ? textOnBlue : iconGray

        // Icon (simple circle placeholder with SF Symbol name)
        let icnX = x + padX + 6 * scale
        let icnY = rowY + (rowH - 2 * scale) / 2

        // Draw a simple icon representation
        ctx.saveGState()
        ctx.setFillColor(icnColor)
        if device.icon == "headphones" {
            // Headphones: two arcs + band
            let hcx = icnX + iconSize / 2
            let hcy = icnY
            let r = iconSize * 0.45
            ctx.setLineWidth(2.2 * scale)
            ctx.setStrokeColor(icnColor)
            ctx.addArc(center: CGPoint(x: hcx, y: hcy + r * 0.2), radius: r,
                       startAngle: .pi * 0.15, endAngle: .pi * 0.85, clockwise: false)
            ctx.strokePath()
            // Ear cups
            let cupW = 4.5 * scale
            let cupH = 7 * scale
            ctx.fill(CGRect(x: hcx - r - cupW / 2, y: hcy - cupH / 2 - r * 0.15, width: cupW, height: cupH))
            ctx.fill(CGRect(x: hcx + r - cupW / 2, y: hcy - cupH / 2 - r * 0.15, width: cupW, height: cupH))
        } else {
            // Mic icon: simple capsule + stand
            let mcx = icnX + iconSize / 2
            let mcy = icnY
            let bw = 5 * scale
            let bh = 9 * scale
            let capsule = CGRect(x: mcx - bw / 2, y: mcy - bh * 0.1, width: bw, height: bh)
            ctx.addPath(CGPath(roundedRect: capsule, cornerWidth: bw / 2, cornerHeight: bw / 2, transform: nil))
            ctx.fillPath()
            ctx.setLineWidth(1.8 * scale)
            ctx.setStrokeColor(icnColor)
            let ar = 5 * scale
            ctx.addArc(center: CGPoint(x: mcx, y: mcy + bh * 0.15),
                       radius: ar, startAngle: .pi * 0.2, endAngle: .pi * 0.8, clockwise: true)
            ctx.strokePath()
            ctx.setLineWidth(1.5 * scale)
            ctx.move(to: CGPoint(x: mcx, y: mcy + bh * 0.15 - ar))
            ctx.addLine(to: CGPoint(x: mcx, y: mcy - bh * 0.45))
            ctx.strokePath()
        }
        ctx.restoreGState()

        // Device name
        let nameX = icnX + iconSize + 10 * scale
        let nameY = rowY + (rowH - 2 * scale) / 2 - fontSize * 0.35
        text(ctx, device.name, x: nameX, y: nameY,
             size: fontSize, weight: .regular, color: textColor)

        // Checkmark for active device
        if device.isActive {
            let checkColor = device.isHovered ? textOnBlue : accentPink
            let checkX = x + w - padX - 16 * scale
            text(ctx, "\u{2713}", x: checkX, y: nameY,
                 size: fontSize, weight: .semibold, color: checkColor)
        }
    }

    // --- Divider ---
    rowY -= 10 * scale
    ctx.setFillColor(dividerColor)
    ctx.fill(CGRect(x: x + padX, y: rowY, width: w - padX * 2, height: 1))

    // --- Settings row ---
    rowY -= rowH - 6 * scale
    let settingsIconX = x + padX + 6 * scale
    let settingsY = rowY + rowH / 2 - fontSize * 0.35
    ctx.setFillColor(iconGray)
    // Gear icon (simplified: circle with notches)
    let gx = settingsIconX + iconSize / 2
    let gy = rowY + rowH / 2
    ctx.setStrokeColor(iconGray)
    ctx.setLineWidth(1.8 * scale)
    ctx.addArc(center: CGPoint(x: gx, y: gy), radius: 4 * scale,
               startAngle: 0, endAngle: .pi * 2, clockwise: false)
    ctx.strokePath()

    text(ctx, "Settings\u{2026}", x: settingsIconX + iconSize + 10 * scale, y: settingsY,
         size: fontSize, weight: .regular, color: textPrimary)
    // Shortcut
    text(ctx, "\u{2318},", x: x + w - padX - 24 * scale, y: settingsY,
         size: smallFont + 1 * scale, weight: .regular, color: textSecondary)

    // --- Quit row ---
    rowY -= rowH - 4 * scale
    let quitY = rowY + rowH / 2 - fontSize * 0.35
    // Power icon (circle with line)
    let qx = settingsIconX + iconSize / 2
    let qy = rowY + rowH / 2
    ctx.setStrokeColor(iconGray)
    ctx.setLineWidth(1.8 * scale)
    ctx.addArc(center: CGPoint(x: qx, y: qy), radius: 4 * scale,
               startAngle: .pi * 0.3, endAngle: .pi * 2.2, clockwise: false)
    ctx.strokePath()
    ctx.move(to: CGPoint(x: qx, y: qy + 2 * scale))
    ctx.addLine(to: CGPoint(x: qx, y: qy + 6 * scale))
    ctx.strokePath()

    text(ctx, "Quit Control Input", x: settingsIconX + iconSize + 10 * scale, y: quitY,
         size: fontSize, weight: .regular, color: textPrimary)
    text(ctx, "\u{2318}Q", x: x + w - padX - 24 * scale, y: quitY,
         size: smallFont + 1 * scale, weight: .regular, color: textSecondary)

    ctx.restoreGState()
}

// MARK: - Generate social-ready popover mockup (1080x1350)

func generatePopover() {
    let w = 1080, h = 1350
    guard let (ctx, rep) = createBitmap(width: w, height: h) else { return }
    let W = CGFloat(w), H = CGFloat(h)

    // Dark outer background
    ctx.setFillColor(darkBg)
    ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))

    // Subtle radial glow
    let glow = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [CGColor(srgbRed: 0.10, green: 0.40, blue: 0.55, alpha: 0.15),
                 CGColor(srgbRed: 0.10, green: 0.40, blue: 0.55, alpha: 0.0)] as CFArray,
        locations: [0.0, 1.0])!
    ctx.drawRadialGradient(glow, startCenter: CGPoint(x: W/2, y: H * 0.6),
        startRadius: 0, endCenter: CGPoint(x: W/2, y: H * 0.6),
        endRadius: 400, options: [])

    // Draw the popover panel
    let panelW: CGFloat = 480
    let panelX = (W - panelW) / 2
    let panelY = H * 0.42
    drawPopover(ctx: ctx, x: panelX, y: panelY, w: panelW, scale: 1.7)

    // Branding below
    text(ctx, "control input", x: W / 2, y: H * 0.18,
         size: 42, weight: .bold, color: CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 1), centered: true)
    text(ctx, "one click. right mic.", x: W / 2, y: H * 0.12,
         size: 20, weight: .medium, color: subtleTeal, centered: true)

    save(rep, to: "marketing/ui-popover.png")
}

// MARK: - Generate social-ready stories hero (1080x1920)

func generateStories() {
    let w = 1080, h = 1920
    guard let (ctx, rep) = createBitmap(width: w, height: h) else { return }
    let W = CGFloat(w), H = CGFloat(h)

    // Dark background
    ctx.setFillColor(darkBg)
    ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))

    // Glow
    let glow = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [CGColor(srgbRed: 0.08, green: 0.45, blue: 0.60, alpha: 0.20),
                 CGColor(srgbRed: 0.08, green: 0.45, blue: 0.60, alpha: 0.0)] as CFArray,
        locations: [0.0, 1.0])!
    ctx.drawRadialGradient(glow, startCenter: CGPoint(x: W/2, y: H * 0.72),
        startRadius: 0, endCenter: CGPoint(x: W/2, y: H * 0.72),
        endRadius: 350, options: [])

    // Draw a smaller popover showing the real UI
    let panelW: CGFloat = 440
    let panelX = (W - panelW) / 2
    drawPopover(ctx: ctx, x: panelX, y: H * 0.48, w: panelW, scale: 1.6)

    // Title and tagline above
    text(ctx, "control input", x: W / 2, y: H * 0.88,
         size: 48, weight: .bold, color: CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 1), centered: true)
    text(ctx, "take back your microphone.", x: W / 2, y: H * 0.84,
         size: 22, weight: .medium, color: subtleTeal, centered: true)

    // Feature bullets below the popover
    let bulletY: [CGFloat] = [H * 0.22, H * 0.18, H * 0.14]
    let bullets = ["one-click switching", "auto-switch to preferred mic", "lives in your menu bar"]
    let dotColor = CGColor(srgbRed: 0.20, green: 0.65, blue: 0.75, alpha: 1)
    let bulletTextColor = CGColor(srgbRed: 0.80, green: 0.83, blue: 0.88, alpha: 1)

    for (i, b) in bullets.enumerated() {
        // Dot
        ctx.setFillColor(dotColor)
        ctx.fillEllipse(in: CGRect(x: W * 0.25, y: bulletY[i] - 3, width: 8, height: 8))
        text(ctx, b, x: W * 0.25 + 20, y: bulletY[i] - 6,
             size: 19, weight: .regular, color: bulletTextColor)
    }

    save(rep, to: "marketing/ui-hero-mobile.png")
}

// MARK: - Run

generatePopover()
generateStories()
print("Done.")

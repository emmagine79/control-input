#!/usr/bin/env swift
// Generates UI mockup images for Control Input social media.
// Run:  swift marketing/GenerateUIMockups.swift

import Cocoa
import CoreText

// MARK: - Colors

let bgDark      = CGColor(srgbRed: 0.04, green: 0.06, blue: 0.12, alpha: 1.0)
let bgMid       = CGColor(srgbRed: 0.06, green: 0.10, blue: 0.20, alpha: 1.0)
let bgLight     = CGColor(srgbRed: 0.08, green: 0.14, blue: 0.26, alpha: 1.0)
let teal        = CGColor(srgbRed: 0.12, green: 0.78, blue: 0.80, alpha: 1.0)
let blue        = CGColor(srgbRed: 0.10, green: 0.42, blue: 0.85, alpha: 1.0)
let white100    = CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 1.0)
let white80     = CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.8)
let white60     = CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.6)
let white40     = CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.4)
let white20     = CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.2)
let white10     = CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.10)
let white06     = CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.06)
let white04     = CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.04)
let tealBright  = CGColor(srgbRed: 0.20, green: 0.85, blue: 0.85, alpha: 1.0)
let tealDim     = CGColor(srgbRed: 0.12, green: 0.55, blue: 0.70, alpha: 0.6)
let popoverBg   = CGColor(srgbRed: 0.12, green: 0.13, blue: 0.16, alpha: 1.0)
let popoverRow  = CGColor(srgbRed: 0.16, green: 0.17, blue: 0.21, alpha: 1.0)
let highlightBg = CGColor(srgbRed: 0.12, green: 0.42, blue: 0.70, alpha: 0.35)
let settingsBg  = CGColor(srgbRed: 0.14, green: 0.15, blue: 0.19, alpha: 1.0)
let sectionBg   = CGColor(srgbRed: 0.18, green: 0.19, blue: 0.24, alpha: 1.0)

// MARK: - Microphone Drawing

func drawMicrophone(ctx: CGContext, size s: CGFloat) {
    ctx.saveGState()
    let cx = s / 2
    let white95 = CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.95)
    let lineW = s * 0.035
    let capsuleW = s * 0.20
    let capsuleH = s * 0.30
    let capsuleBottom = s * 0.48
    ctx.setFillColor(white95)
    let capsuleRect = CGRect(x: cx - capsuleW / 2, y: capsuleBottom, width: capsuleW, height: capsuleH)
    let capsulePath = CGPath(roundedRect: capsuleRect, cornerWidth: capsuleW / 2, cornerHeight: capsuleW / 2, transform: nil)
    ctx.addPath(capsulePath)
    ctx.fillPath()
    ctx.setStrokeColor(white95)
    ctx.setLineWidth(lineW)
    ctx.setLineCap(.round)
    let arcCenterY = capsuleBottom + capsuleH * 0.30
    let arcRadius = s * 0.17
    ctx.addArc(center: CGPoint(x: cx, y: arcCenterY), radius: arcRadius, startAngle: .pi * 0.2, endAngle: .pi * 0.8, clockwise: true)
    ctx.strokePath()
    let stemTop = arcCenterY - arcRadius
    let stemBottom = s * 0.22
    ctx.move(to: CGPoint(x: cx, y: stemTop))
    ctx.addLine(to: CGPoint(x: cx, y: stemBottom))
    ctx.strokePath()
    let baseW = s * 0.16
    ctx.move(to: CGPoint(x: cx - baseW / 2, y: stemBottom))
    ctx.addLine(to: CGPoint(x: cx + baseW / 2, y: stemBottom))
    ctx.strokePath()
    ctx.restoreGState()
}

func drawAppIcon(ctx: CGContext, originX: CGFloat, originY: CGFloat, iconSize: CGFloat) {
    ctx.saveGState()
    ctx.translateBy(x: originX, y: originY)
    let s = iconSize
    let inset: CGFloat = s * 0.05
    let rect = CGRect(x: inset, y: inset, width: s - inset * 2, height: s - inset * 2)
    let radius = s * 0.225
    let squircle = CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)
    ctx.saveGState()
    ctx.addPath(squircle)
    ctx.clip()
    let iconColors = [
        CGColor(srgbRed: 0.12, green: 0.78, blue: 0.80, alpha: 1.0),
        CGColor(srgbRed: 0.10, green: 0.42, blue: 0.85, alpha: 1.0),
    ]
    let iconGrad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: iconColors as CFArray, locations: [0.0, 1.0])!
    ctx.drawLinearGradient(iconGrad, start: CGPoint(x: s / 2, y: s * 0.95), end: CGPoint(x: s / 2, y: s * 0.05), options: [])
    let highlightRect = CGRect(x: inset, y: s * 0.48, width: s - inset * 2, height: s * 0.52 - inset)
    let highlightPath = CGPath(roundedRect: highlightRect, cornerWidth: radius, cornerHeight: radius, transform: nil)
    ctx.addPath(highlightPath)
    ctx.clip()
    let glassColors = [
        CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.32),
        CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.04),
    ]
    let glassGrad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: glassColors as CFArray, locations: [0.0, 1.0])!
    ctx.drawLinearGradient(glassGrad, start: CGPoint(x: s / 2, y: s * 0.95), end: CGPoint(x: s / 2, y: s * 0.48), options: [])
    ctx.restoreGState()
    ctx.saveGState()
    ctx.addPath(squircle)
    ctx.setStrokeColor(CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.18))
    ctx.setLineWidth(s * 0.012)
    ctx.strokePath()
    ctx.restoreGState()
    drawMicrophone(ctx: ctx, size: s)
    ctx.restoreGState()
}

// MARK: - Text Helpers

func drawCenteredText(_ text: String, ctx: CGContext, centerX: CGFloat, centerY: CGFloat,
                      fontSize: CGFloat, fontWeight: NSFont.Weight, color: CGColor) {
    let font = NSFont.systemFont(ofSize: fontSize, weight: fontWeight)
    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor(cgColor: color) ?? NSColor.white,
    ]
    let attrString = NSAttributedString(string: text, attributes: attributes)
    let line = CTLineCreateWithAttributedString(attrString)
    let bounds = CTLineGetBoundsWithOptions(line, .useOpticalBounds)
    let x = centerX - bounds.width / 2 - bounds.origin.x
    let y = centerY - bounds.height / 2 - bounds.origin.y
    ctx.saveGState()
    ctx.textPosition = CGPoint(x: x, y: y)
    CTLineDraw(line, ctx)
    ctx.restoreGState()
}

func drawLeftText(_ text: String, ctx: CGContext, x: CGFloat, centerY: CGFloat,
                  fontSize: CGFloat, fontWeight: NSFont.Weight, color: CGColor) {
    let font = NSFont.systemFont(ofSize: fontSize, weight: fontWeight)
    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor(cgColor: color) ?? NSColor.white,
    ]
    let attrString = NSAttributedString(string: text, attributes: attributes)
    let line = CTLineCreateWithAttributedString(attrString)
    let bounds = CTLineGetBoundsWithOptions(line, .useOpticalBounds)
    let y = centerY - bounds.height / 2 - bounds.origin.y
    ctx.saveGState()
    ctx.textPosition = CGPoint(x: x, y: y)
    CTLineDraw(line, ctx)
    ctx.restoreGState()
}

func drawRightText(_ text: String, ctx: CGContext, rightX: CGFloat, centerY: CGFloat,
                   fontSize: CGFloat, fontWeight: NSFont.Weight, color: CGColor) {
    let font = NSFont.systemFont(ofSize: fontSize, weight: fontWeight)
    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor(cgColor: color) ?? NSColor.white,
    ]
    let attrString = NSAttributedString(string: text, attributes: attributes)
    let line = CTLineCreateWithAttributedString(attrString)
    let bounds = CTLineGetBoundsWithOptions(line, .useOpticalBounds)
    let x = rightX - bounds.width - bounds.origin.x
    let y = centerY - bounds.height / 2 - bounds.origin.y
    ctx.saveGState()
    ctx.textPosition = CGPoint(x: x, y: y)
    CTLineDraw(line, ctx)
    ctx.restoreGState()
}

func textWidth(_ text: String, fontSize: CGFloat, fontWeight: NSFont.Weight) -> CGFloat {
    let font = NSFont.systemFont(ofSize: fontSize, weight: fontWeight)
    let attributes: [NSAttributedString.Key: Any] = [.font: font]
    let attrString = NSAttributedString(string: text, attributes: attributes)
    let line = CTLineCreateWithAttributedString(attrString)
    let bounds = CTLineGetBoundsWithOptions(line, .useOpticalBounds)
    return bounds.width
}

// MARK: - Background

func drawBackground(ctx: CGContext, width: CGFloat, height: CGFloat) {
    let bgColors = [
        CGColor(srgbRed: 0.04, green: 0.06, blue: 0.12, alpha: 1.0),
        CGColor(srgbRed: 0.06, green: 0.10, blue: 0.20, alpha: 1.0),
        CGColor(srgbRed: 0.04, green: 0.08, blue: 0.16, alpha: 1.0),
    ]
    let bgGrad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: bgColors as CFArray, locations: [0.0, 0.5, 1.0])!
    ctx.drawLinearGradient(bgGrad, start: CGPoint(x: 0, y: 0), end: CGPoint(x: width, y: height), options: [])
}

func drawSubtleGlow(ctx: CGContext, centerX: CGFloat, centerY: CGFloat, radius: CGFloat) {
    let glowColors = [
        CGColor(srgbRed: 0.10, green: 0.50, blue: 0.70, alpha: 0.15),
        CGColor(srgbRed: 0.10, green: 0.50, blue: 0.70, alpha: 0.0),
    ]
    let glowGrad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: glowColors as CFArray, locations: [0.0, 1.0])!
    ctx.drawRadialGradient(glowGrad, startCenter: CGPoint(x: centerX, y: centerY), startRadius: 0,
                            endCenter: CGPoint(x: centerX, y: centerY), endRadius: radius, options: [])
}

// MARK: - Shape Helpers

func drawRoundedRect(ctx: CGContext, rect: CGRect, radius: CGFloat, fill: CGColor) {
    let path = CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)
    ctx.saveGState()
    ctx.addPath(path)
    ctx.setFillColor(fill)
    ctx.fillPath()
    ctx.restoreGState()
}

func drawRoundedRectStroke(ctx: CGContext, rect: CGRect, radius: CGFloat, stroke: CGColor, lineWidth: CGFloat) {
    let path = CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)
    ctx.saveGState()
    ctx.addPath(path)
    ctx.setStrokeColor(stroke)
    ctx.setLineWidth(lineWidth)
    ctx.strokePath()
    ctx.restoreGState()
}

// MARK: - Icon Helpers (SF Symbol-like simple icons)

func drawCheckmark(ctx: CGContext, centerX: CGFloat, centerY: CGFloat, size: CGFloat, color: CGColor) {
    ctx.saveGState()
    ctx.setStrokeColor(color)
    ctx.setLineWidth(size * 0.15)
    ctx.setLineCap(.round)
    ctx.setLineJoin(.round)
    ctx.move(to: CGPoint(x: centerX - size * 0.35, y: centerY))
    ctx.addLine(to: CGPoint(x: centerX - size * 0.05, y: centerY - size * 0.30))
    ctx.addLine(to: CGPoint(x: centerX + size * 0.40, y: centerY + size * 0.30))
    ctx.strokePath()
    ctx.restoreGState()
}

func drawLaptopIcon(ctx: CGContext, centerX: CGFloat, centerY: CGFloat, size: CGFloat, color: CGColor) {
    ctx.saveGState()
    ctx.setStrokeColor(color)
    ctx.setLineWidth(size * 0.08)
    ctx.setLineCap(.round)
    ctx.setLineJoin(.round)
    // Screen
    let screenW = size * 0.70
    let screenH = size * 0.45
    let screenRect = CGRect(x: centerX - screenW / 2, y: centerY - size * 0.05, width: screenW, height: screenH)
    let screenPath = CGPath(roundedRect: screenRect, cornerWidth: size * 0.05, cornerHeight: size * 0.05, transform: nil)
    ctx.addPath(screenPath)
    ctx.strokePath()
    // Base
    ctx.move(to: CGPoint(x: centerX - size * 0.48, y: centerY - size * 0.10))
    ctx.addLine(to: CGPoint(x: centerX + size * 0.48, y: centerY - size * 0.10))
    ctx.strokePath()
    ctx.restoreGState()
}

func drawHeadphonesIcon(ctx: CGContext, centerX: CGFloat, centerY: CGFloat, size: CGFloat, color: CGColor) {
    ctx.saveGState()
    ctx.setStrokeColor(color)
    ctx.setLineWidth(size * 0.08)
    ctx.setLineCap(.round)
    // Arc (headband)
    ctx.addArc(center: CGPoint(x: centerX, y: centerY - size * 0.05), radius: size * 0.32,
               startAngle: .pi * 0.05, endAngle: .pi * 0.95, clockwise: false)
    ctx.strokePath()
    // Left ear cup
    let earW = size * 0.14
    let earH = size * 0.28
    let leftEarRect = CGRect(x: centerX - size * 0.38 - earW / 2, y: centerY - size * 0.30, width: earW, height: earH)
    let leftEarPath = CGPath(roundedRect: leftEarRect, cornerWidth: earW * 0.4, cornerHeight: earW * 0.4, transform: nil)
    ctx.setFillColor(color)
    ctx.addPath(leftEarPath)
    ctx.fillPath()
    // Right ear cup
    let rightEarRect = CGRect(x: centerX + size * 0.38 - earW / 2, y: centerY - size * 0.30, width: earW, height: earH)
    let rightEarPath = CGPath(roundedRect: rightEarRect, cornerWidth: earW * 0.4, cornerHeight: earW * 0.4, transform: nil)
    ctx.addPath(rightEarPath)
    ctx.fillPath()
    ctx.restoreGState()
}

func drawMicIcon(ctx: CGContext, centerX: CGFloat, centerY: CGFloat, size: CGFloat, color: CGColor) {
    ctx.saveGState()
    let lineW = size * 0.08
    ctx.setStrokeColor(color)
    ctx.setFillColor(color)
    ctx.setLineWidth(lineW)
    ctx.setLineCap(.round)
    // Capsule
    let capW = size * 0.22
    let capH = size * 0.38
    let capRect = CGRect(x: centerX - capW / 2, y: centerY, width: capW, height: capH)
    let capPath = CGPath(roundedRect: capRect, cornerWidth: capW / 2, cornerHeight: capW / 2, transform: nil)
    ctx.addPath(capPath)
    ctx.fillPath()
    // Holder arc
    let arcR = size * 0.20
    ctx.addArc(center: CGPoint(x: centerX, y: centerY + capH * 0.25), radius: arcR,
               startAngle: .pi * 0.15, endAngle: .pi * 0.85, clockwise: true)
    ctx.strokePath()
    // Stem
    ctx.move(to: CGPoint(x: centerX, y: centerY + capH * 0.25 - arcR))
    ctx.addLine(to: CGPoint(x: centerX, y: centerY - size * 0.22))
    ctx.strokePath()
    // Base
    ctx.move(to: CGPoint(x: centerX - size * 0.12, y: centerY - size * 0.22))
    ctx.addLine(to: CGPoint(x: centerX + size * 0.12, y: centerY - size * 0.22))
    ctx.strokePath()
    ctx.restoreGState()
}

func drawGearIcon(ctx: CGContext, centerX: CGFloat, centerY: CGFloat, size: CGFloat, color: CGColor) {
    ctx.saveGState()
    ctx.setFillColor(color)
    // Simple gear: circle with notches
    let outerR = size * 0.38
    let innerR = size * 0.24
    let teeth = 8
    let path = CGMutablePath()
    for i in 0..<(teeth * 2) {
        let angle = CGFloat(i) * .pi / CGFloat(teeth)
        let r = (i % 2 == 0) ? outerR : innerR
        let px = centerX + r * cos(angle)
        let py = centerY + r * sin(angle)
        if i == 0 { path.move(to: CGPoint(x: px, y: py)) }
        else { path.addLine(to: CGPoint(x: px, y: py)) }
    }
    path.closeSubpath()
    ctx.addPath(path)
    ctx.fillPath()
    // Inner hole
    ctx.setFillColor(popoverBg)
    let holeR = size * 0.13
    ctx.addArc(center: CGPoint(x: centerX, y: centerY), radius: holeR, startAngle: 0, endAngle: .pi * 2, clockwise: false)
    ctx.fillPath()
    ctx.restoreGState()
}

func drawBulletDot(ctx: CGContext, centerX: CGFloat, centerY: CGFloat, radius: CGFloat, color: CGColor) {
    ctx.saveGState()
    ctx.setFillColor(color)
    ctx.addArc(center: CGPoint(x: centerX, y: centerY), radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
    ctx.fillPath()
    ctx.restoreGState()
}

// MARK: - Toggle Helper

func drawToggle(ctx: CGContext, centerX: CGFloat, centerY: CGFloat, width: CGFloat, height: CGFloat, isOn: Bool) {
    let trackRect = CGRect(x: centerX - width / 2, y: centerY - height / 2, width: width, height: height)
    let trackRadius = height / 2
    let trackColor = isOn ? CGColor(srgbRed: 0.12, green: 0.68, blue: 0.70, alpha: 1.0) : CGColor(srgbRed: 0.3, green: 0.3, blue: 0.35, alpha: 1.0)
    drawRoundedRect(ctx: ctx, rect: trackRect, radius: trackRadius, fill: trackColor)
    let knobR = height * 0.38
    let knobX = isOn ? (centerX + width / 2 - height / 2) : (centerX - width / 2 + height / 2)
    ctx.saveGState()
    ctx.setFillColor(white100)
    ctx.addArc(center: CGPoint(x: knobX, y: centerY), radius: knobR, startAngle: 0, endAngle: .pi * 2, clockwise: false)
    ctx.fillPath()
    ctx.restoreGState()
}

// MARK: - Image Generation

func generateImage(width: Int, height: Int, draw: (CGContext, CGFloat, CGFloat) -> Void) -> Data? {
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
    let ctx = gfx.cgContext
    draw(ctx, CGFloat(width), CGFloat(height))
    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])
}

// MARK: - 1) Popover Mockup (1080x1350)

func generatePopoverMockup() -> Data? {
    return generateImage(width: 1080, height: 1350) { ctx, w, h in
        drawBackground(ctx: ctx, width: w, height: h)

        // Glow behind popover
        let popoverCenterY = h * 0.58
        drawSubtleGlow(ctx: ctx, centerX: w / 2, centerY: popoverCenterY, radius: 400)

        // --- Popover window ---
        let popW: CGFloat = 560
        let popH: CGFloat = 640
        let popX = (w - popW) / 2
        let popY = popoverCenterY - popH / 2 + 40
        let popRadius: CGFloat = 18

        // Shadow
        ctx.saveGState()
        ctx.setShadow(offset: CGSize(width: 0, height: -12), blur: 50,
                       color: CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 0.5))
        drawRoundedRect(ctx: ctx, rect: CGRect(x: popX, y: popY, width: popW, height: popH),
                        radius: popRadius, fill: popoverBg)
        ctx.restoreGState()

        // Popover body
        drawRoundedRect(ctx: ctx, rect: CGRect(x: popX, y: popY, width: popW, height: popH),
                        radius: popRadius, fill: popoverBg)
        drawRoundedRectStroke(ctx: ctx, rect: CGRect(x: popX, y: popY, width: popW, height: popH),
                              radius: popRadius, stroke: white10, lineWidth: 1)

        // Small arrow at top center of popover
        let arrowSize: CGFloat = 14
        ctx.saveGState()
        ctx.setFillColor(popoverBg)
        let arrowPath = CGMutablePath()
        arrowPath.move(to: CGPoint(x: w / 2 - arrowSize, y: popY + popH))
        arrowPath.addLine(to: CGPoint(x: w / 2, y: popY + popH + arrowSize))
        arrowPath.addLine(to: CGPoint(x: w / 2 + arrowSize, y: popY + popH))
        arrowPath.closeSubpath()
        ctx.addPath(arrowPath)
        ctx.fillPath()
        ctx.restoreGState()

        // Title: "input devices"
        let titleY = popY + popH - 50
        let leftPad = popX + 30
        let rightPad = popX + popW - 30

        drawLeftText("input devices", ctx: ctx, x: leftPad, centerY: titleY,
                     fontSize: 16, fontWeight: .medium, color: white40)

        // --- Device rows ---
        let rowH: CGFloat = 76
        let rowInset: CGFloat = 16
        let rowW = popW - rowInset * 2
        let rowRadius: CGFloat = 12
        let iconColX = leftPad + 12
        let textColX = leftPad + 60
        let checkColX = rightPad - 20

        struct DeviceRow {
            let name: String
            let icon: String  // "laptop", "headphones", "mic"
            let isSelected: Bool
        }

        let devices = [
            DeviceRow(name: "macbook pro microphone", icon: "laptop", isSelected: true),
            DeviceRow(name: "airpods max", icon: "headphones", isSelected: false),
            DeviceRow(name: "blue yeti", icon: "mic", isSelected: false),
        ]

        for (i, device) in devices.enumerated() {
            let rowY = titleY - 50 - CGFloat(i) * (rowH + 8)
            let rowRect = CGRect(x: popX + rowInset, y: rowY - rowH + 20, width: rowW, height: rowH)

            if device.isSelected {
                drawRoundedRect(ctx: ctx, rect: rowRect, radius: rowRadius, fill: highlightBg)
                drawRoundedRectStroke(ctx: ctx, rect: rowRect, radius: rowRadius,
                                     stroke: CGColor(srgbRed: 0.12, green: 0.60, blue: 0.80, alpha: 0.3), lineWidth: 1)
            } else {
                drawRoundedRect(ctx: ctx, rect: rowRect, radius: rowRadius, fill: popoverRow)
            }

            let rowCenterY = rowRect.midY
            let iconSize: CGFloat = 32

            // Draw device icon
            switch device.icon {
            case "laptop":
                drawLaptopIcon(ctx: ctx, centerX: iconColX + 16, centerY: rowCenterY, size: iconSize, color: device.isSelected ? tealBright : white60)
            case "headphones":
                drawHeadphonesIcon(ctx: ctx, centerX: iconColX + 16, centerY: rowCenterY, size: iconSize, color: white60)
            case "mic":
                drawMicIcon(ctx: ctx, centerX: iconColX + 16, centerY: rowCenterY, size: iconSize, color: white60)
            default: break
            }

            // Device name
            let nameColor = device.isSelected ? white100 : white80
            drawLeftText(device.name, ctx: ctx, x: textColX + 8, centerY: rowCenterY,
                         fontSize: 18, fontWeight: device.isSelected ? .semibold : .regular, color: nameColor)

            // Checkmark for selected
            if device.isSelected {
                drawCheckmark(ctx: ctx, centerX: checkColX, centerY: rowCenterY, size: 16, color: tealBright)
            }
        }

        // Divider
        let dividerY = titleY - 50 - CGFloat(devices.count) * (rowH + 8) + 10
        ctx.saveGState()
        ctx.setStrokeColor(white10)
        ctx.setLineWidth(1)
        ctx.move(to: CGPoint(x: popX + rowInset, y: dividerY))
        ctx.addLine(to: CGPoint(x: popX + popW - rowInset, y: dividerY))
        ctx.strokePath()
        ctx.restoreGState()

        // Settings and Quit buttons
        let btnH: CGFloat = 44
        let btnY1 = dividerY - 16 - btnH
        let btnY2 = btnY1 - 8 - btnH
        let btnW = popW - rowInset * 2

        // Settings button
        let settBtnRect = CGRect(x: popX + rowInset, y: btnY1, width: btnW, height: btnH)
        drawRoundedRect(ctx: ctx, rect: settBtnRect, radius: 10, fill: popoverRow)
        drawGearIcon(ctx: ctx, centerX: popX + rowInset + 30, centerY: settBtnRect.midY, size: 20, color: white60)
        drawLeftText("settings", ctx: ctx, x: popX + rowInset + 50, centerY: settBtnRect.midY,
                     fontSize: 16, fontWeight: .regular, color: white60)

        // Quit button
        let quitBtnRect = CGRect(x: popX + rowInset, y: btnY2, width: btnW, height: btnH)
        drawRoundedRect(ctx: ctx, rect: quitBtnRect, radius: 10, fill: popoverRow)
        // X icon for quit
        ctx.saveGState()
        let qx = popX + rowInset + 30
        let qy = quitBtnRect.midY
        let qs: CGFloat = 7
        ctx.setStrokeColor(white40)
        ctx.setLineWidth(2)
        ctx.setLineCap(.round)
        ctx.move(to: CGPoint(x: qx - qs, y: qy - qs))
        ctx.addLine(to: CGPoint(x: qx + qs, y: qy + qs))
        ctx.move(to: CGPoint(x: qx + qs, y: qy - qs))
        ctx.addLine(to: CGPoint(x: qx - qs, y: qy + qs))
        ctx.strokePath()
        ctx.restoreGState()
        drawLeftText("quit", ctx: ctx, x: popX + rowInset + 50, centerY: quitBtnRect.midY,
                     fontSize: 16, fontWeight: .regular, color: white40)

        // --- Title and tagline below the popover ---
        let brandY = popY - 60
        drawCenteredText("control input", ctx: ctx, centerX: w / 2, centerY: brandY,
                         fontSize: 40, fontWeight: .bold, color: white100)
        drawCenteredText("one click. right mic.", ctx: ctx, centerX: w / 2, centerY: brandY - 50,
                         fontSize: 22, fontWeight: .regular, color: tealDim)
    }
}

// MARK: - 2) Settings Mockup (1080x1350)

func generateSettingsMockup() -> Data? {
    return generateImage(width: 1080, height: 1350) { ctx, w, h in
        drawBackground(ctx: ctx, width: w, height: h)

        let winCenterY = h * 0.58
        drawSubtleGlow(ctx: ctx, centerX: w / 2, centerY: winCenterY, radius: 400)

        // --- Settings window ---
        let winW: CGFloat = 620
        let winH: CGFloat = 700
        let winX = (w - winW) / 2
        let winY = winCenterY - winH / 2 + 30
        let winRadius: CGFloat = 16

        // Shadow
        ctx.saveGState()
        ctx.setShadow(offset: CGSize(width: 0, height: -10), blur: 45,
                       color: CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 0.5))
        drawRoundedRect(ctx: ctx, rect: CGRect(x: winX, y: winY, width: winW, height: winH),
                        radius: winRadius, fill: settingsBg)
        ctx.restoreGState()

        drawRoundedRect(ctx: ctx, rect: CGRect(x: winX, y: winY, width: winW, height: winH),
                        radius: winRadius, fill: settingsBg)
        drawRoundedRectStroke(ctx: ctx, rect: CGRect(x: winX, y: winY, width: winW, height: winH),
                              radius: winRadius, stroke: white10, lineWidth: 1)

        // Title bar area
        let titleBarY = winY + winH - 48
        // Traffic lights
        let tlY = titleBarY + 18
        let tlStartX = winX + 22
        let colors = [
            CGColor(srgbRed: 0.95, green: 0.30, blue: 0.25, alpha: 1),
            CGColor(srgbRed: 0.95, green: 0.75, blue: 0.20, alpha: 1),
            CGColor(srgbRed: 0.25, green: 0.80, blue: 0.30, alpha: 1),
        ]
        for (i, c) in colors.enumerated() {
            ctx.saveGState()
            ctx.setFillColor(c)
            ctx.addArc(center: CGPoint(x: tlStartX + CGFloat(i) * 22, y: tlY), radius: 7,
                       startAngle: 0, endAngle: .pi * 2, clockwise: false)
            ctx.fillPath()
            ctx.restoreGState()
        }
        drawCenteredText("settings", ctx: ctx, centerX: w / 2, centerY: tlY,
                         fontSize: 16, fontWeight: .medium, color: white60)

        // Divider under title bar
        ctx.saveGState()
        ctx.setStrokeColor(white10)
        ctx.setLineWidth(1)
        ctx.move(to: CGPoint(x: winX, y: titleBarY - 4))
        ctx.addLine(to: CGPoint(x: winX + winW, y: titleBarY - 4))
        ctx.strokePath()
        ctx.restoreGState()

        // --- Sections ---
        let sectionInset: CGFloat = 24
        let sectionW = winW - sectionInset * 2
        let sectionRadius: CGFloat = 12
        let labelFontSize: CGFloat = 15
        let valueFontSize: CGFloat = 15

        struct SettingField {
            let label: String
            let value: String
            let isToggle: Bool
            let toggleOn: Bool
            init(_ label: String, _ value: String, isToggle: Bool = false, toggleOn: Bool = false) {
                self.label = label
                self.value = value
                self.isToggle = isToggle
                self.toggleOn = toggleOn
            }
        }

        struct Section {
            let title: String
            let fields: [SettingField]
        }

        let sections = [
            Section(title: "audio", fields: [
                SettingField("preferred input", "macbook pro microphone"),
                SettingField("auto-switch", "", isToggle: true, toggleOn: true),
            ]),
            Section(title: "appearance", fields: [
                SettingField("theme", "system"),
            ]),
            Section(title: "general", fields: [
                SettingField("launch at login", "", isToggle: true, toggleOn: true),
            ]),
        ]

        var cursorY = titleBarY - 30  // below title bar
        let fieldH: CGFloat = 52
        let sectionPadTop: CGFloat = 44
        let sectionPadBottom: CGFloat = 14
        let sectionGap: CGFloat = 22

        for section in sections {
            let sectionH = sectionPadTop + CGFloat(section.fields.count) * fieldH + sectionPadBottom
            let sectionY = cursorY - sectionH
            let sectionRect = CGRect(x: winX + sectionInset, y: sectionY, width: sectionW, height: sectionH)
            drawRoundedRect(ctx: ctx, rect: sectionRect, radius: sectionRadius, fill: sectionBg)

            // Section title
            drawLeftText(section.title, ctx: ctx, x: winX + sectionInset + 20,
                         centerY: sectionY + sectionH - 30,
                         fontSize: 13, fontWeight: .semibold, color: white40)

            // Fields
            for (i, field) in section.fields.enumerated() {
                let fieldY = sectionY + sectionH - sectionPadTop - CGFloat(i) * fieldH - fieldH / 2
                let fieldLeftX = winX + sectionInset + 20
                let fieldRightX = winX + sectionInset + sectionW - 20

                drawLeftText(field.label, ctx: ctx, x: fieldLeftX, centerY: fieldY,
                             fontSize: labelFontSize, fontWeight: .regular, color: white80)

                if field.isToggle {
                    drawToggle(ctx: ctx, centerX: fieldRightX - 28, centerY: fieldY, width: 48, height: 28, isOn: field.toggleOn)
                } else {
                    drawRightText(field.value, ctx: ctx, rightX: fieldRightX, centerY: fieldY,
                                  fontSize: valueFontSize, fontWeight: .regular, color: tealDim)
                }

                // Divider between fields (not after last)
                if i < section.fields.count - 1 {
                    let divY = fieldY - fieldH / 2
                    ctx.saveGState()
                    ctx.setStrokeColor(white06)
                    ctx.setLineWidth(1)
                    ctx.move(to: CGPoint(x: fieldLeftX, y: divY))
                    ctx.addLine(to: CGPoint(x: fieldRightX, y: divY))
                    ctx.strokePath()
                    ctx.restoreGState()
                }
            }

            cursorY = sectionY - sectionGap
        }

        // --- Title and tagline below ---
        let brandY = winY - 60
        drawCenteredText("control input", ctx: ctx, centerX: w / 2, centerY: brandY,
                         fontSize: 40, fontWeight: .bold, color: white100)
        drawCenteredText("set it. forget it.", ctx: ctx, centerX: w / 2, centerY: brandY - 50,
                         fontSize: 22, fontWeight: .regular, color: tealDim)
    }
}

// MARK: - 3) Hero Mobile (1080x1920, Stories)

func generateHeroMobile() -> Data? {
    return generateImage(width: 1080, height: 1920) { ctx, w, h in
        drawBackground(ctx: ctx, width: w, height: h)

        // Large glow
        drawSubtleGlow(ctx: ctx, centerX: w / 2, centerY: h * 0.70, radius: 500)
        drawSubtleGlow(ctx: ctx, centerX: w / 2, centerY: h * 0.70, radius: 300)

        // App icon in upper third
        let iconSize: CGFloat = 200
        let iconX = (w - iconSize) / 2
        let iconY = h * 0.64
        drawAppIcon(ctx: ctx, originX: iconX, originY: iconY, iconSize: iconSize)

        // "control input" large text
        let titleY = iconY - 50
        drawCenteredText("control input", ctx: ctx, centerX: w / 2, centerY: titleY,
                         fontSize: 56, fontWeight: .bold, color: white100)

        // Tagline
        drawCenteredText("take back your microphone.", ctx: ctx, centerX: w / 2, centerY: titleY - 65,
                         fontSize: 24, fontWeight: .regular, color: white60)

        // Feature bullets
        let bulletStartY = titleY - 160
        let bulletSpacing: CGFloat = 60
        let bullets = [
            "one-click switching",
            "auto-switch to preferred mic",
            "lives in your menu bar",
        ]

        for (i, bullet) in bullets.enumerated() {
            let by = bulletStartY - CGFloat(i) * bulletSpacing
            let dotX = w / 2 - 210
            let textX = dotX + 20

            // Teal dot
            drawBulletDot(ctx: ctx, centerX: dotX, centerY: by, radius: 5, color: tealBright)

            // Bullet text
            drawLeftText(bullet, ctx: ctx, x: textX, centerY: by,
                         fontSize: 22, fontWeight: .medium, color: white80)
        }
    }
}

// MARK: - Export

let outputDir = "marketing"

let tasks: [(String, () -> Data?, String)] = [
    ("ui-popover.png", generatePopoverMockup, "1080x1350"),
    ("ui-settings.png", generateSettingsMockup, "1080x1350"),
    ("ui-hero-mobile.png", generateHeroMobile, "1080x1920"),
]

for (filename, generator, dims) in tasks {
    if let data = generator() {
        let path = "\(outputDir)/\(filename)"
        try! data.write(to: URL(fileURLWithPath: path))
        print("wrote \(path) (\(dims))")
    } else {
        print("failed to generate \(filename)")
    }
}

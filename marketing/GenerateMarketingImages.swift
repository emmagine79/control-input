#!/usr/bin/env swift
// Generates marketing images for Control Input.
// Run:  swift marketing/GenerateMarketingImages.swift

import Cocoa
import CoreText

// MARK: - Microphone Drawing (from GenerateIcon.swift)

func drawMicrophone(ctx: CGContext, size s: CGFloat) {
    ctx.saveGState()

    let cx = s / 2
    let white95 = CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.95)
    let lineW = s * 0.035

    let capsuleW = s * 0.20
    let capsuleH = s * 0.30
    let capsuleBottom = s * 0.48
    let capsuleTop = capsuleBottom + capsuleH

    // Mic capsule
    ctx.setFillColor(white95)
    let capsuleRect = CGRect(x: cx - capsuleW / 2, y: capsuleBottom,
                              width: capsuleW, height: capsuleH)
    let capsulePath = CGPath(roundedRect: capsuleRect,
                              cornerWidth: capsuleW / 2,
                              cornerHeight: capsuleW / 2,
                              transform: nil)
    ctx.addPath(capsulePath)
    ctx.fillPath()

    // Holder arc
    ctx.setStrokeColor(white95)
    ctx.setLineWidth(lineW)
    ctx.setLineCap(.round)

    let arcCenterY = capsuleBottom + capsuleH * 0.30
    let arcRadius = s * 0.17

    ctx.addArc(center: CGPoint(x: cx, y: arcCenterY),
               radius: arcRadius,
               startAngle: .pi * 0.2,
               endAngle: .pi * 0.8,
               clockwise: true)
    ctx.strokePath()

    // Stem
    let stemTop = arcCenterY - arcRadius
    let stemBottom = s * 0.22
    ctx.move(to: CGPoint(x: cx, y: stemTop))
    ctx.addLine(to: CGPoint(x: cx, y: stemBottom))
    ctx.strokePath()

    // Base
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

    // Background squircle
    let inset: CGFloat = s * 0.05
    let rect = CGRect(x: inset, y: inset, width: s - inset * 2, height: s - inset * 2)
    let radius = s * 0.225
    let squircle = CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)

    // Gradient: teal to blue
    ctx.saveGState()
    ctx.addPath(squircle)
    ctx.clip()

    let iconColors = [
        CGColor(srgbRed: 0.12, green: 0.78, blue: 0.80, alpha: 1.0),
        CGColor(srgbRed: 0.10, green: 0.42, blue: 0.85, alpha: 1.0),
    ]
    let iconGrad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                               colors: iconColors as CFArray,
                               locations: [0.0, 1.0])!
    ctx.drawLinearGradient(iconGrad,
                            start: CGPoint(x: s / 2, y: s * 0.95),
                            end: CGPoint(x: s / 2, y: s * 0.05),
                            options: [])

    // Glass highlight
    let highlightRect = CGRect(x: inset, y: s * 0.48, width: s - inset * 2, height: s * 0.52 - inset)
    let highlightPath = CGPath(roundedRect: highlightRect, cornerWidth: radius, cornerHeight: radius, transform: nil)
    ctx.addPath(highlightPath)
    ctx.clip()

    let glassColors = [
        CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.32),
        CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.04),
    ]
    let glassGrad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                colors: glassColors as CFArray,
                                locations: [0.0, 1.0])!
    ctx.drawLinearGradient(glassGrad,
                            start: CGPoint(x: s / 2, y: s * 0.95),
                            end: CGPoint(x: s / 2, y: s * 0.48),
                            options: [])
    ctx.restoreGState()

    // Inner border
    ctx.saveGState()
    ctx.addPath(squircle)
    ctx.setStrokeColor(CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.18))
    ctx.setLineWidth(s * 0.012)
    ctx.strokePath()
    ctx.restoreGState()

    // Microphone
    drawMicrophone(ctx: ctx, size: s)

    ctx.restoreGState()
}

// MARK: - Text Drawing with CoreText

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

// MARK: - Background Gradient

func drawBackground(ctx: CGContext, width: CGFloat, height: CGFloat) {
    let bgColors = [
        CGColor(srgbRed: 0.04, green: 0.08, blue: 0.16, alpha: 1.0),
        CGColor(srgbRed: 0.06, green: 0.14, blue: 0.28, alpha: 1.0),
        CGColor(srgbRed: 0.04, green: 0.10, blue: 0.22, alpha: 1.0),
    ]
    let bgGrad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                             colors: bgColors as CFArray,
                             locations: [0.0, 0.5, 1.0])!
    ctx.drawLinearGradient(bgGrad,
                            start: CGPoint(x: 0, y: 0),
                            end: CGPoint(x: width, y: height),
                            options: [])
}

func drawSubtleGlow(ctx: CGContext, centerX: CGFloat, centerY: CGFloat, radius: CGFloat) {
    let glowColors = [
        CGColor(srgbRed: 0.10, green: 0.50, blue: 0.70, alpha: 0.15),
        CGColor(srgbRed: 0.10, green: 0.50, blue: 0.70, alpha: 0.0),
    ]
    let glowGrad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                               colors: glowColors as CFArray,
                               locations: [0.0, 1.0])!
    ctx.drawRadialGradient(glowGrad,
                            startCenter: CGPoint(x: centerX, y: centerY),
                            startRadius: 0,
                            endCenter: CGPoint(x: centerX, y: centerY),
                            endRadius: radius,
                            options: [])
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

// MARK: - Hero Image (1200x630)

func generateHero() -> Data? {
    return generateImage(width: 1200, height: 630) { ctx, w, h in
        // Background
        drawBackground(ctx: ctx, width: w, height: h)

        // Subtle glow behind icon
        drawSubtleGlow(ctx: ctx, centerX: w / 2, centerY: h * 0.55, radius: 280)

        // App icon centered, offset slightly upward
        let iconSize: CGFloat = 180
        let iconX = (w - iconSize) / 2
        let iconY = h * 0.45
        drawAppIcon(ctx: ctx, originX: iconX, originY: iconY, iconSize: iconSize)

        // App name below icon
        let white = CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 1.0)
        let white60 = CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.6)

        drawCenteredText("Control Input", ctx: ctx,
                         centerX: w / 2, centerY: h * 0.32,
                         fontSize: 48, fontWeight: .bold, color: white)

        // Tagline
        drawCenteredText("Take back your microphone.", ctx: ctx,
                         centerX: w / 2, centerY: h * 0.20,
                         fontSize: 22, fontWeight: .regular, color: white60)
    }
}

// MARK: - Banner Image (1280x640)

func generateBanner() -> Data? {
    return generateImage(width: 1280, height: 640) { ctx, w, h in
        // Background
        drawBackground(ctx: ctx, width: w, height: h)

        // Subtle glow behind icon
        drawSubtleGlow(ctx: ctx, centerX: w / 2, centerY: h * 0.55, radius: 300)

        // App icon
        let iconSize: CGFloat = 160
        let iconX = (w - iconSize) / 2
        let iconY = h * 0.48
        drawAppIcon(ctx: ctx, originX: iconX, originY: iconY, iconSize: iconSize)

        // App name
        let white = CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 1.0)
        let white60 = CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.6)
        let white40 = CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.4)

        drawCenteredText("Control Input", ctx: ctx,
                         centerX: w / 2, centerY: h * 0.34,
                         fontSize: 46, fontWeight: .bold, color: white)

        // Tagline
        drawCenteredText("Take back your microphone.", ctx: ctx,
                         centerX: w / 2, centerY: h * 0.22,
                         fontSize: 20, fontWeight: .regular, color: white60)

        // Subtitle
        drawCenteredText("A lightweight macOS menu bar utility for switching audio input devices.", ctx: ctx,
                         centerX: w / 2, centerY: h * 0.14,
                         fontSize: 14, fontWeight: .regular, color: white40)
    }
}

// MARK: - Export

let outputDir = "marketing"

if let heroData = generateHero() {
    let path = "\(outputDir)/hero.png"
    try! heroData.write(to: URL(fileURLWithPath: path))
    print("Wrote \(path) (1200x630)")
} else {
    print("Failed to generate hero image")
}

if let bannerData = generateBanner() {
    let path = "\(outputDir)/banner.png"
    try! bannerData.write(to: URL(fileURLWithPath: path))
    print("Wrote \(path) (1280x640)")
} else {
    print("Failed to generate banner image")
}

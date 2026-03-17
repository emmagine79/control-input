#!/usr/bin/env swift
// Generates a glass-style macOS app icon for Control Input.
// Run:  swift GenerateIcon.swift

import Cocoa

// MARK: - Icon Sizes (macOS)

let sizes: [(points: Int, scale: Int)] = [
    (16, 1), (16, 2),
    (32, 1), (32, 2),
    (128, 1), (128, 2),
    (256, 1), (256, 2),
    (512, 1), (512, 2),
]

// MARK: - Drawing

func drawIcon(size px: Int) -> Data? {
    // Use NSBitmapImageRep to get exact pixel dimensions (avoids Retina 2x scaling).
    guard let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: px, pixelsHigh: px,
        bitsPerSample: 8, samplesPerPixel: 4,
        hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0, bitsPerPixel: 0
    ) else { return nil }
    rep.size = NSSize(width: px, height: px)

    guard let gfx = NSGraphicsContext(bitmapImageRep: rep) else { return nil }
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = gfx
    let ctx = gfx.cgContext

    let s = CGFloat(px)

    // ── Background squircle ──
    let inset: CGFloat = s * 0.05
    let rect = CGRect(x: inset, y: inset, width: s - inset * 2, height: s - inset * 2)
    let radius = s * 0.225   // macOS-style continuous corner radius
    let squircle = CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)

    // Gradient: deep teal → rich blue
    ctx.saveGState()
    ctx.addPath(squircle)
    ctx.clip()

    let colors = [
        CGColor(srgbRed: 0.12, green: 0.78, blue: 0.80, alpha: 1.0),
        CGColor(srgbRed: 0.10, green: 0.42, blue: 0.85, alpha: 1.0),
    ]
    let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                               colors: colors as CFArray,
                               locations: [0.0, 1.0])!
    ctx.drawLinearGradient(gradient,
                            start: CGPoint(x: s / 2, y: s * 0.95),
                            end: CGPoint(x: s / 2, y: s * 0.05),
                            options: [])

    // Glass highlight (top half, translucent white overlay)
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

    // Subtle inner border for glass depth
    ctx.saveGState()
    ctx.addPath(squircle)
    ctx.setStrokeColor(CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.18))
    ctx.setLineWidth(s * 0.012)
    ctx.strokePath()
    ctx.restoreGState()

    // ── Microphone icon (white, centered) ──
    drawMicrophone(ctx: ctx, size: s)

    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])
}

func drawMicrophone(ctx: CGContext, size s: CGFloat) {
    ctx.saveGState()

    let cx = s / 2
    let white95 = CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.95)
    let lineW = s * 0.035

    // ── Layout (y-up coordinate system: higher y = higher on screen) ──
    let capsuleW = s * 0.20
    let capsuleH = s * 0.30
    let capsuleBottom = s * 0.48           // bottom edge of mic capsule
    let capsuleTop = capsuleBottom + capsuleH

    // ── 1. Mic capsule (pill shape) ──
    ctx.setFillColor(white95)
    let capsuleRect = CGRect(x: cx - capsuleW / 2, y: capsuleBottom,
                              width: capsuleW, height: capsuleH)
    let capsulePath = CGPath(roundedRect: capsuleRect,
                              cornerWidth: capsuleW / 2,
                              cornerHeight: capsuleW / 2,
                              transform: nil)
    ctx.addPath(capsulePath)
    ctx.fillPath()

    // ── 2. Holder arc (U-shape below the capsule) ──
    ctx.setStrokeColor(white95)
    ctx.setLineWidth(lineW)
    ctx.setLineCap(.round)

    let arcCenterY = capsuleBottom + capsuleH * 0.30  // arc centered partway up capsule
    let arcRadius = s * 0.17

    // In y-up coords: sweep from upper-right (0.2π) → bottom → upper-left (0.8π)
    // clockwise = true means decreasing angle direction = right → down → left  ✓
    ctx.addArc(center: CGPoint(x: cx, y: arcCenterY),
               radius: arcRadius,
               startAngle: .pi * 0.2,
               endAngle: .pi * 0.8,
               clockwise: true)
    ctx.strokePath()

    // ── 3. Stem (vertical line from arc bottom to base) ──
    let stemTop = arcCenterY - arcRadius
    let stemBottom = s * 0.22
    ctx.move(to: CGPoint(x: cx, y: stemTop))
    ctx.addLine(to: CGPoint(x: cx, y: stemBottom))
    ctx.strokePath()

    // ── 4. Base (horizontal line) ──
    let baseW = s * 0.16
    ctx.move(to: CGPoint(x: cx - baseW / 2, y: stemBottom))
    ctx.addLine(to: CGPoint(x: cx + baseW / 2, y: stemBottom))
    ctx.strokePath()

    ctx.restoreGState()
}

// MARK: - Export

let assetDir = "ControlInput/Assets.xcassets/AppIcon.appiconset"

// Generate each size
var images: [(filename: String, points: Int, scale: Int)] = []
for (points, scale) in sizes {
    let px = points * scale
    guard let png = drawIcon(size: px) else {
        print("Failed to generate \(points)x\(points)@\(scale)x")
        continue
    }

    let filename = "icon_\(points)x\(points)@\(scale)x.png"
    let path = "\(assetDir)/\(filename)"
    do {
        try png.write(to: URL(fileURLWithPath: path))
        images.append((filename, points, scale))
        print("Wrote \(path) (\(px)x\(px) px)")
    } catch {
        print("Error writing \(path): \(error)")
    }
}

// Write updated Contents.json
var imageEntries: [String] = []
for (filename, points, scale) in images {
    imageEntries.append("""
        {
          "filename" : "\(filename)",
          "idiom" : "mac",
          "scale" : "\(scale)x",
          "size" : "\(points)x\(points)"
        }
    """)
}

let contentsJSON = """
{
  "images" : [
\(imageEntries.joined(separator: ",\n"))
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
"""
try! contentsJSON.write(toFile: "\(assetDir)/Contents.json", atomically: true, encoding: .utf8)
print("Updated Contents.json")

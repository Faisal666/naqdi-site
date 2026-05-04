#!/usr/bin/env swift
// Generate naqdi-site favicons + Open Graph preview image from the
// master 1024×1024 app icon.
//
// Run:
//   cd naqdi-site
//   swift scripts/generate_web_icons.swift
//
// Outputs (committed to repo):
//   icons/favicon-16.png
//   icons/favicon-32.png
//   icons/favicon-180.png   ← apple-touch-icon
//   icons/favicon-192.png
//   icons/favicon-512.png
//   icons/og-image.png      ← 1200×630 share card
//
// AppKit-only, no dependencies.

import Foundation
import AppKit

// MARK: - Paths

let fm = FileManager.default
let cwd = fm.currentDirectoryPath
let masterPath = "\(cwd)/../Naqdi/Naqdi/Assets.xcassets/AppIcon.appiconset/icon.png"
let outDir = "\(cwd)/icons"

guard let masterIcon = NSImage(contentsOfFile: masterPath) else {
    FileHandle.standardError.write(Data("error: cannot read master icon at \(masterPath)\n".utf8))
    exit(1)
}

try? fm.createDirectory(atPath: outDir, withIntermediateDirectories: true)

// MARK: - Helpers

func writePNG(_ image: NSImage, to path: String) {
    guard
        let tiff = image.tiffRepresentation,
        let rep = NSBitmapImageRep(data: tiff),
        let png = rep.representation(using: .png, properties: [:])
    else {
        FileHandle.standardError.write(Data("error: PNG encode failed for \(path)\n".utf8))
        return
    }
    try? png.write(to: URL(fileURLWithPath: path))
    print("✓ \(path)")
}

func resized(_ src: NSImage, to size: CGSize) -> NSImage {
    let img = NSImage(size: size)
    img.lockFocus()
    NSGraphicsContext.current?.imageInterpolation = .high
    src.draw(
        in: NSRect(origin: .zero, size: size),
        from: NSRect(origin: .zero, size: src.size),
        operation: .copy,
        fraction: 1.0
    )
    img.unlockFocus()
    return img
}

// MARK: - Favicons

let faviconSizes: [Int] = [16, 32, 180, 192, 512]
for s in faviconSizes {
    let img = resized(masterIcon, to: CGSize(width: s, height: s))
    writePNG(img, to: "\(outDir)/favicon-\(s).png")
}

// MARK: - Open Graph card (1200×630, parchment editorial)

let ogSize = CGSize(width: 1200, height: 630)
let og = NSImage(size: ogSize)
og.lockFocus()
guard let ctx = NSGraphicsContext.current?.cgContext else {
    og.unlockFocus()
    fatalError("no CG context")
}

// Parchment background
let parchment = NSColor(srgbRed: 0.957, green: 0.937, blue: 0.894, alpha: 1.0)
parchment.setFill()
NSRect(origin: .zero, size: ogSize).fill()

// Teal radial glow (top)
let teal = NSColor(srgbRed: 0.055, green: 0.416, blue: 0.345, alpha: 1.0)
let amber = NSColor(srgbRed: 0.78, green: 0.478, blue: 0.11, alpha: 1.0)
let ink = NSColor(srgbRed: 0.06, green: 0.067, blue: 0.082, alpha: 1.0)
let inkSoft = NSColor(srgbRed: 0.36, green: 0.325, blue: 0.278, alpha: 1.0)

func radialGlow(center: CGPoint, color: NSColor, radius: CGFloat, alpha: CGFloat) {
    let colors = [color.withAlphaComponent(alpha).cgColor, color.withAlphaComponent(0).cgColor]
    let space = CGColorSpaceCreateDeviceRGB()
    if let grad = CGGradient(colorsSpace: space, colors: colors as CFArray, locations: [0, 1]) {
        ctx.drawRadialGradient(
            grad,
            startCenter: center, startRadius: 0,
            endCenter: center, endRadius: radius,
            options: []
        )
    }
}

radialGlow(center: CGPoint(x: 200, y: 540), color: teal, radius: 520, alpha: 0.18)
radialGlow(center: CGPoint(x: 1050, y: 90), color: amber, radius: 480, alpha: 0.16)

// Hairline frame (editorial vibe)
let ruleColor = NSColor(srgbRed: 0.85, green: 0.812, blue: 0.722, alpha: 1.0)
ruleColor.setStroke()
let frame = NSBezierPath(rect: NSRect(x: 32, y: 32, width: ogSize.width - 64, height: ogSize.height - 64))
frame.lineWidth = 1
frame.stroke()

// Tiny "section tag" top-left: a small dash + uppercase mono
let monoFont = NSFont(name: "IBM Plex Mono", size: 16)
    ?? NSFont.monospacedSystemFont(ofSize: 16, weight: .medium)
let tag = "FIG. 01 · INVOICING, REIMAGINED"
let tagAttrs: [NSAttributedString.Key: Any] = [
    .font: monoFont,
    .foregroundColor: inkSoft,
    .kern: 2.5
]
ruleColor.setStroke()
let dash = NSBezierPath()
dash.move(to: CGPoint(x: 64, y: 562))
dash.line(to: CGPoint(x: 92, y: 562))
dash.lineWidth = 1
dash.stroke()
NSString(string: tag).draw(at: NSPoint(x: 104, y: 552), withAttributes: tagAttrs)

// App icon, large, slightly off-center to the left
let iconSize: CGFloat = 220
let iconRect = NSRect(
    x: (ogSize.width - iconSize) / 2 - 8,
    y: ogSize.height - 280,
    width: iconSize,
    height: iconSize
)
// Subtle shadow under the icon
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -16), blur: 40, color: NSColor.black.withAlphaComponent(0.18).cgColor)
masterIcon.draw(in: iconRect)
ctx.restoreGState()

// Wordmark — Fraunces serif if installed, fall back to NY/system serif
let serif = NSFont(name: "Fraunces", size: 100)
    ?? NSFont(name: "New York", size: 100)
    ?? NSFont(descriptor: NSFont.systemFont(ofSize: 100).fontDescriptor.withSymbolicTraits(.italic), size: 100)
    ?? NSFont.systemFont(ofSize: 100, weight: .light)

let wordmark = "نقدي · Naqdi"
let wordParas = NSMutableParagraphStyle()
wordParas.alignment = .center
let wordAttrs: [NSAttributedString.Key: Any] = [
    .font: serif,
    .foregroundColor: ink,
    .kern: -2.5,
    .paragraphStyle: wordParas
]
let wordRect = NSRect(x: 0, y: 200, width: ogSize.width, height: 120)
NSString(string: wordmark).draw(in: wordRect, withAttributes: wordAttrs)

// Tagline — IBM Plex Sans / system
let body = NSFont(name: "IBM Plex Sans", size: 26)
    ?? NSFont.systemFont(ofSize: 26, weight: .regular)
let tagline = "Invoicing & VAT, without the headache."
let lineParas = NSMutableParagraphStyle()
lineParas.alignment = .center
let lineAttrs: [NSAttributedString.Key: Any] = [
    .font: body,
    .foregroundColor: inkSoft,
    .paragraphStyle: lineParas
]
NSString(string: tagline).draw(in: NSRect(x: 0, y: 152, width: ogSize.width, height: 40), withAttributes: lineAttrs)

// Domain footer (mono, small, centered)
let footMono = NSFont(name: "IBM Plex Mono", size: 16)
    ?? NSFont.monospacedSystemFont(ofSize: 16, weight: .medium)
let foot = "naqdiapp.com  ·  Made in الرياض"
let footAttrs: [NSAttributedString.Key: Any] = [
    .font: footMono,
    .foregroundColor: inkSoft,
    .kern: 2.0,
    .paragraphStyle: lineParas
]
NSString(string: foot).draw(in: NSRect(x: 0, y: 78, width: ogSize.width, height: 30), withAttributes: footAttrs)

og.unlockFocus()
writePNG(og, to: "\(outDir)/og-image.png")

print("\nDone. \(faviconSizes.count) favicons + 1 OG card written to \(outDir).")

import AppKit
import Foundation

struct IconSpec {
    let points: Int
    let scale: Int

    var pixels: Int { points * scale }
    var filename: String {
        if scale == 1 {
            return "icon_\(points)x\(points).png"
        }
        return "icon_\(points)x\(points)@\(scale)x.png"
    }
}

let specs: [IconSpec] = [
    .init(points: 16, scale: 1),
    .init(points: 16, scale: 2),
    .init(points: 32, scale: 1),
    .init(points: 32, scale: 2),
    .init(points: 128, scale: 1),
    .init(points: 128, scale: 2),
    .init(points: 256, scale: 1),
    .init(points: 256, scale: 2),
    .init(points: 512, scale: 1),
    .init(points: 512, scale: 2),
]

let fileManager = FileManager.default
let repoRoot = URL(fileURLWithPath: fileManager.currentDirectoryPath)
let appIconDir = repoRoot.appendingPathComponent("RateLimited/Assets.xcassets/AppIcon.appiconset", isDirectory: true)
let docsAssetDir = repoRoot.appendingPathComponent("docs/assets", isDirectory: true)

func drawIcon(pixelSize: Int) -> NSImage {
    let image = NSImage(size: NSSize(width: pixelSize, height: pixelSize))
    image.lockFocus()
    defer { image.unlockFocus() }

    guard let ctx = NSGraphicsContext.current?.cgContext else { return image }
    ctx.setAllowsAntialiasing(true)
    ctx.setShouldAntialias(true)

    let canvas = CGRect(x: 0, y: 0, width: pixelSize, height: pixelSize)
    let corner = CGFloat(pixelSize) * 0.22
    let outerRect = canvas.insetBy(dx: CGFloat(pixelSize) * 0.03, dy: CGFloat(pixelSize) * 0.03)
    let outerPath = NSBezierPath(roundedRect: outerRect, xRadius: corner, yRadius: corner)

    ctx.saveGState()
    outerPath.addClip()

    let bg = NSGradient(colors: [
        NSColor(calibratedRed: 0.05, green: 0.06, blue: 0.09, alpha: 1),
        NSColor(calibratedRed: 0.08, green: 0.17, blue: 0.28, alpha: 1),
        NSColor(calibratedRed: 0.05, green: 0.08, blue: 0.13, alpha: 1)
    ])!
    bg.draw(in: outerRect, angle: 135)

    let glowCenter = CGPoint(x: outerRect.maxX * 0.80, y: outerRect.maxY * 0.84)
    let glowColors = [NSColor(calibratedRed: 0.20, green: 0.72, blue: 1.00, alpha: 0.95).cgColor,
                      NSColor(calibratedRed: 0.20, green: 0.72, blue: 1.00, alpha: 0.00).cgColor] as CFArray
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let glowGradient = CGGradient(colorsSpace: colorSpace, colors: glowColors, locations: [0, 1])!
    ctx.drawRadialGradient(glowGradient,
                           startCenter: glowCenter, startRadius: 0,
                           endCenter: glowCenter, endRadius: CGFloat(pixelSize) * 0.62,
                           options: [])

    let redCenter = CGPoint(x: outerRect.minX + CGFloat(pixelSize) * 0.20, y: outerRect.minY + CGFloat(pixelSize) * 0.20)
    let redColors = [NSColor(calibratedRed: 1.00, green: 0.22, blue: 0.30, alpha: 0.35).cgColor,
                     NSColor(calibratedRed: 1.00, green: 0.22, blue: 0.30, alpha: 0.00).cgColor] as CFArray
    let redGradient = CGGradient(colorsSpace: colorSpace, colors: redColors, locations: [0, 1])!
    ctx.drawRadialGradient(redGradient,
                           startCenter: redCenter, startRadius: 0,
                           endCenter: redCenter, endRadius: CGFloat(pixelSize) * 0.50,
                           options: [])

    ctx.restoreGState()

    NSColor.white.withAlphaComponent(0.10).setStroke()
    outerPath.lineWidth = max(1, CGFloat(pixelSize) * 0.01)
    outerPath.stroke()

    let innerRect = outerRect.insetBy(dx: CGFloat(pixelSize) * 0.10, dy: CGFloat(pixelSize) * 0.12)
    let panelPath = NSBezierPath(roundedRect: innerRect,
                                 xRadius: CGFloat(pixelSize) * 0.13,
                                 yRadius: CGFloat(pixelSize) * 0.13)
    let panelGradient = NSGradient(colors: [
        NSColor(calibratedWhite: 0.11, alpha: 0.96),
        NSColor(calibratedRed: 0.06, green: 0.09, blue: 0.14, alpha: 0.96)
    ])!
    panelGradient.draw(in: panelPath, angle: 135)

    NSColor.white.withAlphaComponent(0.03).setStroke()
    panelPath.lineWidth = max(0.5, CGFloat(pixelSize) * 0.003)
    panelPath.stroke()

    // Two "usage" bars: 5h (blue) and 7d (orange)
    let horizontalInset = innerRect.width * 0.13
    let topInset = innerRect.height * 0.08
    let barWidth = innerRect.width - (horizontalInset * 2)
    let barHeight = max(CGFloat(pixelSize) * 0.07, 1)
    let barX = innerRect.minX + horizontalInset
    // Keep the bars visually separated from the "RL" badge at the top-left.
    let topBarY = innerRect.midY - CGFloat(pixelSize) * 0.01
    let bottomBarY = innerRect.midY - CGFloat(pixelSize) * 0.19

    func drawBar(y: CGFloat, fillFraction: CGFloat, tint: NSColor) {
        let trackRect = CGRect(x: barX, y: y, width: barWidth, height: barHeight)
        let radius = barHeight / 2
        let track = NSBezierPath(roundedRect: trackRect, xRadius: radius, yRadius: radius)
        NSColor.white.withAlphaComponent(0.16).setFill()
        track.fill()

        let fillRect = CGRect(x: barX, y: y, width: barWidth * fillFraction, height: barHeight)
        let fill = NSBezierPath(roundedRect: fillRect, xRadius: radius, yRadius: radius)
        let fillGradient = NSGradient(colors: [tint.withAlphaComponent(0.95), tint.blended(withFraction: 0.35, of: .white) ?? tint])!
        NSGraphicsContext.saveGraphicsState()
        fill.addClip()
        fillGradient.draw(in: fillRect, angle: 0)
        NSGraphicsContext.restoreGraphicsState()

        NSColor.black.withAlphaComponent(0.08).setStroke()
        track.lineWidth = max(0.5, CGFloat(pixelSize) * 0.003)
        track.stroke()
    }

    drawBar(y: topBarY, fillFraction: 0.82, tint: NSColor(calibratedRed: 0.12, green: 0.60, blue: 0.98, alpha: 1))
    drawBar(y: bottomBarY, fillFraction: 0.38, tint: NSColor(calibratedRed: 1.00, green: 0.23, blue: 0.29, alpha: 1))

    // Monogram badge for small-size recognition.
    let badgeSize = CGSize(width: innerRect.width * 0.34, height: innerRect.height * 0.26)
    let badgeRect = CGRect(x: innerRect.minX + horizontalInset,
                           y: innerRect.maxY - badgeSize.height - topInset,
                           width: badgeSize.width,
                           height: badgeSize.height)
    let badge = NSBezierPath(roundedRect: badgeRect,
                             xRadius: badgeRect.height * 0.35,
                             yRadius: badgeRect.height * 0.35)
    NSColor.white.withAlphaComponent(0.10).setFill()
    badge.fill()

    let fontSize = max(7, CGFloat(pixelSize) * 0.12)
    let attrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: fontSize, weight: .heavy),
        .foregroundColor: NSColor.white.withAlphaComponent(0.96),
        .kern: -0.2
    ]
    let text = "RL" as NSString
    let textSize = text.size(withAttributes: attrs)
    let textRect = CGRect(
        x: badgeRect.midX - textSize.width / 2,
        y: badgeRect.midY - textSize.height / 2,
        width: textSize.width,
        height: textSize.height
    )
    text.draw(in: textRect, withAttributes: attrs)

    return image
}

func writePNG(_ image: NSImage, to url: URL) throws {
    guard
        let tiff = image.tiffRepresentation,
        let rep = NSBitmapImageRep(data: tiff),
        let data = rep.representation(using: .png, properties: [:])
    else {
        throw NSError(domain: "RateLimitedIcon", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode PNG"])
    }
    try data.write(to: url)
}

func writeContentsJSON() throws {
    let images = specs.map { spec -> [String: String] in
        [
            "filename": spec.filename,
            "idiom": "mac",
            "scale": "\(spec.scale)x",
            "size": "\(spec.points)x\(spec.points)"
        ]
    }
    let root: [String: Any] = [
        "images": images,
        "info": ["author": "xcode", "version": 1]
    ]
    let data = try JSONSerialization.data(withJSONObject: root, options: [.prettyPrinted, .sortedKeys])
    var text = String(decoding: data, as: UTF8.self)
    text.append("\n")
    try text.write(to: appIconDir.appendingPathComponent("Contents.json"), atomically: true, encoding: .utf8)
}

try fileManager.createDirectory(at: appIconDir, withIntermediateDirectories: true)
try fileManager.createDirectory(at: docsAssetDir, withIntermediateDirectories: true)

for spec in specs {
    let image = drawIcon(pixelSize: spec.pixels)
    try writePNG(image, to: appIconDir.appendingPathComponent(spec.filename))
}

// README preview asset
let preview = drawIcon(pixelSize: 512)
try writePNG(preview, to: docsAssetDir.appendingPathComponent("icon-512.png"))

try writeContentsJSON()
print("Generated app icons in \(appIconDir.path)")

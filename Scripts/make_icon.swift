import AppKit
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let resources = root.appendingPathComponent("Resources", isDirectory: true)
let iconset = resources.appendingPathComponent("LookAway.iconset", isDirectory: true)

try? FileManager.default.removeItem(at: iconset)
try FileManager.default.createDirectory(at: iconset, withIntermediateDirectories: true)

struct IconSpec {
    let points: Int
    let scale: Int

    var pixels: Int { points * scale }
    var filename: String {
        scale == 1 ? "icon_\(points)x\(points).png" : "icon_\(points)x\(points)@2x.png"
    }
}

let specs = [
    IconSpec(points: 16, scale: 1),
    IconSpec(points: 16, scale: 2),
    IconSpec(points: 32, scale: 1),
    IconSpec(points: 32, scale: 2),
    IconSpec(points: 128, scale: 1),
    IconSpec(points: 128, scale: 2),
    IconSpec(points: 256, scale: 1),
    IconSpec(points: 256, scale: 2),
    IconSpec(points: 512, scale: 1),
    IconSpec(points: 512, scale: 2)
]

func drawIcon(size: Int) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    let rect = NSRect(x: 0, y: 0, width: size, height: size)
    let corner = CGFloat(size) * 0.22
    let background = NSBezierPath(roundedRect: rect.insetBy(dx: CGFloat(size) * 0.04, dy: CGFloat(size) * 0.04), xRadius: corner, yRadius: corner)
    NSColor(red: 0.10, green: 0.13, blue: 0.13, alpha: 1).setFill()
    background.fill()

    let glow = NSBezierPath(ovalIn: rect.insetBy(dx: CGFloat(size) * 0.14, dy: CGFloat(size) * 0.16))
    NSColor(red: 0.22, green: 0.78, blue: 0.69, alpha: 0.22).setFill()
    glow.fill()

    let eyeRect = NSRect(
        x: CGFloat(size) * 0.18,
        y: CGFloat(size) * 0.35,
        width: CGFloat(size) * 0.64,
        height: CGFloat(size) * 0.30
    )
    let eye = NSBezierPath()
    eye.move(to: NSPoint(x: eyeRect.minX, y: eyeRect.midY))
    eye.curve(
        to: NSPoint(x: eyeRect.maxX, y: eyeRect.midY),
        controlPoint1: NSPoint(x: eyeRect.minX + eyeRect.width * 0.26, y: eyeRect.maxY),
        controlPoint2: NSPoint(x: eyeRect.minX + eyeRect.width * 0.74, y: eyeRect.maxY)
    )
    eye.curve(
        to: NSPoint(x: eyeRect.minX, y: eyeRect.midY),
        controlPoint1: NSPoint(x: eyeRect.minX + eyeRect.width * 0.74, y: eyeRect.minY),
        controlPoint2: NSPoint(x: eyeRect.minX + eyeRect.width * 0.26, y: eyeRect.minY)
    )
    eye.lineWidth = max(2, CGFloat(size) * 0.035)
    NSColor.white.withAlphaComponent(0.92).setStroke()
    eye.stroke()

    NSColor(red: 0.25, green: 0.77, blue: 0.68, alpha: 1).setFill()
    NSBezierPath(ovalIn: NSRect(
        x: CGFloat(size) * 0.43,
        y: CGFloat(size) * 0.405,
        width: CGFloat(size) * 0.14,
        height: CGFloat(size) * 0.14
    )).fill()

    let horizon = NSBezierPath()
    horizon.move(to: NSPoint(x: CGFloat(size) * 0.25, y: CGFloat(size) * 0.27))
    horizon.line(to: NSPoint(x: CGFloat(size) * 0.75, y: CGFloat(size) * 0.27))
    horizon.lineWidth = max(2, CGFloat(size) * 0.025)
    NSColor(red: 0.25, green: 0.77, blue: 0.68, alpha: 0.9).setStroke()
    horizon.stroke()

    image.unlockFocus()
    return image
}

for spec in specs {
    let image = drawIcon(size: spec.pixels)
    guard
        let tiff = image.tiffRepresentation,
        let bitmap = NSBitmapImageRep(data: tiff),
        let png = bitmap.representation(using: .png, properties: [:])
    else {
        fatalError("Could not render \(spec.filename)")
    }

    try png.write(to: iconset.appendingPathComponent(spec.filename))
}

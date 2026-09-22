import AppKit
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let resources = root.appendingPathComponent("Resources", isDirectory: true)
let iconset = resources.appendingPathComponent("LookAway.iconset", isDirectory: true)
let logo = resources.appendingPathComponent("logo.png")

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

guard let sourceLogo = NSImage(contentsOf: logo) else {
    fatalError("Could not load \(logo.path)")
}

func resizedLogoPNG(size: Int) -> Data {
    guard let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: size,
        pixelsHigh: size,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        fatalError("Could not create bitmap for \(size)x\(size)")
    }

    bitmap.size = NSSize(width: size, height: size)

    NSGraphicsContext.saveGraphicsState()
    guard let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
        fatalError("Could not create drawing context for \(size)x\(size)")
    }

    context.imageInterpolation = .high
    NSGraphicsContext.current = context
    NSColor.clear.setFill()
    NSRect(x: 0, y: 0, width: size, height: size).fill()
    sourceLogo.draw(
        in: NSRect(x: 0, y: 0, width: size, height: size),
        from: NSRect(origin: .zero, size: sourceLogo.size),
        operation: .sourceOver,
        fraction: 1
    )
    NSGraphicsContext.restoreGraphicsState()

    guard let png = bitmap.representation(using: .png, properties: [:]) else {
        fatalError("Could not render \(size)x\(size) PNG")
    }

    return png
}

for spec in specs {
    let png = resizedLogoPNG(size: spec.pixels)
    try png.write(to: iconset.appendingPathComponent(spec.filename))
}

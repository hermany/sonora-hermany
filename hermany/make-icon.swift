import AppKit
let n = 1024
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: n, pixelsHigh: n, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
let ctx = NSGraphicsContext(bitmapImageRep: rep)!
NSGraphicsContext.current = ctx
let g = ctx.cgContext
func c(_ h: UInt32) -> NSColor { NSColor(red: CGFloat((h>>16)&255)/255, green: CGFloat((h>>8)&255)/255, blue: CGFloat(h&255)/255, alpha: 1) }
// squircle-ish background with Tokyo Night gradient (macOS icon grid: 824px art centered)
let rect = CGRect(x: 100, y: 100, width: 824, height: 824)
let path = NSBezierPath(roundedRect: rect, xRadius: 185, yRadius: 185)
g.saveGState(); path.addClip()
NSGradient(colors: [c(0x1a1b26), c(0x24283b), c(0x3b4261)], atLocations: [0, 0.55, 1], colorSpace: .deviceRGB)!.draw(in: rect, angle: -60)
// glow
NSGradient(colors: [c(0x7aa2f7).withAlphaComponent(0.45), c(0x7aa2f7).withAlphaComponent(0)], atLocations: [0, 1], colorSpace: .deviceRGB)!.draw(fromCenter: CGPoint(x: 512, y: 560), radius: 0, toCenter: CGPoint(x: 512, y: 560), radius: 420, options: [])
// sound bars
let heights: [CGFloat] = [180, 320, 470, 360, 250, 400, 210]
let bw: CGFloat = 62, gap: CGFloat = 36
let total = CGFloat(heights.count) * bw + CGFloat(heights.count - 1) * gap
var x = (1024 - total) / 2
let cols = [0x7aa2f7, 0x7dcfff, 0x9ece6a, 0xe0af68, 0xff9e64, 0xf7768e, 0xbb9af7]
for (i, h) in heights.enumerated() {
  let r = CGRect(x: x, y: 512 - h/2, width: bw, height: h)
  c(UInt32(cols[i])).setFill()
  NSBezierPath(roundedRect: r, xRadius: bw/2, yRadius: bw/2).fill()
  x += bw + gap
}
g.restoreGState()
NSGraphicsContext.current = nil
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))

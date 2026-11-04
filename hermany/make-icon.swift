import AppKit
let n = 1024
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: n, pixelsHigh: n, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
let ctx = NSGraphicsContext(bitmapImageRep: rep)!
NSGraphicsContext.current = ctx
let g = ctx.cgContext
func c(_ h: UInt32) -> NSColor { NSColor(red: CGFloat((h>>16)&255)/255, green: CGFloat((h>>8)&255)/255, blue: CGFloat(h&255)/255, alpha: 1) }
// squircle background, 910px centered in the 1024px canvas with a black-to-graphite gradient 
let rect = CGRect(x: 57, y: 57, width: 910, height: 910)
let path = NSBezierPath(roundedRect: rect, xRadius: 204, yRadius: 204)
g.saveGState(); path.addClip()
NSGradient(colors: [c(0x000000), c(0x111111), c(0x2a2a2a)], atLocations: [0, 0.55, 1], colorSpace: .deviceRGB)!.draw(in: rect, angle: -60)
// glow
NSGradient(colors: [c(0xffffff).withAlphaComponent(0.14), c(0xffffff).withAlphaComponent(0)], atLocations: [0, 1], colorSpace: .deviceRGB)!.draw(fromCenter: CGPoint(x: 512, y: 560), radius: 0, toCenter: CGPoint(x: 512, y: 560), radius: 420, options: [])
// sound bars
let s: CGFloat = 1.65
let heights: [CGFloat] = [180, 320, 470, 360, 250, 400, 210].map { $0 * s }
let bw: CGFloat = 86, gap: CGFloat = 38
let total = CGFloat(heights.count) * bw + CGFloat(heights.count - 1) * gap
var x = (1024 - total) / 2
for h in heights {
  let r = CGRect(x: x, y: 512 - h/2, width: bw, height: h)
  NSColor.white.setFill()
  NSBezierPath(roundedRect: r, xRadius: bw/2, yRadius: bw/2).fill()
  x += bw + gap
}
g.restoreGState()
NSGraphicsContext.current = nil
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))

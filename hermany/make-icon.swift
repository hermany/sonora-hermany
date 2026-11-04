import AppKit
let n = 1024
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: n, pixelsHigh: n, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
let ctx = NSGraphicsContext(bitmapImageRep: rep)!
NSGraphicsContext.current = ctx
let g = ctx.cgContext
func c(_ h: UInt32) -> NSColor { NSColor(red: CGFloat((h>>16)&255)/255, green: CGFloat((h>>8)&255)/255, blue: CGFloat(h&255)/255, alpha: 1) }
// squircle background, the chatapp frame (824px) centered, lighter at the top so the edge reads on a dark Dock in the 1024px canvas with a black-to-graphite gradient 
let rect = CGRect(x: 100, y: 100, width: 824, height: 824)
let path = NSBezierPath(roundedRect: rect, xRadius: 185, yRadius: 185)
g.saveGState(); path.addClip()
NSGradient(colors: [c(0x060606), c(0x1c1c1c), c(0x404040)], atLocations: [0, 0.55, 1], colorSpace: .deviceRGB)!.draw(in: rect, angle: 90)
// sound bars
let s: CGFloat = 1.053
let heights: [CGFloat] = [180, 320, 470, 360, 250, 400, 210].map { $0 * s }
let bw: CGFloat = 57, gap: CGFloat = 26
let total = CGFloat(heights.count) * bw + CGFloat(heights.count - 1) * gap
var x = (1024 - total) / 2
for h in heights {
  let r = CGRect(x: x, y: 521.5 - h/2, width: bw, height: h)
  NSColor.white.setFill()
  NSBezierPath(roundedRect: r, xRadius: bw/2, yRadius: bw/2).fill()
  x += bw + gap
}
g.restoreGState()
NSGraphicsContext.current = nil
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))

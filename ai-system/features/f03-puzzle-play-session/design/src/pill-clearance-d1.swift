// F03-FE-D1 — hint-pill clearance on a runtime capture (ui-design §6, §11.5 (9); ruling §19.8 (3)).
// Usage: swift pill-clearance-d1.swift <runtime.png> <scale> <W> <H>
// Scans the vertical line x = W/2 from the board card's bottom edge to the undo pill's top (both
// from the D1 geometry) and reports the pill's outer top/bottom — the first/last pixel whose luma
// rises clearly above the ground between them — and the clearance on each side, in points.
import CoreGraphics
import Foundation
import ImageIO

let a = CommandLine.arguments
let src = CGImageSourceCreateWithURL(URL(fileURLWithPath: a[1]) as CFURL, nil)!
let cg = CGImageSourceCreateImageAtIndex(src, 0, nil)!
let scale = Double(a[2])!, W = Double(a[3])!, H = Double(a[4])!
let w = cg.width, h = cg.height
let raw = UnsafeMutablePointer<UInt8>.allocate(capacity: w * h * 4)
let ctx = CGContext(data: raw, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4,
                    space: cg.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!,
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
ctx.draw(cg, in: CGRect(x: 0, y: 0, width: w, height: h))
func luma(_ x: Int, _ y: Int) -> Double {
  let i = (y * w + x) * 4
  return 0.2126 * Double(raw[i]) + 0.7152 * Double(raw[i + 1]) + 0.0722 * Double(raw[i + 2])
}
let s = W / 358, e = max(0, H - 717 * s), e1 = 0.3 * e
let boardBottom = 261.5 * s + e1 + 307.5 * s
let undoTop = 592.5 * s + e
let x = Int(W / 2 * scale)
// Ground reference: the band just under the card (skipping its 1 px edge and shadow onset).
let y0 = Int((boardBottom + 1.0) * scale), y1 = Int((undoTop - 1.0) * scale)
var ground = 0.0
for y in y0..<(y0 + 3) { ground += luma(x, y) }
ground /= 3
let threshold = ground + 12
var top = -1, bottom = -1
for y in y0...y1 where luma(x, y) > threshold { if top < 0 { top = y }; bottom = y }
guard top >= 0 else { print("no pill found"); exit(1) }
let pillTop = Double(top) / scale, pillBottom = Double(bottom + 1) / scale
print(String(format: "board bottom %.2f  pill %.2f–%.2f (h %.2f)  undo top %.2f", boardBottom, pillTop, pillBottom, pillBottom - pillTop, undoTop))
print(String(format: "clearance above %.2f pt, below %.2f pt", pillTop - boardBottom, undoTop - pillBottom))

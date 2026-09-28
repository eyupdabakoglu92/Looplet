// F03-QA-D1 pixel profile probe (QA-owned).
// Usage:
//   qa-pixels <png> <scale> col <x pt> <y0 pt> <y1 pt>   — luma + RGB down a vertical line, per device pixel
//   qa-pixels <png> <scale> row <y pt> <x0 pt> <x1 pt>   — the same along a horizontal line
//   qa-pixels <png> <scale> box <x0> <y0> <x1> <y1> <lumaMin>
//       — the bounding box (pt) of pixels brighter than lumaMin inside the given rect
import CoreGraphics
import Foundation
import ImageIO

let a = CommandLine.arguments
let src = CGImageSourceCreateWithURL(URL(fileURLWithPath: a[1]) as CFURL, nil)!
let cg = CGImageSourceCreateImageAtIndex(src, 0, nil)!
let w = cg.width, h = cg.height
let space = cg.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!
var px = [UInt8](repeating: 0, count: w * h * 4)
px.withUnsafeMutableBytes { buf in
  let ctx = CGContext(data: buf.baseAddress, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4,
                      space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
  ctx.draw(cg, in: CGRect(x: 0, y: 0, width: w, height: h))
}
let s = Double(a[2])!
func rgb(_ x: Int, _ y: Int) -> (Int, Int, Int) {
  let i = (min(max(y, 0), h - 1) * w + min(max(x, 0), w - 1)) * 4
  return (Int(px[i]), Int(px[i + 1]), Int(px[i + 2]))
}
func luma(_ c: (Int, Int, Int)) -> Double { 0.2126 * Double(c.0) + 0.7152 * Double(c.1) + 0.0722 * Double(c.2) }
switch a[3] {
case "col", "row":
  let fixed = Int(Double(a[4])! * s), p0 = Int(Double(a[5])! * s), p1 = Int(Double(a[6])! * s)
  for p in p0...p1 {
    let c = a[3] == "col" ? rgb(fixed, p) : rgb(p, fixed)
    print(String(format: "%7.2f pt  luma %5.1f  rgb %3d,%3d,%3d", Double(p) / s, luma(c), c.0, c.1, c.2))
  }
case "box":
  let x0 = Int(Double(a[4])! * s), y0 = Int(Double(a[5])! * s)
  let x1 = Int(Double(a[6])! * s), y1 = Int(Double(a[7])! * s), m = Double(a[8])!
  var bx0 = Int.max, by0 = Int.max, bx1 = -1, by1 = -1
  for y in y0...y1 { for x in x0...x1 where luma(rgb(x, y)) > m {
    bx0 = min(bx0, x); by0 = min(by0, y); bx1 = max(bx1, x); by1 = max(by1, y) } }
  print(String(format: "box > %.0f: x %.2f–%.2f  y %.2f–%.2f pt", m, Double(bx0) / s, Double(bx1 + 1) / s,
               Double(by0) / s, Double(by1 + 1) / s))
default: break
}

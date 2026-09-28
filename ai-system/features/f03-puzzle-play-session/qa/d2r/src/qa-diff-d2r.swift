// qa-diff-d2r — QA's pixel diff for F03-QA-D2R: pixels differing (any channel > 2 levels) below the
// status bar (y ≥ 60 pt) between two same-size captures. Used for "no scroll at the 1.3× cap" (a drag
// attempt must change nothing) and "after the fix the shrunk capture equals the offset-0 control".
//   qa-diff-d2r <Wpt> <a.png> <b.png>
import CoreGraphics
import Foundation
import ImageIO

func load(_ p: String) -> (Int, Int, [UInt8]) {
  let src = CGImageSourceCreateWithURL(URL(fileURLWithPath: p) as CFURL, nil)!
  let img = CGImageSourceCreateImageAtIndex(src, 0, nil)!
  let w = img.width, h = img.height
  var buf = [UInt8](repeating: 0, count: w * h * 4)
  let ctx = CGContext(data: &buf, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4,
                      space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
  ctx.draw(img, in: CGRect(x: 0, y: 0, width: w, height: h))
  return (w, h, buf)
}
let a = CommandLine.arguments
let wPt = Double(a[1])!
let (w, h, p) = load(a[2]), (w2, h2, q) = load(a[3])
precondition(w == w2 && h == h2, "size mismatch")
let y0 = Int(60 * Double(w) / wPt)
var diff = 0
var bx0 = Int.max, by0 = Int.max, bx1 = -1, by1 = -1
for y in y0..<h { for x in 0..<w {
  let i = (y * w + x) * 4
  if abs(Int(p[i]) - Int(q[i])) > 2 || abs(Int(p[i + 1]) - Int(q[i + 1])) > 2 || abs(Int(p[i + 2]) - Int(q[i + 2])) > 2 { diff += 1; bx0 = min(bx0, x); by0 = min(by0, y); bx1 = max(bx1, x); by1 = max(by1, y) }
} }
print("\((a[3] as NSString).lastPathComponent) vs \((a[2] as NSString).lastPathComponent): \(diff) / \(w * (h - y0)) px differ below the status bar" + (diff > 0 ? String(format: "; bbox %.0f,%.0f – %.0f,%.0f pt", Double(bx0) * wPt / Double(w), Double(by0) * wPt / Double(w), Double(bx1) * wPt / Double(w), Double(by1) * wPt / Double(w)) : ""))

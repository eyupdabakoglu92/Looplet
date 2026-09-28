// band-d2r.swift — F03-FE-D2R (architecture §20.9): compares the ScrollBand region of a capture
// taken after a live OS text-size shrink with the offset-0 control at the same size. The region
// runs from below the status bar (60 pt) to the band's bottom (54·s + 58 pt, s = W / 358), full
// width. Prints each region's mean luma (0–255) and the share of pixels whose luma differs by
// more than 8 levels. A band left drawn (F03-QA-D2-01) darkens the badge and the back button.
// usage: swiftc -O band-d2r.swift -o band-d2r && ./band-d2r <width-pt> <shrunk> <control> [...]
import CoreGraphics
import Foundation
import ImageIO

func lumaRegion(_ path: String, _ wPt: Double) -> [Double] {
  let url = URL(fileURLWithPath: path) as CFURL
  guard let src = CGImageSourceCreateWithURL(url, nil),
        let img = CGImageSourceCreateImageAtIndex(src, 0, nil) else { fatalError("cannot read \(path)") }
  let w = img.width, h = img.height
  var buf = [UInt8](repeating: 0, count: w * h * 4)
  let ctx = CGContext(data: &buf, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4,
                      space: CGColorSpaceCreateDeviceRGB(),
                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
  ctx.draw(img, in: CGRect(x: 0, y: 0, width: w, height: h))
  let px = Double(w) / wPt, s = wPt / 358
  let top = Int(60 * px), bottom = Int((54 * s + 58) * px)
  var out: [Double] = []
  out.reserveCapacity((bottom - top) * w)
  for y in top..<bottom {  // buffer rows run top-down
    for x in 0..<w {
      let i = (y * w + x) * 4
      out.append(0.299 * Double(buf[i]) + 0.587 * Double(buf[i + 1]) + 0.114 * Double(buf[i + 2]))
    }
  }
  return out
}

let a = CommandLine.arguments
let wPt = Double(a[1])!
var i = 2
while i + 1 < a.count {
  let r1 = lumaRegion(a[i], wPt), r2 = lumaRegion(a[i + 1], wPt)
  precondition(r1.count == r2.count, "size mismatch")
  let m1 = r1.reduce(0, +) / Double(r1.count), m2 = r2.reduce(0, +) / Double(r2.count)
  let d = Double(zip(r1, r2).filter { abs($0 - $1) > 8 }.count) / Double(r1.count)
  print(String(format: "%@ mean %.2f | %@ mean %.2f | differing %.3f %%",
               (a[i] as NSString).lastPathComponent, m1, (a[i + 1] as NSString).lastPathComponent, m2, d * 100))
  i += 2
}

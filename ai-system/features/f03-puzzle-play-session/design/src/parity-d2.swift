// parity-d2 — F03-FE-D2 parity helpers (frontend.md § Visual Parity Evidence).
//   swift parity-d2.swift bands <png> <scale>
//       Prints every horizontal band of "lime" pixels (the answer tiles, the primary pill, the
//       badge label) in points: top, bottom, left, right, height. `scale` = pixels per point
//       (renders 2, simulator captures 3). Lime = G ≥ 220, B ≤ 160, G − B ≥ 90, R 170…245.
//   swift parity-d2.swift compose <out.jpg> <png> <png> [...]
//       Side-by-side sheet: each input scaled to 1400 px tall on the ground colour, 24 px apart.
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

func load(_ path: String) -> CGImage {
  let src = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil)!
  return CGImageSourceCreateImageAtIndex(src, 0, nil)!
}

func pixels(_ image: CGImage) -> ([UInt8], Int, Int) {
  let w = image.width, h = image.height
  var data = [UInt8](repeating: 0, count: w * h * 4)
  let ctx = CGContext(data: &data, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4,
                      space: CGColorSpace(name: CGColorSpace.sRGB)!,
                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
  ctx.draw(image, in: CGRect(x: 0, y: 0, width: w, height: h))
  return (data, w, h)
}

func isLime(_ r: Int, _ g: Int, _ b: Int) -> Bool {
  if g < 220 || b > 160 { return false }
  if g - b < 90 { return false }
  return r >= 170 && r <= 245
}

let args = CommandLine.arguments
switch args[1] {
case "bands":
  let (p, w, h) = pixels(load(args[2]))
  let scale = Double(args[3])!
  var rows = [Int](repeating: 0, count: h)
  var minX = [Int](repeating: Int.max, count: h)
  var maxX = [Int](repeating: -1, count: h)
  for y in 0..<h {
    for x in 0..<w {
      let i = (y * w + x) * 4
      if isLime(Int(p[i]), Int(p[i + 1]), Int(p[i + 2])) {
        rows[y] += 1
        minX[y] = min(minX[y], x)
        maxX[y] = max(maxX[y], x)
      }
    }
  }
  var y = 0
  while y < h {
    if rows[y] < 3 { y += 1; continue }
    let top = y
    var l = Int.max, r = -1
    while y < h && rows[y] >= 3 { l = min(l, minX[y]); r = max(r, maxX[y]); y += 1 }
    let bottom = y
    if bottom - top < Int(4 * scale) { continue }
    let f = { (v: Int) in String(format: "%.1f", Double(v) / scale) }
    print("band top \(f(top)) bottom \(f(bottom)) left \(f(l)) right \(f(r + 1)) height \(f(bottom - top))")
  }
case "compose":
  let out = args[2]
  let images = args[3...].map(load)
  let H = 1400
  let widths = images.map { Int(Double($0.width) * Double(H) / Double($0.height)) }
  let W = widths.reduce(0, +) + 24 * (images.count + 1)
  let ctx = CGContext(data: nil, width: W, height: H + 48, bitsPerComponent: 8, bytesPerRow: 0,
                      space: CGColorSpace(name: CGColorSpace.sRGB)!,
                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
  ctx.setFillColor(CGColor(srgbRed: 0.02, green: 0.04, blue: 0.12, alpha: 1))
  ctx.fill(CGRect(x: 0, y: 0, width: W, height: H + 48))
  ctx.interpolationQuality = .high
  var x = 24
  for (i, image) in images.enumerated() {
    ctx.draw(image, in: CGRect(x: x, y: 24, width: widths[i], height: H))
    x += widths[i] + 24
  }
  let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: out) as CFURL, UTType.jpeg.identifier as CFString, 1, nil)!
  CGImageDestinationAddImage(dest, ctx.makeImage()!, [kCGImageDestinationLossyCompressionQuality: 0.82] as CFDictionary)
  CGImageDestinationFinalize(dest)
  print("wrote \(out) \(W)x\(H + 48)")
default:
  print("unknown command")
}

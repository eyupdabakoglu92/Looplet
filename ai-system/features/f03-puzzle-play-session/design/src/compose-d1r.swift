// F03-FE-D1R before / after composite: crops the same rect (pt) from each input
// screenshot (@3x), scales it by <zoom>, and lays the crops side by side on a
// dark ground with a 24-px gutter.
// Usage: swift compose-d1r.swift <out.jpg> <x> <y> <w> <h> <zoom> <png>...
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

let a = CommandLine.arguments
let out = a[1]
let (x, y, w, h, zoom) = (Double(a[2])!, Double(a[3])!, Double(a[4])!, Double(a[5])!, Double(a[6])!)
let inputs = Array(a[7...])
let cw = Int(w * 3 * zoom / 3), ch = Int(h * 3 * zoom / 3)
let gutter = 24
let W = inputs.count * cw + (inputs.count + 1) * gutter, H = ch + 2 * gutter
let space = CGColorSpace(name: CGColorSpace.sRGB)!
let ctx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: 0, space: space,
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
ctx.setFillColor(CGColor(red: 0.02, green: 0.03, blue: 0.08, alpha: 1))
ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
ctx.interpolationQuality = .none
for (i, path) in inputs.enumerated() {
  let src = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil)!
  let img = CGImageSourceCreateImageAtIndex(src, 0, nil)!
  let crop = img.cropping(to: CGRect(x: x * 3, y: y * 3, width: w * 3, height: h * 3))!
  ctx.draw(crop, in: CGRect(x: gutter + i * (cw + gutter), y: gutter, width: cw, height: ch))
}
let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: out) as CFURL, UTType.jpeg.identifier as CFString, 1, nil)!
CGImageDestinationAddImage(dest, ctx.makeImage()!, [kCGImageDestinationLossyCompressionQuality: 0.9] as CFDictionary)
CGImageDestinationFinalize(dest)
print("wrote \(out) \(W)×\(H)")

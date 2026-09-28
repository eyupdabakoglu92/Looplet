// qa-band-d2r — QA's own ScrollBand probe for F03-QA-D2R (independent of the Frontend's band-d2r).
//
//   qa-band-d2r <Wpt> <control.png> <capture.png> [<capture.png> …]
//   qa-band-d2r video <Wpt> <control.png> <video>     the same reading for every decoded frame
//                                                    (CSV: t, alpha, badge, tilesTopPt)
//
// The band (ScrollBand, 54·s + 58 pt tall, s = W / 358) is the ground #0B1234 (luma 19.8) over
// its top 78 %, drawn at opacity = offset / 12 (result_view.dart). QA reads three things per
// capture, each against a control at the same text size that was never scrolled:
//   * alpha  — the band opacity estimated in an empty strip of the solid part of the band
//              (x 0.80 W … 0.96 W, y 62 pt … 0.78 · band): only the background and the band are
//              drawn there, so alpha = (L_control − L) / (L_control − 19.8);
//   * badge  — lime pixels of the `HARİKA` badge text (x 0.33 W … 0.67 W, y 64 … 112 pt);
//   * back   — the brightest luma of the back chevron (x 24 … 72 pt, y 58 … 106 pt);
//   * lift   — how far the content moved up vs the control (the first lime row of the answer
//              tiles, scanned down the centre column), i.e. the scroll offset in points.
// Lime = R 175…245, G ≥ 215, B ≤ 150, G − B ≥ 85 (the answer / badge lime of tokens.dart).
import AVFoundation
import CoreGraphics
import Foundation
import ImageIO

struct Img { let w: Int; let h: Int; let px: [UInt8] }

func load(_ path: String) -> Img {
  let url = URL(fileURLWithPath: path) as CFURL
  guard let src = CGImageSourceCreateWithURL(url, nil),
        let img = CGImageSourceCreateImageAtIndex(src, 0, nil) else { fatalError("cannot read \(path)") }
  let w = img.width, h = img.height
  var buf = [UInt8](repeating: 0, count: w * h * 4)
  let ctx = CGContext(data: &buf, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4,
                      space: CGColorSpaceCreateDeviceRGB(),
                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
  ctx.draw(img, in: CGRect(x: 0, y: 0, width: w, height: h))
  return Img(w: w, h: h, px: buf)
}

func luma(_ m: Img, _ x: Int, _ y: Int) -> Double {
  let i = (y * m.w + x) * 4
  return 0.299 * Double(m.px[i]) + 0.587 * Double(m.px[i + 1]) + 0.114 * Double(m.px[i + 2])
}

func lime(_ m: Img, _ x: Int, _ y: Int) -> Bool {
  let i = (y * m.w + x) * 4
  let r = Int(m.px[i]), g = Int(m.px[i + 1]), b = Int(m.px[i + 2])
  return r >= 175 && r <= 245 && g >= 215 && b <= 150 && g - b >= 85
}

var args = CommandLine.arguments
let videoMode = args.count > 1 && args[1] == "video"
if videoMode { args.remove(at: 1) }
guard args.count >= 4, let wPt = Double(args[1]) else {
  print("usage: qa-band-d2r <Wpt> <control.png> <capture.png> [...]"); exit(2)
}
let s = wPt / 358, bandH = 54 * s + 58

func measure(_ m: Img) -> (strip: Double, badge: Int, back: Double, limeTop: Int) {
  let k = Double(m.w) / wPt
  var sum = 0.0, n = 0
  for y in Int(62 * k)..<Int(0.78 * bandH * k) {
    for x in Int(0.80 * wPt * k)..<Int(0.96 * wPt * k) { sum += luma(m, x, y); n += 1 }
  }
  var badge = 0
  for y in Int(64 * k)..<Int(112 * k) {
    for x in Int(0.33 * wPt * k)..<Int(0.67 * wPt * k) where lime(m, x, y) { badge += 1 }
  }
  var back = 0.0
  for y in Int(58 * k)..<Int(106 * k) { for x in Int(24 * k)..<Int(72 * k) { back = max(back, luma(m, x, y)) } }
  // First row (below the band) where ≥ 30 % of a centre strip is lime: the answer tiles.
  var limeTop = -1
  let x0 = Int(0.30 * wPt * k), x1 = Int(0.70 * wPt * k)
  for y in Int(120 * k)..<m.h {
    var c = 0
    for x in stride(from: x0, to: x1, by: 2) where lime(m, x, y) { c += 1 }
    if Double(c) >= 0.30 * Double((x1 - x0) / 2) { limeTop = y; break }
  }
  return (sum / Double(n), badge, back, limeTop)
}

let ctl = load(args[2])
let c = measure(ctl)
let kc = Double(ctl.w) / wPt
print(String(format: "control %@: strip luma %.2f, badge lime px %d, back max luma %.1f, tiles top %.1f pt",
             (args[2] as NSString).lastPathComponent, c.strip, c.badge, c.back, Double(c.limeTop) / kc))
if videoMode {
  let asset = AVURLAsset(url: URL(fileURLWithPath: args[3]))
  let track = asset.tracks(withMediaType: .video).first!
  let reader = try! AVAssetReader(asset: asset)
  let out = AVAssetReaderTrackOutput(track: track, outputSettings: [
    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA])
  reader.add(out)
  reader.startReading()
  print("t,alpha,badge,tilesTopPt")
  while let sb = out.copyNextSampleBuffer(), let pb = CMSampleBufferGetImageBuffer(sb) {
    let t = CMSampleBufferGetPresentationTimeStamp(sb).seconds
    CVPixelBufferLockBaseAddress(pb, .readOnly)
    let w = CVPixelBufferGetWidth(pb), h = CVPixelBufferGetHeight(pb), bpr = CVPixelBufferGetBytesPerRow(pb)
    let base = CVPixelBufferGetBaseAddress(pb)!.assumingMemoryBound(to: UInt8.self)
    var px = [UInt8](repeating: 0, count: w * h * 4)
    for y in 0..<h { for x in 0..<w {  // BGRA -> RGBA
      let i = y * bpr + x * 4, o = (y * w + x) * 4
      px[o] = base[i + 2]; px[o + 1] = base[i + 1]; px[o + 2] = base[i]; px[o + 3] = 255
    } }
    CVPixelBufferUnlockBaseAddress(pb, .readOnly)
    let r = measure(Img(w: w, h: h, px: px))
    let k = Double(w) / wPt
    print(String(format: "%.4f,%.3f,%d,%.1f", t, (c.strip - r.strip) / (c.strip - 19.8), r.badge,
                 r.limeTop >= 0 ? Double(r.limeTop) / k : -1))
  }
  exit(0)
}
for p in args.dropFirst(3) {
  let m = load(p)
  let r = measure(m)
  let k = Double(m.w) / wPt
  let alpha = (c.strip - r.strip) / (c.strip - 19.8)
  let lift = (c.limeTop >= 0 && r.limeTop >= 0) ? Double(c.limeTop - r.limeTop) / k : .nan
  print(String(format: "%@: strip luma %.2f → band alpha %.3f; badge lime px %d (%.0f %% of control); back max luma %.1f (Δ %.1f); content lift %.1f pt → expected alpha %.3f",
               (p as NSString).lastPathComponent, r.strip, alpha, r.badge,
               c.badge > 0 ? 100 * Double(r.badge) / Double(c.badge) : .nan, r.back, r.back - c.back,
               lift, lift.isNaN ? .nan : min(1, max(0, lift / 12))))
}

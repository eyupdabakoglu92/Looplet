// qa-probe-d2 — QA's own frame probe for F03-QA-D2 (independent of the Frontend's video-d2 / timing-d2).
//
//   qa-probe-d2 probe <video> <Wpt> <Hpt>
//       For every decoded frame (real presentation time): the count of lime pixels OUTSIDE the
//       board card (expanded by 3 pt), the count INSIDE it, and the lime bounding box in points.
//       "Lime" = the answer-tile / pill lime of tokens.dart (#DDFA6B … #CDEB4B): R 175…245,
//       G ≥ 215, B ≤ 150, G − B ≥ 85. Cream tiles, ink, glass and the 13–30 % glows fail it.
//       T0 is estimated independently as the first frame with ≥ 40 lime pixels inside the board
//       (the fill of tile 0 starts at T0; so this is an upper bound of T0, ≤ one frame late).
//   qa-probe-d2 frames <video> <outPrefix> <sec> [<sec> …]     exact-time PNG stills
//   qa-probe-d2 sheet <out.jpg> <cols> <cellWidthPx> <png> [<png> …]   a contact sheet
//
// Board card geometry (Play, `play_layout.dart`): s = W / 358, e = max(0, H − 717 s),
// left = 24.75 s, top = 261.5 s + 0.3 e, 308.5 × 307.5 s.
import AVFoundation
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

func board(_ W: Double, _ H: Double) -> CGRect {
  let s = W / 358.0
  let e = max(0, H - 717 * s)
  return CGRect(x: 24.75 * s, y: 261.5 * s + 0.3 * e, width: 308.5 * s, height: 307.5 * s)
}

func isLime(_ r: Int, _ g: Int, _ b: Int) -> Bool {
  return r >= 175 && r <= 245 && g >= 215 && b <= 150 && g - b >= 85
}

func probe(_ path: String, _ W: Double, _ H: Double) throws {
  let asset = AVURLAsset(url: URL(fileURLWithPath: path))
  guard let track = asset.tracks(withMediaType: .video).first else { fatalError("no video track") }
  let reader = try AVAssetReader(asset: asset)
  let out = AVAssetReaderTrackOutput(track: track, outputSettings: [
    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
  ])
  reader.add(out)
  reader.startReading()
  let b = board(W, H).insetBy(dx: -3, dy: -3)
  print("t,limeOutside,limeInside,minX,minY,maxX,maxY")
  while let sample = out.copyNextSampleBuffer() {
    guard let px = CMSampleBufferGetImageBuffer(sample) else { continue }
    let t = CMSampleBufferGetPresentationTimeStamp(sample).seconds
    CVPixelBufferLockBaseAddress(px, .readOnly)
    let w = CVPixelBufferGetWidth(px), h = CVPixelBufferGetHeight(px)
    let row = CVPixelBufferGetBytesPerRow(px)
    let base = CVPixelBufferGetBaseAddress(px)!.assumingMemoryBound(to: UInt8.self)
    let k = Double(w) / W  // px per pt
    var outside = 0, inside = 0
    var minX = Double.infinity, minY = Double.infinity, maxX = -1.0, maxY = -1.0
    var y = 0
    while y < h {
      var x = 0
      while x < w {
        let p = base + y * row + x * 4
        if isLime(Int(p[2]), Int(p[1]), Int(p[0])) {
          let ptx = Double(x) / k, pty = Double(y) / k
          if b.contains(CGPoint(x: ptx, y: pty)) {
            inside += 1
            minX = min(minX, ptx); minY = min(minY, pty); maxX = max(maxX, ptx); maxY = max(maxY, pty)
          } else {
            outside += 1
          }
        }
        x += 2
      }
      y += 2
    }
    CVPixelBufferUnlockBaseAddress(px, .readOnly)
    if inside > 0 {
      print(String(format: "%.4f,%d,%d,%.1f,%.1f,%.1f,%.1f", t, outside, inside, minX, minY, maxX, maxY))
    } else {
      print(String(format: "%.4f,%d,%d,,,,", t, outside, inside))
    }
  }
}

func savePNG(_ image: CGImage, _ path: String) {
  let url = URL(fileURLWithPath: path) as CFURL
  let type = path.hasSuffix(".jpg") ? UTType.jpeg.identifier : UTType.png.identifier
  guard let dest = CGImageDestinationCreateWithURL(url, type as CFString, 1, nil) else { return }
  CGImageDestinationAddImage(dest, image, [kCGImageDestinationLossyCompressionQuality: 0.85] as CFDictionary)
  CGImageDestinationFinalize(dest)
}

func frames(_ path: String, _ prefix: String, _ secs: [Double]) {
  let asset = AVURLAsset(url: URL(fileURLWithPath: path))
  let gen = AVAssetImageGenerator(asset: asset)
  gen.requestedTimeToleranceBefore = .zero
  gen.requestedTimeToleranceAfter = .zero
  for s in secs {
    var actual = CMTime.zero
    if let img = try? gen.copyCGImage(at: CMTime(seconds: s, preferredTimescale: 600), actualTime: &actual) {
      let out = String(format: "%@-%.3f.png", prefix, s)
      savePNG(img, out)
      print(String(format: "%@ (actual %.4f s)", out, actual.seconds))
    }
  }
}

func sheet(_ out: String, _ cols: Int, _ cellW: Int, _ paths: [String]) {
  let imgs: [CGImage] = paths.compactMap {
    guard let src = CGImageSourceCreateWithURL(URL(fileURLWithPath: $0) as CFURL, nil) else { return nil }
    return CGImageSourceCreateImageAtIndex(src, 0, nil)
  }
  guard let first = imgs.first else { return }
  let cellH = Int(Double(cellW) * Double(first.height) / Double(first.width))
  let rows = (imgs.count + cols - 1) / cols
  let gap = 8
  let W = cols * cellW + (cols + 1) * gap, H = rows * cellH + (rows + 1) * gap
  let ctx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: 0,
                      space: CGColorSpaceCreateDeviceRGB(),
                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
  ctx.setFillColor(CGColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1))
  ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
  ctx.interpolationQuality = .high
  for (i, img) in imgs.enumerated() {
    let c = i % cols, r = i / cols
    let x = gap + c * (cellW + gap)
    let y = H - (gap + (r + 1) * cellH + r * gap)
    ctx.draw(img, in: CGRect(x: x, y: y, width: cellW, height: cellH))
  }
  savePNG(ctx.makeImage()!, out)
  print(out)
}

/// `colshift <video> <Wpt> <Hpt> <col> <winRow> <refSec>`: T0 from the settle itself. For every
/// frame, the vertical luma profile of board column <col> (a 24-pt stripe, the winning row's band
/// excluded) is matched to the profile at <refSec> (a frame after the settle) by normalised
/// correlation over shifts −70…+70 pt; the best shift is 0 once the column has settled. The
/// dim (a uniform scale) does not move the correlation peak.
func profiles(_ path: String, _ W: Double, _ H: Double, _ col: Int) throws -> [(Double, [Double])] {
  let asset = AVURLAsset(url: URL(fileURLWithPath: path))
  let track = asset.tracks(withMediaType: .video).first!
  let reader = try AVAssetReader(asset: asset)
  let out = AVAssetReaderTrackOutput(track: track, outputSettings: [
    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
  ])
  reader.add(out)
  reader.startReading()
  let s = W / 358.0
  let bd = board(W, H)
  let cx = bd.minX + 11 * s + Double(col) * 58.5 * s + 26 * s
  var res: [(Double, [Double])] = []
  while let sample = out.copyNextSampleBuffer() {
    guard let px = CMSampleBufferGetImageBuffer(sample) else { continue }
    let t = CMSampleBufferGetPresentationTimeStamp(sample).seconds
    CVPixelBufferLockBaseAddress(px, .readOnly)
    let w = CVPixelBufferGetWidth(px)
    let row = CVPixelBufferGetBytesPerRow(px)
    let base = CVPixelBufferGetBaseAddress(px)!.assumingMemoryBound(to: UInt8.self)
    let k = Double(w) / W
    var prof: [Double] = []
    var ypt = bd.minY
    while ypt < bd.maxY {
      let y = Int(ypt * k)
      var sum = 0.0, n = 0.0
      var xpt = cx - 12
      while xpt < cx + 12 {
        let p = base + y * row + Int(xpt * k) * 4
        sum += 0.299 * Double(p[2]) + 0.587 * Double(p[1]) + 0.114 * Double(p[0]); n += 1
        xpt += 1
      }
      prof.append(sum / n)
      ypt += 1
    }
    CVPixelBufferUnlockBaseAddress(px, .readOnly)
    res.append((t, prof))
  }
  return res
}

func colshift(_ path: String, _ W: Double, _ H: Double, _ col: Int, _ winRow: Int, _ refSec: Double) throws {
  let all = try profiles(path, W, H, col)
  let s = W / 358.0
  let ref = all.min(by: { abs($0.0 - refSec) < abs($1.0 - refSec) })!.1
  let bandTop = Int(11 * s + Double(winRow) * 58.5 * s) - 4
  let bandBot = bandTop + Int(52 * s) + 8
  print("t,bestShiftPt,ncc")
  for (t, p) in all {
    var best = -2.0, bestK = 0
    for kk in -70...70 {
      var xs: [Double] = [], ys: [Double] = []
      for i in 0..<ref.count {
        let j = i + kk
        if j < 0 || j >= p.count { continue }
        if (i >= bandTop && i <= bandBot) || (j >= bandTop && j <= bandBot) { continue }
        xs.append(ref[i]); ys.append(p[j])
      }
      let mx = xs.reduce(0, +) / Double(xs.count), my = ys.reduce(0, +) / Double(ys.count)
      var sxy = 0.0, sxx = 0.0, syy = 0.0
      for i in 0..<xs.count { sxy += (xs[i] - mx) * (ys[i] - my); sxx += (xs[i] - mx) * (xs[i] - mx); syy += (ys[i] - my) * (ys[i] - my) }
      let ncc = sxy / max(1e-9, (sxx * syy).squareRoot())
      if ncc > best { best = ncc; bestK = kk }
    }
    print(String(format: "%.4f,%d,%.3f", t, bestK, best))
  }
}

/// `luma <video> <Wpt> <x> <y> <w> <h>` (points): mean luma of a region per frame.
func luma(_ path: String, _ W: Double, _ r: CGRect) throws {
  let asset = AVURLAsset(url: URL(fileURLWithPath: path))
  let track = asset.tracks(withMediaType: .video).first!
  let reader = try AVAssetReader(asset: asset)
  let out = AVAssetReaderTrackOutput(track: track, outputSettings: [
    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
  ])
  reader.add(out)
  reader.startReading()
  print("t,luma")
  while let sample = out.copyNextSampleBuffer() {
    guard let px = CMSampleBufferGetImageBuffer(sample) else { continue }
    let t = CMSampleBufferGetPresentationTimeStamp(sample).seconds
    CVPixelBufferLockBaseAddress(px, .readOnly)
    let w = CVPixelBufferGetWidth(px)
    let row = CVPixelBufferGetBytesPerRow(px)
    let base = CVPixelBufferGetBaseAddress(px)!.assumingMemoryBound(to: UInt8.self)
    let k = Double(w) / W
    var sum = 0.0, n = 0.0
    var y = Int(r.minY * k)
    while y < Int(r.maxY * k) {
      var x = Int(r.minX * k)
      while x < Int(r.maxX * k) {
        let p = base + y * row + x * 4
        sum += 0.299 * Double(p[2]) + 0.587 * Double(p[1]) + 0.114 * Double(p[0]); n += 1
        x += 2
      }
      y += 2
    }
    CVPixelBufferUnlockBaseAddress(px, .readOnly)
    print(String(format: "%.4f,%.2f", t, sum / n))
  }
}

let a = CommandLine.arguments
switch a[1] {
case "luma": try luma(a[2], Double(a[3])!, CGRect(x: Double(a[4])!, y: Double(a[5])!, width: Double(a[6])!, height: Double(a[7])!))
case "colshift": try colshift(a[2], Double(a[3])!, Double(a[4])!, Int(a[5])!, Int(a[6])!, Double(a[7])!)
case "probe": try probe(a[2], Double(a[3])!, Double(a[4])!)
case "frames": frames(a[2], a[3], a[4...].map { Double($0)! })
case "sheet": sheet(a[2], Int(a[3])!, Int(a[4])!, Array(a[5...]))
default: fatalError("usage: probe | frames | sheet")
}

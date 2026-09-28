// F03-QA-D1 frame probe (QA-owned; independent of the Frontend's video-d1.swift).
// Usage:
//   qa-frames <video.mp4> info
//   qa-frames <video.mp4> probe <t0> <t1> <axis h|v> <fixed pt> <from pt> <to pt> <W pt>
//       For every decoded frame in [t0, t1] s, scans the line (y = fixed for h, x = fixed for v)
//       from `from` to `to` (points, increasing) and prints every rising edge where luma crosses
//       200 (the leading edge of a cream tile), plus the frame's timestamp in ms.
//   qa-frames <video.mp4> dump <t0> <t1> <outdir> [every]
//       Writes the frames in [t0, t1] as PNG named by their timestamp in ms.
import AVFoundation
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

let a = CommandLine.arguments
let asset = AVURLAsset(url: URL(fileURLWithPath: a[1]))
let track = asset.tracks(withMediaType: .video)[0]
let size = track.naturalSize
let mode = a[2]
if mode == "info" {
  print("size \(Int(size.width))x\(Int(size.height)) fps \(track.nominalFrameRate) duration \(CMTimeGetSeconds(asset.duration)) s")
  exit(0)
}
if mode == "trim" {
  // qa-frames <video> trim <t0> <t1> <out.mp4> — re-encodes [t0, t1] s (AVAssetExportPreset960x540,
  // aspect kept) so the evidence stays small; timestamps restart at 0 in the output.
  let range = CMTimeRange(start: CMTime(seconds: Double(a[3])!, preferredTimescale: 600),
                          end: CMTime(seconds: Double(a[4])!, preferredTimescale: 600))
  let ex = AVAssetExportSession(asset: asset, presetName: AVAssetExportPreset960x540)!
  ex.outputURL = URL(fileURLWithPath: a[5]); ex.outputFileType = .mp4; ex.timeRange = range
  let done = DispatchSemaphore(value: 0)
  ex.exportAsynchronously { done.signal() }
  done.wait()
  print("trim \(ex.status == .completed ? "ok" : "FAILED \(String(describing: ex.error))")")
  exit(ex.status == .completed ? 0 : 1)
}
let t0 = Double(a[3])!, t1 = Double(a[4])!
let reader = try! AVAssetReader(asset: asset)
reader.timeRange = CMTimeRange(start: CMTime(seconds: t0, preferredTimescale: 600),
                               end: CMTime(seconds: t1, preferredTimescale: 600))
let out = AVAssetReaderTrackOutput(track: track, outputSettings: [
  kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA])
reader.add(out)
reader.startReading()
var every = 1, n = 0
if mode == "dump", a.count > 6 { every = Int(a[6])! }
while let sb = out.copyNextSampleBuffer() {
  let t = CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sb))
  guard let pb = CMSampleBufferGetImageBuffer(sb) else { continue }
  CVPixelBufferLockBaseAddress(pb, .readOnly)
  let w = CVPixelBufferGetWidth(pb), h = CVPixelBufferGetHeight(pb)
  let bpr = CVPixelBufferGetBytesPerRow(pb)
  let base = CVPixelBufferGetBaseAddress(pb)!.assumingMemoryBound(to: UInt8.self)
  if mode == "probe" {
    let axis = a[5], fixed = Double(a[6])!, from = Double(a[7])!, to = Double(a[8])!, W = Double(a[9])!
    let k = Double(w) / W
    func luma(_ x: Int, _ y: Int) -> Double {
      let i = y * bpr + x * 4
      return 0.0722 * Double(base[i]) + 0.7152 * Double(base[i + 1]) + 0.2126 * Double(base[i + 2])
    }
    // Every rising edge (luma crossing 200 upward) along the line, in points.
    var edges: [String] = []
    var prev = 0.0
    var p = from
    while p <= to {
      let px = Int(p * k)
      let fx = Int(fixed * k)
      let l = axis == "h" ? luma(min(px, w - 1), min(fx, h - 1)) : luma(min(fx, w - 1), min(px, h - 1))
      if l > 200 && prev <= 200 { edges.append(String(format: "%.2f", p)) }
      prev = l
      p += 1.0 / k
    }
    print(String(format: "%8.1f ms  ", t * 1000) + edges.joined(separator: " "))
  } else if mode == "pixel" {
    // qa-frames <video> pixel <t0> <t1> <x pt> <y pt> <W pt> — RGB at one point per frame.
    let k = Double(w) / Double(a[7])!
    let x = min(Int(Double(a[5])! * k), w - 1), y = min(Int(Double(a[6])! * k), h - 1)
    let i = y * bpr + x * 4
    print(String(format: "%8.1f ms  rgb %3d,%3d,%3d", t * 1000, base[i + 2], base[i + 1], base[i]))
  } else if mode == "dump" {
    if n % every == 0 {
      let cs = CGColorSpace(name: CGColorSpace.sRGB)!
      let ctx = CGContext(data: base, width: w, height: h, bitsPerComponent: 8, bytesPerRow: bpr, space: cs,
                          bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)!
      let img = ctx.makeImage()!
      let url = URL(fileURLWithPath: String(format: "%@/f%06.0f.png", a[5], t * 1000))
      let dst = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil)!
      CGImageDestinationAddImage(dst, img, nil)
      CGImageDestinationFinalize(dst)
    }
    n += 1
  }
  CVPixelBufferUnlockBaseAddress(pb, .readOnly)
}

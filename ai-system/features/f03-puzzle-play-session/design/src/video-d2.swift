// video-d2 — per-frame traces of a `simctl io recordVideo` capture for the F03-FE-D2 frame-timing
// evidence (architecture §20.6, §20.7 C2). Reads EVERY decoded frame with its real presentation
// time (the capture is variable-frame-rate), so event times are exact to the frame.
//   swift video-d2.swift trace <video> <region> [<region> ...]
//       region = name:x:y:w:h in video pixels. For each frame prints one CSV line:
//       t, then per region: meanLuma, limeCount, limeMinX, limeMinY, limeMaxX, limeMaxY
//       ("lime" = the resolution lime of the answer tiles / CTA: G ≥ 220, B ≤ 160, G − B ≥ 90,
//       R 170…245 — cream tiles, the ground, glass and the 13–30 % lime glows never pass).
//   swift video-d2.swift frames <video> <outPrefix> <sec> [<sec> ...]   (exact-time PNG stills)
//   swift video-d2.swift encode <in> <out> <startSec> <durationSec> <width> <height> <bps>
import AVFoundation
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

struct Region { let name: String; let x: Int; let y: Int; let w: Int; let h: Int }

func parseRegion(_ s: String) -> Region {
  let p = s.split(separator: ":").map(String.init)
  return Region(name: p[0], x: Int(p[1])!, y: Int(p[2])!, w: Int(p[3])!, h: Int(p[4])!)
}

func savePNG(_ image: CGImage, _ path: String) {
  let url = URL(fileURLWithPath: path) as CFURL
  guard let dest = CGImageDestinationCreateWithURL(url, UTType.png.identifier as CFString, 1, nil) else { return }
  CGImageDestinationAddImage(dest, image, nil)
  CGImageDestinationFinalize(dest)
}

func isLime(_ r: Int, _ g: Int, _ b: Int) -> Bool {
  if g < 220 || b > 160 { return false }
  if g - b < 90 { return false }
  return r >= 170 && r <= 245
}

let args = CommandLine.arguments
let sem = DispatchSemaphore(value: 0)
Task {
  defer { sem.signal() }
  let asset = AVURLAsset(url: URL(fileURLWithPath: args[2]))
  switch args[1] {
  case "trace":
    let regions = args[3...].map(parseRegion)
    let track = try await asset.loadTracks(withMediaType: .video).first!
    let reader = try AVAssetReader(asset: asset)
    let output = AVAssetReaderTrackOutput(track: track, outputSettings: [
      kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
    ])
    reader.add(output)
    reader.startReading()
    var header: [String] = ["t"]
    for r in regions {
      let n = r.name
      header.append(n + "_luma,"  + n + "_lime,"  + n + "_x0,"  + n + "_y0,"  + n + "_x1,"  + n + "_y1")
    }
    print(header.joined(separator: ","))
    while let sample = output.copyNextSampleBuffer() {
      guard let buffer = CMSampleBufferGetImageBuffer(sample) else { continue }
      let t = CMSampleBufferGetPresentationTimeStamp(sample).seconds
      CVPixelBufferLockBaseAddress(buffer, .readOnly)
      let base = CVPixelBufferGetBaseAddress(buffer)!.assumingMemoryBound(to: UInt8.self)
      let row = CVPixelBufferGetBytesPerRow(buffer)
      let bw = CVPixelBufferGetWidth(buffer), bh = CVPixelBufferGetHeight(buffer)
      var cols = [String(format: "%.4f", t)]
      for r in regions {
        var sum = 0.0, n = 0, lime = 0
        var x0 = Int.max, y0 = Int.max, x1 = -1, y1 = -1
        for y in max(0, r.y)..<min(bh, r.y + r.h) {
          for x in max(0, r.x)..<min(bw, r.x + r.w) {
            let i = y * row + x * 4
            let b = Int(base[i]), g = Int(base[i + 1]), rr = Int(base[i + 2])
            let l1: Double = 0.2126 * Double(rr)
            let l2: Double = 0.7152 * Double(g)
            let l3: Double = 0.0722 * Double(b)
            sum += l1 + l2 + l3
            n += 1
            if isLime(rr, g, b) {
              lime += 1
              x0 = min(x0, x); y0 = min(y0, y); x1 = max(x1, x); y1 = max(y1, y)
            }
          }
        }
        cols.append(String(format: "%.2f", n > 0 ? sum / Double(n) : 0))
        cols.append("\(lime)")
        cols.append(lime > 0 ? "\(x0),\(y0),\(x1),\(y1)" : "-1,-1,-1,-1")
      }
      CVPixelBufferUnlockBaseAddress(buffer, .readOnly)
      print(cols.joined(separator: ","))
    }
  case "frames":
    let g = AVAssetImageGenerator(asset: asset)
    g.requestedTimeToleranceBefore = .zero
    g.requestedTimeToleranceAfter = .zero
    for s in args[4...] {
      let (image, actual) = try await g.image(at: CMTime(seconds: Double(s)!, preferredTimescale: 6000))
      let out = "\(args[3])-\(s).png"
      savePNG(image, out)
      print("\(out) (actual \(String(format: "%.4f", actual.seconds)) s)")
    }
  case "encode":
    let outURL = URL(fileURLWithPath: args[3])
    try? FileManager.default.removeItem(at: outURL)
    let start = CMTime(seconds: Double(args[4])!, preferredTimescale: 600)
    let duration = CMTime(seconds: Double(args[5])!, preferredTimescale: 600)
    let width = Int(args[6])!, height = Int(args[7])!, bitrate = Int(args[8])!
    let track = try await asset.loadTracks(withMediaType: .video).first!
    let reader = try AVAssetReader(asset: asset)
    reader.timeRange = CMTimeRange(start: start, duration: duration)
    let output = AVAssetReaderTrackOutput(track: track, outputSettings: [
      kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
    ])
    reader.add(output)
    let writer = try AVAssetWriter(outputURL: outURL, fileType: .mp4)
    let input = AVAssetWriterInput(mediaType: .video, outputSettings: [
      AVVideoCodecKey: AVVideoCodecType.h264,
      AVVideoWidthKey: width,
      AVVideoHeightKey: height,
      AVVideoScalingModeKey: AVVideoScalingModeResizeAspect,
      AVVideoCompressionPropertiesKey: [
        AVVideoAverageBitRateKey: bitrate,
        AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel,
      ],
    ])
    input.expectsMediaDataInRealTime = false
    writer.add(input)
    reader.startReading()
    writer.startWriting()
    writer.startSession(atSourceTime: start)
    var frames = 0
    while let sample = output.copyNextSampleBuffer() {
      while !input.isReadyForMoreMediaData { usleep(1000) }
      input.append(sample)
      frames += 1
    }
    input.markAsFinished()
    await writer.finishWriting()
    print("wrote \(args[3]): \(frames) frames, status \(writer.status.rawValue)")
  default:
    print("unknown command")
  }
}
sem.wait()

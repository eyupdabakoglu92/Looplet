// video-d1 — video info, frame extraction, region-luma timelines and re-encoding for the F03-FE-D1
// runtime-video evidence (simctl recordVideo output is variable-frame-rate and ~60 MB per minute).
//   swift video-d1.swift info <video>
//   swift video-d1.swift frames <video> <outPrefix> <sec> [<sec> ...]
//   swift video-d1.swift diff <video> <outPrefix> <fromSec> <toSec> <stepSec> <x> <y> <w> <h>
//        (prints the mean luma of a region per step — to find motion onsets)
import AVFoundation
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

func loadAsset(_ path: String) -> AVURLAsset { AVURLAsset(url: URL(fileURLWithPath: path)) }

func savePNG(_ image: CGImage, _ path: String) {
  let url = URL(fileURLWithPath: path) as CFURL
  guard let dest = CGImageDestinationCreateWithURL(url, UTType.png.identifier as CFString, 1, nil) else { return }
  CGImageDestinationAddImage(dest, image, nil)
  CGImageDestinationFinalize(dest)
}

func generator(_ asset: AVURLAsset) -> AVAssetImageGenerator {
  let g = AVAssetImageGenerator(asset: asset)
  g.requestedTimeToleranceBefore = .zero
  g.requestedTimeToleranceAfter = .zero
  g.appliesPreferredTrackTransform = true
  return g
}

func rgba(_ image: CGImage) -> (UnsafeMutablePointer<UInt8>, Int, Int) {
  let w = image.width, h = image.height
  let data = UnsafeMutablePointer<UInt8>.allocate(capacity: w * h * 4)
  let ctx = CGContext(data: data, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4,
                      space: CGColorSpace(name: CGColorSpace.sRGB)!,
                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
  ctx.draw(image, in: CGRect(x: 0, y: 0, width: w, height: h))
  return (data, w, h)
}

let args = CommandLine.arguments
let sem = DispatchSemaphore(value: 0)
Task {
  defer { sem.signal() }
  switch args[1] {
  case "info":
    let asset = loadAsset(args[2])
    let duration = try await asset.load(.duration)
    for track in try await asset.loadTracks(withMediaType: .video) {
      let size = try await track.load(.naturalSize)
      let fps = try await track.load(.nominalFrameRate)
      let count = try await track.load(.timeRange)
      print("duration \(String(format: "%.3f", duration.seconds)) s, \(Int(size.width))x\(Int(size.height)), \(fps) fps, track \(String(format: "%.3f", count.duration.seconds)) s")
    }
  case "frames":
    let asset = loadAsset(args[2])
    let g = generator(asset)
    for s in args[4...] {
      let t = CMTime(seconds: Double(s)!, preferredTimescale: 600)
      let (image, actual) = try await g.image(at: t)
      let out = "\(args[3])-\(s).png"
      savePNG(image, out)
      print("\(out) (actual \(String(format: "%.3f", actual.seconds)) s)")
    }
  case "diff":
    let asset = loadAsset(args[2])
    let g = generator(asset)
    let from = Double(args[4])!, to = Double(args[5])!, step = Double(args[6])!
    let rx = Int(args[7])!, ry = Int(args[8])!, rw = Int(args[9])!, rh = Int(args[10])!
    var t = from
    while t <= to {
      let (image, actual) = try await g.image(at: CMTime(seconds: t, preferredTimescale: 600))
      let (p, w, _) = rgba(image)
      var sum = 0.0
      for y in ry..<(ry + rh) {
        for x in rx..<(rx + rw) {
          let i = (y * w + x) * 4
          sum += 0.2126 * Double(p[i]) + 0.7152 * Double(p[i + 1]) + 0.0722 * Double(p[i + 2])
        }
      }
      p.deallocate()
      print(String(format: "%.3f %.3f %.2f", t, actual.seconds, sum / Double(rw * rh)))
      t += step
    }
  case "encode":
    // encode <in> <out> <startSec> <durationSec> <width> <height> <bitsPerSecond>
    let asset = loadAsset(args[2])
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
    let size = (try? FileManager.default.attributesOfItem(atPath: args[3])[.size] as? Int) ?? 0
    print("wrote \(args[3]): \(frames) frames, \(size) bytes, status \(writer.status.rawValue) \(writer.error?.localizedDescription ?? "")")
  default:
    print("unknown command")
  }
}
sem.wait()

// F03-QA-D1R pixel checks (QA-owned; independent of the Frontend's measure-d1r.swift).
// Unlike measure-d1r, nothing is taken from PlayLayout: the card outline and its
// corner radius are scanned / fitted from the capture itself.
// Usage:
//   qa-d1r card <png> <W pt>
//     — the HAMLE card: outline scanned in a search box around the header's right
//       end (fill/border luma > 42 against the ground ≈ 30), the bottom-corner radius
//       least-squares fitted from the scanned left/right edge rows, then every glyph
//       pixel (luma > 120, and > 100 away from the top rim) measured as a signed
//       distance to that rounded rect. Also: glyph pixels found OUTSIDE the outline
//       (search box ± 8 pt), and the gap from the card bottom to the next ink below.
//   qa-d1r headline <png> <W pt>
//     — the load-error headline: the card found by scanning, white ink (R, G, B > 200)
//       split into lines by empty rows, each line into words by column gaps wider
//       than 0.32 × the shortest full line's ink height. Prints words per line and flags a line
//       that is only punctuation (< 0.3 × line height wide) or ink touching the card.
//   qa-d1r crop <png> <W pt> <x0> <y0> <x1> <y1> <zoom> <out.png>
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

let a = CommandLine.arguments
let mode = a[1]
let src = CGImageSourceCreateWithURL(URL(fileURLWithPath: a[2]) as CFURL, nil)!
let cg = CGImageSourceCreateImageAtIndex(src, 0, nil)!
let w = cg.width, h = cg.height
let space = CGColorSpace(name: CGColorSpace.sRGB)!
var px = [UInt8](repeating: 0, count: w * h * 4)
px.withUnsafeMutableBytes { buf in
  let ctx = CGContext(data: buf.baseAddress, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4,
                      space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
  ctx.draw(cg, in: CGRect(x: 0, y: 0, width: w, height: h))
}
let W = Double(a[3])!
let k = Double(w) / W
func rgb(_ x: Int, _ y: Int) -> (Double, Double, Double) {
  let i = (min(max(y, 0), h - 1) * w + min(max(x, 0), w - 1)) * 4
  return (Double(px[i]), Double(px[i + 1]), Double(px[i + 2]))
}
func luma(_ x: Int, _ y: Int) -> Double { let c = rgb(x, y); return 0.2126 * c.0 + 0.7152 * c.1 + 0.0722 * c.2 }
func pt(_ p: Int) -> Double { Double(p) / k }
func dp(_ v: Double) -> Int { Int((v * k).rounded(.down)) }
func f(_ v: Double) -> String { String(format: "%.2f", v) }
func sdRRect(_ x: Double, _ y: Double, _ l: Double, _ t: Double, _ r: Double, _ b: Double, _ rad: Double) -> Double {
  let cx = (l + r) / 2, cy = (t + b) / 2, hx = (r - l) / 2, hy = (b - t) / 2
  let qx = abs(x - cx) - hx + rad, qy = abs(y - cy) - hy + rad
  let ox = max(qx, 0), oy = max(qy, 0)
  return (ox * ox + oy * oy).squareRoot() + min(max(qx, qy), 0) - rad
}

switch mode {
case "card":
  // Search box: the right ~25 % of the width, 12–30 % of the height.
  let bx0 = dp(0.70 * W), bx1 = dp(0.985 * W), by0 = dp(0.07 * W * 852 / 393), by1 = dp(0.30 * W * 852 / 393)
  // Centre column of the card: the column in the box with the most card pixels.
  var best = (0, 0)
  for x in stride(from: bx0, to: bx1, by: 1) {
    var n = 0
    for y in by0..<by1 where luma(x, y) > 42 { n += 1 }
    if n > best.1 { best = (x, n) }
  }
  // Vertical run of card pixels on a column near the middle of the card: first find
  // the mid row (numeral region), then scan left/right edges on it.
  var ys: [Int] = []
  for y in by0..<by1 where luma(best.0, y) > 42 { ys.append(y) }
  // The vertical middle of the run: below the top corner arcs at every size.
  let midY = (ys.first! + ys.last!) / 2
  var l = bx0, r = bx1
  var x = best.0
  while x > bx0 && luma(x, midY) > 42 { x -= 1 }; l = x + 1
  x = best.0
  while x < bx1 && luma(x, midY) > 42 { x += 1 }; r = x - 1
  let cx = (l + r) / 2
  var y = midY
  while y > by0 && luma(cx, y) > 42 { y -= 1 }; let t = y + 1
  // Downward: skip glyph ink; stop at the first row back at ground level for 3 pt.
  y = midY; var lastCard = midY
  while y < by1 { if luma(cx, y) > 42 { lastCard = y } else if y - lastCard > Int(3 * k) { break }; y += 1 }
  let b = lastCard
  let L = pt(l), R = pt(r + 1), T = pt(t), B = pt(b + 1)
  // Radius fit on the bottom corners: for each row, the left/right edge crossing.
  var bestRad = 0.0, bestErr = Double.infinity
  var samples: [(Double, Double, Bool)] = []  // (y centre pt, edge x pt, isLeft)
  for yy in stride(from: b, to: b - Int(30 * k), by: -1) {
    var xl = l; while xl < cx && luma(xl, yy) <= 42 { xl += 1 }
    var xr = r; while xr > cx && luma(xr, yy) <= 42 { xr -= 1 }
    samples.append((pt(yy) + 0.5 / k, pt(xl), true))
    samples.append((pt(yy) + 0.5 / k, pt(xr + 1), false))
  }
  for rad10 in 100...400 {
    let rad = Double(rad10) / 10
    var err = 0.0, n = 0
    for (sy, sx, left) in samples {
      let dy = sy - (B - rad)
      let expect: Double
      if dy <= 0 { expect = left ? L : R } else if dy < rad {
        let off = rad - (rad * rad - dy * dy).squareRoot()
        expect = left ? L + off : R - off
      } else { continue }
      err += (sx - expect) * (sx - expect); n += 1
    }
    if n > 0 && err / Double(n) < bestErr { bestErr = err / Double(n); bestRad = rad }
  }
  print("card outline (scanned) l \(f(L)) t \(f(T)) r \(f(R)) b \(f(B))  w \(f(R - L)) h \(f(B - T))  bottom radius fit \(f(bestRad)) (rms \(f(bestErr.squareRoot())) pt)")
  // Glyph ink, grouped into bands by empty rows.
  for thr in [120.0, 100.0] {
    var rowsIn: [Int: (Int, Int, Double)] = [:]
    var outside = 0, worstOut = 0.0
    for yy in dp(T - 8)..<dp(B + 8) {
      for xx in dp(L - 8)..<dp(R + 8) where luma(xx, yy) > thr {
        let d = sdRRect(pt(xx) + 0.5 / k, pt(yy) + 0.5 / k, L, T, R, B, bestRad)
        // The 1-pt top rim is brighter than the fill: at the lower threshold ignore
        // pixels within 1.2 pt of the outline in the card's top quarter.
        if thr < 120 && d > -1.2 && pt(yy) < T + (B - T) / 4 { continue }
        if d > 0 { outside += 1; worstOut = max(worstOut, d) }
        let c = rowsIn[yy] ?? (Int.max, -1, Double.infinity)
        // Most conservative corner of the pixel.
        var dmax = -Double.infinity
        for (ox, oy) in [(0.0, 0.0), (1.0, 0.0), (0.0, 1.0), (1.0, 1.0)] {
          dmax = max(dmax, sdRRect(pt(xx) + ox / k, pt(yy) + oy / k, L, T, R, B, bestRad))
        }
        rowsIn[yy] = (min(c.0, xx), max(c.1, xx), min(c.2, -dmax))
      }
    }
    var groups: [[Int]] = []
    for yy in rowsIn.keys.sorted() {
      if let g = groups.last, let p = g.last, yy - p <= 2 { groups[groups.count - 1].append(yy) } else { groups.append([yy]) }
    }
    for (i, g) in groups.enumerated() {
      var x0 = Int.max, x1 = -1, ins = Double.infinity
      for yy in g { let v = rowsIn[yy]!; x0 = min(x0, v.0); x1 = max(x1, v.1); ins = min(ins, v.2) }
      let name = groups.count == 2 ? (i == 0 ? "numeral" : "label") : "band\(i)"
      print("  luma > \(Int(thr)) \(name): x \(f(pt(x0)))–\(f(pt(x1 + 1))) y \(f(pt(g.first!)))–\(f(pt(g.last! + 1)))  min inset \(f(ins)) pt")
    }
    print("  luma > \(Int(thr)) glyph pixels outside the outline: \(outside)\(outside > 0 ? " (worst \(f(worstOut)) pt)" : "")")
  }
  // Next ink below the card (HEDEF DÖNGÜ), across the middle half of the screen.
  var below = -1
  for yy in (b + 1)..<min(h, b + dp(220)) where below < 0 {
    for xx in dp(0.25 * W)..<dp(0.75 * W) where luma(xx, yy) > 120 { below = yy; break }
  }
  print("  next ink below the card at \(f(pt(below)))  gap \(f(pt(below) - B)) pt")
case "headline":
  // The error card's fill fades into the ground on the right, so its side edges
  // are found as the 1-pt border: on each headline row, the pixel standing out most
  // above the mean of the pixels 2 pt either side (left in 3–12 % of W, right in
  // 88–97 %). Headline ink search starts at 25 % of the height (below the chrome).
  let top = dp(0.25 * W * 852 / 393)
  func border(_ yy: Int, _ x0: Int, _ x1: Int) -> Int {
    var bx = x0, bv = -Double.infinity
    for xx in x0..<x1 {
      let v = luma(xx, yy) - (luma(xx - dp(2), yy) + luma(xx + dp(2), yy)) / 2
      if v > bv { bv = v; bx = xx }
    }
    return bx
  }
  var rows: [Int: [Int]] = [:]
  for yy in top..<h {
    for xx in dp(0.03 * W)..<dp(0.97 * W) {
      let c = rgb(xx, yy)
      if c.0 > 200 && c.1 > 200 && c.2 > 200 { rows[yy, default: []].append(xx) }
    }
  }
  var groups: [[Int]] = []
  for yy in rows.keys.sorted() {
    if let g = groups.last, let p = g.last, yy - p <= 3 { groups[groups.count - 1].append(yy) } else { groups.append([yy]) }
  }
  // Keep every band ≥ 3 pt tall (a lone "." line included); drop antialias specks.
  let lines = groups.filter { pt($0.last! + 1) - pt($0.first!) >= 3 }
  // Word gaps: wider than 0.32 × the shortest full text line's ink height (that
  // line has no descender, so it tracks the cap height): letter gaps at the cap
  // are ≈ 6.3 pt, word gaps ≈ 16 pt; at 1.0× ≈ 4.9 / 12.5 pt.
  let full = lines.map { pt($0.last! + 1) - pt($0.first!) }.filter { $0 >= 10 }
  let gapMin = 0.32 * (full.min() ?? 20)
  print("headline lines: \(lines.count)")
  var words = 0
  for g in lines {
    var cols = Set<Int>()
    for yy in g { for xx in rows[yy]! { cols.insert(xx) } }
    let sorted = cols.sorted()
    let lh = pt(g.last! + 1) - pt(g.first!)
    var segs: [(Int, Int)] = [(sorted[0], sorted[0])]
    var gaps: [Double] = []
    for xx in sorted.dropFirst() {
      let gap = pt(xx) - pt(segs[segs.count - 1].1 + 1)
      if gap > gapMin { segs.append((xx, xx)); gaps.append(gap) } else { segs[segs.count - 1].1 = xx }
    }
    words += segs.count
    let x0 = pt(sorted.first!), x1 = pt(sorted.last! + 1)
    let widths = segs.map { f(pt($0.1 + 1) - pt($0.0)) }.joined(separator: ", ")
    let punct = segs.count == 1 && (x1 - x0) < 0.3 * (full.max() ?? 20)
    let midRow = g[g.count / 2]
    let cardL = border(midRow, dp(0.03 * W), dp(0.12 * W)), cardR = border(midRow, dp(0.88 * W), dp(0.97 * W))
    let touch = x0 - pt(cardL + 1) < 2 || pt(cardR) - x1 < 2
    print("  y \(f(pt(g.first!)))–\(f(pt(g.last! + 1)))  x \(f(x0))–\(f(x1))  words \(segs.count) [\(widths)] gaps [\(gaps.map { f($0) }.joined(separator: ", "))]  card border x \(f(pt(cardL)))–\(f(pt(cardR + 1)))  margins \(f(x0 - pt(cardL + 1))) / \(f(pt(cardR) - x1))\(punct ? "  <- PUNCTUATION-ONLY LINE" : "")\(touch ? "  <- INK AT CARD EDGE" : "")")
  }
  print("words total \(words) (expected 3: Bu · bulmaca · yüklenemedi.)")
case "crop":
  let x0 = Double(a[4])!, y0 = Double(a[5])!, x1 = Double(a[6])!, y1 = Double(a[7])!, z = Double(a[8])!
  let rect = CGRect(x: x0 * k, y: y0 * k, width: (x1 - x0) * k, height: (y1 - y0) * k)
  let c = cg.cropping(to: rect)!
  let ow = Int(Double(c.width) * z), oh = Int(Double(c.height) * z)
  let ctx = CGContext(data: nil, width: ow, height: oh, bitsPerComponent: 8, bytesPerRow: 0, space: space,
                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
  ctx.interpolationQuality = .none
  ctx.draw(c, in: CGRect(x: 0, y: 0, width: ow, height: oh))
  let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: a[9]) as CFURL, UTType.png.identifier as CFString, 1, nil)!
  CGImageDestinationAddImage(dest, ctx.makeImage()!, nil)
  CGImageDestinationFinalize(dest)
  print("wrote \(a[9]) \(ow)x\(oh)")
default:
  print("unknown mode")
}

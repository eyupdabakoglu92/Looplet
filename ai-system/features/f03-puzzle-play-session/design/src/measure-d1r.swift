// F03-FE-D1R runtime measurements (architecture §19.10) on simulator screenshots.
// Usage:
//   swift measure-d1r.swift card <png> <width pt>
//     — the HAMLE card: its bottom edge (scanned), the numeral and label ink
//       (luma > 90 and > 120) and each one's smallest inset from the card's
//       rounded rect, corner arcs included (signed distance to the rrect);
//       the gap from the card bottom to the HEDEF DÖNGÜ ink.
//   swift measure-d1r.swift headline <png> <width pt>
//     — the load-error headline: the white ink (luma > 200, blue > 180, so the
//       lime pill is excluded) split into lines by empty rows; each line's
//       box, and whether any line is narrower than a word (a lone ".").
// Geometry from PlayLayout: s = W / 358, card at (273.5, 75)·s, 60·s wide,
// radius 22·s; error card x 24.5·s … 333.5·s from y 140·s.
import CoreGraphics
import Foundation
import ImageIO

let a = CommandLine.arguments
let mode = a[1]
let src = CGImageSourceCreateWithURL(URL(fileURLWithPath: a[2]) as CFURL, nil)!
let cg = CGImageSourceCreateImageAtIndex(src, 0, nil)!
let w = cg.width, h = cg.height
let space = cg.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!
var px = [UInt8](repeating: 0, count: w * h * 4)
px.withUnsafeMutableBytes { buf in
  let ctx = CGContext(data: buf.baseAddress, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4,
                      space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
  ctx.draw(cg, in: CGRect(x: 0, y: 0, width: w, height: h))
}
let W = Double(a[3])!
let k = Double(w) / W  // device pixels per point
let s = W / 358
func rgb(_ x: Int, _ y: Int) -> (Double, Double, Double) {
  let i = (min(max(y, 0), h - 1) * w + min(max(x, 0), w - 1)) * 4
  return (Double(px[i]), Double(px[i + 1]), Double(px[i + 2]))
}
func luma(_ x: Int, _ y: Int) -> Double {
  let c = rgb(x, y); return 0.2126 * c.0 + 0.7152 * c.1 + 0.0722 * c.2
}
func pt(_ p: Int) -> Double { Double(p) / k }
func f(_ v: Double) -> String { String(format: "%.2f", v) }

/// Signed distance (pt) from point (x, y) to a rounded rect; negative inside.
func sdRRect(_ x: Double, _ y: Double, _ l: Double, _ t: Double, _ r: Double, _ b: Double, _ rad: Double) -> Double {
  let cx = (l + r) / 2, cy = (t + b) / 2, hx = (r - l) / 2, hy = (b - t) / 2
  let qx = abs(x - cx) - hx + rad, qy = abs(y - cy) - hy + rad
  let ox = max(qx, 0), oy = max(qy, 0)
  return (ox * ox + oy * oy).squareRoot() + min(max(qx, qy), 0) - rad
}

if mode == "card" {
  let l = 273.5 * s, t = 75 * s, r = l + 60 * s, rad = 22 * s
  let cx = Int((l + r) / 2 * k)
  // The label's lowest bright row on the centre column, then the edge below it.
  var y = Int((t + 20 * s) * k), lastInk = y
  while y < Int((t + 140 * s) * k) { if luma(cx, y) > 120 { lastInk = y }; y += 1 }
  // The card edge: the last row, below the label, still brighter than the ground
  // (fill luma ≈ 60, 1-pt border lighter; ground ≈ 15–30).
  var edge = lastInk
  y = lastInk
  while y < Int((t + 160 * s) * k) { if luma(cx, y) > 42 { edge = y }; y += 1; if luma(cx, y) < 35 && y - edge > 6 { break } }
  let b = pt(edge + 1)
  print("card l \(f(l)) t \(f(t)) r \(f(r)) b \(f(b)) (scanned)  h \(f(b - t)) = \(f((b - t) / s))·s  radius \(f(rad))")
  for thr in [90.0, 120.0] {
    // Ink rows inside the card, split into numeral / label by the empty band.
    var rows: [Int: (Int, Int)] = [:]
    // From 3 pt below the top: the card's top rim is brighter than the fill.
    for yy in Int((t + 3) * k)..<Int(b * k) {
      for xx in Int(l * k)..<Int(r * k) where luma(xx, yy) > thr {
        // The 1-pt border ring (white at 9 % over the fill, brightest at the
        // top-left of the gradient) peaks near luma 100; a dim pixel on the
        // ring is border, a bright one (label core ≈ 180) is glyph ink.
        if luma(xx, yy) < 130 && sdRRect(pt(xx) + 0.5 / k, pt(yy) + 0.5 / k, l, t, r, b, rad) > -1.5 { continue }
        let cur = rows[yy] ?? (Int.max, -1)
        rows[yy] = (min(cur.0, xx), max(cur.1, xx))
      }
    }
    let ys = rows.keys.sorted()
    var groups: [[Int]] = []
    for yy in ys { if let g = groups.last, let p = g.last, yy - p <= 2 { groups[groups.count - 1].append(yy) } else { groups.append([yy]) } }
    for (i, g) in groups.enumerated() {
      var inset = Double.infinity, x0 = Int.max, x1 = -1
      for yy in g {
        let (a0, a1) = rows[yy]!
        x0 = min(x0, a0); x1 = max(x1, a1)
        for xx in a0...a1 where luma(xx, yy) > thr {
          for (dx, dy) in [(0.0, 0.0), (1.0, 0.0), (0.0, 1.0), (1.0, 1.0)] {
            inset = min(inset, -sdRRect(pt(xx) + dx / k, pt(yy) + dy / k, l, t, r, b, rad))
          }
        }
      }
      let name = groups.count == 2 ? (i == 0 ? "numeral" : "label") : "group\(i)"
      print("  luma > \(Int(thr)) \(name): ink x \(f(pt(x0)))–\(f(pt(x1 + 1))) y \(f(pt(g.first!)))–\(f(pt(g.last! + 1)))  inset \(f(inset)) pt")
    }
  }
  // HEDEF DÖNGÜ caption: first bright row below the card, centre band.
  var capTop = -1
  for yy in Int(b * k)..<Int((b + 200) * k) where capTop < 0 {
    for xx in Int(0.25 * W * k)..<Int(0.75 * W * k) where luma(xx, yy) > 120 { capTop = yy; break }
  }
  print("  HEDEF DÖNGÜ ink top \(f(pt(capTop)))  gap from card bottom \(f(pt(capTop) - b)) pt")
} else if mode == "headline" {
  let l = 24.5 * s, r = 333.5 * s
  var rows: [Int: (Int, Int)] = [:]
  for yy in Int(140 * s * k)..<h {
    for xx in Int(l * k)..<Int(r * k) {
      let c = rgb(xx, yy)
      if luma(xx, yy) > 200 && c.2 > 180 {
        let cur = rows[yy] ?? (Int.max, -1); rows[yy] = (min(cur.0, xx), max(cur.1, xx))
      }
    }
  }
  var groups: [[Int]] = []
  for yy in rows.keys.sorted() { if let g = groups.last, let p = g.last, yy - p <= 3 { groups[groups.count - 1].append(yy) } else { groups.append([yy]) } }
  // The pill label "Ana ekrana dön" is dark on lime, so only headline lines remain.
  print("headline lines: \(groups.count)  (inner column x \(f(l + 26 * s))–\(f(r - 26 * s)))")
  for g in groups {
    var x0 = Int.max, x1 = -1
    for yy in g { x0 = min(x0, rows[yy]!.0); x1 = max(x1, rows[yy]!.1) }
    let width = pt(x1 + 1) - pt(x0)
    print("  y \(f(pt(g.first!)))–\(f(pt(g.last! + 1)))  x \(f(pt(x0)))–\(f(pt(x1 + 1)))  width \(f(width))\(width < 12 ? "  <- punctuation-only line" : "")")
  }
}

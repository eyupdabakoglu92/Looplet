// F03-FE-D1 parity measurement — render (D1-* / S-*, @2x) vs runtime (RT-*, @3x).
// Usage: swift measure-d1.swift <render.png> <renderScale> <runtime.png> <runtimeScale> <W> <H> [grid]
//
// For each feature it looks for the strongest luminance edge within ±8 pt of the position the
// D1 geometry predicts (ui-design §6: s = W/358, e = H − 717 s), in both images, and prints the
// two positions in points and their difference. It then samples colour patches in both images
// and prints ΔE2000 (sRGB, D65). Raw decoded pixel values are read — no colour-space conversion —
// so a P3/sRGB tag difference between the simulator and Chrome captures does not skew the result.
// `grid` (optional, default 1) = 0 skips the tile-grid features (states where the board is dimmed).
import CoreGraphics
import Foundation
import ImageIO

struct Img {
  let w: Int, h: Int, scale: Double
  let px: [UInt8]  // RGBA
  let bpp: Int, stride: Int

  init(_ path: String, scale: Double) {
    let src = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil)!
    let cg = CGImageSourceCreateImageAtIndex(src, 0, nil)!
    w = cg.width; h = cg.height; self.scale = scale
    // Redraw into a plain RGBA buffer with the image's OWN colour space (no conversion). The
    // buffer must outlive the context, so it is allocated explicitly (not `&array`).
    let space = cg.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!
    let raw = UnsafeMutablePointer<UInt8>.allocate(capacity: w * h * 4)
    defer { raw.deallocate() }
    let ctx = CGContext(data: raw, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4,
                        space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    ctx.draw(cg, in: CGRect(x: 0, y: 0, width: w, height: h))
    px = Array(UnsafeBufferPointer(start: raw, count: w * h * 4)); bpp = 4; stride = w * 4
  }

  func rgb(_ x: Int, _ y: Int) -> (Double, Double, Double) {
    let cx = min(max(x, 0), w - 1), cy = min(max(y, 0), h - 1)
    let i = cy * stride + cx * bpp
    return (Double(px[i]), Double(px[i + 1]), Double(px[i + 2]))
  }

  func luma(_ x: Int, _ y: Int) -> Double {
    let (r, g, b) = rgb(x, y)
    return 0.2126 * r + 0.7152 * g + 0.0722 * b
  }

  /// Mean colour of a patch given in points (centre, half-size).
  func patch(_ cx: Double, _ cy: Double, _ half: Double) -> (Double, Double, Double) {
    var r = 0.0, g = 0.0, b = 0.0, n = 0.0
    let x0 = Int((cx - half) * scale), x1 = Int((cx + half) * scale)
    let y0 = Int((cy - half) * scale), y1 = Int((cy + half) * scale)
    for y in y0...y1 { for x in x0...x1 { let c = rgb(x, y); r += c.0; g += c.1; b += c.2; n += 1 } }
    return (r / n, g / n, b / n)
  }

  /// Strongest luminance step (|Δ| over 2 px) along a line near `expected` (pt), ±`window` pt.
  /// `vertical` = scan along y at fixed x. `sign` +1 = rising (dark → light), −1 = falling, 0 = either.
  func edge(vertical: Bool, fixed: Double, expected: Double, window: Double = 8, sign: Double = 0) -> Double {
    let a = Int((expected - window) * scale), b = Int((expected + window) * scale)
    let f = Int(fixed * scale)
    var best = -1.0, bestPos = expected
    for p in a...b {
      let l0 = vertical ? luma(f, p - 1) : luma(p - 1, f)
      let l1 = vertical ? luma(f, p + 1) : luma(p + 1, f)
      let d = l1 - l0
      let score = sign == 0 ? abs(d) : d * sign
      if score > best { best = score; bestPos = Double(p) / scale }
    }
    return bestPos
  }
}

func lab(_ c: (Double, Double, Double)) -> (Double, Double, Double) {
  func lin(_ v: Double) -> Double { let s = v / 255; return s <= 0.04045 ? s / 12.92 : pow((s + 0.055) / 1.055, 2.4) }
  let r = lin(c.0), g = lin(c.1), b = lin(c.2)
  let x = (0.4124 * r + 0.3576 * g + 0.1805 * b) / 0.95047
  let y = (0.2126 * r + 0.7152 * g + 0.0722 * b)
  let z = (0.0193 * r + 0.1192 * g + 0.9505 * b) / 1.08883
  func f(_ t: Double) -> Double { t > 0.008856 ? cbrt(t) : 7.787 * t + 16.0 / 116 }
  return (116 * f(y) - 16, 500 * (f(x) - f(y)), 200 * (f(y) - f(z)))
}

func de2000(_ c1: (Double, Double, Double), _ c2: (Double, Double, Double)) -> Double {
  let (L1, a1, b1) = lab(c1), (L2, a2, b2) = lab(c2)
  let C1 = hypot(a1, b1), C2 = hypot(a2, b2), Cm = (C1 + C2) / 2
  let G = 0.5 * (1 - sqrt(pow(Cm, 7) / (pow(Cm, 7) + pow(25.0, 7))))
  let a1p = (1 + G) * a1, a2p = (1 + G) * a2
  let C1p = hypot(a1p, b1), C2p = hypot(a2p, b2)
  func hp(_ a: Double, _ b: Double) -> Double { if a == 0 && b == 0 { return 0 }; var h = atan2(b, a) * 180 / .pi; if h < 0 { h += 360 }; return h }
  let h1p = hp(a1p, b1), h2p = hp(a2p, b2)
  let dLp = L2 - L1, dCp = C2p - C1p
  var dhp = 0.0
  if C1p * C2p != 0 { dhp = h2p - h1p; if dhp > 180 { dhp -= 360 } else if dhp < -180 { dhp += 360 } }
  let dHp = 2 * sqrt(C1p * C2p) * sin(dhp * .pi / 360)
  let Lpm = (L1 + L2) / 2, Cpm = (C1p + C2p) / 2
  var hpm = h1p + h2p
  if C1p * C2p != 0 { if abs(h1p - h2p) <= 180 { hpm /= 2 } else if h1p + h2p < 360 { hpm = (hpm + 360) / 2 } else { hpm = (hpm - 360) / 2 } }
  let T = 1 - 0.17 * cos((hpm - 30) * .pi / 180) + 0.24 * cos(2 * hpm * .pi / 180) + 0.32 * cos((3 * hpm + 6) * .pi / 180) - 0.20 * cos((4 * hpm - 63) * .pi / 180)
  let dTheta = 30 * exp(-pow((hpm - 275) / 25, 2))
  let Rc = 2 * sqrt(pow(Cpm, 7) / (pow(Cpm, 7) + pow(25.0, 7)))
  let Sl = 1 + 0.015 * pow(Lpm - 50, 2) / sqrt(20 + pow(Lpm - 50, 2))
  let Sc = 1 + 0.045 * Cpm, Sh = 1 + 0.015 * Cpm * T
  let Rt = -sin(2 * dTheta * .pi / 180) * Rc
  return sqrt(pow(dLp / Sl, 2) + pow(dCp / Sc, 2) + pow(dHp / Sh, 2) + Rt * (dCp / Sc) * (dHp / Sh))
}

let a = CommandLine.arguments
let render = Img(a[1], scale: Double(a[2])!)
let runtime = Img(a[3], scale: Double(a[4])!)
let W = Double(a[5])!, H = Double(a[6])!
let withGrid = a.count > 7 ? a[7] != "0" : true
let s = W / 358, e = max(0, H - 717 * s), e1 = 0.3 * e
let boardLeft = (W - 308.5 * s) / 2, boardTop = 261.5 * s + e1
let pad = 11 * s, tile = 52 * s, gap = 6.5 * s, stride = tile + gap
let hudTop = 592.5 * s + e
func cx(_ c: Int) -> Double { boardLeft + pad + Double(c) * stride + tile / 2 }
func cy(_ r: Int) -> Double { boardTop + pad + Double(r) * stride + tile / 2 }
let railW = 36 * s, railGap = 8 * s, railLeft = (W - (5 * railW + 4 * railGap)) / 2, railTop = 197 * s + e1

var features: [(String, Bool, Double, Double, Double)] = [  // name, vertical, fixed, expected, sign
  // Top/bottom edges are probed on the element's flat middle, clear of its corner radius.
  ("board card top light line (y)", true, W / 2, boardTop, 0),
  ("rail tile 2 top (y)", true, railLeft + 2 * (railW + railGap) + railW / 2, railTop, 0),
  ("rail tile 2 bottom (y)", true, railLeft + 2 * (railW + railGap) + railW / 2, railTop + 42 * s, 0),
  ("rail tile 0 left (x)", false, railTop + 21 * s + 8 * s, railLeft, 0),
  ("HAMLE card top (y)", true, 273.5 * s + 30 * s, 75 * s, 0),
  ("HAMLE card left (x)", false, 75 * s + 50 * s, 273.5 * s, 0),
  ("undo pill top (y)", true, 29 * s + 49.25 * s, hudTop, 0),
  ("undo pill left (x)", false, hudTop + 25 * s, 29 * s, 0),
  ("restart square left (x)", false, hudTop + 25 * s, 289 * s, 0),
  ("restart square top (y)", true, 289 * s + 22, hudTop + (50 * s - 44) / 2, 0),
  // The chevron stroke is ~1.6 pt wide: its rising (left) edge at the apex.
  ("back chevron apex (x)", false, 96 * s + 10 * s, 25 * s + 8 * 20 * s / 24, 1),
]
if withGrid {
  features += [
    ("tile (0,0) left (x)", false, cy(0), boardLeft + pad, 1),
    ("tile (0,0) top (y)", true, cx(0), boardTop + pad, 1),
    ("tile (0,4) right (x)", false, cy(0), boardLeft + pad + 4 * stride + tile, -1),
    ("tile (4,0) bottom (y)", true, cx(0), boardTop + pad + 4 * stride + tile, -1),
    ("tile (2,2) left (x)", false, cy(2), cx(2) - tile / 2, 1),
  ]
}
print(String(format: "geometry W %.0f H %.0f  s %.4f  e %.2f", W, H, s, e))
print("feature | render pt | runtime pt | Δ pt")
var worst = 0.0
for (name, vertical, fixed, expected, sign) in features {
  let r = render.edge(vertical: vertical, fixed: fixed, expected: expected, sign: sign)
  let t = runtime.edge(vertical: vertical, fixed: fixed, expected: expected, sign: sign)
  worst = max(worst, abs(t - r))
  print(String(format: "%@ | %.2f | %.2f | %+.2f", name, r, t, t - r))
}
print(String(format: "max |Δ| %.2f pt", worst))

var patches: [(String, Double, Double, Double)] = [  // name, x, y, half-size (pt)
  ("ground, left middle (teal spill)", 8, H * 0.58, 3),
  ("ground, top right (light)", W - 20, 40 * s, 3),
  ("ground, bottom", W / 2, H - 20 * s, 3),
  ("rail tile body", railLeft + railW * 0.2, railTop + 42 * s * 0.8, 1.5),
  ("HAMLE card fill", 273.5 * s + 8 * s, 75 * s + 32 * s, 2),
  ("undo pill fill", 29 * s + 12 * s, hudTop + 8 * s, 2),
  ("board card, bottom margin", W / 2, boardTop + 307.5 * s - 4 * s, 1.5),
]
if withGrid {
  patches += [
    ("tile (1,0) body", cx(0) - tile * 0.32, cy(1) - tile * 0.32, 3),
    ("tile (3,4) body", cx(4) + tile * 0.32, cy(3) + tile * 0.32, 3),
  ]
}
print("patch | render RGB | runtime RGB | ΔE2000")
var worstDE = 0.0
for (name, x, y, half) in patches {
  let r = render.patch(x, y, half), t = runtime.patch(x, y, half)
  let d = de2000(r, t)
  worstDE = max(worstDE, d)
  print(String(format: "%@ | %.0f,%.0f,%.0f | %.0f,%.0f,%.0f | %.2f", name, r.0, r.1, r.2, t.0, t.1, t.2, d))
}
print(String(format: "max ΔE2000 %.2f", worstDE))

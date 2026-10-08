import SwiftUI

struct SeededRNG: RandomNumberGenerator {
    var state: UInt64
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

enum BrainShape {
    static var cerebrum: Path {
        var p = Path()
        p.move(to: CGPoint(x: 0.05, y: 0.50))
        p.addCurve(to: CGPoint(x: 0.30, y: 0.07), control1: CGPoint(x: 0.04, y: 0.22), control2: CGPoint(x: 0.16, y: 0.08))
        p.addCurve(to: CGPoint(x: 0.72, y: 0.10), control1: CGPoint(x: 0.46, y: 0.03), control2: CGPoint(x: 0.60, y: 0.04))
        p.addCurve(to: CGPoint(x: 0.95, y: 0.50), control1: CGPoint(x: 0.88, y: 0.16), control2: CGPoint(x: 0.97, y: 0.32))
        p.addCurve(to: CGPoint(x: 0.82, y: 0.64), control1: CGPoint(x: 0.94, y: 0.58), control2: CGPoint(x: 0.90, y: 0.64))
        p.addCurve(to: CGPoint(x: 0.55, y: 0.72), control1: CGPoint(x: 0.74, y: 0.70), control2: CGPoint(x: 0.64, y: 0.76))
        p.addCurve(to: CGPoint(x: 0.25, y: 0.62), control1: CGPoint(x: 0.45, y: 0.66), control2: CGPoint(x: 0.34, y: 0.64))
        p.addCurve(to: CGPoint(x: 0.05, y: 0.50), control1: CGPoint(x: 0.14, y: 0.62), control2: CGPoint(x: 0.06, y: 0.58))
        p.closeSubpath()
        return p
    }
    static var cerebellum: Path { Path(ellipseIn: CGRect(x: 0.68, y: 0.665, width: 0.24, height: 0.15)) }
    static var stem: Path {
        var p = Path()
        p.move(to: CGPoint(x: 0.60, y: 0.66))
        p.addLine(to: CGPoint(x: 0.72, y: 0.66))
        p.addCurve(to: CGPoint(x: 0.69, y: 0.96), control1: CGPoint(x: 0.72, y: 0.80), control2: CGPoint(x: 0.70, y: 0.88))
        p.addLine(to: CGPoint(x: 0.63, y: 0.96))
        p.addCurve(to: CGPoint(x: 0.60, y: 0.66), control1: CGPoint(x: 0.63, y: 0.88), control2: CGPoint(x: 0.60, y: 0.80))
        p.closeSubpath()
        return p
    }
    static var parts: [Path] { [cerebrum, cerebellum, stem] }

    /// Yan görünüş silüetinin kalınlığı (z yarı-genişliği, w birimiyle).
    static func halfThickness(u: Double, v: Double, part: Int) -> Double {
        switch part {
        case 0:
            let e = pow((u - 0.5) / 0.50, 2) + pow((v - 0.36) / 0.34, 2)
            return 0.30 * sqrt(max(0.06, 1 - e * 0.85))
        case 1:
            let e = pow((u - 0.80) / 0.12, 2) + pow((v - 0.74) / (0.075 * 1.2), 2)
            return 0.20 * sqrt(max(0.10, 1 - e))
        default:
            return 0.06
        }
    }
}

enum BrainLayout {
    static let aspect: CGFloat = 1.2
    static func rect(in size: CGSize) -> CGRect {
        let narrow = size.width < 600
        let w = min(size.width * (narrow ? 0.58 : 0.70), size.height * 0.74 * aspect)
        let h = w / aspect
        return CGRect(x: (size.width - w) / 2, y: (size.height - h) / 2 - size.height * 0.02, width: w, height: h)
    }
}

/// 3B → ekran izdüşümü. Girdi: birim koordinat (u,v) ve derinlik z (w biriminde).
struct BrainProjector {
    let rect: CGRect
    let yaw: Double
    let pitch: Double
    private let cy: Double, sy: Double, cp: Double, sp: Double

    init(rect: CGRect, yaw: Double, pitch: Double) {
        self.rect = rect; self.yaw = yaw; self.pitch = pitch
        cy = cos(yaw); sy = sin(yaw); cp = cos(pitch); sp = sin(pitch)
    }

    func project(u: Double, v: Double, z: Double = 0) -> (pt: CGPoint, depth: Double) {
        let x = u - 0.5, y = (v - 0.5) / BrainLayout.aspect
        let x1 = x * cy + z * sy, z1 = -x * sy + z * cy
        let y2 = y * cp - z1 * sp, z2 = y * sp + z1 * cp
        let s = 1 + z2 * 0.22
        return (CGPoint(x: rect.midX + x1 * s * rect.width, y: rect.midY + y2 * s * rect.width), z2)
    }

    static func angles(store: BrainStore, t: Double) -> (yaw: Double, pitch: Double) {
        (store.yaw + 0.10 * sin(t * 0.4), store.pitch + 0.03 * sin(t * 0.3))
    }
}

final class BrainNetwork {
    struct RegionWeight { let index: Int; let weight: Double }
    struct Neuron { let u: Double; let v: Double; let z: Double; let seed: Double; let weights: [RegionWeight]; let dominant: Region }
    struct Link { let a: Int; let b: Int; let phase: Double; let speed: Double; let gate: Double }

    static let shared = BrainNetwork()
    let neurons: [Neuron]
    let links: [Link]

    private init() {
        var rng = SeededRNG(state: 42)
        let regions = Region.allCases
        let parts = BrainShape.parts
        var raw: [(u: Double, v: Double, z: Double, part: Int)] = []

        func gauss() -> Double {
            let a = Double.random(in: 0.0001...1, using: &rng), b = Double.random(in: 0...1, using: &rng)
            return sqrt(-2 * log(a)) * cos(2 * .pi * b)
        }
        func sample(part: Int, count: Int) {
            var got = 0
            while got < count {
                let u = Double.random(in: 0.02...0.98, using: &rng), v = Double.random(in: 0.02...0.98, using: &rng)
                guard parts[part].contains(CGPoint(x: u, y: v)) else { continue }
                let zmax = BrainShape.halfThickness(u: u, v: v, part: part)
                let shell = Double.random(in: 0...1, using: &rng) < 0.65
                let mag = shell ? zmax * Double.random(in: 0.88...1.0, using: &rng) : zmax * Double.random(in: 0...0.85, using: &rng)
                let sign: Double = Bool.random(using: &rng) ? 1 : -1
                raw.append((u, v, sign * max(0.02, mag), part))
                got += 1
            }
        }
        sample(part: 0, count: 650)
        sample(part: 1, count: 100)
        sample(part: 2, count: 40)
        // Derin yapılar (hipokampus, amigdala): beynin iç kısmında nöron kümeleri.
        for r in [Region.hippocampus, .amygdala] {
            for _ in 0..<45 {
                let u = r.center.x + gauss() * 0.03, v = r.center.y + gauss() * 0.03 * BrainLayout.aspect
                let z = (Bool.random(using: &rng) ? 1.0 : -1.0) * Double.random(in: 0.04...0.14, using: &rng)
                raw.append((u, v, z, 0))
            }
        }

        var ns: [Neuron] = []
        for q in raw {
            var ws: [RegionWeight] = []
            var best = (0, 0.0)
            let ratio = abs(q.z) / BrainShape.halfThickness(u: q.u, v: q.v, part: q.part)
            for (i, r) in regions.enumerated() {
                let dx = q.u - r.center.x, dy = (q.v - r.center.y) / BrainLayout.aspect
                var w = exp(-pow(hypot(dx, dy) / r.radius, 2))
                if (r == .hippocampus || r == .amygdala) && ratio > 0.6 { w = 0 }
                if w > 0.04 { ws.append(RegionWeight(index: i, weight: w)) }
                if w > best.1 { best = (i, w) }
            }
            ns.append(Neuron(u: q.u, v: q.v, z: q.z, seed: Double.random(in: 0...1, using: &rng), weights: ws, dominant: regions[best.0]))
        }
        neurons = ns

        func dist(_ a: Neuron, _ b: Neuron) -> Double {
            sqrt(pow(a.u - b.u, 2) + pow((a.v - b.v) / BrainLayout.aspect, 2) + pow(a.z - b.z, 2))
        }
        var ls: [Link] = []
        var seen = Set<Int>()
        for i in ns.indices {
            let near = ns.indices.filter { $0 != i }.map { ($0, dist(ns[i], ns[$0])) }.sorted { $0.1 < $1.1 }.prefix(3)
            for (j, d) in near where d < 0.12 {
                let key = min(i, j) * 10_000 + max(i, j)
                if seen.insert(key).inserted {
                    ls.append(Link(a: i, b: j, phase: Double.random(in: 0...1, using: &rng),
                                   speed: Double.random(in: 0.25...0.8, using: &rng), gate: Double.random(in: 0...1, using: &rng)))
                }
            }
        }
        links = ls
    }
}

struct BrainView: View {
    let store: BrainStore
    private let net = BrainNetwork.shared
    @State private var dragStart: (yaw: Double, pitch: Double)?

    var body: some View {
        GeometryReader { geo in
            let rect = BrainLayout.rect(in: geo.size)
            TimelineView(.animation) { tl in
                let t = tl.date.timeIntervalSinceReferenceDate
                let ang = BrainProjector.angles(store: store, t: t)
                let proj = BrainProjector(rect: rect, yaw: ang.yaw, pitch: ang.pitch)
                ZStack {
                    Canvas { ctx, _ in draw(&ctx, rect: rect, proj: proj, t: t) }
                    ForEach(Region.allCases) { r in
                        let c = proj.project(u: r.center.x, v: r.center.y).pt
                        RegionTag(region: r, value: store.current[r] ?? 0, focused: store.focusRegion == r)
                            .position(x: c.x + (r.labelPos.x - r.center.x) * rect.width,
                                      y: c.y + (r.labelPos.y - r.center.y) * rect.height)
                    }
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 6)
                    .onChanged { v in
                        if dragStart == nil { dragStart = (store.yaw, store.pitch) }
                        store.dragging = true
                        store.lastInteraction = Date()
                        store.yaw = (dragStart?.yaw ?? 0) + Double(v.translation.width) * 0.012
                        store.pitch = max(-0.7, min(0.7, (dragStart?.pitch ?? 0) + Double(v.translation.height) * 0.008))
                    }
                    .onEnded { _ in
                        dragStart = nil
                        store.dragging = false
                        store.lastInteraction = Date()
                    }
            )
            .simultaneousGesture(
                SpatialTapGesture().onEnded { tap in
                    let t = Date().timeIntervalSinceReferenceDate
                    let ang = BrainProjector.angles(store: store, t: t)
                    let proj = BrainProjector(rect: rect, yaw: ang.yaw, pitch: ang.pitch)
                    let hit = Region.allCases
                        .map { r -> (Region, Double) in
                            let c = proj.project(u: r.center.x, v: r.center.y).pt
                            return (r, hypot(c.x - tap.location.x, c.y - tap.location.y) / (r.radius * rect.width))
                        }
                        .filter { $0.1 < 1.3 }
                        .min { $0.1 < $1.1 }?.0
                    store.focus(hit == store.focusRegion ? nil : hit)
                }
            )
        }
    }

    private func draw(_ ctx: inout GraphicsContext, rect: CGRect, proj: BrainProjector, t: Double) {
        let w = rect.width
        let regions = Region.allCases
        let focus = store.focusRegion

        var act = [Double](repeating: 0, count: regions.count)
        for (i, r) in regions.enumerated() {
            let base = store.current[r] ?? 0
            act[i] = max(0, min(1, base * (1 + 0.06 * sin(t * 2.2 + Double(i) * 1.7))))
        }
        var nAct = [Double](repeating: 0, count: net.neurons.count)
        var P = [CGPoint](repeating: .zero, count: net.neurons.count)
        var D = [Double](repeating: 0, count: net.neurons.count)
        for (i, n) in net.neurons.enumerated() {
            var s = 0.0
            for rw in n.weights { s += rw.weight * act[rw.index] }
            nAct[i] = min(1, s)
            let p = proj.project(u: n.u, v: n.v, z: n.z)
            P[i] = p.pt
            D[i] = max(0.3, min(1.0, 0.65 + p.depth * 1.1))
        }

        // Bölge ışıması
        ctx.drawLayer { layer in
            layer.blendMode = .plusLighter
            for (i, r) in regions.enumerated() {
                let c = proj.project(u: r.center.x, v: r.center.y).pt, rad = r.radius * w * 1.5
                let boost = focus == r ? 1.4 : 1.0
                layer.fill(Path(ellipseIn: CGRect(x: c.x - rad, y: c.y - rad, width: rad * 2, height: rad * 2)),
                           with: .radialGradient(Gradient(colors: [r.color.opacity(min(1, 0.5 * act[i] * boost)), r.color.opacity(0)]),
                                                 center: c, startRadius: 0, endRadius: rad))
            }
        }

        // Silüet: yalnızca yandan bakışa yakınken
        let sideness = max(0, 1 - abs(proj.yaw) / 0.55) * max(0, 1 - abs(proj.pitch) / 0.5)
        if sideness > 0.02 {
            let tf = CGAffineTransform(a: w, b: 0, c: 0, d: rect.height, tx: rect.minX, ty: rect.minY)
            ctx.drawLayer { layer in
                layer.addFilter(.blur(radius: 7))
                for part in BrainShape.parts { layer.stroke(part.applying(tf), with: .color(Theme.cyan.opacity(0.30 * sideness)), lineWidth: 4) }
            }
            for part in BrainShape.parts {
                ctx.stroke(part.applying(tf), with: .color(Theme.cyan.opacity(0.40 * sideness)), lineWidth: 1.0)
            }
        }

        // Bağlantılar
        var faint = Path()
        for l in net.links { faint.move(to: P[l.a]); faint.addLine(to: P[l.b]) }
        ctx.stroke(faint, with: .color(Theme.cyan.opacity(0.08)), lineWidth: 0.5)

        for l in net.links {
            let la = max(nAct[l.a], nAct[l.b])
            guard la > 0.18 else { continue }
            let color = (nAct[l.a] >= nAct[l.b] ? net.neurons[l.a] : net.neurons[l.b]).dominant.color
            let depth = (D[l.a] + D[l.b]) / 2
            var line = Path(); line.move(to: P[l.a]); line.addLine(to: P[l.b])
            ctx.stroke(line, with: .color(color.opacity(la * 0.55 * depth)), lineWidth: 0.8)
            if l.gate < la {
                let f = (t * l.speed * (0.6 + la) + l.phase).truncatingRemainder(dividingBy: 1)
                let c = CGPoint(x: P[l.a].x + (P[l.b].x - P[l.a].x) * f, y: P[l.a].y + (P[l.b].y - P[l.a].y) * f)
                ctx.fill(Path(ellipseIn: CGRect(x: c.x - 2, y: c.y - 2, width: 4, height: 4)), with: .color(.white.opacity(0.9 * depth)))
            }
        }

        // Nöronlar: arkadakiler önce çizilsin
        let scale = max(0.8, w / 600)
        let order = net.neurons.indices.sorted { D[$0] < D[$1] }
        for i in order {
            let n = net.neurons[i], a = nAct[i], c = P[i], d = D[i]
            let twinkle = 0.85 + 0.15 * sin(t * 2 + n.seed * 6.28)
            let r = (1.2 + 2.4 * a) * (0.6 + 0.5 * d) * scale * twinkle
            let color = a > 0.12 ? n.dominant.color : Theme.cyan
            let dim = (focus != nil && n.dominant != focus && a < 0.5) ? 0.55 : 1.0
            if a > 0.5 {
                ctx.fill(Path(ellipseIn: CGRect(x: c.x - r * 2.2, y: c.y - r * 2.2, width: r * 4.4, height: r * 4.4)),
                         with: .color(color.opacity(0.14 * d)))
            }
            ctx.fill(Path(ellipseIn: CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2)),
                     with: .color(color.opacity((0.20 + 0.80 * a) * d * dim)))
        }

        // Etiket çizgileri + odak halkası
        for (i, r) in regions.enumerated() {
            let c = proj.project(u: r.center.x, v: r.center.y).pt
            var line = Path()
            line.move(to: c)
            line.addLine(to: CGPoint(x: c.x + (r.labelPos.x - r.center.x) * rect.width, y: c.y + (r.labelPos.y - r.center.y) * rect.height))
            ctx.stroke(line, with: .color(r.color.opacity(0.12 + 0.5 * act[i])), style: StrokeStyle(lineWidth: 0.8, dash: [3, 4]))
            ctx.fill(Path(ellipseIn: CGRect(x: c.x - 3, y: c.y - 3, width: 6, height: 6)), with: .color(r.color.opacity(0.4 + 0.6 * act[i])))
            if focus == r {
                let rad = r.radius * w * 0.95
                ctx.stroke(Path(ellipseIn: CGRect(x: c.x - rad, y: c.y - rad, width: rad * 2, height: rad * 2)),
                           with: .color(r.color.opacity(0.9)),
                           style: StrokeStyle(lineWidth: 1.5, dash: [6, 5], dashPhase: CGFloat(t * 20)))
            }
        }
    }
}

struct RegionTag: View {
    let region: Region
    let value: Double
    var focused = false

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(region.short)
                .font(.system(size: 9.5, weight: .semibold, design: .monospaced))
                .foregroundStyle(region.color)
            Text("\(Int((value * 100).rounded()))%")
                .font(.system(size: 17, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 8).padding(.vertical, 5)
        .background(RoundedRectangle(cornerRadius: 6).fill(Theme.bg.opacity(0.85)))
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(focused ? Color.white : region.color.opacity(0.25 + 0.6 * value), lineWidth: focused ? 1.6 : 1))
        .opacity(focused ? 1 : 0.6 + 0.4 * value)
        .fixedSize()
        .allowsHitTesting(false)
    }
}

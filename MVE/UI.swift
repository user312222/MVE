import SwiftUI

extension View {
    func panel() -> some View {
        self.padding(14)
            .background(RoundedRectangle(cornerRadius: 14).fill(Theme.panelFill))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.panelStroke, lineWidth: 1))
    }
}

func sectionTitle(_ s: String) -> some View {
    Text(s).font(.system(size: 10.5, weight: .bold, design: .monospaced)).tracking(2)
        .foregroundStyle(Theme.cyan.opacity(0.8))
}

struct Bar: View {
    let value: Double
    let color: Color
    var height: CGFloat = 5
    var body: some View {
        GeometryReader { g in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.07))
                Capsule().fill(LinearGradient(colors: [color.opacity(0.5), color], startPoint: .leading, endPoint: .trailing))
                    .frame(width: max(0, min(1, value)) * g.size.width)
                    .shadow(color: color.opacity(0.6), radius: 4)
            }
        }
        .frame(height: height)
    }
}

struct BackgroundView: View {
    var body: some View {
        ZStack {
            Theme.bg
            RadialGradient(colors: [Theme.cyan.opacity(0.10), .clear], center: .center, startRadius: 0, endRadius: 650)
            Canvas { ctx, size in
                var p = Path()
                var x: CGFloat = 0
                while x < size.width { p.move(to: CGPoint(x: x, y: 0)); p.addLine(to: CGPoint(x: x, y: size.height)); x += 40 }
                var y: CGFloat = 0
                while y < size.height { p.move(to: CGPoint(x: 0, y: y)); p.addLine(to: CGPoint(x: size.width, y: y)); y += 40 }
                ctx.stroke(p, with: .color(Theme.cyan.opacity(0.035)), lineWidth: 0.5)
            }
        }
        .ignoresSafeArea()
    }
}

struct HeaderBar: View {
    let store: BrainStore
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text("NEURO·V2").font(.system(size: 22, weight: .heavy, design: .monospaced)).tracking(4)
                    .foregroundStyle(LinearGradient(colors: [.white, Theme.cyan], startPoint: .leading, endPoint: .trailing))
                Text("İNSAN v1.0 → v2.0  ·  BEYİN AKTİVASYON SİMÜLATÖRÜ")
                    .font(.system(size: 10, design: .monospaced)).tracking(1.5).foregroundStyle(.secondary)
            }
            Spacer()
            Text("sürükle: döndür · dokun: bölge").font(.system(size: 9.5, design: .monospaced)).foregroundStyle(.tertiary)
            Button { store.soundOn.toggle() } label: {
                Image(systemName: store.soundOn ? "speaker.wave.2.fill" : "speaker.slash.fill")
                    .foregroundStyle(store.soundOn ? Theme.cyan : .secondary)
            }
            .buttonStyle(.plain).padding(.horizontal, 6).help("Ambient ses")
            HStack(spacing: 6) {
                Circle().fill(store.isSimulating ? Color.green : Theme.cyan).frame(width: 7, height: 7)
                    .shadow(color: store.isSimulating ? .green : Theme.cyan, radius: 4)
                Text(store.isSimulating ? "GÜN SİMÜLASYONU" : store.activeTask == nil ? "DİNLENME MODU" : "ÖNİZLEME")
                    .font(.system(size: 10.5, weight: .semibold, design: .monospaced)).tracking(1.5)
            }
        }
    }
}

struct ActiveBanner: View {
    let store: BrainStore
    var body: some View {
        HStack(spacing: 12) {
            if let r = store.focusRegion {
                Circle().fill(r.color).frame(width: 12, height: 12).shadow(color: r.color, radius: 6).frame(width: 30)
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(r.name.uppercased()) · %\(Int(((store.current[r] ?? 0) * 100).rounded()))")
                        .font(.system(size: 13, weight: .bold, design: .monospaced)).foregroundStyle(r.color)
                    Text(r.role + " — bu bölgeyi en çok çalıştıranlar:").font(.system(size: 12)).foregroundStyle(.secondary)
                }
                Spacer()
                HStack(spacing: 6) {
                    ForEach(BrainTask.all.sorted { ($0.activation[r] ?? 0) > ($1.activation[r] ?? 0) }.prefix(3)) { t in
                        Button { store.select(t) } label: {
                            Text("\(t.name) %\(Int((t.activation[r] ?? 0) * 100))")
                                .font(.system(size: 10, weight: .semibold)).lineLimit(1)
                                .padding(.horizontal, 8).padding(.vertical, 4)
                                .background(Capsule().fill(r.color.opacity(0.2)))
                        }.buttonStyle(.plain)
                    }
                    Button { store.focus(nil) } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary) }
                        .buttonStyle(.plain)
                }
            } else if let t = store.activeTask {
                Image(systemName: t.icon).font(.system(size: 20)).foregroundStyle(Theme.cyan).frame(width: 30)
                VStack(alignment: .leading, spacing: 2) {
                    Text(t.name.uppercased()).font(.system(size: 13, weight: .bold, design: .monospaced))
                    Text(t.tip).font(.system(size: 12)).foregroundStyle(.secondary)
                }
                Spacer()
                let top = t.activation.sorted { $0.value > $1.value }.prefix(3)
                HStack(spacing: 6) {
                    ForEach(Array(top), id: \.key) { r, v in
                        Text("\(r.short) \(Int(v * 100))%")
                            .font(.system(size: 9.5, weight: .semibold, design: .monospaced))
                            .padding(.horizontal, 6).padding(.vertical, 3)
                            .background(Capsule().fill(r.color.opacity(0.18)))
                            .foregroundStyle(r.color)
                    }
                }
            } else {
                Image(systemName: "moon.stars").font(.system(size: 20)).foregroundStyle(.secondary).frame(width: 30)
                Text("Soldan bir görev seç ya da günü simüle et. Beyin bölgeleri her görevde farklı yüzdelerle çalışır.")
                    .font(.system(size: 12)).foregroundStyle(.secondary)
                Spacer()
            }
        }
        .panel()
        .frame(minHeight: 70)
    }
}

struct LibraryPanel: View {
    let store: BrainStore
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("GÖREV KÜTÜPHANESİ")
            ScrollView {
                VStack(spacing: 6) {
                    ForEach(BrainTask.all) { t in
                        let sel = store.selectedTaskID == t.id
                        Button { store.select(sel ? nil : t) } label: {
                            HStack(spacing: 10) {
                                Image(systemName: t.icon).frame(width: 22).foregroundStyle(sel ? Theme.cyan : .secondary)
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(t.name).font(.system(size: 12, weight: .medium)).lineLimit(1)
                                    if let top = t.activation.max(by: { $0.value < $1.value }) {
                                        Text("\(top.key.short) \(Int(top.value * 100))%")
                                            .font(.system(size: 9, design: .monospaced)).foregroundStyle(top.key.color)
                                    }
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 10).padding(.vertical, 7)
                            .background(RoundedRectangle(cornerRadius: 9).fill(sel ? Theme.cyan.opacity(0.14) : Color.white.opacity(0.03)))
                            .overlay(RoundedRectangle(cornerRadius: 9).stroke(sel ? Theme.cyan.opacity(0.6) : .clear, lineWidth: 1))
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .panel()
    }
}

struct StatusPanel: View {
    let store: BrainStore
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                VersionCard(store: store)
                ActivationCard(store: store)
                SuggestionCard(store: store)
            }
        }
        .scrollIndicators(.hidden)
    }
}

struct VersionCard: View {
    let store: BrainStore
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("EVRİM İLERLEMESİ")
            HStack(alignment: .firstTextBaseline) {
                Text(String(format: "v%.2f", store.version))
                    .font(.system(size: 40, weight: .heavy, design: .monospaced))
                    .foregroundStyle(LinearGradient(colors: [.white, Theme.cyan], startPoint: .top, endPoint: .bottom))
                    .shadow(color: Theme.cyan.opacity(0.6), radius: 10)
                Text("→ v2.00").font(.system(size: 13, design: .monospaced)).foregroundStyle(.secondary)
                Spacer()
            }
            Bar(value: store.progress, color: Theme.cyan, height: 7)
            Text("\(store.stage) · %\(Int(store.progress * 100))")
                .font(.system(size: 10, weight: .semibold, design: .monospaced)).tracking(1.5).foregroundStyle(Theme.cyan)
            VStack(spacing: 7) {
                ForEach(Skill.allCases) { s in
                    HStack(spacing: 8) {
                        Text(s.name).font(.system(size: 11)).frame(width: 74, alignment: .leading)
                        Bar(value: store.skillLevel(s), color: s.color, height: 4)
                        Text("\(Int(store.skillLevel(s) * 100))")
                            .font(.system(size: 10, design: .monospaced)).foregroundStyle(.secondary).frame(width: 24, alignment: .trailing)
                    }
                }
            }
        }
        .panel()
    }
}

struct ActivationCard: View {
    let store: BrainStore
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("BÖLGE AKTİVASYONU")
            let sorted = Region.allCases.sorted { (store.current[$0] ?? 0) > (store.current[$1] ?? 0) }
            ForEach(sorted) { r in
                let v = store.current[r] ?? 0
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(r.name).font(.system(size: 11.5, weight: .medium))
                        Spacer()
                        Text("\(Int((v * 100).rounded()))%").font(.system(size: 12, weight: .bold, design: .monospaced)).foregroundStyle(r.color)
                    }
                    Bar(value: v, color: r.color, height: 4)
                    Text(r.role).font(.system(size: 9.5)).foregroundStyle(.secondary)
                }
            }
        }
        .panel()
    }
}

struct SuggestionCard: View {
    let store: BrainStore
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("PLAN ANALİZİ")
            if let s = store.suggestion {
                if s.average < 0.30 {
                    Text("Bugünkü planında **\(s.region.name)** ortalama sadece %\(Int(s.average * 100)) çalışıyor. **\(s.task.name)** bu bölgeyi %\(Int((s.task.activation[s.region] ?? 0) * 100)) aktive eder.")
                        .font(.system(size: 12))
                    Button { store.add(s.task) } label: {
                        Label("Plana ekle", systemImage: "plus.circle.fill").font(.system(size: 12, weight: .semibold))
                    }
                    .buttonStyle(.borderedProminent).tint(s.region.color).controlSize(.small)
                } else {
                    Text("Planın dengeli görünüyor: en zayıf bölge **\(s.region.name)** bile ortalama %\(Int(s.average * 100)).")
                        .font(.system(size: 12))
                }
            } else {
                Text("Analiz için plana görev ekle.").font(.system(size: 12)).foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .panel()
    }
}

struct TimelinePanel: View {
    let store: BrainStore
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                sectionTitle("GÜN PLANI")
                Spacer()
                Button {
                    store.isSimulating ? store.stopSimulation() : store.startSimulation()
                } label: {
                    Label(store.isSimulating ? "Durdur" : "Günü Simüle Et", systemImage: store.isSimulating ? "stop.fill" : "play.fill")
                        .font(.system(size: 11.5, weight: .semibold))
                }
                .buttonStyle(.borderedProminent).tint(Theme.cyan).controlSize(.small)
                Menu {
                    ForEach(BrainTask.all) { t in Button(t.name) { store.add(t) } }
                } label: { Label("Görev Ekle", systemImage: "plus").font(.system(size: 11.5)) }
                    .fixedSize()
                Button { store.resetDay() } label: { Image(systemName: "arrow.counterclockwise") }
                    .buttonStyle(.plain).help("Günü sıfırla")
            }
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(Array(store.plan.enumerated()), id: \.element.id) { idx, item in
                        if let t = BrainTask.find(item.taskID) {
                            PlanCard(item: item, task: t, active: store.simIndex == idx || (!store.isSimulating && store.selectedTaskID == t.id),
                                     toggle: { store.toggleDone(item.id) })
                                .onTapGesture { store.select(t) }
                                .contextMenu { Button("Sil", role: .destructive) { store.remove(item.id) } }
                        }
                    }
                }
                .padding(.vertical, 2)
            }
            .scrollIndicators(.hidden)
        }
        .panel()
    }
}

struct PlanCard: View {
    let item: PlanItem
    let task: BrainTask
    let active: Bool
    let toggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(item.timeText).font(.system(size: 11, weight: .bold, design: .monospaced)).foregroundStyle(Theme.cyan)
                Spacer()
                Button(action: toggle) {
                    Image(systemName: item.done ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(item.done ? Color.green : .secondary)
                }.buttonStyle(.plain)
            }
            HStack(spacing: 6) {
                Image(systemName: task.icon).font(.system(size: 12)).foregroundStyle(.secondary)
                Text(task.name).font(.system(size: 11.5, weight: .medium)).lineLimit(1)
            }
            Text("\(item.duration) dk").font(.system(size: 10, design: .monospaced)).foregroundStyle(.secondary)
        }
        .padding(9)
        .frame(width: 150)
        .background(RoundedRectangle(cornerRadius: 10).fill(active ? Theme.cyan.opacity(0.15) : Color.white.opacity(0.035)))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(active ? Theme.cyan : Color.white.opacity(0.08), lineWidth: active ? 1.4 : 1))
        .opacity(item.done && !active ? 0.65 : 1)
        .contentShape(Rectangle())
    }
}

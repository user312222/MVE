import SwiftUI
import Observation

@MainActor
@Observable
final class BrainStore {
    static let skillCap = 600.0
    static let simStep = 3.0

    var plan: [PlanItem]
    var xp: [String: Double]
    var selectedTaskID: String?
    var current: [Region: Double]
    var isSimulating = false
    var simIndex: Int?
    var yaw = 0.0
    var pitch = 0.0
    var dragging = false
    var focusRegion: Region?
    var soundOn: Bool = UserDefaults.standard.bool(forKey: "soundOn") {
        didSet {
            UserDefaults.standard.set(soundOn, forKey: "soundOn")
            AmbientAudio.shared.setEnabled(soundOn)
            if soundOn { AmbientAudio.shared.blip(520) }
        }
    }

    @ObservationIgnored var lastInteraction = Date.distantPast
    @ObservationIgnored private var simClock = 0.0
    @ObservationIgnored private var timer: Timer?

    init() {
        let d = UserDefaults.standard
        var loadedPlan = (d.data(forKey: "plan.v1")).flatMap { try? JSONDecoder().decode([PlanItem].self, from: $0) }
        let today = Self.dayString()
        if d.string(forKey: "planDay") != today {
            loadedPlan = loadedPlan?.map { var i = $0; i.done = false; return i }
            d.set(today, forKey: "planDay")
        }
        plan = loadedPlan ?? Self.defaultPlan
        xp = (d.data(forKey: "xp.v1")).flatMap { try? JSONDecoder().decode([String: Double].self, from: $0) } ?? [:]
        current = Dictionary(uniqueKeysWithValues: Region.allCases.map { ($0, Self.rest($0)) })

        if soundOn { AmbientAudio.shared.setEnabled(true) }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.tick(1.0 / 30) }
        }
    }

    static func dayString() -> String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f.string(from: Date())
    }

    static func rest(_ r: Region) -> Double {
        switch r {
        case .prefrontal: 0.14
        case .parietal: 0.12
        case .hippocampus: 0.10
        default: 0.06
        }
    }

    static var defaultPlan: [PlanItem] {
        func item(_ id: String, _ h: Int, _ m: Int, _ dur: Int) -> PlanItem {
            PlanItem(taskID: id, startMinute: h * 60 + m, duration: dur)
        }
        return [
            item("cardio", 6, 30, 40), item("meditation", 7, 30, 15), item("deepwork", 9, 0, 90),
            item("language", 11, 0, 30), item("social", 13, 0, 45), item("problem", 14, 30, 90),
            item("strength", 17, 0, 45), item("reading", 19, 30, 40), item("creative", 20, 30, 45),
            item("sleep", 22, 30, 480),
        ]
    }

    // MARK: - Simülasyon döngüsü

    private func tick(_ dt: Double) {
        let task = selectedTaskID.flatMap(BrainTask.find)
        for r in Region.allCases {
            let target = task.map { $0.activation[r] ?? 0.06 } ?? Self.rest(r)
            let c = current[r] ?? 0
            current[r] = c + (target - c) * 0.10
        }
        if isSimulating { advanceSim(dt) }

        if !dragging, Date().timeIntervalSince(lastInteraction) > 2.5 {
            yaw = atan2(sin(yaw), cos(yaw)) * 0.94
            pitch *= 0.94
        }
        if soundOn { AmbientAudio.shared.energy = current.values.reduce(0, +) / Double(max(1, current.count)) * 2.2 }
    }

    func focus(_ region: Region?) {
        focusRegion = region
        if region != nil { Haptics.play(.light); if soundOn { AmbientAudio.shared.blip(740) } }
    }

    func select(_ task: BrainTask?) {
        if isSimulating { stopSimulation() }
        selectedTaskID = task?.id
        Haptics.play(.medium)
        if soundOn { AmbientAudio.shared.blip(task == nil ? 440 : 660) }
    }

    func startSimulation() {
        guard !plan.isEmpty else { return }
        isSimulating = true
        simClock = 0
        simIndex = nil
    }

    func stopSimulation() {
        isSimulating = false
        simIndex = nil
        selectedTaskID = nil
    }

    private func advanceSim(_ dt: Double) {
        simClock += dt
        let idx = Int(simClock / Self.simStep)
        if idx >= plan.count {
            if let p = simIndex { complete(p) }
            stopSimulation()
            return
        }
        if idx != simIndex {
            if let p = simIndex { complete(p) }
            simIndex = idx
            selectedTaskID = plan[idx].taskID
            Haptics.play(.light)
            if soundOn { AmbientAudio.shared.blip(600 + Double(idx % 5) * 60) }
        }
    }

    // MARK: - Plan & XP

    private func complete(_ i: Int) {
        guard plan.indices.contains(i), !plan[i].done else { return }
        plan[i].done = true
        award(plan[i], sign: 1)
        save()
    }

    func toggleDone(_ id: UUID) {
        guard let i = plan.firstIndex(where: { $0.id == id }) else { return }
        plan[i].done.toggle()
        if plan[i].done { Haptics.play(.success); if soundOn { AmbientAudio.shared.blip(880) } }
        award(plan[i], sign: plan[i].done ? 1 : -1)
        save()
    }

    private func award(_ item: PlanItem, sign: Double) {
        guard let t = BrainTask.find(item.taskID), let s = t.skill else { return }
        let v = (xp[s.rawValue] ?? 0) + sign * Double(item.duration) * t.xpRate
        xp[s.rawValue] = min(Self.skillCap, max(0, v))
    }

    func add(_ task: BrainTask) {
        let start = plan.map { $0.startMinute + $0.duration }.max().map { min($0, 23 * 60) } ?? 8 * 60
        plan.append(PlanItem(taskID: task.id, startMinute: start, duration: task.minutes))
        plan.sort { $0.startMinute < $1.startMinute }
        save()
    }

    func remove(_ id: UUID) {
        plan.removeAll { $0.id == id }
        save()
    }

    func resetDay() {
        stopSimulation()
        for i in plan.indices where plan[i].done {
            plan[i].done = false
            award(plan[i], sign: -1)
        }
        save()
    }

    private func save() {
        let d = UserDefaults.standard
        d.set(try? JSONEncoder().encode(plan), forKey: "plan.v1")
        d.set(try? JSONEncoder().encode(xp), forKey: "xp.v1")
    }

    // MARK: - Türetilmiş değerler

    var progress: Double {
        Skill.allCases.reduce(0) { $0 + (xp[$1.rawValue] ?? 0) } / (Self.skillCap * Double(Skill.allCases.count))
    }
    var version: Double { 1.0 + progress }
    var stage: String {
        switch progress {
        case ..<0.25: "UYANIŞ"
        case ..<0.5: "ADAPTASYON"
        case ..<0.75: "GENİŞLEME"
        case ..<1.0: "ENTEGRASYON"
        default: "EVRİM TAMAM"
        }
    }
    func skillLevel(_ s: Skill) -> Double { (xp[s.rawValue] ?? 0) / Self.skillCap }

    var activeTask: BrainTask? { selectedTaskID.flatMap(BrainTask.find) }

    /// Planın uyku hariç süre-ağırlıklı ortalama bölge aktivasyonu.
    var dayAverage: [Region: Double] {
        let items = plan.filter { $0.taskID != "sleep" }
        let total = Double(items.reduce(0) { $0 + $1.duration })
        guard total > 0 else { return [:] }
        var out: [Region: Double] = [:]
        for r in Region.allCases {
            out[r] = items.reduce(0.0) { $0 + Double($1.duration) * (BrainTask.find($1.taskID)?.activation[r] ?? 0.06) } / total
        }
        return out
    }

    struct Suggestion { let region: Region; let average: Double; let task: BrainTask }

    var suggestion: Suggestion? {
        let avg = dayAverage
        guard let weakest = Region.allCases.filter({ $0 != .brainstem && $0 != .amygdala }).min(by: { (avg[$0] ?? 0) < (avg[$1] ?? 0) }),
              let task = BrainTask.all.filter({ $0.skill != nil && $0.id != "sleep" }).max(by: { ($0.activation[weakest] ?? 0) < ($1.activation[weakest] ?? 0) })
        else { return nil }
        return Suggestion(region: weakest, average: avg[weakest] ?? 0, task: task)
    }
}

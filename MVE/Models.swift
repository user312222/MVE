import SwiftUI

enum Theme {
    static let bg = Color(red: 0.015, green: 0.025, blue: 0.06)
    static let cyan = Color(red: 0.25, green: 0.88, blue: 1.0)
    static let panelFill = Color.white.opacity(0.035)
    static let panelStroke = Color(red: 0.25, green: 0.88, blue: 1.0).opacity(0.18)
}

enum Region: String, CaseIterable, Identifiable, Codable {
    case prefrontal, motor, sensory, parietal, occipital, temporal, hippocampus, amygdala, cerebellum, brainstem
    var id: String { rawValue }

    var name: String {
        switch self {
        case .prefrontal: "Prefrontal Korteks"
        case .motor: "Motor Korteks"
        case .sensory: "Duyusal Korteks"
        case .parietal: "Parietal Lob"
        case .occipital: "Oksipital Lob"
        case .temporal: "Temporal Lob"
        case .hippocampus: "Hipokampus"
        case .amygdala: "Amigdala"
        case .cerebellum: "Beyincik"
        case .brainstem: "Beyin Sapı"
        }
    }
    var short: String {
        switch self {
        case .prefrontal: "PREFRONTAL"
        case .motor: "MOTOR"
        case .sensory: "DUYUSAL"
        case .parietal: "PARİYETAL"
        case .occipital: "OKSİPİTAL"
        case .temporal: "TEMPORAL"
        case .hippocampus: "HİPOKAMPUS"
        case .amygdala: "AMİGDALA"
        case .cerebellum: "BEYİNCİK"
        case .brainstem: "BEYİN SAPI"
        }
    }
    var role: String {
        switch self {
        case .prefrontal: "Planlama, karar, odak"
        case .motor: "Hareket kontrolü"
        case .sensory: "Dokunma, beden algısı"
        case .parietal: "Uzamsal zekâ, dikkat"
        case .occipital: "Görme"
        case .temporal: "Dil, işitme, anlam"
        case .hippocampus: "Bellek oluşturma"
        case .amygdala: "Duygu, tehdit algısı"
        case .cerebellum: "Denge, koordinasyon"
        case .brainstem: "Uyanıklık, uyku, otonom"
        }
    }
    /// Birim koordinat (0...1), beyin yan görünüş, ön = sol.
    var center: CGPoint {
        switch self {
        case .prefrontal: CGPoint(x: 0.17, y: 0.38)
        case .motor: CGPoint(x: 0.40, y: 0.15)
        case .sensory: CGPoint(x: 0.55, y: 0.15)
        case .parietal: CGPoint(x: 0.72, y: 0.25)
        case .occipital: CGPoint(x: 0.86, y: 0.45)
        case .temporal: CGPoint(x: 0.52, y: 0.60)
        case .hippocampus: CGPoint(x: 0.56, y: 0.45)
        case .amygdala: CGPoint(x: 0.38, y: 0.52)
        case .cerebellum: CGPoint(x: 0.80, y: 0.74)
        case .brainstem: CGPoint(x: 0.65, y: 0.84)
        }
    }
    var radius: CGFloat {
        switch self {
        case .prefrontal: 0.17
        case .motor: 0.12
        case .sensory: 0.11
        case .parietal: 0.14
        case .occipital: 0.12
        case .temporal: 0.15
        case .hippocampus: 0.07
        case .amygdala: 0.06
        case .cerebellum: 0.10
        case .brainstem: 0.07
        }
    }
    var labelPos: CGPoint {
        switch self {
        case .prefrontal: CGPoint(x: -0.14, y: 0.18)
        case .motor: CGPoint(x: 0.27, y: -0.15)
        case .sensory: CGPoint(x: 0.62, y: -0.15)
        case .parietal: CGPoint(x: 1.10, y: 0.05)
        case .occipital: CGPoint(x: 1.14, y: 0.36)
        case .temporal: CGPoint(x: 0.22, y: 0.93)
        case .hippocampus: CGPoint(x: 0.44, y: 1.04)
        case .amygdala: CGPoint(x: -0.14, y: 0.62)
        case .cerebellum: CGPoint(x: 1.14, y: 0.78)
        case .brainstem: CGPoint(x: 0.86, y: 1.04)
        }
    }
    var color: Color {
        switch self {
        case .prefrontal: Color(red: 0.25, green: 0.85, blue: 1.0)
        case .motor: Color(red: 0.30, green: 1.0, blue: 0.55)
        case .sensory: Color(red: 1.0, green: 0.85, blue: 0.30)
        case .parietal: Color(red: 1.0, green: 0.55, blue: 0.25)
        case .occipital: Color(red: 1.0, green: 0.30, blue: 0.70)
        case .temporal: Color(red: 0.65, green: 0.45, blue: 1.0)
        case .hippocampus: Color(red: 0.35, green: 0.55, blue: 1.0)
        case .amygdala: Color(red: 1.0, green: 0.30, blue: 0.35)
        case .cerebellum: Color(red: 0.20, green: 1.0, blue: 0.85)
        case .brainstem: Color(red: 0.80, green: 1.0, blue: 0.40)
        }
    }
}

enum Skill: String, CaseIterable, Identifiable, Codable {
    case focus, memory, creativity, body, emotion
    var id: String { rawValue }
    var name: String {
        switch self {
        case .focus: "Odak"
        case .memory: "Bellek"
        case .creativity: "Yaratıcılık"
        case .body: "Beden"
        case .emotion: "Duygu"
        }
    }
    var color: Color {
        switch self {
        case .focus: Color(red: 0.25, green: 0.85, blue: 1.0)
        case .memory: Color(red: 0.55, green: 0.5, blue: 1.0)
        case .creativity: Color(red: 1.0, green: 0.5, blue: 0.8)
        case .body: Color(red: 0.3, green: 1.0, blue: 0.55)
        case .emotion: Color(red: 1.0, green: 0.75, blue: 0.3)
        }
    }
}

struct BrainTask: Identifiable {
    let id: String
    let name: String
    let icon: String
    let skill: Skill?
    let minutes: Int
    let xpRate: Double
    let tip: String
    let activation: [Region: Double]

    static func find(_ id: String) -> BrainTask? { all.first { $0.id == id } }

    static let all: [BrainTask] = [
        BrainTask(id: "deepwork", name: "Derin Çalışma", icon: "brain.head.profile", skill: .focus, minutes: 90, xpRate: 1.0,
                  tip: "Bildirimleri kapat, tek hedef seç. 90 dk sonra mola ver.",
                  activation: [.prefrontal: 0.92, .parietal: 0.55, .hippocampus: 0.35, .motor: 0.15, .brainstem: 0.30, .occipital: 0.35]),
        BrainTask(id: "reading", name: "Okuma", icon: "book.fill", skill: .memory, minutes: 40, xpRate: 1.1,
                  tip: "Okuduktan sonra 3 cümleyle özetle; hipokampusu pekiştirir.",
                  activation: [.occipital: 0.78, .temporal: 0.72, .prefrontal: 0.50, .hippocampus: 0.52, .parietal: 0.35]),
        BrainTask(id: "language", name: "Yeni Dil Öğrenme", icon: "character.bubble.fill", skill: .memory, minutes: 30, xpRate: 1.4,
                  tip: "Sesli tekrar et: temporal + motor konuşma devreleri birlikte çalışır.",
                  activation: [.temporal: 0.90, .hippocampus: 0.75, .prefrontal: 0.60, .motor: 0.35, .parietal: 0.30]),
        BrainTask(id: "cardio", name: "Koşu / Kardiyo", icon: "figure.run", skill: .body, minutes: 40, xpRate: 1.2,
                  tip: "Aerobik egzersiz BDNF'yi artırır; öğrenmeden önce yap.",
                  activation: [.motor: 0.90, .cerebellum: 0.75, .sensory: 0.62, .brainstem: 0.50, .hippocampus: 0.38, .prefrontal: 0.22]),
        BrainTask(id: "strength", name: "Ağırlık Antrenmanı", icon: "dumbbell.fill", skill: .body, minutes: 45, xpRate: 1.0,
                  tip: "Karmaşık hareketler beyincik ve motor korteksi birlikte eğitir.",
                  activation: [.motor: 0.85, .sensory: 0.66, .cerebellum: 0.55, .prefrontal: 0.35, .brainstem: 0.35]),
        BrainTask(id: "meditation", name: "Meditasyon", icon: "figure.mind.and.body", skill: .emotion, minutes: 15, xpRate: 1.6,
                  tip: "Nefese dön: prefrontal dikkat artar, amigdala reaktivitesi düşer.",
                  activation: [.prefrontal: 0.42, .parietal: 0.22, .brainstem: 0.36, .hippocampus: 0.28, .amygdala: 0.10, .sensory: 0.25]),
        BrainTask(id: "creative", name: "Yaratıcı Üretim", icon: "paintpalette.fill", skill: .creativity, minutes: 45, xpRate: 1.2,
                  tip: "Kısıt koy, sonra kuralları boz. Farklı bölgeler birbiriyle konuşur.",
                  activation: [.parietal: 0.62, .occipital: 0.62, .prefrontal: 0.60, .temporal: 0.50, .motor: 0.45, .amygdala: 0.35]),
        BrainTask(id: "social", name: "Sosyal Sohbet", icon: "person.2.fill", skill: .emotion, minutes: 45, xpRate: 0.9,
                  tip: "Gerçek yüz yüze sohbet empatiyi ve dil devrelerini besler.",
                  activation: [.temporal: 0.80, .amygdala: 0.55, .prefrontal: 0.55, .occipital: 0.42, .sensory: 0.25]),
        BrainTask(id: "problem", name: "Problem Çözme / Kodlama", icon: "chevron.left.forwardslash.chevron.right", skill: .focus, minutes: 90, xpRate: 1.1,
                  tip: "Önce kâğıtta çiz; sonra kodla. Çalışma belleği yükünü azaltır.",
                  activation: [.prefrontal: 0.95, .parietal: 0.76, .occipital: 0.45, .hippocampus: 0.40, .motor: 0.20]),
        BrainTask(id: "planning", name: "Planlama / Gözden Geçirme", icon: "calendar", skill: .focus, minutes: 20, xpRate: 1.3,
                  tip: "Geleceği simüle etmek prefrontal + hipokampus işidir.",
                  activation: [.prefrontal: 0.86, .hippocampus: 0.55, .parietal: 0.40, .amygdala: 0.20]),
        BrainTask(id: "music", name: "Müzik Aleti", icon: "pianokeys", skill: .creativity, minutes: 30, xpRate: 1.5,
                  tip: "Beyni en çok kapsayan aktivitelerden biri: duyu, motor, işitme birlikte.",
                  activation: [.motor: 0.82, .temporal: 0.80, .cerebellum: 0.70, .sensory: 0.52, .parietal: 0.50, .prefrontal: 0.40]),
        BrainTask(id: "walk", name: "Doğa Yürüyüşü", icon: "figure.walk", skill: .body, minutes: 30, xpRate: 0.9,
                  tip: "Telefonsuz yürü; varsayılan mod ağı dinlenir, fikirler gelir.",
                  activation: [.motor: 0.50, .occipital: 0.50, .cerebellum: 0.45, .prefrontal: 0.25, .amygdala: 0.12]),
        BrainTask(id: "sleep", name: "Derin Uyku", icon: "bed.double.fill", skill: .emotion, minutes: 480, xpRate: 0.15,
                  tip: "Bellek konsolidasyonu uykuda olur. 7-8 saat pazarlık dışı.",
                  activation: [.brainstem: 0.80, .hippocampus: 0.72, .temporal: 0.20, .prefrontal: 0.08]),
        BrainTask(id: "scroll", name: "Sonsuz Kaydırma (v1.0 alışkanlığı)", icon: "iphone", skill: nil, minutes: 30, xpRate: 0,
                  tip: "Yüksek uyarı, düşük prefrontal. Gelişim yok: bunu planından çıkar.",
                  activation: [.amygdala: 0.62, .occipital: 0.72, .prefrontal: 0.14, .sensory: 0.30, .motor: 0.10]),
    ]
}

struct PlanItem: Identifiable, Codable, Equatable {
    var id = UUID()
    var taskID: String
    var startMinute: Int
    var duration: Int
    var done = false

    var timeText: String { String(format: "%02d:%02d", (startMinute / 60) % 24, startMinute % 60) }
}

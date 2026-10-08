# NEURO·V2

**İnsan v1.0 → v2.0** — hayatını planlamana ve beynini geliştirmene yardımcı olan, futuristik bir SwiftUI uygulaması. Ortada canlı bir 3B beyin simülasyonu var: hangi görev beynin hangi bölgesini yüzde kaç çalıştırıyor, gerçek zamanlı görürsün.

> ⚠️ Bölge yüzdeleri nörobilim literatürüne dayanan **kabaca tahminlerdir**, tıbbi ölçüm değildir. Tıbbi tavsiye yerine geçmez.

## Özellikler

- **3B beyin simülasyonu:** ~900 nöron, bağlantılar ve akan sinyal atımları. Sürükleyerek döndür, bir bölgeye dokunarak odaklan.
- **10 beyin bölgesi:** prefrontal, motor, duyusal, parietal, oksipital, temporal, hipokampus, amigdala, beyincik, beyin sapı. Her biri canlı `%` etiketiyle gösterilir.
- **Görev kütüphanesi:** 14 görev (derin çalışma, okuma, dil öğrenme, kardiyo, meditasyon, müzik, uyku…). Birini seçince bölgeler o görevin aktivasyon yüzdelerine geçer.
- **Gün planı:** Görev ekle/sil, tamamla, **Günü Simüle Et** ile günü baştan sona beyin üzerinde izle.
- **Evrim ilerlemesi:** Odak, Bellek, Yaratıcılık, Beden ve Duygu becerileri XP kazanır; hepsi dolunca `v2.00`.
- **Plan analizi:** Planında en az çalışan bölgeyi bulur, onu en çok çalıştıran görevi önerir.
- **Geri bildirim:** Haptik titreşim (iOS ve Mac trackpad) ve isteğe bağlı, kodla üretilen ambient ses.

## Gereksinimler

- Xcode (proje `objectVersion 90`, iOS/macOS/visionOS 27.0 hedefli)
- Harici bağımlılık yok

## Çalıştırma

1. `MVE.xcodeproj` dosyasını Xcode'da aç.
2. `MVE` şemasını ve bir hedef seç (iPhone, iPad veya Mac).
3. ▶ ile çalıştır.

Komut satırından derlemek için:

```bash
xcodebuild -project MVE.xcodeproj -scheme MVE -destination 'generic/platform=macOS' build
```

## Kullanım

| Eylem | Sonuç |
|---|---|
| Soldan bir görev seç | Beyin o görevin aktivasyon haritasına geçer |
| Beyni sürükle | 3B döndürme (bırakınca yan görünüşe döner) |
| Bir bölgeye dokun | Bölge bilgi kartı + o bölgeyi en çok çalıştıran görevler |
| **Günü Simüle Et** | Planı sırayla oynatır, tamamlananlar XP kazandırır |
| Plan kartındaki daire | Görevi tamamla / geri al |
| Plan kartına sağ tık / uzun bas | Sil |
| Hoparlör simgesi | Ambient sesi aç/kapat |

Arayüz ekran genişliğine uyum sağlar: Mac ve iPad'de 3 kolon, iPhone'da *Beyin / Görevler / Durum* sekmeleri.

## Proje yapısı

```
MVE/
├── MyApp.swift       Uygulama girişi
├── ContentView.swift Geniş / dar ekran düzeni
├── Models.swift      Bölgeler, beceriler, görevler ve aktivasyon verileri, tema
├── Store.swift       Uygulama durumu (@Observable): plan, XP, simülasyon, odak
├── Brain.swift       Nöron ağı üretimi, 3B izdüşüm ve Canvas çizimi, jestler
├── UI.swift          Paneller: kütüphane, durum, plan, banner
└── Feedback.swift    Haptik ve ambient ses (AVAudioEngine)
```

## Veriyi özelleştirme

- **Görev ekle / yüzdeleri değiştir:** `Models.swift` içindeki `BrainTask.all`. Her görevin `activation` sözlüğü bölge başına 0–1 değer taşır.
- **Bölge konumu / etiketi:** `Region` enum'unda `center`, `radius`, `labelPos`.
- **Evrim hızı:** `Store.swift` içindeki `skillCap` (varsayılan 600 XP/beceri).

Plan ve XP `UserDefaults` içinde saklanır; görev tamamlama işaretleri her yeni gün sıfırlanır.

## Yol haritası

- [ ] HealthKit (uyku, adım, HRV) ile gerçek veriden beyin tepkisi
- [ ] SwiftData ile geçmiş günler, haftalık rapor ve grafikler
- [ ] Mini beyin oyunları (n-back, Stroop, reaksiyon)
- [ ] Seri (streak), bildirimler ve seviye atlama animasyonu
- [ ] Widget / Live Activity (ayrı bir extension hedefi gerekir)
- [ ] Yapay zekâ koçu
- [ ] iCloud senkronu ve Apple Watch

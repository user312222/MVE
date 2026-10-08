import SwiftUI
import AVFoundation
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

enum HapticKind { case light, medium, success }

enum Haptics {
    static func play(_ kind: HapticKind) {
        #if os(iOS)
        switch kind {
        case .light: UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .medium: UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .success: UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
        #elseif os(macOS)
        NSHapticFeedbackManager.defaultPerformer.perform(kind == .light ? .alignment : .levelChange, performanceTime: .now)
        #endif
    }
}

/// Aktivasyona göre tonu zenginleşen, kod ile üretilen ambient ses + kısa "blip" efektleri.
nonisolated final class Synth: @unchecked Sendable {
    var energy = 0.1
    private var smoothE = 0.1
    private var phases = [Double](repeating: 0, count: 5)
    private var lfoPhase = 0.0
    private var blipPhase = 0.0
    private var blipFreq = 660.0
    private var blipEnv = 0.0
    var sampleRate = 44100.0
    private let freqs = [110.0, 164.81, 220.0, 277.18, 329.63]

    func blip(_ f: Double) { blipFreq = f; blipEnv = 1 }

    func render(frames: Int, list: UnsafeMutablePointer<AudioBufferList>) {
        let buffers = UnsafeMutableAudioBufferListPointer(list)
        let twoPi = 2 * Double.pi
        for i in 0..<frames {
            smoothE += (energy - smoothE) * 0.00012
            lfoPhase += twoPi * 0.11 / sampleRate
            let lfo = sin(lfoPhase)
            var s = 0.0
            for k in 0..<freqs.count {
                let amp = k < 3 ? 1.0 : smoothE * 1.4
                phases[k] += twoPi * freqs[k] * (1 + 0.0015 * lfo) / sampleRate
                if phases[k] > twoPi { phases[k] -= twoPi }
                s += sin(phases[k]) * amp
            }
            s *= 0.03 * (0.6 + 0.9 * smoothE)
            if blipEnv > 0.0005 {
                s += sin(blipPhase) * blipEnv * 0.10
                blipPhase += twoPi * blipFreq / sampleRate
                if blipPhase > twoPi { blipPhase -= twoPi }
                blipEnv *= 0.9993
            }
            let v = Float(s)
            for b in buffers {
                b.mData?.assumingMemoryBound(to: Float.self)[i] = v
            }
        }
    }
}

@MainActor
final class AmbientAudio {
    static let shared = AmbientAudio()
    private let engine = AVAudioEngine()
    private let synth = Synth()
    private var configured = false

    var energy: Double {
        get { synth.energy }
        set { synth.energy = newValue }
    }

    func setEnabled(_ on: Bool) {
        if on {
            configureIfNeeded()
            #if os(iOS)
            try? AVAudioSession.sharedInstance().setCategory(.ambient)
            try? AVAudioSession.sharedInstance().setActive(true)
            #endif
            try? engine.start()
        } else {
            engine.pause()
        }
    }

    func blip(_ freq: Double) {
        guard engine.isRunning else { return }
        synth.blip(freq)
    }

    private func configureIfNeeded() {
        guard !configured else { return }
        configured = true
        let format = engine.outputNode.inputFormat(forBus: 0)
        synth.sampleRate = format.sampleRate
        let node = Self.makeNode(synth: synth, format: format)
        engine.attach(node)
        engine.connect(node, to: engine.mainMixerNode, format: format)
    }

    private nonisolated static func makeNode(synth: Synth, format: AVAudioFormat) -> AVAudioSourceNode {
        AVAudioSourceNode(format: format) { _, _, frameCount, list -> OSStatus in
            synth.render(frames: Int(frameCount), list: list)
            return noErr
        }
    }
}

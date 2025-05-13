//
//  SoundManager.swift
//  Solemate
//
//  Created by sashank.yalamanchili on 29.04.25.
//

import AVFoundation
import UIKit

class SoundManager {
    static let shared = SoundManager()
    private var player: AVAudioPlayer?

    init() {
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
    }

    func play(_ type: SoundType) {
        guard let url = Bundle.main.url(forResource: type.rawValue, withExtension: "wav") else {
            print("Missing sound file: \(type.rawValue).wav")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("Sound playback error: \(error)")
        }
    }
    
    func stop() {
        player?.stop()
    }
    
    func vibrate() {
        #if os(iOS)
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        #endif
    }

    enum SoundType: String {
        case start
        case warn
        case end
    }
}

extension UIDevice {
    var hasHapticFeedback: Bool {
        if #available(iOS 13.0, *) {
            return true
        }
        return false
    }
}

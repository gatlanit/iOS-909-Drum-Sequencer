//
//  DrumSequencer.swift
//  Drum Sequencer
//
//  Created by Nitin G on 2/22/25.
//


import AVFoundation

class DrumSequencer: ObservableObject {
    @Published var bpm: Double = 140
    @Published var stepIndex = 0
    @Published var sequence: [[Bool]] = Array(repeating: Array(repeating: false, count: 16), count: 14)
    @Published var isPlaying = false
    @Published var soloedDrums: Set<Int> = [] // Solo tracks
    @Published var mutedDrums: Set<Int> = [] // Mute tracks

    let drumSounds = [
        "Kick 1", "Kick 2",
        "Snare 1", "Snare 2",
        "Clap 1", "Clap 2",
        "Hi-Hat 1", "Hi-Hat 2", "Hi-Hat Open",
        "Crash", "Ride",
        "Tom Low", "Tom Mid", "Tom High"
    ]
    var audioEngine = AVAudioEngine()
    var players: [AVAudioPlayerNode] = []
    var buffers: [AVAudioPCMBuffer] = []
    var timer: Timer?

    init() {
        setupAudioEngine()
    }

    func setupAudioEngine() {
        for sound in drumSounds {
            guard let url = Bundle.main.url(forResource: sound, withExtension: "wav") else { continue }
            let file = try! AVAudioFile(forReading: url)
            let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length))!
            try! file.read(into: buffer)

            let player = AVAudioPlayerNode()
            audioEngine.attach(player)
            audioEngine.connect(player, to: audioEngine.mainMixerNode, format: buffer.format)

            players.append(player)
            buffers.append(buffer)
        }
        try! audioEngine.start()
    }

    func togglePlayback() {
        isPlaying.toggle()
        if isPlaying {
            startSequencer()
        } else {
            stopSequencer()
        }
    }

    func startSequencer() {
        stopSequencer()
        timer = Timer.scheduledTimer(withTimeInterval: (60.0 / bpm) / 4, repeats: true) { _ in
            self.playStep()
        }
    }

    func stopSequencer() {
        timer?.invalidate()
        timer = nil
        stepIndex = 0
    }

    func resetSequence() {
        sequence = Array(repeating: Array(repeating: false, count: 16), count: 14)
        stepIndex = 0
        soloedDrums.removeAll() // Reset the solo state
        mutedDrums.removeAll()  // Reset the mute state
    }

    func playStep() {
        for (index, player) in players.enumerated() {
            if sequence[index][stepIndex] && !mutedDrums.contains(index) {
                // Play only if not muted
                if soloedDrums.isEmpty || soloedDrums.contains(index) {
                    player.scheduleBuffer(buffers[index], at: nil, options: .interrupts, completionHandler: nil)
                    player.play()
                }
            }
        }
        stepIndex = (stepIndex + 1) % 16
    }

    func toggleSolo(for index: Int) {
        if soloedDrums.contains(index) {
            soloedDrums.remove(index) // If solo is active, toggle it off
        } else {
            soloedDrums.insert(index) // Otherwise, add the drum to the solo set
        }
    }

    func toggleMute(for index: Int) {
        if mutedDrums.contains(index) {
            mutedDrums.remove(index)
        } else {
            mutedDrums.insert(index)
        }
    }
}

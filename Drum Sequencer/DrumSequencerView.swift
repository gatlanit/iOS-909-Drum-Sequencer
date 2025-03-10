//
//  DrumSequencerView.swift
//  Drum Sequencer
//
//  Created by Nitin G on 2/22/25.
//


import SwiftUI

struct DrumSequencerView: View {
    @StateObject private var sequencer = DrumSequencer()

    // Highlights
    func getRowHighlightColor(for index: Int) -> Color {
        switch index {
        case 0, 1: return Color.pink.opacity(0.2) // Kicks (Hot Pink)
        case 2, 3, 4, 5: return Color.orange.opacity(0.2) // Claps & Snares (Light Orange)
        case 6, 7, 8, 9, 10: return Color.cyan.opacity(0.2) // Hats & Cymbals (Cyan)
        case 11, 12, 13: return Color.teal.opacity(0.2) // Toms (Teal)
        default: return Color.gray.opacity(0.2)
        }
    }
    
    func getStepButtonColor(for index: Int) -> Color {
        switch index {
        case 0, 1: return Color.pink.opacity(0.9) // Kicks
        case 2, 3, 4, 5: return Color.orange.opacity(0.9) // Claps & Snares
        case 6, 7, 8, 9, 10: return Color.cyan.opacity(0.9) // Hats & Cymbals
        case 11, 12, 13: return Color.teal.opacity(0.9) // Toms
        default: return Color.gray.opacity(0.9)
        }
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    ForEach(0..<14, id: \.self) { row in
                        HStack {
                            Button(action: {
                                sequencer.toggleMute(for: row)
                            }) {
                                Image(systemName: "speaker.slash")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(sequencer.mutedDrums.contains(row) ? .red : .white)
                                    .padding(5)
                                    .background(sequencer.mutedDrums.contains(row) ? Color.black.opacity(0.7) : Color.clear)
                                    .clipShape(Circle())
                                    .shadow(radius: 3)
                            }
                            .padding(.trailing, 5)

                            Button(action: {
                                sequencer.toggleSolo(for: row)
                            }) {
                                Image(systemName: "headphones")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(sequencer.soloedDrums.contains(row) ? .yellow : .white)
                                    .padding(5)
                                    .background(sequencer.soloedDrums.contains(row) ? Color.black.opacity(0.7) : Color.clear)
                                    .clipShape(Circle())
                                    .shadow(radius: 3)
                            }
                            .padding(.trailing, 5)

                            Text(sequencer.drumSounds[row])
                                .frame(width: 80, alignment: .leading)
                                .foregroundColor(.white)

                            ForEach(0..<16, id: \.self) { step in
                                Button(action: {
                                    sequencer.sequence[row][step].toggle()
                                }) {
                                    Rectangle()
                                        .frame(width: 25, height: 25)
                                        .cornerRadius(5)
                                        .foregroundColor(sequencer.sequence[row][step] ? getStepButtonColor(for: row) : (sequencer.stepIndex == step ? Color(red: 0.9, green: 0.9, blue: 0.9) : .gray))
                                        .border(Color.black)
                                        .padding(.trailing, step % 4 == 3 ? 8 : 0)
                                }
                            }
                        }
                        .padding(5)
                        .background(getRowHighlightColor(for: row)) // Apply background color to highlight row (low opacity)
                        .cornerRadius(8) // Rounded edges for better aesthetics
                    }
                }
            }

            Spacer() // Push everything above to the top

            HStack {
                // BPM Slider
                Text("BPM: \(Int(sequencer.bpm))")
                    .foregroundColor(.white)
                    .padding(.leading, 10)
                    .padding(.trailing, 10)

                Slider(value: $sequencer.bpm, in: 80...200, step: 1)
                    .padding(.trailing, 10)

                // Play/Pause Button
                Button(action: {
                    sequencer.togglePlayback()
                }) {
                    Image(systemName: sequencer.isPlaying ? "pause.fill" : "play.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.black)
                        .padding(10)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 3)
                }.padding(.trailing, 270)

                // Reset Button
                Button(action: {
                    sequencer.resetSequence()
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.black)
                        .padding(10)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 3)
                }.padding(.trailing, 10)
            }
            .padding(.bottom, 20) // Add bottom padding to avoid touching the screen edge
            .background(Color.black.opacity(0.7))
        }
        .preferredColorScheme(.dark) // Enforce Dark Mode
    }
}

#Preview {
    DrumSequencerView()
}

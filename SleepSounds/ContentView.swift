//
//  ContentView.swift
//  SleepSounds
//
//  Created by Mehmet Jiyan Atalay on 9.12.2024.
//

import SwiftUI
import AVKit

struct ContentView: View {
    
    @StateObject var viewModel = ContenViewModel()
    
    @State private var selectedElement: SleepModel? = nil
    @State private var player: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var totalTime: TimeInterval = 0.0 //
    @State private var currentTime: TimeInterval = 0.0 //
    
    @State private var timer: Timer? = nil
    @State private var timeRemaining: TimeInterval = 0
    @Environment(\.dismiss) private var dismiss
    
    @State private var showSheet = false
    @State private var selectedHour = 2
    @State private var selectedMinute = 30
    @State private var remainingTimeString = "00:00:00"
    
    var body: some View {
        NavigationStack {
            ZStack {
                if let selectedElement {
                    Image(selectedElement.image)
                        .resizable()
                        .ignoresSafeArea()
                        .zIndex(0)
                        .blur(radius: 55)
                }
                GeometryReader { geometry in
                    VStack {
                        GroupBox {
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(viewModel.elements) { element in
                                        VStack {
                                            Image(element.image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 60, height: 60)
                                                .clipShape(Circle())
                                                .clipped()
                                        }
                                        .onTapGesture {
                                            if selectedElement != element {
                                                if isPlaying == true {
                                                    player?.stop()
                                                    isPlaying = false
                                                }
                                                self.selectedElement = element
                                                setupAudio(withURL: element.sound)
                                                player?.play()
                                                isPlaying = true
                                            }
                                        }
                                    }
                                }
                            }
                        }.groupBoxStyle(CustomGroupBoxStyle())
                        
                        Spacer()
                        
                        if let selectedElement {
                            VStack {
                                GeometryReader { geometry in
                                    Image(selectedElement.image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: geometry.size.width, height: geometry.size.height)
                                        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                                        .padding()
                                }
                                .frame(height: 375)
                                .padding(.vertical, geometry.size.height < 700 ? 10 : 30)
                                .padding(.trailing, 30)
                                
                                GroupBox {
                                    HStack {
                                        Button {
                                            showSheet = true
                                        } label: {
                                            if remainingTimeString == "00:00:00" {
                                                Image(systemName: "stopwatch")
                                                    .resizable()
                                                    .frame(width: 30, height: 30)
                                                    .foregroundStyle(.red)
                                                    .padding(.horizontal)
                                            } else {
                                                Text(remainingTimeString)
                                                    .bold()
                                                    .foregroundStyle(.red)
                                            }
                                        }
                                        
                                        Button {
                                            if isPlaying {
                                                togglePlayPause()
                                            } else {
                                                togglePlayPause()
                                            }
                                        } label: {
                                            Image(systemName: isPlaying ? "pause.circle" : "play.circle")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                                .foregroundStyle(.red)
                                                .padding(.horizontal)
                                        }
                                    }.frame(height: 20)
                                    .frame(maxWidth: .infinity)
                                }.groupBoxStyle(CustomGroupBoxStyle()).padding(.vertical)
                                    .padding(.top, 50).padding(.bottom, 50)
                            }.transition(.slide)
                        }
                        Spacer()
                    }
                }.zIndex(1)
            }
        }
        .onAppear {
            self.selectedElement = viewModel.elements.first
            setupAudio(withURL: selectedElement!.sound)
        }
        .sheet(isPresented: $showSheet) {
            VStack {
                Text("How long do you want sound to play for?")
                HStack {
                    VStack {
                        Picker("Select Hour", selection: $selectedHour) {
                            ForEach(0..<24) { hour in
                                Text("\(hour)")
                            }
                        }
                        .pickerStyle(.inline)
                        .padding()
                        
                        Text("Hour")
                    }
                    
                    VStack {
                        Picker("Select Minute", selection: $selectedMinute) {
                            ForEach(Array(stride(from: 0, through: 59, by: 1)), id: \.self) { minute in
                                Text("\(minute)")
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .padding()
                        
                        Text("Minute")
                    }
                }
                if remainingTimeString == "00:00:00" {
                    Button {
                        startTimer()
                        showSheet = false
                        if !isPlaying {
                            player?.play()
                            isPlaying = true
                        }
                    } label: {
                        Text("Set Timer")
                    }
                    .buttonStyle(.bordered)
                    .background(.red)
                    .foregroundStyle(.black)
                } else {
                    Button {
                        stopTimer()
                        remainingTimeString = "00:00:00"
                    } label: {
                        Text("Stop Timer")
                    }
                    .buttonStyle(.bordered)
                    .background(.red)
                    .foregroundStyle(.black)

                }

            }.presentationDetents([.fraction(0.5)])
        }
    }
    
    private func setupAudio(withURL url: URL) {
        do {
            //print("Dosya URL'si: \(url)")
            //print("Dosya mevcut mu: \(FileManager.default.fileExists(atPath: url.path))")
            
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: .mixWithOthers)
            try session.setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.numberOfLoops = -1
            totalTime = player?.duration ?? 0.0
        } catch {
            print("Ses yükleme hatası: \(error)")
            print("Hata kodu: \(error._code)")
        }
    }
    
    private func startTimer() {
        let totalSeconds: TimeInterval = (Double(selectedHour) * 3600) + (Double(selectedMinute) * 60)
        
        timeRemaining = totalSeconds
        
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            
            if timeRemaining > 0 {
                timeRemaining -= 1
                
                
                let hours = Int(timeRemaining) / 3600
                let minutes = (Int(timeRemaining) % 3600) / 60
                let seconds = Int(timeRemaining) % 60
                
                remainingTimeString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
                
            } else {
                player?.stop()
                isPlaying = false
                UIApplication.shared.isIdleTimerDisabled = false
                timer?.invalidate()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        
        timeRemaining = 0
        
        player?.stop()
        isPlaying = false
        
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    private func togglePlayPause() {
        if isPlaying {
            isPlaying = false
            player?.stop()
            
            UIApplication.shared.isIdleTimerDisabled = false
        } else {
            isPlaying = true
            player?.play()
            
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
}

#Preview {
    ContentView()
}

struct CustomGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
            configuration.content
                .padding()
                .background(Color.primary.opacity(0.2))
                .cornerRadius(10)
                .shadow(radius: 5)
        }
    }
}

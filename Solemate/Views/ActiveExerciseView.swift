//
//  ActiveExerciseView.swift
//  Solemate
//
//  Created by sashank.yalamanchili on 12.05.25.
//

import SwiftUI

struct ActiveExerciseView: View {
    let routine: Routine
    let index: Int
    let time: Int
    let rep: Int
    let side: String
    let nextPrep: (Routine, Int, PrepContext) -> Void
    let nextComplete: () -> Void
    let reset: () -> Void
    
    @State private var timeRemaining: Int
    @State private var timerRunning = true
    @State private var showRestart = false
    @State private var currentRep: Int
    @State private var currentSide: String
    @State private var timer: Timer?
    
    init(routine: Routine, index: Int, time: Int, rep: Int = 1, side: String = "Right",
         nextPrep: @escaping (Routine, Int, PrepContext) -> Void,
         nextComplete: @escaping () -> Void,
         reset: @escaping () -> Void) {
        self.routine = routine
        self.index = index
        self.time = time
        self.rep = rep
        self.side = side
        self.nextPrep = nextPrep
        self.nextComplete = nextComplete
        self.reset = reset
        _timeRemaining = State(initialValue: time)
        _currentRep = State(initialValue: rep)
        _currentSide = State(initialValue: side)
    }
    
    var formattedTime: String {
        switch routine.timeUnit {
        case .seconds:
            return String(format: "00:%02d", timeRemaining)
        case .minutes:
            return String(format: "%02d:00", timeRemaining)
        }
    }
    
    var body: some View {
        let item = routine.exercises[index]
        
        VStack(spacing: 32) {
            VStack(spacing: 4) {
                Text(item.label)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                if item.alternateSide {
                    Text("\(currentSide) Side")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    Text("Both sides together")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let reps = item.reps {
                    Text("Rep \(currentRep) of \(reps)")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
            .padding(.top, 40)
            
            Text(formattedTime)
                .font(.system(size: 88, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)
            
            Image("\(item.id)_loop")
                .resizable()
                .scaledToFit()
                .frame(height: 250)
            
            HStack(spacing: 40) {
                Button {
                    timerRunning.toggle()
                    showRestart = !timerRunning
                } label: {
                    Image(systemName: timerRunning ? "pause.fill" : "play.fill")
                        .font(.title)
                        .frame(width: 88, height: 88)
                        .background(Circle().stroke(Color.gray, lineWidth: 1))
                        .foregroundColor(.gray)
                        .clipShape(Circle())
                }
                
                Button {
                    if showRestart {
                        timeRemaining = time
                        timerRunning = true
                        showRestart = false
                    } else {
                        timer?.invalidate()
                        timer = nil
                        reset()
                    }
                } label: {
                    Image(systemName: showRestart ? "arrow.counterclockwise" : "stop.fill")
                        .font(.title)
                        .frame(width: 88, height: 88)
                        .background(Circle().stroke(Color.gray, lineWidth: 1))
                        .foregroundColor(.gray)
                        .clipShape(Circle())
                }
            }
            
            Spacer()
        }
        .padding()
        .onAppear(perform: startTimer)
    }
    
    func startTimer() {
        UIApplication.shared.isIdleTimerDisabled = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            if timerRunning && timeRemaining > 0 {
                if timeRemaining <= 5 && timeRemaining > 1 {
                    SoundManager.shared.play(.warn)
                } else if timeRemaining == 1 {
                    SoundManager.shared.play(.end)
                    SoundManager.shared.vibrate()
                }
                timeRemaining -= 1
            } else if timeRemaining == 0 {
                UIApplication.shared.isIdleTimerDisabled = false
                t.invalidate()
                timer = nil
                
                let item = routine.exercises[index]
                let reps = item.reps ?? 1
                
                if currentRep < reps {
                    nextPrep(routine, index, .rest(currentRep: currentRep + 1, currentSide: currentSide))
                    return
                }
                
                if item.alternateSide && currentSide == "Right" {
                    nextPrep(routine, index, .rest(currentRep: 1, currentSide: "Left"))
                    return
                }
                
                if index + 1 < routine.exercises.count {
                    nextPrep(routine, index + 1, .next)
                } else {
                    HealthKitService.shared.logWorkout(
                        routine: routine,
                        duration: TimeInterval(routine.totalDurationSeconds())
                    ) { _ in }
                    nextComplete()
                }
            }
        }
        SoundManager.shared.play(.start)
    }
}

#Preview {
    ActiveExerciseView(
        routine: Routine.routine,
        index: 0,
        time: 5,
        rep: 1,
        side: "Right",
        nextPrep: { _, _, _ in },
        nextComplete: {},
        reset: {}
    )
}

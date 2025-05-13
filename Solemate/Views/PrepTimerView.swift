//
//  PrepTimerView.swift
//  Solemate
//
//  Created by sashank.yalamanchili on 12.05.25.
//

import SwiftUI

enum PrepContext: Hashable {
    case start
    case rest(currentRep: Int, currentSide: String)
    case next
}

struct PrepTimerView: View {
    let routine: Routine
    let index: Int
    let context: PrepContext
    let next: (Routine, Int, Exercise) -> Void
    let reset: () -> Void
    
    @State private var timeRemaining: Int
    @State private var timerRunning = true
    @State private var timer: Timer?
    
    init(routine: Routine, index: Int, context: PrepContext,
         next: @escaping (Routine, Int, Exercise) -> Void,
         reset: @escaping () -> Void) {
        self.routine = routine
        self.index = index
        self.context = context
        self.next = next
        self.reset = reset
        _timeRemaining = State(initialValue: Self.duration(for: context, in: routine))
    }
    
    static func duration(for context: PrepContext, in routine: Routine) -> Int {
        switch context {
        case .start:
            return routine.prepTime
        case .rest, .next:
            return routine.restTime
        }
    }
    
    var currentRep: Int {
        if case .rest(let rep, _) = context {
            return rep
        }
        return 1
    }
    
    var currentSide: String {
        if case .rest(_, let side) = context {
            return side
        }
        return "Right"
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
                Text("Coming up")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(item.label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if item.alternateSide {
                    Text("\(currentSide) Side - Rep \(currentRep)")
                        .font(.footnote)
                        .foregroundColor(.gray)
                } else {
                    Text("Rep \(currentRep) - Both sides together")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                
            }
            .padding(.top, 40)
            
            Text(formattedTime)
                .font(.system(size: 88, weight: .bold, design: .monospaced))
                .foregroundColor(.yellow)
            
            Image("\(item.id)_prep")
                .resizable()
                .scaledToFit()
                .frame(height: 250)
            
            HStack(spacing: 40) {
                Button {
                    timerRunning.toggle()
                } label: {
                    Image(systemName: timerRunning ? "pause.fill" : "play.fill")
                        .font(.title)
                        .frame(width: 88, height: 88)
                        .background(Circle().stroke(Color.gray, lineWidth: 1))
                        .foregroundColor(.gray)
                        .clipShape(Circle())
                }
                
                Button {
                    timer?.invalidate()
                    timer = nil
                    reset()
                } label: {
                    Image(systemName: "stop.fill")
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
                next(routine, index, routine.exercises[index])
            }
        }
        SoundManager.shared.play(.start)
    }
}

#Preview {
    PrepTimerView(
        routine: Routine.routine,
        index: 0,
        context: .start,
        next: { _, _, _ in },
        reset: {}
    )
}

//
//  Root.swift
//  Solemate
//
//  Created by sashank.yalamanchili on 13.05.25.
//


import SwiftUI

enum AppScreen {
    case home
    case prep(routine: Routine, index: Int, context: PrepContext)
    case active(routine: Routine, index: Int, time: Int, rep: Int, side: String)
    case complete
}

final class AppState: ObservableObject {
    @Published var screen: AppScreen = .home

    func reset() {
        screen = .home
    }

    func goToPrep(routine: Routine, index: Int, context: PrepContext) {
        screen = .prep(routine: routine, index: index, context: context)
    }

    func goToActive(routine: Routine, index: Int, time: Int, rep: Int = 1, side: String = "Right") {
        screen = .active(routine: routine, index: index, time: time, rep: rep, side: side)
    }

    func complete() {
        screen = .complete
    }
}

struct Root: View {
    @StateObject private var appState = AppState()

    var body: some View {
        NavigationStack {
            switch appState.screen {
            case .home:
                HomeView(start: { routine in
                    appState.goToPrep(routine: routine, index: 0, context: .start)
                })
            case .prep(let routine, let index, let context):
                PrepTimerView(
                    routine: routine,
                    index: index,
                    context: context,
                    next: { r, i, exercise in
                        let rep: Int
                        let side: String
                        switch context {
                        case .rest(let currentRep, let currentSide):
                            rep = currentRep
                            side = currentSide
                        default:
                            rep = 1
                            side = "Right"
                        }
                        appState.goToActive(routine: r, index: i, time: exercise.hold, rep: rep, side: side)
                    },
                    reset: { appState.reset() }
                )
            case .active(let routine, let index, let time, let rep, let side):
                ActiveExerciseView(
                    routine: routine,
                    index: index,
                    time: time,
                    rep: rep,
                    side: side,
                    nextPrep: { r, i, c in appState.goToPrep(routine: r, index: i, context: c) },
                    nextComplete: { appState.complete() },
                    reset: { appState.reset() }
                )
            case .complete:
                FinishView(reset: { appState.reset() })
            }
        }
        .onAppear {
            HealthKitService.shared.requestPermission()
        }
    }
}

#Preview {
    Root()
}

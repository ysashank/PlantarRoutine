//
//  InstructionDetailView.swift
//  PlantarRoutine
//
//  Created by sashank.yalamanchili on 30.04.25.
//

import SwiftUI

struct InstructionDetailView: View {
    let title: String
    let steps: [String]

    var body: some View {
        NavigationView {
            List(steps.indices, id: \.self) { i in
                Text("\(i + 1). \(steps[i])")
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

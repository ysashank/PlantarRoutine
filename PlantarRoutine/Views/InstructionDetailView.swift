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
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(steps.indices, id: \.self) { i in
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(i + 1).")
                            .foregroundColor(.secondary)
                        Text(steps[i])
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal)

                    if i < steps.count - 1 {
                        Divider()
                            .padding(.leading)
                    }
                }
            }
            .padding(.top)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    InstructionDetailView(title: "Preview", steps: ["String", "String", "String"])
}

//
//  ExerciseDescriptionView.swift
//  Solemate
//
//  Created by sashank.yalamanchili on 12.05.25.
//

import SwiftUI

struct ExerciseDescriptionView: View {
    let item: Exercise

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.label)
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(item.alternateSide ? "Alternate sides" : "Both sides together")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)

            Text("Instructions:")
                .font(.headline)

            VStack(alignment: .leading, spacing: 12) {
                ForEach(item.instructions.indices, id: \.self) { i in
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(i + 1).")
                            .font(.body)
                            .frame(width: 24, alignment: .leading)

                        Text(item.instructions[i])
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 16)
                }
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    ExerciseDescriptionView(item: Exercise(
        id: "heel_raises",
        label: "Heel Raises",
        sets: 3,
        reps: 10,
        hold: 0,
        alternateSide: true,
        instructions: [
            "Stand tall near a wall or chair for balance.",
            "Slowly lift your heels, rising onto your toes.",
            "Pause briefly at the top.",
            "Lower your heels slowly back down.",
            "Repeat for the recommended reps."
        ]
    ))
}

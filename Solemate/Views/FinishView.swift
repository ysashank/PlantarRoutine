//
//  CompleteScreen.swift
//  Solemate
//
//  Created by sashank.yalamanchili on 12.05.25.
//


import SwiftUI

struct FinishView: View {
    let reset: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 8) {
                Button(action: {
                    reset()
                }) {
                    Text("Done")
                        .frame(maxWidth: .infinity)
                        .padding(40)
                        .foregroundColor(.accentColor)
                        .background(Circle().stroke(Color.accentColor, lineWidth: 1))
                }
                .padding(.horizontal)
                .buttonStyle(PlainButtonStyle())
                .shadow(radius: 1)

                Text("You did good. Same time tomorrow.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top)
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    FinishView(reset: {})
}

//
//  SessionCompleteView.swift
//  Breathsy
//
//  Created by sashank.yalamanchili on 03.05.25.
//


import SwiftUI

struct SessionCompleteView: View {
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Session Complete")
                .font(.largeTitle)
                .foregroundColor(.primary)
            
            Button(action: {
                onDismiss()
            }) {
                Text("Done")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primary.opacity(0.1))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SessionCompleteView(onDismiss: {})
}

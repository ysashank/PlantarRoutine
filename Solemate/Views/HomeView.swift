//
//  HomeView.swift
//  Solemate
//
//  Created by sashank.yalamanchili on 12.05.25.
//


import SwiftUI

struct HomeView: View {
    let start: (Routine) -> Void
    
    var body: some View {
        let routine = Routine.routine
        
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 4) {
                Text(routine.name)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                
                Text(routine.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
            
            Text("The Routine:")
                .font(.headline)
            
            ForEach(routine.exercises.indices, id: \.self) { i in
                let item = routine.exercises[i]
                HStack {
                    Text("\(i + 1). \(item.label)")
                        .font(.body)
                    Spacer()
                    NavigationLink(destination: ExerciseDescriptionView(item: item)) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 16)
            }
            
            Text("Total Duration: 00:18")
                .font(.footnote)
                .foregroundColor(.gray)
                .monospacedDigit()
            
            Spacer()
            
            Button(action: {
                start(routine)
            }) {
                Text("Start")
                    .frame(maxWidth: .infinity)
                    .padding(40)
                    .foregroundColor(.accentColor)
                    .background(Circle().stroke(Color.accentColor, lineWidth: 1))
                    .padding(.bottom, 40)
            }
            .buttonStyle(PlainButtonStyle())
            .shadow(radius: 4)
        }
        .padding(.horizontal)
    }
}

#Preview {
    HomeView(start: { _ in })
}

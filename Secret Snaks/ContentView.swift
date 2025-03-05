//
//  ContentView.swift
//  Secret Snaks
//
//  Created by Sergei A. on 4/3/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                Text("Как вы хотите отслеживать калории?")
                    .font(.system(size: 24, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                VStack(spacing: 20) {
                    CalorieTrackingButton(title: "Отслеживать по количеству калорий") {
                        // Действие для первой кнопки
                        print("Выбрано отслеживание по количеству калорий")
                    }
                    
                    CalorieTrackingButton(title: "Отслеживать по весу") {
                        // Действие для второй кнопки
                        print("Выбрано отслеживание по весу")
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
    }
}

struct CalorieTrackingButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.8))
                        .shadow(color: Color.orange.opacity(0.3), radius: 5, x: 0, y: 3)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ContentView()
}

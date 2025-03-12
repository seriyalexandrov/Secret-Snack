//
//  ContentView.swift
//  Secret Snaks
//
//  Created by Sergei A. on 4/3/25.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                Text("How would you like to track calories?")
                    .font(.system(size: 24, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                VStack(spacing: 20) {
                    CalorieTrackingButton(title: "Track by calorie count") {
                        // Запрос разрешения на доступ к HealthKit
                        if HKHealthStore.isHealthDataAvailable() {
                            let healthStore = HKHealthStore()
                            
                            // Типы данных, к которым мы хотим получить доступ
                            let typesToShare: Set = [
                                HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
                            ]
                            
                            let typesToRead: Set = [
                                HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
                            ]
                            
                            // Запрос авторизации
                            healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
                                if success {
                                    print("HealthKit access permission granted")
                                } else {
                                    print("Error requesting permission: \(String(describing: error))")
                                }
                            }
                        } else {
                            print("HealthKit is not available on this device")
                        }
                    }
                    
                    CalorieTrackingButton(title: "Track by weight") {
                        // Действие для второй кнопки
                        print("Weight tracking selected")
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

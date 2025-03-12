//
//  ContentView.swift
//  Secret Snaks
//
//  Created by Sergei A. on 4/3/25.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @State private var showingCalorieInput = false
    @State private var showingWeightInput = false
    
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
                        // Показываем экран ввода калорий
                        showingCalorieInput = true
                    }
                    
                    CalorieTrackingButton(title: "Track by weight") {
                        // Показываем экран ввода веса
                        showingWeightInput = true
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            
            // Экран ввода калорий
            if showingCalorieInput {
                CalorieInputView(isPresented: $showingCalorieInput)
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut, value: showingCalorieInput)
            }
            
            // Экран ввода веса
            if showingWeightInput {
                WeightInputView(isPresented: $showingWeightInput)
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut, value: showingWeightInput)
            }
        }
    }
}

struct CalorieInputView: View {
    @Binding var isPresented: Bool
    @State private var calorieInput: String = ""
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        ZStack {
            // Затемненный фон
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            // Карточка ввода
            VStack(spacing: 20) {
                Text("Enter Calories")
                    .font(.system(size: 24, weight: .bold))
                    .padding(.top, 20)
                
                TextField("Calories", text: $calorieInput)
                    .keyboardType(.numberPad)
                    .font(.system(size: 18))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(UIColor.secondarySystemBackground))
                    )
                    .padding(.horizontal, 20)
                    .focused($isInputFocused)
                
                Button(action: {
                    if let calories = Int(calorieInput) {
                        print("Added calories: \(calories)")
                        isPresented = false
                        calorieInput = ""
                    }
                }) {
                    Text("Add")
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
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .disabled(calorieInput.isEmpty)
                .opacity(calorieInput.isEmpty ? 0.6 : 1)
            }
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(UIColor.systemBackground))
            )
            .padding(.horizontal, 20)
            .onAppear {
                isInputFocused = true
            }
        }
    }
}

struct WeightInputView: View {
    @Binding var isPresented: Bool
    @State private var weightInput: String = ""
    @State private var caloriesPerHundredGrams: String = ""
    @FocusState private var isWeightFocused: Bool
    @FocusState private var isCaloriesFocused: Bool
    
    var body: some View {
        ZStack {
            // Затемненный фон
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            // Карточка ввода
            VStack(spacing: 20) {
                Text("Calculate Calories by Weight")
                    .font(.system(size: 24, weight: .bold))
                    .padding(.top, 20)
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Weight (g)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                    
                    TextField("Enter weight", text: $weightInput)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 18))
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(UIColor.secondarySystemBackground))
                        )
                        .padding(.horizontal, 20)
                        .focused($isWeightFocused)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Calories per 100g")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                    
                    TextField("Enter calories", text: $caloriesPerHundredGrams)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 18))
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(UIColor.secondarySystemBackground))
                        )
                        .padding(.horizontal, 20)
                        .focused($isCaloriesFocused)
                }
                
                Button(action: {
                    if let weight = Double(weightInput), let caloriesPer100g = Double(caloriesPerHundredGrams) {
                        let totalCalories = weight * caloriesPer100g / 100
                        print("Total calories: \(totalCalories)")
                        isPresented = false
                        weightInput = ""
                        caloriesPerHundredGrams = ""
                    }
                }) {
                    Text("Add")
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
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .disabled(weightInput.isEmpty || caloriesPerHundredGrams.isEmpty)
                .opacity((weightInput.isEmpty || caloriesPerHundredGrams.isEmpty) ? 0.6 : 1)
            }
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(UIColor.systemBackground))
            )
            .padding(.horizontal, 20)
            .onAppear {
                isWeightFocused = true
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

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
    @State private var showingDailyCalories = false
    
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
                        
                        if HKHealthStore.isHealthDataAvailable() {
                             let healthStore = HKHealthStore()
                             
                             // Types of data we want to access
                             let typesToShare: Set = [
                                 HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
                             ]
                             
                             let typesToRead: Set = [
                                 HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
                             ]
                             
                             // Authorization request
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
                        
                        showingCalorieInput = true
                    }
                    
                    CalorieTrackingButton(title: "Track by weight") {
                        
                        if HKHealthStore.isHealthDataAvailable() {
                             let healthStore = HKHealthStore()
                             
                             // Types of data we want to access
                             let typesToShare: Set = [
                                 HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
                             ]
                             
                             let typesToRead: Set = [
                                 HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
                             ]
                             
                             // Authorization request
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
                        
                        showingWeightInput = true
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            
            // Экран ввода калорий
            if showingCalorieInput {
                CalorieInputView(isPresented: $showingCalorieInput, showDailyCalories: $showingDailyCalories)
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut, value: showingCalorieInput)
            }
            
            // Экран ввода веса
            if showingWeightInput {
                WeightInputView(isPresented: $showingWeightInput, showDailyCalories: $showingDailyCalories)
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut, value: showingWeightInput)
            }
            
            // Экран с дневным потреблением калорий
            if showingDailyCalories {
                DailyCaloriesView(isPresented: $showingDailyCalories)
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut, value: showingDailyCalories)
            }
        }
    }
}

struct CalorieInputView: View {
    @Binding var isPresented: Bool
    @Binding var showDailyCalories: Bool
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
                        // Запись потребленных калорий в Apple Health
                        let healthStore = HKHealthStore()
                        let energyType = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
                        let calories = HKQuantity(unit: .kilocalorie(), doubleValue: Double(calories))
                        let sample = HKQuantitySample(type: energyType, quantity: calories, start: Date(), end: Date())
                        
                        healthStore.save(sample) { (success, error) in
                            if let error = error {
                                print("Error saving calories: \(error.localizedDescription)")
                            } else {
                                print("Calories successfully saved to Apple Health")
                                DispatchQueue.main.async {
                                    isPresented = false
                                    calorieInput = ""
                                    showDailyCalories = true
                                }
                            }
                        }
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
    @Binding var showDailyCalories: Bool
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
                        
                        // Запись потребленных калорий в Apple Health
                        let healthStore = HKHealthStore()
                        let energyType = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
                        let calories = HKQuantity(unit: .kilocalorie(), doubleValue: totalCalories)
                        let sample = HKQuantitySample(type: energyType, quantity: calories, start: Date(), end: Date())
                        
                        healthStore.save(sample) { (success, error) in
                            if let error = error {
                                print("Error saving calories: \(error.localizedDescription)")
                            } else {
                                print("Calories successfully saved to Apple Health")
                                DispatchQueue.main.async {
                                    isPresented = false
                                    weightInput = ""
                                    caloriesPerHundredGrams = ""
                                    showDailyCalories = true
                                }
                            }
                        }
                        
                        print("Total calories: \(totalCalories)")
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

struct DailyCaloriesView: View {
    @Binding var isPresented: Bool
    @State private var totalCalories: Double = 0
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    
    var body: some View {
        ZStack {
            // Затемненный фон
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            // Карточка с информацией
            VStack(spacing: 20) {
                Text("Calories consumed today:")
                    .font(.system(size: 24, weight: .bold))
                    .padding(.top, 20)
                    .multilineTextAlignment(.center)
                
                if isLoading {
                    ProgressView()
                        .padding()
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    Text("\(Int(totalCalories))")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.orange)
                    
                    Text("kcal")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                }
                
                // Кнопка "Add more"
                Button(action: {
                    // Просто возвращаемся на основной экран
                    isPresented = false
                }) {
                    Text("Add more")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green.opacity(0.8))
                                .shadow(color: Color.green.opacity(0.3), radius: 5, x: 0, y: 3)
                        )
                }
                .padding(.horizontal, 20)
                
                Button(action: {
                    // Сначала возвращаемся на главный экран
                    isPresented = false
                    
                    // Затем с небольшой задержкой закрываем приложение
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                    }
                }) {
                    Text("Close")
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
            }
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(UIColor.systemBackground))
            )
            .padding(.horizontal, 20)
            .onAppear {
                fetchTodayCalories()
            }
        }
    }
    
    func fetchTodayCalories() {
        isLoading = true
        errorMessage = nil
        
        guard HKHealthStore.isHealthDataAvailable() else {
            isLoading = false
            errorMessage = "HealthKit is not available on this device"
            return
        }
        
        let healthStore = HKHealthStore()
        
        // Проверяем разрешения
        let energyType = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
        let typesToRead: Set = [energyType]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if !success {
                DispatchQueue.main.async {
                    isLoading = false
                    errorMessage = "No access to HealthKit data"
                }
                return
            }
            
            // Создаем предикат для сегодняшнего дня
            let now = Date()
            let startOfDay = Calendar.current.startOfDay(for: now)
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
            
            // Создаем запрос для суммирования калорий
            let query = HKStatisticsQuery(
                quantityType: energyType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                DispatchQueue.main.async {
                    isLoading = false
                    
                    if let error = error {
                        errorMessage = "Error retrieving data: \(error.localizedDescription)"
                        return
                    }
                    
                    guard let result = result, let sum = result.sumQuantity() else {
                        totalCalories = 0
                        return
                    }
                    
                    totalCalories = sum.doubleValue(for: .kilocalorie())
                }
            }
            
            healthStore.execute(query)
        }
    }
}

#Preview {
    ContentView()
}

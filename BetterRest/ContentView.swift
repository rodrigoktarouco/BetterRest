//
//  ContentView.swift
//  BetterRest
//
//  Created by Rodrigo Tarouco on 12/04/22.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
        var calculatedBedtime: String {
            let model = SleepCalculator()

            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            var bedTime = "Please set all input values"

            do {
                let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
                let sleepTime = wakeUp - prediction.actualSleep

                let formatter = DateFormatter()
                formatter.timeStyle = .short
                bedTime = formatter.string(from: sleepTime)
            } catch {
                alertTitle = "Error"
                alertMessage = "Sorry, there was a problem calculating your bedtime."
                showingAlert = true
            }

            return bedTime
        }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                } header: {
                    Text("When do you want to wake up?").font(.headline)
                }
                Section {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                } header: {
                    Text("Desired amount of sleep").font(.headline)
                }
                Section {
                    Picker("", selection: $coffeeAmount) {
                        ForEach(1...20, id: \.self) {
                            Text("\($0)")
                        }
                        .labelsHidden()
                        .pickerStyle(.automatic)
                    }
                } header: {
                    Text("Daily coffee intake").font(.headline)
                }
                Section(header: Text("Amount of bed time")) {
                    Text("\(calculatedBedtime)")
                        .font(.largeTitle)
                }
            }
            .navigationTitle("BatterRest")
               
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

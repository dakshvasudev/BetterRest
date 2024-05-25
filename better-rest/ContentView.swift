//
//  ContentView.swift
//  better-rest
//
//  Created by daksh vasudev on 25/05/24.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State private var coffeeAmount = 1
    @State private var sleepAmount = 8.0
    @State private var wakeUp = defaultWakeTime
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date{
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    
    func calculateBedtime(){
        do{
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour,.minute], from: wakeUp)
            let hour = (components.hour ?? 0)*60*60
            let minute = (components.minute ?? 0)*60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bedtime is: "
            alertMessage = sleepTime.formatted(date: .omitted, time:  .shortened)
        }catch{
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bed time"
        }
        
        showingAlert = true
    }
    
    var body: some View {
        NavigationStack{
            ZStack(){
                Form{
                    VStack(alignment: .leading){
                        Text("When do you want to wake up?").font(.headline)
                        DatePicker("Please input the time you wanna wake up", selection: $wakeUp, displayedComponents: .hourAndMinute).labelsHidden()
                    }
                    VStack(alignment: .leading){
                        Text("Desired amount of sleep").font(.headline)
                        Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount,in: 4...12,step: 0.25)
                    }
                    
                    VStack(alignment: .leading){
                        Text("Daily coffee intake").font(.headline)
                        Stepper("^[\(coffeeAmount) cup](inflect: true)", value: $coffeeAmount,in: 0...20, step: 1)
                    }
                }
                
                VStack {
                    Spacer()
                    
                    Button(action: calculateBedtime) {
                        Text("Calculate")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                }
            }
            .navigationTitle("BetterRest")
            .alert(alertTitle, isPresented: $showingAlert){
                Button("OK"){}
            }message: {
                Text(alertMessage)
            }
        }
    }
}

#Preview {
    ContentView()
}

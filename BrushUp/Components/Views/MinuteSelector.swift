//
//  MinuteSelector.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 2/27/26.
//
import SwiftUI
import SwiftData
struct MinuteSelector: View {
    @Binding var selectedNumber: Int
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Text("Time")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                
                Spacer()
                
                HStack(spacing: 0) {
                    // Scrollable number
                    Picker("Number", selection: $selectedNumber) {
                        ForEach(AppConstants.minutesList, id: \.self) { number in
                            Text("\(number) minutes")
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                                .foregroundStyle(.white)
                                .tag(number)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 120, height: 60)
                    .clipped()
                    
                    VStack {
                        // Up arrow
                        Button(action: {
                            if let index = AppConstants.minutesList.firstIndex(of: selectedNumber), index > 0 {
                                selectedNumber = AppConstants.minutesList[index - 1]
                            }
                        }) {
                            Image(systemName: "chevron.up")
                                .font(.system(size: 16))
                                .foregroundStyle(selectedNumber == AppConstants.minutesList.first ? .gray: .white)
                                .frame(width: 6, height: 6)
                        }
                        .buttonStyle(.plain)
                        
                        // Down arrow
                        Button(action: {
                            if let index = AppConstants.minutesList.firstIndex(of: selectedNumber), index < AppConstants.minutesList.count - 1 {
                                selectedNumber = AppConstants.minutesList[index + 1]
                            }
                        }) {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 16))
                                .foregroundStyle(selectedNumber == AppConstants.minutesList.last ? .gray: .white)
                                .frame(width: 6, height: 6)
                        }
                        .buttonStyle(.plain)
                        
                    }.padding()
                    
                }
                .onChange(of: selectedNumber) { _, newValue in
                    UserDefaults.standard.set(newValue, forKey: "minutes")
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal, 2)
    }
}

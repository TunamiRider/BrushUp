//
//  GoalEditSheet.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 3/4/26.
//
import SwiftUI
struct GoalEditSheet: View {
    @Binding var countDrawings: Int
    @Binding var frequency: Frequency
    @Binding var showingGoalSheet: Bool
    
    private var index: Int {
        Frequency.allCases.firstIndex(of: frequency) ?? 0
    }

    var body: some View {
        ZStack{
            Color(AppConstants.spaceblack.opacity(0.8)).ignoresSafeArea()
            
            Form {
                Section {
                    HStack {
                        Button(action: { showingGoalSheet.toggle() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                                .foregroundStyle(.gray)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                        
                        Text("Edit Goal")
                            .font(.title2)
                            .foregroundStyle(.white)
                        
                        Spacer()
                    }
                    .listRowInsets(EdgeInsets())  // Full width
                }
                .listRowBackground(Color.gray.opacity(0))
                .listRowSeparator(.hidden)
                
                Section {
                    HStack {
                        Text("Drawings")
                        Spacer()
                        Text("\(Int(countDrawings))")
                            .font(.headline)
                        VStack(spacing: 0) {
                            // Up arrow (top)
                            Button(action: {
                                countDrawings = min(10, countDrawings + 1)
                            }) {
                                Image(systemName: "chevron.up")
                                    .clipShape(Circle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Down arrow (bottom)
                            Button(action: {
                                countDrawings = max(1, countDrawings - 1)
                            }) {
                                Image(systemName: "chevron.down")
                                    .clipShape(Circle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    HStack {
                        Text("Frequency")

                        Spacer()

                        Text(frequency.rawValue)
                            .font(.headline)

                        VStack(spacing: 0) {
                            // Up arrow
                            Button {
                                let nextIndex = min(index + 1, Frequency.allCases.count - 1)
                                frequency = Frequency.allCases[nextIndex]
                            } label: {
                                Image(systemName: "chevron.up")
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)

                            // Down arrow
                            Button {
                                let prevIndex = max(index - 1, 0)
                                frequency = Frequency.allCases[prevIndex]
                            } label: {
                                Image(systemName: "chevron.down")
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                }
                .foregroundStyle(.white)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.gray.opacity(0.2))
                
            }
            .scrollContentBackground(.hidden)  // iOS 16+
            .listSectionSpacing(8)

        }
        .onChange(of: countDrawings){
            UserDefaults.standard.set(countDrawings, forKey: "countDrawings")
        }
        .onChange(of: frequency){
            let strFrequency = frequency.rawValue
            UserDefaults.standard.set(strFrequency, forKey: "frequency")
        }
    }
}

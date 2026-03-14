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
        GeometryReader { geo in
            //ZStack{
                //Color(AppConstants.spaceblack)
                
                Form {
                    Section {
                        HStack {
                            Button(action: { showingGoalSheet.toggle() }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(AppConstants.boldRoundedFont)
                                    .foregroundColor(.white)
                                    .foregroundStyle(.gray)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Spacer()
                            
                            Text("Edit Goal")
                                .font(AppConstants.mediumRoundedFont)
                                .foregroundStyle(.white)
                            
                            Spacer()
                        }
                        .listRowInsets(EdgeInsets())  // Full width
                    }
                    .listRowBackground(Color.gray)
                    .listRowSeparator(.hidden)
                    
                    Section {
                        HStack {
                            Text("Drawings")
                                .font(AppConstants.mediumRoundedFont)
                            Spacer()
                            Text("\(Int(countDrawings))")
                                .font(AppConstants.mediumRoundedFont)
                            VStack(spacing: 0) {
                                // Up arrow (top)
                                Button(action: {
                                    countDrawings = min(10, countDrawings + 1)
                                }) {
                                    Image(systemName: "chevron.up")
                                        .clipShape(Circle())
                                        .font(AppConstants.mediumRoundedFont)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // Down arrow (bottom)
                                Button(action: {
                                    countDrawings = max(1, countDrawings - 1)
                                }) {
                                    Image(systemName: "chevron.down")
                                        .clipShape(Circle())
                                        .font(AppConstants.mediumRoundedFont)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        
                        HStack {
                            Text("Frequency")
                                .font(AppConstants.mediumRoundedFont)
                            
                            Spacer()
                            
                            Text(frequency.rawValue)
                                .font(AppConstants.mediumRoundedFont)
                            
                            VStack(spacing: 0) {
                                // Up arrow
                                Button {
                                    let nextIndex = min(index + 1, Frequency.allCases.count - 1)
                                    frequency = Frequency.allCases[nextIndex]
                                } label: {
                                    Image(systemName: "chevron.up")
                                        .clipShape(Circle())
                                        .font(AppConstants.mediumRoundedFont)
                                }
                                .buttonStyle(.plain)
                                
                                // Down arrow
                                Button {
                                    let prevIndex = max(index - 1, 0)
                                    frequency = Frequency.allCases[prevIndex]
                                } label: {
                                    Image(systemName: "chevron.down")
                                        .clipShape(Circle())
                                        .font(AppConstants.mediumRoundedFont)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                    }
                    .foregroundStyle(.white)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.black.opacity(0.3))
                    
                    
                }
                .scrollContentBackground(.hidden)  // iOS 16+
                .listSectionSpacing(8)
                .padding(.top, -30)
                .interactiveDismissDisabled(AppConstants.isiPad ? true : false)
                .background(Color.gray)
                .cornerRadius(32)
                
            //}
            .onChange(of: countDrawings){
                UserDefaults.standard.set(countDrawings, forKey: "countDrawings")
            }
            .onChange(of: frequency){
                let strFrequency = frequency.rawValue
                UserDefaults.standard.set(strFrequency, forKey: "frequency")
            }
            .frame(width: geo.size.width, height: geo.size.height/2, alignment: .center)
            
            //.border(Color.blue)
            
        }//.border(Color.red)
        
    }
}

#Preview {
    @Previewable @State var showingGoalSheet: Bool = true
    @Previewable  @State var countDrawings: Int = 1
    @Previewable @State var frequency: Frequency = .week
    GoalEditSheet(countDrawings: $countDrawings, frequency: $frequency, showingGoalSheet: $showingGoalSheet)
}

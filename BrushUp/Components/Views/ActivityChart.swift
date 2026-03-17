//
//  test.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 3/10/26.
//
import SwiftUI
import Foundation
typealias GoalStats = (String, Double, String)
typealias CatStats = (String, Array<String>)

struct test : View {
    @State var dayValues = [5, 6, 7, 3, 10, 2, 4]
    @State var monthValues = [10, 9, 8, 7, 6, 4, 3, 2, 1, 11, 12, 13]
    

    @State var goalStats: [GoalStats] = [GoalStats("Days you hit your goal", 6.0, "days")]
    //@State var cattats: [CatStats] = [("Top 3 categories painted", ["animal", "city", "food"])]
    
    var body: some View {
        ActivityChart(dayValues: dayValues, monthValues: monthValues)
        //Spacer()
        DailyActivityStat(goalStats: goalStats) // top3Categories: cattats
    }
}
struct SectionContainer<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 12) {
            content
        }
        .padding(24)
        .frame(height: AppConstants.isiPad ? UIScreen.main.bounds.size.height / 4 : UIScreen.main.bounds.size.height / 4.5)
        //.border(Color.blue)
        
        //.background(AppConstants.lightgray) // Glassy depth effect
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 8)
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 4)
//        .overlay(
//            RoundedRectangle(cornerRadius: 20)
//                .stroke(.white.opacity(0.3), lineWidth: 1)
//        )
        
        .scaleEffect(0.98) // Subtle inward float
        //.animation(.spring(response: 0.5, dampingFraction: 0.8), value: content)
    }
}

#Preview {

    test().background(AppConstants.spaceblack)
}
struct DailyActivityStat: View {
    let numOfContents = 4
//    Total hours spent painting per day
//    Total hours of breaks per day
//    Total number of days you hit your goal
//    Total number of stars you earned
//    let stats = [
//        ("Days you hit your goal", 6, "days"),
//        ("Total Stars you earned", 5, "stars"),
//        ("Total hours spent painting a day", 5.5, "h"),
//        //("Total hours of breaks per day", 2.2, "h")
//    ]
//    let top5Categories = [
//        ("Top 3 categories painted", ["animal", "city", "food"])
//    ]
    
    let goalStats: [GoalStats]
    // let top3Categories: [CatStats]
    
    @State private var dashPhase: CGFloat = 0
    @State private var cometOffset: CGFloat = -40
    @State private var shineOffset: CGFloat = -50
    var body: some View {
        SectionContainer {
            VStack(alignment: .leading, spacing: 20) {
                
                //ZStack {
                    VStack(spacing: 0){

                        ForEach(Array(goalStats.enumerated()), id:\.offset){ index, stat in
                            let (title, value, param) = stat
                            
                            VStack {
                                HStack {
                                    Text("\(title)")
                                        .font(AppConstants.mediumRoundedFont)
                                        .foregroundStyle(AppConstants.perlwhilte.opacity(1))
                                        .frame(height: 10)
                                        .minimumScaleFactor(0.8)
                                        .lineLimit(1)
                                    Spacer()
                                    Text("\(String(format: "%.0f", value)) \(param)")
                                        .font(AppConstants.mediumRoundedFont)
                                        .foregroundStyle(AppConstants.perlwhilte.opacity(1))
                                        .frame(height: 10)
                                        .frame(alignment: .trailing)
                                    
                                }.padding(.horizontal, AppConstants.isiPad ? 16 : 6)
                                
//                                HStack{
//                                    Rectangle()
//                                        .stroke(Color.white.opacity(0.2),
//                                                style: StrokeStyle(lineWidth: 1, dash: [1, 1]))
//                                        .frame(height: 1)
//                                }
                                ShineCometLine()
                            }

                            if index < goalStats.count {
                                Spacer()
                            }
                        }
                        
//                        ForEach(Array(top3Categories.enumerated()), id:\.offset){ index, cat in
//                                let (title, arr) = cat
//                            VStack {
//                                HStack(alignment: .top){
//                                    Text("\(title)")
//                                        .font(AppConstants.mediumRoundedFont)
//                                        .foregroundStyle(AppConstants.perlwhilte.opacity(1))
//                                        .frame(height: 10)
//                                        .minimumScaleFactor(0.8)
//                                        .lineLimit(1)
//                                    Spacer()
//                                    VStack(alignment: .leading) {
//                                        ForEach(Array(arr.enumerated()), id: \.offset){ index, category in
//                                            Text("\(index+1). \(category)")
//                                                .font(AppConstants.mediumRoundedFont)
//                                                .foregroundStyle(AppConstants.perlwhilte.opacity(1))
//                                                .frame(height: 10)
//                                                .frame(alignment: .trailing)
//                                        }
//                                        
//                                    }
//                                    
//                                }
//                                .padding(.horizontal, AppConstants.isiPad ? 16 : 6)
//                                ShineCometLine()
//                                
//                            }
//
//                            if index < top3Categories.count {
//                                Spacer()
//                            }
//                        }
                        
                    }
//                    .frame(height: UIScreen.main.bounds.size.height / 6)
//                    .frame(width: .infinity )
                //}


            }
//            .frame(height: UIScreen.main.bounds.size.height / 4)
//            .frame(width: AppConstants.isiPad ? UIScreen.main.bounds.size.width / 2 : .infinity )

        }
    }
}

struct ActivityChart: View {
    let yLimit = 5
    let golas = 5
    let limit = 7
    let monthLimit = 12
    let dayValues: [Int]
    let monthValues: [Int]
    
    private var computedWeeklyData: [(String, Double)] {
        if isToggled {
            
            if AppConstants.isiPad {
                return Array(zip(
                    AppConstants.months.prefix(monthLimit),
                    monthValues.prefix(monthLimit).map { dayValue in Double(dayValue) / Double(golas * yLimit) }
                ))
            }else {
                if Calendar.current.isJanuaryToMarch() {
                   // Q1
                    return Array(zip(
                        AppConstants.months[0..<7],
                        monthValues[0..<7].map { dayValue in Double(dayValue) / Double(golas * yLimit) }
                    ))
                } else if Calendar.current.isNovemberToDecember() {
                    // Q3
                    return Array(zip(
                        AppConstants.months[5..<12],
                        monthValues[5..<12].map { dayValue in Double(dayValue) / Double(golas * yLimit) }
                    ))
                } else {
                    // Q2
                    return Array(zip(
                        AppConstants.months[3..<10],
                        monthValues[3..<10].map { dayValue in Double(dayValue) / Double(golas * yLimit) }
                    ))
                }
            }
        }
        return Array(zip(
            AppConstants.weekdays.prefix(limit),
            dayValues.prefix(limit).map {dayValue in
                    Double(dayValue) / Double(golas * yLimit)
            }
        ))
        
    }
    
    @State private var isToggled = false
    @State var showingTips = false
    var body: some View {
        SectionContainer {
            VStack(alignment: .leading, spacing: 8) {
                
                HStack {
                    Text(isToggled ? "Monthly Activity" : "Daily Activity")
                        .font(.title2)
                        .foregroundStyle(Color.white.opacity(0.8))
                        .padding(.bottom, 6)
                    
                    Button(action: {
                        isToggled.toggle()
                    }) {
                        Image(systemName: isToggled ? "calendar": "calendar.circle")
                            .foregroundStyle(Color.white.opacity(0.8))
                            .font(.title2)
                            .buttonStyle(.plain)
                            .padding(.bottom, 6)
                    }
                    Spacer()
                    Spacer()
                    makeTipsView().padding(.bottom, 6)
                }
                .transition(.scale.combined(with: .opacity))
                .padding(.leading, 16)
                .padding(.top, -8)
    
                
                    
                ZStack {
                    VStack(spacing: 0){
                        ForEach((1..<yLimit).reversed(), id:\.self){index in
                            HStack{
                                Rectangle()
                                    .stroke(
                                        Color.white.opacity(0.2),
                                        style: StrokeStyle(
                                            lineWidth: 1,
                                            dash: [3, 3]  // [dash length, gap length] - adjust as needed
                                        )
                                    )
                                    .frame(height: 1)
                                Text("\(index * golas)").font(.footnote)
                                    .foregroundStyle(Color.white.opacity(0.2))
                                    .frame(height: 1)
                            }

                            if index < yLimit {
                                Spacer()
                            }
                        }
                    }
                    //.border(Color.black)
                    .frame(height: AppConstants.isiPad ? UIScreen.main.bounds.size.height / 6 : UIScreen.main.bounds.size.height / 8)

                    HStack(alignment: .bottom, spacing: 20) {
                        ForEach(computedWeeklyData, id: \.0) { day, progress in
                            VStack(spacing: 0) {
                                Group {
                                    VerticalProgressBarView(for: progress)
                                        .frame(height: AppConstants.deviceScreenHeightScalingForBarChart)
                                    
                                    Text(day)
                                        .font(.caption.bold())
                                        .foregroundStyle(Color.white.opacity(0.2))
                                        //.frame(height: 120)
                                    
                                }
                                    
                            }
                            //.border(Color.red)
                            

                        }
                    }
                    //.border(Color.brown)
                }



            }
            .animation(.easeInOut(duration: 0.4), value: isToggled)

        }
        .sheet(isPresented: $showingTips){
            TipsView()
                .presentationDragIndicator(.visible)
        }
//        .frame(height: AppConstants.isiPad ? UIScreen.main.bounds.size.height / 8 : UIScreen.main.bounds.size.height / 6)
//        .frame(width: AppConstants.isiPad ? UIScreen.main.bounds.size.width / 2 : .infinity )
//        .border(Color.blue)
    }
    @ViewBuilder
    fileprivate func VerticalProgressBarView(for progress: Double) -> some View {
            GeometryReader { geo in
                ZStack(alignment: .bottom) {
                    // Background track
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.gray.opacity(0))
                        .frame(width: 12, height: geo.size.height)
                    
                    // Progress fill (grows from bottom up)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [AppConstants.dustypink.opacity(0.8), AppConstants.perlwhilte],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(width: 12, height: geo.size.height * max(0, min(1, progress)))  // Clamp 0-1
                        .clipped()
                        //.frame(width: 12, height: geo.size.height * progress)
                }
            }
            //.frame(height: 120)
            .frame(width: 12)
            .frame(height: AppConstants.deviceScreenHeightScalingForBarChart)

    }
    @ViewBuilder
    fileprivate func makeTipsView() -> some View {
        
        Button(action: {
            showingTips = true
        }){
            Image("Tips")
                .resizable()
                .frame(width: 32, height: 32)
                .padding(.horizontal, 0)
        }
    }
    @ViewBuilder
    fileprivate func TipsView() -> some View {
        ZStack {

            VStack(spacing: 0) {
                LinearGradient(
                    colors: [AppConstants.dustypink.opacity(0.5)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .overlay(  // ← Text displays ON the red color
                    Image("Tips")
                        .resizable()
                        .frame(width: 90, height: 90)
                        .padding(50)
                )
                VStack(alignment: .leading, spacing: 16) {
                    TipView(number: 1,
                            title: "Get Started Quickly",
                            text: "Take a moment to explore the main features of the app. Most tools are designed to be simple, so try tapping around and see what each section does. The faster you get familiar with the layout, the easier it becomes to get things done.")

                    TipView(number: 2,
                            title: "Customize Your Experience",
                            text: "Check the settings or preferences area to personalize the app. Many apps allow you to adjust notifications, themes, or default behaviors so the experience matches how you like to work.")

                    TipView(number: 3,
                            title: "Use Shortcuts and Time‑Savers",
                            text: "Look for built‑in shortcuts, quick actions, or automation features. These tools can help you complete tasks faster and reduce repetitive steps once you know where to find them.")
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppConstants.spaceblack.opacity(0.8))
                .font(AppConstants.mediumRoundedFont)
                .foregroundStyle(AppConstants.perlwhilte)
//                AppConstants.spaceblack.opacity(0.8).overlay{
//                    VStack(alignment: .leading, spacing : 4){
//                        Text("Tip 1: Get Started Quickly")
//
//                        Text("Take a moment to explore the main features of the app. Most tools are designed to be simple, so try tapping around and see what each section does. The faster you get familiar with the layout, the easier it becomes to get things done.")
//                    }
//                }
//                .font(AppConstants.mediumRoundedFont)
//                .foregroundStyle(AppConstants.perlwhilte)
//                
//                AppConstants.spaceblack.opacity(0.8).overlay{
//                    VStack(alignment: .leading, spacing : 4){
//                        Text("Tip 2: Customize Your Experience")
//
//                        Text("Check the settings or preferences area to personalize the app. Many apps allow you to adjust notifications, themes, or default behaviors so the experience matches how you like to work.")
//                    }
//                }
//                .font(AppConstants.mediumRoundedFont)
//                .foregroundStyle(AppConstants.perlwhilte)
//                
//                AppConstants.spaceblack.opacity(0.8).overlay{
//                    VStack(alignment: .leading, spacing : 4){
//                        Text("Tip 3: Use Shortcuts and Time‑Savers")
//                        
//                        Text("Look for built‑in shortcuts, quick actions, or automation features. These tools can help you complete tasks faster and reduce repetitive steps once you know where to find them.")
//                    }
//                }
//                .font(AppConstants.mediumRoundedFont)
//                .foregroundStyle(AppConstants.perlwhilte)
                
            }
        }
        
        .ignoresSafeArea()
    }
    struct TipView: View {
        let number: Int
        let title: String
        let text: String

        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text("Tip \(number): \(title)")
                Text(text).lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
}


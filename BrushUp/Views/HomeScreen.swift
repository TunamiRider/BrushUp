//
//  HomeScreen.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 2/24/26.
//
import SwiftUI

struct HomeScreen: View {
    @Environment(AppServices.self) var services
    
    @State private var historyViewModel: HistoryViewModel?
    @State var showingGoalSheet = false
    //@State private var buttonPosition: CGPoint = .zero
    @State private var progressCounter = 0 // actual painted
    @State private var countDrawings = 1 // goal to paint
    @State private var frequency: Frequency = .day
    
    @Binding var goMainView: Bool
    @Binding var isResume: Bool
    @State private var animateDismiss = false
    //@State var starPositions: [CGSize] = []
    @State var showingTips = false
    
    @State var stats: [GoalStats] = []
    @State var todaysStars: Int = 0
    // @State var top3Categories: [CatStats] = []
//    let top5Categories = [
//        ("Top 3 categories painted", ["animal", "city", "food"])
//    ]
//    let stats = [
//        ("Days you hit your goal", 6, "days"),
//        ("Total Stars you earned", 5, "stars"),
//        ("Total hours spent painting a day", 5.5, "h"),
//        //("Total hours of breaks per day", 2.2, "h")
//    ]
    
    private var reachedGoals: Int {
        return max(0, min(countDrawings, progressCounter))

    }
    private var isGoMainView: Bool {
        !goMainView
    }

    private var leftToReach: Int {
        return max(0, progressCounter>AppConstants.maximumDrawingGoal ? (AppConstants.maximumDrawingGoal-countDrawings) : progressCounter - countDrawings)
    }
    
    private func updateProgress() {
        let basecountDrawings = UserDefaults.standard.integer(forKey: SwiftDataKey.countDrawings)
        let strFrequency = UserDefaults.standard.string(forKey: SwiftDataKey.frequency)
        let rawFrequency = strFrequency.flatMap { Frequency(rawValue: $0) } ?? .day
        let count = historyViewModel?.countActivity(frequency: rawFrequency)
        
        countDrawings = basecountDrawings == 0 ? 1 : basecountDrawings
        UserDefaults.standard.set(countDrawings, forKey: SwiftDataKey.countDrawings)
        frequency = rawFrequency
        UserDefaults.standard.set(frequency.rawValue, forKey: SwiftDataKey.frequency)
        progressCounter = count ?? 0
    }
    private func updateStats() {
        stats.removeAll()
        let basecountDrawings = UserDefaults.standard.integer(forKey: SwiftDataKey.countDrawings)
        let count = historyViewModel?.countActivity(frequency: .day) ?? 0
        let yearCount = historyViewModel?.countActivity(frequency: .year) ?? 0
        let numOfStars = count - basecountDrawings
        //print("numOfStars: \(numOfStars) : count: \(count) : basecountDrawings: \(basecountDrawings)")
        let (hitDate, hitCount) = (UserDefaults.standard.string(forKey: SwiftDataKey.hitTheGoals) ?? "").dateCountParts()
        let (starDate, starCount) = (UserDefaults.standard.string(forKey: SwiftDataKey.hitTheStars) ?? "").dateCountParts()
        
        
        let isHitTheGoal: Bool = count >= basecountDrawings
        let isHitTheStar: Bool = numOfStars >= 1
        
        var strNewHitTheGoals:String
        var strNewHitTheStars:String
        //validate date format
        if !hitDate.isValidMMddyyyy {

            strNewHitTheGoals = Date.yesterdayMMDDYYYYString + ":0"
            UserDefaults.standard.set(strNewHitTheGoals, forKey: SwiftDataKey.hitTheGoals)

        }
        if !starDate.isValidMMddyyyy {
            
            strNewHitTheStars = Date.mmddyyyyString + ":0"
            UserDefaults.standard.set(strNewHitTheStars, forKey: SwiftDataKey.hitTheStars)

        }
        
        if !hitDate.isValidMMddyyyy || !starDate.isValidMMddyyyy {
            stats.append(GoalStats("Days you hit your goal", Double(0), "days"))
            stats.append(GoalStats("Total Stars you earned", Double(0), "stars"))
            stats.append(GoalStats("Paintings you've drawn", Double(0), "paintings"))
            return
        }
        let todayMidnight = Calendar.current.startOfDay(for: Date())

        //update hit the goal first time in a day
        if isHitTheGoal && hitDate.mmddyyyyDate! < todayMidnight {
            
            let strNewHitTheGoals = Date.mmddyyyyString + ":" + String(Int(hitCount)! + 1)
            UserDefaults.standard.set(strNewHitTheGoals, forKey: SwiftDataKey.hitTheGoals)
        }
  
        //update hit the stars first time in a day
        if  isHitTheStar && starDate.mmddyyyyDate! < todayMidnight {
            todaysStars = numOfStars
            let strNewHitTheStars = Date.mmddyyyyString + ":" + String(Int(starCount)! + numOfStars)
            UserDefaults.standard.set(strNewHitTheStars, forKey: SwiftDataKey.hitTheStars)
        }
        
        // culculate hit the satrs again simultaneously
        if starDate.mmddyyyyDate! == todayMidnight {
            //let diffStars = numOfStars > todaysStars ? numOfStars - todaysStars : 0
            var curTodaysStars = UserDefaults.standard.integer(forKey: SwiftDataKey.curTodaysStars)
            //print("currrr: \(curTodaysStars)")
            todaysStars = numOfStars >= curTodaysStars ? numOfStars : todaysStars
            
            curTodaysStars = numOfStars >= curTodaysStars ? numOfStars : curTodaysStars
            
            UserDefaults.standard.set(curTodaysStars, forKey: SwiftDataKey.curTodaysStars)
            //print(": todaysStars \(todaysStars) : numOfStars \(numOfStars) : curTodaysStars \(curTodaysStars)")
            //print("starCount : \(starCount)")
        }
        
        let (_, hitCount2) = (UserDefaults.standard.string(forKey: SwiftDataKey.hitTheGoals) ?? "").dateCountParts()
        let (_, starCount2) = (UserDefaults.standard.string(forKey: SwiftDataKey.hitTheStars) ?? "").dateCountParts()
        
        
        stats.append(GoalStats("Days you hit your goal", Double(hitCount2) ?? 0.0, "days"))
        let totalStars = Int(Double(starCount2) ?? 0) + todaysStars
        //print("starCount2: \(starCount2) : todaysStars : \(todaysStars)")
        stats.append(GoalStats("Total Stars you earned", Double(totalStars), "stars"))
        stats.append(GoalStats("Paintings you've drawn", Double(yearCount), "paintings"))
    }

    
    var body: some View {
        ZStack {
            VStack() {
                VStack(alignment: .leading, spacing: 4){
                    
                    Text("Let's Brush Up!")
                        .font(AppConstants.boldRoundedFont)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                    HStack(spacing: 8) {
                        Image("Target")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        
                        Text("Progress: \(progressCounter)/\(countDrawings) drawings")
                            .font(AppConstants.mediumRoundedFont)
                            .foregroundStyle(.white)
                            .minimumScaleFactor(0.8)
                            .lineLimit(1)
                        
                        if !AppConstants.isiPad {
                            Spacer()
                        }


                        Button("Edit Goal") {
                            showingGoalSheet.toggle()
                        }
                        .font(AppConstants.mediumRoundedFont)
                        .foregroundColor(AppConstants.dustypink)
                        //.padding(.horizontal, 32)
                        .padding(.vertical, 6)
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
                        .cornerRadius(8)
                        
                        
                    }.frame(maxWidth: .infinity)
                    

                    makeProgressBar().frame(maxWidth: .infinity)
                    

                    
                    //makeTipsView().frame(maxWidth: .infinity)

                    ActivityChart(dayValues: historyViewModel?.dayCount ?? [], monthValues: historyViewModel?.monthsCount ?? [])//.frame(maxWidth: .infinity)
                    
                    DailyActivityStat(goalStats: stats) // top3Categories: top3Categories
                        //.frame(maxWidth: .infinity)

                }//.frame(maxWidth: .infinity)
                
                .disabled(showingGoalSheet)
//                .sheet(isPresented: $showingGoalSheet, onDismiss: {
//                    updateProgress()
//                }) {
//                    
//                    GoalEditSheet(countDrawings: $countDrawings, frequency: $frequency, showingGoalSheet: $showingGoalSheet)
//                        .presentationDetents([.medium])  // Half screen height
//                        .presentationDragIndicator(.visible)
//                        .presentationCornerRadius(20)
//                        .transition(.move(edge: .top).combined(with: .opacity))
//                }
                
                .overlay(
                    Group {
                        if showingGoalSheet {
                            GoalEditSheet(countDrawings: $countDrawings, frequency: $frequency, showingGoalSheet: $showingGoalSheet)
                                //.frame(height: 200)
                                .offset(y: 80)
                                .cornerRadius(8)
                                .offset(x: 0, y: 0)
                            //.opacity(showingGoalSheet ? 1 : 0)
                                .offset(x: showingGoalSheet ? 0 : 200)
                            
                                .animation(.easeInOut(duration: 0.8), value: showingGoalSheet)
                        }
                    }
                )
                //Spacer()
                
                
                
                makeMascot2()
                    .frame(height: max(50, UIScreen.main.bounds.height / 6))
                    .frame(width: UIScreen.main.bounds.size.width / 3)

                Spacer()
                createStartButton().disabled(showingGoalSheet).padding(.bottom, 10)
                    //.frame(width: .infinity)
                Spacer()
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .task{
                do {
                    historyViewModel = HistoryViewModel(firebaseService: services.firebaseService)
                    await historyViewModel?.loadHistory()
                }
//                catch {
//                    print("Failed to load data: \(error)")
//                }
                updateProgress()
                updateStats()
                
            }
            .onChange(of: showingGoalSheet){_, newValue in
                    
                if !newValue {
                    updateStats()
                }
            }
        }
    }
    
    @ViewBuilder
    fileprivate func createStartButton() -> some View {
        Button(action: {
            goMainView = true
        }) {
            Text(isResume ? "Resume" : "Start Drawing")
                .font(AppConstants.boldRoundedFont)
                .padding(.vertical, 18)
                .padding(.horizontal, 60)
            
                .foregroundColor(.white)
                .background(AppConstants.dustypink)
                .cornerRadius(100)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(.white, lineWidth: 1)
                        .overlay(
                            // Thinner lines for top-right & bottom-left corners
                            RoundedRectangle(cornerRadius: 40)
                                .stroke(.white, lineWidth: 1)
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 40)
                                        .offset(x: 8, y: -8) // Top-right position
                                )
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 40)
                                        .offset(x: -8, y: 8) // Bottom-left position
                                )
                        )
                        
                )
                //.border(Color.cyan)
//                .transition(.opacity.combined(with: .asymmetric(
//                    insertion: .move(edge: .leading),
//                    removal: .move(edge: .trailing))))
//            .animation(.easeInOut(duration: 0), value: isResume)
        }
    }
    @ViewBuilder
    fileprivate func makeProgressBar() -> some View {
        let safeReached = max(0, min(10, reachedGoals))
        let safeLeft    = max(0, min(10, leftToReach))
        let safeRest    = max(0, 10 - safeReached - safeLeft)
        
        // 1=reached, 2=leftToReach, 3=rest empty
        Grid{
            GridRow {
                ForEach(0..<safeReached, id: \.self) { index in
                    makeRectangle(1)
                }
                ForEach(0..<safeLeft, id: \.self){ index in
                    makeRectangle(2)
                }
                ForEach(0..<safeRest, id: \.self){ index in
                    makeRectangle(3)
                }
                if progressCounter > AppConstants.maximumDrawingGoal {
                    Image(systemName: "plus")
                        .font(.footnote).foregroundStyle(Color.yellow)
                }
            }
        }
    }
    @ViewBuilder
    fileprivate func makeRectangle(_ isProgress: Int) -> some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [AppConstants.spaceblack],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 20, height: 20)
            .cornerRadius(3)
            .overlay(  // Icon INSIDE rectangle
                makeIcon(isProgress: isProgress)
            )
            .rotation3DEffect(.degrees(20), axis: (x: 0, y: 0, z: 0))
            .shadow(color: .black.opacity(0.3), radius: 16, x: 8, y: 12)
    }
    @ViewBuilder
    fileprivate func makeIcon(isProgress: Int) -> some View {
        if(isProgress==1){
            Image(systemName: "checkmark")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(.white)
                .frame(width: 15, height: 15)
        }else if isProgress==2 {
            Image(systemName: "star.fill")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.yellow.opacity(0.8))
        }
    }

    @ViewBuilder
    fileprivate func makeMascot() -> some View {
        GeometryReader { geometry in
            Image("Mascot")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .overlay {
                    ForEach(0..<leftToReach, id: \.self) { index in
                        let angle = Double(index) * 36 * .pi / 180  // Evenly spaced angles
                        let radius: CGFloat = 90
                        let offset = CGSize(
                            width: cos(angle) * radius,
                            height: sin(angle) * radius
                        )
                        
                        Star(points: 5)
                            .foregroundStyle(.yellow)
                            .frame(width: 16, height: 16)
                            .opacity(0.8)
                            .offset(offset)
                    }
                }
        }
        .frame(width: 200, height: 200)  // Match image frame
    }
    
//    @ViewBuilder
//    fileprivate func makeMascot2() -> some View {
//        GeometryReader { geometry in
//            Image("Mascot")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 200, height: 200)
//                .overlay {
//                    ForEach(0..<leftToReach, id: \.self) { index in
//                        let angle = Double(index) * 36 * .pi / 180
//                        let radius: CGFloat = animateDismiss ? 110 : 90
//                        let offset = CGSize(
//                            width: cos(angle) * radius,
//                            height: sin(angle) * radius
//                        )
//                        
//                        Star(points: 5)
//                            .foregroundStyle(.yellow)
//                            .frame(width: 16, height: 16)
//                            .opacity(animateDismiss ? 0 : 0.8)
//                            .offset(offset)
//                            .rotationEffect(.degrees(animateDismiss ? 720 : 0))  // Stars spin
//                    }
//                }
//        }
//        .frame(width: 200, height: 200)
//        // Removed: .rotationEffect(.degrees(animateDismiss ? 360 : 0))
//        .onChange(of: showingGoalSheet) { oldValue, newValue in
//            if !newValue {
//                withAnimation(.easeInOut(duration: 1.2)) {
//                    animateDismiss = true
//                }
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
//                    animateDismiss = false
//                }
//            }
//        }
//    }
    
    @ViewBuilder
    fileprivate func makeMascot2() -> some View {
        let mascotImage = Image("Mascot")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 200, height: 200)
        
        let starOverlay = Group {
            ForEachStars()
        }
        
        mascotImage
            .overlay(starOverlay)
            .frame(width: 200, height: 200)
            .onChange(of: showingGoalSheet) { oldValue, newValue in
                if !newValue {
                    withAnimation(.easeInOut(duration: 1.2)) {
                        animateDismiss = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        animateDismiss = false
                    }
                }
            }
            .onChange(of: isGoMainView) { oldValue, newValue in
                if !newValue {
                    withAnimation(.easeInOut(duration: 10)) {
                        animateDismiss = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                        animateDismiss = false
                    }
                }
            }

    }

    @ViewBuilder
    private func ForEachStars() -> some View {
        ForEach(0..<leftToReach, id: \.self) { index in
            StarView(index: index)
        }
    }

    @ViewBuilder
    private func StarView(index: Int) -> some View {
        let angle = Double(index) * 36 * .pi / 180
        let radius: CGFloat = animateDismiss ? 110 : 90
        let offset = CGSize(
            width: cos(angle) * radius,
            height: sin(angle) * radius
        )
        
        Star(points: 5)
            .foregroundStyle(.yellow)
            .frame(width: 16, height: 16)
            .opacity(animateDismiss ? 0 : 0.8)
            .offset(offset)
            .rotationEffect(.degrees(animateDismiss ? 720 : 0))
    }
    struct Star: Shape {
        let points: Int
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let radius: CGFloat = min(rect.width, rect.height) * 0.4
            
            for i in 0..<points * 2 {
                let angle = CGFloat.pi * 2 * Double(i) / Double(points * 2)
                let radiusOffset = (i % 2 == 0) ? radius : radius * 0.5
                let point = CGPoint(
                    x: center.x + cos(angle) * radiusOffset,
                    y: center.y + sin(angle) * radiusOffset
                )
                
                if i == 0 {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }
            path.closeSubpath()
            return path
        }
    }
    
}

//#Preview {
//     
//    @Previewable @State var showingGoalSheet = true
//    @Previewable @State var countDrawings = 0
//    @Previewable @State var frequency = Frequency.day
//    @Previewable @State  var goMainView = false
//    @Previewable @State var isResume = false
//    let appServices = AppServices()
////    let unsplashPhotoManager = UnsplashPhotoManager(
////        unsplashService: appServices.unsplashService,
////        firebaseService: appServices.firebaseService
////    )
//    
//    HomeScreen(goMainView: $goMainView, isResume: $isResume)
//        .environment(appServices).background(AppConstants.spaceblack)
//}

